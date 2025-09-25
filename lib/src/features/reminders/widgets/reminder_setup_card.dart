import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/reminder_type.dart';
import '../models/medication.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../../../services/ai_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReminderSetupCard extends StatefulWidget {
  final VoidCallback? onComplete;

  const ReminderSetupCard({
    super.key,
    this.onComplete,
  });

  @override
  State<ReminderSetupCard> createState() => _ReminderSetupCardState();
}

class _ReminderSetupCardState extends State<ReminderSetupCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReminderService _reminderService = ReminderService();
  final AIService _aiService = AIService();
  final ImagePicker _imagePicker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  int _timesPerDay = 1;
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
  final ReminderType _selectedType = ReminderType.medication;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _pickImageAndAnalyze(ImageSource source) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) {
        setState(() => _isLoading = false);
        return;
      }

      final extractedData = await _aiService.extractPrescriptionInfo(image);

      if (extractedData.isEmpty) {
        setState(() {
          _error = 'Could not read prescription. Please try again or enter manually.';
          _isLoading = false;
        });
        return;
      }

      _nameController.text = extractedData['medicationName'] ?? '';
      _dosageController.text = extractedData['dosage'] ?? '';
      _instructionsController.text = extractedData['instructions'] ?? '';
      _timesPerDay = extractedData['timesPerDay'] ?? 1;

      final scheduledTimes = extractedData['scheduledTimes'] as List<dynamic>?;
      if (scheduledTimes != null && scheduledTimes.isNotEmpty) {
        _selectedTimes = scheduledTimes.map((time) {
          final parts = time.toString().split(':');
          return TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }).toList();
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prescription analyzed! Please review and confirm.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Error analyzing image: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter a name');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      if (_selectedType == ReminderType.medication) {
        final medication = Medication(
          id: '',
          userId: user.uid,
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          timesPerDay: _timesPerDay,
          scheduledTimes: _selectedTimes
              .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
              .toList(),
          instructions: _instructionsController.text.trim().isEmpty
              ? null
              : _instructionsController.text.trim(),
          createdAt: DateTime.now(),
        );

        final medicationId = await _reminderService.createMedication(medication);

        for (final time in _selectedTimes) {
          final now = DateTime.now();
          var scheduledTime = DateTime(
            now.year,
            now.month,
            now.day,
            time.hour,
            time.minute,
          );

          if (scheduledTime.isBefore(now)) {
            scheduledTime = scheduledTime.add(const Duration(days: 1));
          }

          final reminder = Reminder(
            id: '',
            userId: user.uid,
            type: ReminderType.medication,
            title: '💊 ${medication.name}',
            description: '${medication.dosage}${medication.instructions != null ? '\n${medication.instructions}' : ''}',
            scheduledTime: scheduledTime,
            repeatDaily: true,
            medicationId: medicationId,
            createdAt: DateTime.now(),
          );

          await _reminderService.createReminder(reminder);
        }
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Reminder created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onComplete?.call();
      }
    } catch (e) {
      setState(() {
        _error = 'Error saving reminder: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green.shade700,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.green.shade700,
              labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.camera_alt, size: 32), text: 'Photo'),
                Tab(icon: Icon(Icons.edit, size: 32), text: 'Manual'),
                Tab(icon: Icon(Icons.event, size: 32), text: 'Appointment'),
              ],
            ),
          ),
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 500,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPhotoMode(),
                _buildManualMode(),
                _buildAppointmentMode(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoMode() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Take a photo of your prescription',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImageAndAnalyze(ImageSource.camera),
                  icon: const Icon(Icons.camera, size: 32),
                  label: const Text('Camera', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _pickImageAndAnalyze(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library, size: 32),
                  label: const Text('Gallery', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          if (_isLoading)
            const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Analyzing prescription...',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            )
          else if (_nameController.text.isNotEmpty)
            Expanded(child: _buildReviewForm()),
        ],
      ),
    );
  }

  Widget _buildManualMode() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _buildReviewForm(),
    );
  }

  Widget _buildReviewForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nameController,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(
            labelText: 'Medication Name',
            labelStyle: TextStyle(fontSize: 18),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dosageController,
          style: const TextStyle(fontSize: 20),
          decoration: const InputDecoration(
            labelText: 'Dosage (e.g., 10mg, 2 tablets)',
            labelStyle: TextStyle(fontSize: 18),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _instructionsController,
          style: const TextStyle(fontSize: 20),
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Instructions (optional)',
            labelStyle: TextStyle(fontSize: 18),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveReminder,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
              backgroundColor: Colors.green.shade600,
              foregroundColor: Colors.white,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save Reminder', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentMode() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.blue.shade600),
            const SizedBox(height: 16),
            const Text(
              'Appointment Mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming soon! Set reminders for doctor visits and appointments.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}