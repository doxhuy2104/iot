import 'package:app/core/components/inputs/text_input.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';

class CreateSchedulePage extends StatefulWidget {
  final int zoneId;
  final Map<String, dynamic>? schedule; // If editing

  const CreateSchedulePage({super.key, required this.zoneId, this.schedule});

  @override
  State<CreateSchedulePage> createState() => _CreateSchedulePageState();
}

class _CreateSchedulePageState extends State<CreateSchedulePage> {
  late TimeOfDay _selectedTime;
  bool _isRecurring = true;
  final List<String> _daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  final List<bool> _selectedDays = List.filled(7, false);
  final _durationController = TextEditingController(text: '30');
  final _volumeController = TextEditingController(text: '5');

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      // Parse existing schedule
      // Mock parsing logic
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _selectedDays[1] = true; // Mon
      _selectedDays[3] = true; // Wed
      _selectedDays[5] = true; // Fri
    } else {
      _selectedTime = TimeOfDay.now();
      _selectedDays.fillRange(0, 7, true); // Default all days
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.schedule == null ? 'Add Schedule' : 'Edit Schedule'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimePicker(),
            const SizedBox(height: 24),
            const SizedBox(height: 24),
            const Text(
              'Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            TextInput(
              controller: _durationController,
              placeholder: 'Duration (s)',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            const Text(
              'Volume',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            TextInput(
              controller: _volumeController,
              placeholder: 'Volume (L)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 24),
            _buildFrequencySelector(),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Save Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start Time',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              use24hFormat: true,
              initialDateTime: DateTime(
                2024,
                1,
                1,
                _selectedTime.hour,
                _selectedTime.minute,
              ),
              onDateTimeChanged: (DateTime newTime) {
                setState(() {
                  _selectedTime = TimeOfDay.fromDateTime(newTime);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Repeat',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              Switch(
                value: _isRecurring,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() {
                    _isRecurring = val;
                  });
                },
              ),
            ],
          ),
          if (_isRecurring) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                final isSelected = _selectedDays[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDays[index] = !isSelected;
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      _daysOfWeek[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveSchedule() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final startTime = DateFormat('HH:mm').format(dt);

    List<String> repeatDays = [];
    if (_isRecurring) {
      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      for (int i = 0; i < 7; i++) {
        if (_selectedDays[i]) {
          repeatDays.add(days[i]);
        }
      }
    }

    final duration = int.tryParse(_durationController.text) ?? 30;
    final volume = double.tryParse(_volumeController.text) ?? 5.0;

    final result = await Modular.get<ZoneRepository>().createSchedule(
      zoneId: widget.zoneId,
      startTime: startTime,
      duration: duration,
      volume: volume,
      repeatDays: repeatDays,
      active: true,
    );

    if (mounted) Navigator.pop(context); // Close dialog

    result.fold(
      (l) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l.reason)));
        }
      },
      (r) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule created successfully')),
          );
          Navigator.pop(context, true);
        }
      },
    );
  }
}
