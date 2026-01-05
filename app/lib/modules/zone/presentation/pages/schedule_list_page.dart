import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/helpers/navigation_helper.dart';
import 'package:app/modules/zone/general/zone_module_routes.dart';
import 'package:flutter/material.dart';

class ScheduleListPage extends StatefulWidget {
  final int zoneId;
  const ScheduleListPage({super.key, required this.zoneId});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  // Mock data
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': 1,
      'time': '07:00 AM',
      'days': 'Daily',
      'duration': 10,
      'isActive': true,
    },
    {
      'id': 2,
      'time': '06:30 PM',
      'days': 'Mon, Wed, Fri',
      'duration': 15,
      'isActive': false,
    },
    {
      'id': 3,
      'time': '09:00 AM',
      'days': 'Every 2 Days',
      'duration': 5,
      'isActive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Watering Schedules'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _schedules.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final schedule = _schedules[index];
          return _buildScheduleCard(schedule);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await NavigationHelper.pushNamed(
            ZoneModuleRoutes.createSchedule,
            arguments: {'zoneId': widget.zoneId},
          );
          if (result == true) {
            // Mock Refresh
            setState(() {
              _schedules.add({
                'id': 4,
                'time': '08:15 AM',
                'days': 'Daily',
                'duration': 12,
                'isActive': true,
              });
            });
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> schedule) {
    return GestureDetector(
      onTap: () {
        NavigationHelper.pushNamed(
          ZoneModuleRoutes.createSchedule,
          arguments: {'zoneId': widget.zoneId, 'schedule': schedule},
        );
      },
      child: Container(
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
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule['time'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Switch(
                  value: schedule['isActive'],
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      schedule['isActive'] = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  schedule['days'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${schedule['duration']} mins',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
