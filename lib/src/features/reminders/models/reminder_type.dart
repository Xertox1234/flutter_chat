enum ReminderType {
  medication,
  appointment,
  custom,
}

extension ReminderTypeExtension on ReminderType {
  String get displayName {
    switch (this) {
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.appointment:
        return 'Appointment';
      case ReminderType.custom:
        return 'Custom Reminder';
    }
  }

  String get icon {
    switch (this) {
      case ReminderType.medication:
        return '💊';
      case ReminderType.appointment:
        return '📅';
      case ReminderType.custom:
        return '⏰';
    }
  }
}