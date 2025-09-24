import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reminder.dart';
import '../models/medication.dart';
import 'notification_service.dart';

class ReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  String? get _userId => _auth.currentUser?.uid;

  Future<String> createMedication(Medication medication) async {
    if (_userId == null) throw Exception('User not logged in');

    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .add(medication.toFirestore());

    print('[ReminderService] Created medication: ${medication.name} (${docRef.id})');
    return docRef.id;
  }

  Future<void> updateMedication(Medication medication) async {
    if (_userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medication.id)
        .update(medication.toFirestore());

    print('[ReminderService] Updated medication: ${medication.name}');
  }

  Future<void> deleteMedication(String medicationId) async {
    if (_userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .doc(medicationId)
        .delete();

    final reminders = await getRemindersForMedication(medicationId);
    for (final reminder in reminders) {
      await deleteReminder(reminder.id);
    }

    print('[ReminderService] Deleted medication and ${reminders.length} reminders');
  }

  Stream<List<Medication>> getMedications() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('medications')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medication.fromFirestore(doc))
            .toList());
  }

  Future<String> createReminder(Reminder reminder) async {
    if (_userId == null) throw Exception('User not logged in');

    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .add(reminder.toFirestore());

    await _notificationService.scheduleReminder(reminder.copyWith(id: docRef.id));

    print('[ReminderService] Created reminder: ${reminder.title} (${docRef.id})');
    return docRef.id;
  }

  Future<void> updateReminder(Reminder reminder) async {
    if (_userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .doc(reminder.id)
        .update(reminder.toFirestore());

    await _notificationService.cancelReminder(reminder.id);
    await _notificationService.scheduleReminder(reminder);

    print('[ReminderService] Updated reminder: ${reminder.title}');
  }

  Future<void> deleteReminder(String reminderId) async {
    if (_userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .doc(reminderId)
        .delete();

    await _notificationService.cancelReminder(reminderId);

    print('[ReminderService] Deleted reminder: $reminderId');
  }

  Stream<List<Reminder>> getReminders() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .where('isActive', isEqualTo: true)
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Reminder.fromFirestore(doc))
            .toList());
  }

  Future<List<Reminder>> getRemindersForMedication(String medicationId) async {
    if (_userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .where('medicationId', isEqualTo: medicationId)
        .get();

    return snapshot.docs.map((doc) => Reminder.fromFirestore(doc)).toList();
  }

  Future<void> toggleReminderActive(String reminderId, bool isActive) async {
    if (_userId == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('reminders')
        .doc(reminderId)
        .update({'isActive': isActive});

    if (isActive) {
      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('reminders')
          .doc(reminderId)
          .get();
      final reminder = Reminder.fromFirestore(doc);
      await _notificationService.scheduleReminder(reminder);
    } else {
      await _notificationService.cancelReminder(reminderId);
    }

    print('[ReminderService] Toggled reminder $reminderId to $isActive');
  }
}