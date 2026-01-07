import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/models/water_log_model.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  final int zoneId;
  const HistoryPage({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: Modular.get<ZoneRepository>().getWaterLogs(zoneId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return snapshot.data!.fold(
            (failure) => Center(child: Text(failure.reason)),
            (logs) {
              if (logs.isEmpty) {
                return const Center(child: Text('No history available'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return _buildHistoryItem(logs[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(WaterLogModel log) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Text(
                    log.startedAt != null
                        ? DateFormat('HH:mm dd/MM/yyyy').format(log.startedAt!)
                        : 'N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, size: 12, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${(log.waterVolumeLiters ?? 0).toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.timer, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${log.durationSeconds ?? 0} s',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
