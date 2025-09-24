import 'package:cloud_firestore/cloud_firestore.dart';

class Medication {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final int timesPerDay;
  final List<String> scheduledTimes;
  final String? instructions;
  final DateTime createdAt;
  final bool isActive;

  const Medication({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.timesPerDay,
    required this.scheduledTimes,
    this.instructions,
    required this.createdAt,
    this.isActive = true,
  });

  factory Medication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Medication(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      dosage: data['dosage'] as String,
      timesPerDay: data['timesPerDay'] as int,
      scheduledTimes: List<String>.from(data['scheduledTimes'] as List),
      instructions: data['instructions'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'timesPerDay': timesPerDay,
      'scheduledTimes': scheduledTimes,
      'instructions': instructions,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  Medication copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    int? timesPerDay,
    List<String>? scheduledTimes,
    String? instructions,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Medication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      timesPerDay: timesPerDay ?? this.timesPerDay,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}