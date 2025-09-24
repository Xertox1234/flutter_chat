import 'package:cloud_firestore/cloud_firestore.dart';
import 'reminder_type.dart';

class Reminder {
  final String id;
  final String userId;
  final ReminderType type;
  final String title;
  final String? description;
  final DateTime scheduledTime;
  final bool repeatDaily;
  final List<int>? repeatDays;
  final String? medicationId;
  final bool isActive;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.description,
    required this.scheduledTime,
    this.repeatDaily = false,
    this.repeatDays,
    this.medicationId,
    this.isActive = true,
    required this.createdAt,
  });

  factory Reminder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Reminder(
      id: doc.id,
      userId: data['userId'] as String,
      type: ReminderType.values.byName(data['type'] as String),
      title: data['title'] as String,
      description: data['description'] as String?,
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      repeatDaily: data['repeatDaily'] as bool? ?? false,
      repeatDays: data['repeatDays'] != null
          ? List<int>.from(data['repeatDays'] as List)
          : null,
      medicationId: data['medicationId'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'description': description,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'repeatDaily': repeatDaily,
      'repeatDays': repeatDays,
      'medicationId': medicationId,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Reminder copyWith({
    String? id,
    String? userId,
    ReminderType? type,
    String? title,
    String? description,
    DateTime? scheduledTime,
    bool? repeatDaily,
    List<int>? repeatDays,
    String? medicationId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      repeatDays: repeatDays ?? this.repeatDays,
      medicationId: medicationId ?? this.medicationId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}