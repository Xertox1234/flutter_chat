import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../models/medication.dart';
import '../services/reminder_service.dart';
import '../widgets/reminder_setup_card.dart';

class RemindersScreen extends StatefulWidget {
  final bool showAppointments;
  const RemindersScreen({super.key, this.showAppointments = false});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _reminderService = ReminderService();
  late bool _showMedications;

  @override
  void initState() {
    super.initState();
    _showMedications = !widget.showAppointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showMedications ? 'My Medications' : 'My Appointments', style: const TextStyle(fontSize: 24)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm, size: 32),
            onPressed: _showAddReminderDialog,
            tooltip: 'Add Reminder',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _showMedications = true),
                    icon: const Icon(Icons.medical_services, size: 28),
                    label: const Text('Medications', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _showMedications ? Colors.green.shade600 : Colors.grey.shade300,
                      foregroundColor: _showMedications ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => setState(() => _showMedications = false),
                    icon: const Icon(Icons.event, size: 28),
                    label: const Text('Appointments', style: TextStyle(fontSize: 20)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: !_showMedications ? Colors.blue.shade600 : Colors.grey.shade300,
                      foregroundColor: !_showMedications ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showMedications ? _buildMedicationsList() : _buildAppointmentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        icon: const Icon(Icons.add, size: 32),
        label: const Text('Add Reminder', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildMedicationsList() {
    return StreamBuilder<List<Medication>>(
      stream: _reminderService.getMedications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading medications',
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }

        final medications = snapshot.data ?? [];

        if (medications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No medications yet',
                  style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first medication',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: medications.length,
          itemBuilder: (context, index) {
            final medication = medications[index];
            return _buildMedicationCard(medication);
          },
        );
      },
    );
  }

  Widget _buildMedicationCard(Medication medication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.medication, size: 32, color: Colors.green),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medication.dosage,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: medication.isActive,
                  onChanged: (value) async {
                    final updatedMedication = medication.copyWith(isActive: value);
                    await _reminderService.updateMedication(updatedMedication);
                  },
                  activeTrackColor: Colors.green,
                ),
              ],
            ),
            if (medication.instructions != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        medication.instructions!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Times: ${medication.scheduledTimes.join(", ")}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 32, color: Colors.red),
                  onPressed: () => _confirmDelete(medication),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return StreamBuilder<List<Reminder>>(
      stream: _reminderService.getReminders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading appointments',
                  style: TextStyle(fontSize: 20, color: Colors.grey.shade700),
                ),
              ],
            ),
          );
        }

        final reminders = snapshot.data ?? [];

        if (reminders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_outlined, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No appointments yet',
                  style: TextStyle(fontSize: 24, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first appointment',
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return _buildAppointmentCard(reminder);
          },
        );
      },
    );
  }

  Widget _buildAppointmentCard(Reminder reminder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event, size: 32, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reminder.scheduledTime.day}/${reminder.scheduledTime.month}/${reminder.scheduledTime.year}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (value) async {
                    final updatedReminder = reminder.copyWith(isActive: value);
                    await _reminderService.updateReminder(updatedReminder);
                  },
                  activeTrackColor: Colors.blue,
                ),
              ],
            ),
            if (reminder.description != null && reminder.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notes, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        reminder.description!,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Time: ${reminder.scheduledTime.hour.toString().padLeft(2, '0')}:${reminder.scheduledTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 32, color: Colors.red),
                  onPressed: () => _confirmDeleteReminder(reminder),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddReminderDialog() async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: ReminderSetupCard(
            onComplete: () {
              Navigator.of(context).pop();
              setState(() {});
            },
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Medication medication) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medication?', style: TextStyle(fontSize: 24)),
        content: Text(
          'Are you sure you want to delete ${medication.name}? This will also delete all related reminders.',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _reminderService.deleteMedication(medication.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medication.name} deleted', style: const TextStyle(fontSize: 18)),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteReminder(Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment?', style: TextStyle(fontSize: 24)),
        content: Text(
          'Are you sure you want to delete "${reminder.title}"?',
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _reminderService.deleteReminder(reminder.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${reminder.title}" deleted', style: const TextStyle(fontSize: 18)),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }
}