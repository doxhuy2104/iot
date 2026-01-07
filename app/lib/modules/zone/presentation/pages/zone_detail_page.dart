import 'dart:async';
import 'dart:convert';

import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/extensions/num_extension.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/core/helpers/navigation_helper.dart';
import 'package:app/core/models/schedule_model.dart';
import 'package:app/core/models/water_log_model.dart';
import 'package:app/core/models/zone_model.dart';
import 'package:app/core/services/mqtt_service.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:app/modules/zone/general/zone_module_routes.dart';
import 'package:app/modules/zone/presentation/bloc/zone_bloc.dart';
import 'package:app/modules/zone/presentation/bloc/zone_event.dart';
import 'package:app/modules/zone/presentation/bloc/zone_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ZoneDetailPage extends StatefulWidget {
  final int zoneId;
  const ZoneDetailPage({super.key, required this.zoneId});

  @override
  State<StatefulWidget> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage>
    with WidgetsBindingObserver {
  ZoneModel? _currentZone;
  final _bloc = Modular.get<ZoneBloc>();
  final _mqttService = Modular.get<MqttService>();
  bool _isLoading = true;
  double _targetHumidity = 80.0; // Default target humidity
  StreamSubscription? _mqttSubscription;
  double _currentHumidity = 36;
  // String _selectedMode = 'Manual'; // Manual, Auto, Schedule
  bool _isDeviceOffline = false;
  bool _isWatering = false;
  bool _isEnableTargetHumidity = false;
  // History Logs State
  bool _isLoadingLogs = true;
  List<WaterLogModel> _logs = [];
  String _logError = '';

  List<ScheduleModel> _schedules = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectAndPublishOnline();
    _getZoneDetail();
    _getWaterLogs();
    _getSchedules();
  }

  void _getSchedules() async {
    final result = await Modular.get<ZoneRepository>().getSchedules(
      widget.zoneId,
    );
    if (!mounted) return;
    result.fold(
      (l) => Utils.debugLog('Error fetching schedules: ${l.reason}'),
      (r) => setState(() {
        _schedules = r;
      }),
    );
  }

  void _deleteSchedule(int scheduleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await Modular.get<ZoneRepository>().deleteSchedule(
        scheduleId,
      );
      if (!mounted) return;
      result.fold(
        (l) => Utils.showToast('Error deleting schedule: ${l.reason}'),
        (r) {
          Utils.showToast('Schedule deleted');
          _getSchedules();
        },
      );
    }
  }

  void _toggleSchedule(int scheduleId, bool currentStatus) async {
    final result = await Modular.get<ZoneRepository>().toggleScheduleActive(
      scheduleId,
      !currentStatus,
    );
    if (!mounted) return;
    result.fold(
      (l) => Utils.showToast('Error updating schedule: ${l.reason}'),
      (r) {
        _getSchedules(); // Refresh to update UI with latest state
      },
    );
  }

  void _getWaterLogs() async {
    try {
      final result = await Modular.get<ZoneRepository>().getWaterLogs(
        widget.zoneId,
      );
      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoadingLogs = false;
            _logError = failure.reason;
          });
        },
        (logs) {
          setState(() {
            _isLoadingLogs = false;
            _logs = logs;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingLogs = false;
        _logError = e.toString();
      });
    }
  }

  // Flow Sensor Data
  double _currentFlowRate = 0.0;
  double _currentVolume = 0.0;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectAndPublishOnline();
    } else if (state == AppLifecycleState.paused) {
      _mqttService.publish(
        'irrigation/status/${widget.zoneId}',
        'offline',
        retain: true,
      );
      // We might want to disconnect or just let LWT handle it if the OS kills the socket.
      // But explicit disconnect avoids 'Software caused connection abort' on resume often.
      // However, if we disconnect, LWT won't fire (unless we set it to).
      // Actually, standard disconnect DOES NOT fire LWT.
      // LWT is for ungraceful disconnects.
      // If we want 'offline' status, we published it above.
      // Now we disconnect to save resources/avoid socket errors.
      _mqttService.disconnect();
    }
  }

  Future<void> _connectAndPublishOnline() async {
    // Connect with LWT for this app instance (App Status)
    await _mqttService.connect(
      willTopic: 'irrigation/status/${widget.zoneId}',
      willMessage: 'offline',
    );
    // Publish App Online Status
    _mqttService.publish(
      'irrigation/status/${widget.zoneId}',
      'online',
      retain: true,
    );

    // Subscribe to Device topics
    _mqttService.subscribe('irrigation/sensor/zone/${widget.zoneId}');
    _mqttService.subscribe('irrigation/status/zone/${widget.zoneId}');

    _mqttSubscription = _mqttService.updates?.listen((
      List<MqttReceivedMessage<MqttMessage>> c,
    ) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      if (c[0].topic == 'irrigation/status/zone/${widget.zoneId}') {
        if (mounted) {
          setState(() {
            _isDeviceOffline = pt == 'offline';
          });
        }
      }

      if (c[0].topic == 'irrigation/sensor/zone/${widget.zoneId}') {
        try {
          final doc = jsonDecode(pt);
          final humidity = doc['humidity'];
          final pumpStatus = doc['pump'];
          final flowRate = doc['flowRate'];
          final volume = doc['volume'];

          if (mounted) {
            setState(() {
              if (humidity != null) {
                _currentHumidity = (humidity as num).toDouble();
              }
              if (pumpStatus != null) {
                bool wasWatering = _isWatering;
                _isWatering = pumpStatus == 'on';
                if (wasWatering && !_isWatering) {
                  // Watering finished, refresh logs and zone detail
                  // Add a small delay to ensure backend has processed the data
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      _getWaterLogs();
                      // _getZoneDetail();
                    }
                  });
                }
              }
              if (flowRate != null) {
                _currentFlowRate = (flowRate as num).toDouble();
              }
              if (volume != null) {
                _currentVolume = (volume as num).toDouble();
              }
            });
          }
        } catch (e) {
          Utils.debugLog('Error parsing MQTT message: $e');
        }
      }
    });
  }

  // Future<void> _connectAndSubscribeMQTT() async {
  //   await _mqttService.connect();
  //   _mqttService.subscribe('irrigation/status/zone/${widget.zoneId}');
  //   Utils.debugLog('Subscribed to irrigation/status/zone/${widget.zoneId}');
  // }

  void _getZoneDetail() async {
    final rt = await Modular.get<ZoneRepository>().getZoneDetail(widget.zoneId);
    if (!mounted) return;
    rt.fold(
      (l) {
        Utils.debugLog(l.reason);
        setState(() {
          _isLoading = false;
        });
      },
      (r) {
        setState(() {
          // Utils.debugLog(r.deviceIdentifier);
          _currentZone = r;
          _isLoading = false;
          // Update target humidity from zone if available
          if (_currentZone?.thresholdMax != null) {
            _targetHumidity = _currentZone!.thresholdMax!;
          }
        });
      },
    );
  }

  void _startWatering() {
    final Map<String, dynamic> payload = {
      'pump': 'on',
      'targetHumidity': _isEnableTargetHumidity ? _targetHumidity : 101,
      'time': DateTime.now().toIso8601String(),
    };
    _mqttService.publish(
      'irrigation/control/zone/${widget.zoneId}',
      jsonEncode(payload),
    );
  }

  void _stopWatering() {
    _mqttService.publish('irrigation/control/zone/${widget.zoneId}', 'off');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Utils.debugLog('Disposing ZoneDetailPage - Publishing offline status');
    _mqttService.publish(
      'irrigation/status/${widget.zoneId}',
      'offline',
      retain: true,
    );
    _mqttSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ZoneBloc, ZoneState>(
      bloc: _bloc,
      listener: (context, state) {
        if (_currentZone == null) return;

        // Check if zone was deleted
        final stillExists = state.zones.any(
          (z) => z.zoneId == _currentZone!.zoneId,
        );
        if (!stillExists) {
          Navigator.of(context).pop();
          return;
        }

        final updatedZone = state.zones.firstWhere(
          (z) => z.zoneId == _currentZone!.zoneId,
          orElse: () => _currentZone!,
        );
        if (updatedZone != _currentZone) {
          setState(() {
            _currentZone = updatedZone;
            // Sync selected mode with data if externally changed
          });
        }
      },
      builder: (context, state) {
        if (_isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_currentZone == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: Text(context.localization.zone),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(child: Text("Zone not found")),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background, // Light background
          appBar: _buildAppBar(context),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // if (_isDeviceOffline) ...[
                //   Center(
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         const Icon(
                //           Icons.wifi_off,
                //           size: 64,
                //           color: Colors.grey,
                //         ),
                //         const SizedBox(height: 16),
                //         const Text(
                //           'Device is current offline',
                //           style: TextStyle(
                //             fontSize: 18,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.grey,
                //           ),
                //         ),
                //         const SizedBox(height: 24),
                //         ElevatedButton.icon(
                //           onPressed: () {
                //             // Navigate to wifi config or add device page
                //             NavigationHelper.push(
                //               '${AppRoutes.moduleZone}${ZoneModuleRoutes.addDevice}',
                //               args: {
                //                 'zoneId': _currentZone!.zoneId,
                //                 'isConfig': true,
                //               },
                //             );
                //           },
                //           icon: const Icon(Icons.settings, color: Colors.white),
                //           label: const Text(
                //             'Configure WiFi',
                //             style: TextStyle(color: Colors.white),
                //           ),
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: AppColors.primary,
                //             padding: const EdgeInsets.symmetric(
                //               horizontal: 24,
                //               vertical: 12,
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ]
                //  else ...[
                _buildSensorMonitoringSection(),
                const SizedBox(height: 16),
                _buildManualControl(),
                const SizedBox(height: 16),
                _buildFlowInfoCard(),
                const SizedBox(height: 16),
                _buildSchedulesSection(),
                const SizedBox(height: 16),
                _buildHistorySection(),
                const SizedBox(height: 16),
                _buildDeleteSection(),
                // ],
              ],
            ),
          ),
          floatingActionButton: _currentZone!.deviceIdentifier?.isEmpty ?? true
              ? FloatingActionButton.extended(
                  onPressed: () {
                    NavigationHelper.navigate(
                      '${AppRoutes.moduleZone}${ZoneModuleRoutes.addDevice}',
                      args: {'zoneId': _currentZone!.zoneId},
                    );
                  },
                  label: const Text('Add Device'),
                  icon: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentZone!.zoneName ?? 'Zone Detail',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          if (_currentZone!.location != null)
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  _currentZone!.location!,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
        ],
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _showEditDialog(context),
        ),
      ],
    );
  }

  Widget _buildSensorMonitoringSection() {
    // Determine humidity status
    // Assuming thresholdValue is the lower bound for "Optimal"
    // This logic can be adjusted based on specific requirements
    Color statusColor = Colors.green;
    // Real-time humidity from MQTT

    double currentHumidity = _currentHumidity;

    // Logic: Based on user provided table
    if (currentHumidity < 10) {
      statusColor = Colors.red;
    } else if (currentHumidity < (_currentZone?.thresholdMin ?? 40)) {
      statusColor = Colors.orange;
    } else if (currentHumidity <= (_currentZone?.thresholdMax ?? 60)) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.deepPurple;
    }

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // const Text(
                //   'Real-time Humidity',
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //     color: AppColors.primaryText,
                //   ),
                // ),
                // Text(
                //   DateFormat('HH:mm').format(DateTime.now()),
                //   style: const TextStyle(color: Colors.grey, fontSize: 12),
                // ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: currentHumidity / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${currentHumidity.toInt()}%',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    // Text(
                    //   status,
                    //   style: TextStyle(
                    //     fontSize: 14,
                    //     color: statusColor,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Thresholds: ${_currentZone!.thresholdMin?.toInt() ?? 0}% - ${_currentZone!.thresholdMax?.toInt() ?? 100}%',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterUsageSummary() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Water Usage',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildUsageItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Today',
                    value: '15 L', // Mock data
                    color: Colors.blue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withOpacity(0.2),
                ),
                Expanded(
                  child: _buildUsageItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'This Month',
                    value: '450 L', // Mock data
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Container(
        //   padding: const EdgeInsets.all(8),
        //   decoration: BoxDecoration(
        //     color: color.withOpacity(0.1),
        //     shape: BoxShape.circle,
        //   ),
        //   child: Icon(icon, color: color, size: 20),
        // ),
        // const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowInfoCard() {
    // Utils.debugLog(_currentVolume);
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flow Sensor Status',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildUsageItem(
                    icon: Icons.speed,
                    label: 'Flow Rate',
                    value: '${_currentFlowRate.toStringAsFixed(1)} L/m',
                    color: Colors.blue,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withOpacity(0.2),
                ).paddingSymmetric(h: 8),
                Expanded(
                  child: _buildUsageItem(
                    icon: Icons.water_drop,
                    label: 'Total Volume',
                    value: '${_currentVolume.toStringAsFixed(1)} L',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualControl() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          16.verticalSpace,
          Icon(
            _isWatering ? Icons.water_drop : Icons.water_drop_outlined,
            size: 64,
            color: _isWatering ? Colors.blue : Colors.grey,
          ),
          8.verticalSpace,
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: Row(
              children: [
                Checkbox(
                  value: _isEnableTargetHumidity && !_isWatering,
                  onChanged: (value) {
                    setState(() {
                      _isEnableTargetHumidity = value!;
                    });
                  },
                ),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Target Humidity (%)'),
                          Text(
                            '${_targetHumidity.toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isEnableTargetHumidity
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Builder(
                        builder: (context) {
                          double minVal = _currentHumidity;
                          if (minVal < 0) minVal = 0;
                          if (minVal > 100) minVal = 100;

                          double sliderVal = _targetHumidity;
                          if (sliderVal < minVal) sliderVal = minVal;
                          if (sliderVal > 100) sliderVal = 100;

                          int divisions = (100 - minVal).floor();
                          if (divisions <= 0) divisions = 1;

                          return Slider(
                            value: sliderVal,
                            min: minVal,
                            max: 100,
                            divisions: divisions,
                            activeColor: Colors.blue,
                            label: '${sliderVal.toInt()}%',
                            onChanged: _isWatering || !_isEnableTargetHumidity
                                ? null
                                : (value) {
                                    setState(() {
                                      _targetHumidity = value;
                                    });
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // _bloc.add(
                //   UpdateZoneEvent(
                //     zoneId: _currentZone!.zoneId!,
                //     pumpStatus: true,
                //     thresholdMax: _targetHumidity,
                //   ),
                // );
                _isWatering ? _stopWatering() : _startWatering();
              },

              // icon: const Icon(Icons.water_drop),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(_isWatering ? 'Stop Watering' : 'Start Watering'),
            ),
          ).paddingSymmetric(h: 16, v: 8),
        ],
      ),
    );
  }

  Widget _buildSchedulesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Schedules',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () async {
                final result = await NavigationHelper.push(
                  '${AppRoutes.moduleZone}${ZoneModuleRoutes.createSchedule}',
                  args: {'zoneId': _currentZone!.zoneId},
                );
                if (result == true) {
                  _getSchedules();
                }
              },
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_schedules.isEmpty)
          const Padding(padding: EdgeInsets.all(0), child: Text("No schedules"))
        else
          ..._schedules.map(
            (schedule) => Card(
              color: Colors.white,
              elevation: 1,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(() {
                  final raw = schedule.startTime ?? '';
                  if (raw.isEmpty) return '';
                  try {
                    // Try parsing as full DateTime (e.g., 2026-01-07T10:54:00)
                    final dt = DateTime.tryParse(raw);
                    if (dt != null) {
                      return DateFormat('HH:mm').format(dt);
                    }
                    // If not a full date, assume it's a time string
                    // Check if it has seconds (HH:mm:ss) or just HH:mm
                    final parts = raw.split(':');
                    if (parts.length >= 2) {
                      return '${parts[0]}:${parts[1]}';
                    }
                    return raw;
                  } catch (e) {
                    return raw;
                  }
                }(), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.repeatDays != null &&
                              schedule.repeatDays!.isNotEmpty
                          ? schedule.repeatDays!.join(', ')
                          : 'One-time',
                    ),
                    Text(
                      'Duration: ${schedule.duration}s - Volume: ${schedule.volume}L',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: schedule.active ?? false,
                  onChanged: (val) =>
                      _toggleSchedule(schedule.id!, schedule.active ?? false),
                ),
                onLongPress: () => _deleteSchedule(schedule.id!),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                NavigationHelper.push(
                  '${AppRoutes.moduleZone}${ZoneModuleRoutes.history}',
                  args: {'zoneId': _currentZone!.zoneId},
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoadingLogs)
          const Center(child: CircularProgressIndicator())
        else if (_logError.isNotEmpty)
          Text('Error loading history: $_logError')
        else if (_logs.isEmpty)
          const Text('No history found')
        else
          Column(
            children: _logs
                .take(3)
                .map((log) => _buildHistoryItem(log))
                .toList(),
          ),
      ],
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

  Widget _buildDeleteSection() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showDeleteConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50], // Light red background
          foregroundColor: Colors.red, // Red text/icon
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.withOpacity(0.5)),
          ),
        ),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Delete Zone'),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Zone'),
        content: Text(
          'Are you sure you want to delete "${_currentZone?.zoneName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              if (_currentZone?.zoneId != null) {
                _bloc.add(DeleteZoneEvent(zoneId: _currentZone!.zoneId!));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    if (_currentZone == null) return;
    final nameController = TextEditingController(text: _currentZone!.zoneName);
    final descController = TextEditingController(
      text: _currentZone!.description,
    );
    RangeValues currentRangeValues = RangeValues(
      _currentZone!.thresholdMin ?? 0,
      _currentZone!.thresholdMax ?? 100,
    );
    final minThresholdController = TextEditingController(
      text: (_currentZone!.thresholdMin ?? 0).round().toString(),
    );
    final maxThresholdController = TextEditingController(
      text: (_currentZone!.thresholdMax ?? 100).round().toString(),
    );
    bool currentAutoMode = _currentZone!.autoMode ?? false;
    bool currentWeatherMode = _currentZone!.weatherMode ?? false;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Zone'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              // Added scroll view
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Zone Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 12),
                  Text(
                    'Threshold Range:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RangeSlider(
                    values: currentRangeValues,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withOpacity(0.2),
                    labels: RangeLabels(
                      currentRangeValues.start.round().toString(),
                      currentRangeValues.end.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        currentRangeValues = values;
                        minThresholdController.text = values.start
                            .round()
                            .toString();
                        maxThresholdController.text = values.end
                            .round()
                            .toString();
                      });
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minThresholdController,
                          decoration: const InputDecoration(
                            labelText: 'Min Threshold (%)',
                            hintText: 'e.g. 20',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final v = double.tryParse(val);
                            if (v != null &&
                                v >= 0 &&
                                v < currentRangeValues.end) {
                              setState(() {
                                currentRangeValues = RangeValues(
                                  v,
                                  currentRangeValues.end,
                                );
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: maxThresholdController,
                          decoration: const InputDecoration(
                            labelText: 'Max Threshold (%)',
                            hintText: 'e.g. 80',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final v = double.tryParse(val);
                            if (v != null &&
                                v > currentRangeValues.start &&
                                v <= 100) {
                              setState(() {
                                currentRangeValues = RangeValues(
                                  currentRangeValues.start,
                                  v,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SwitchListTile(
                    title: const Text('Auto Mode'),
                    value: currentAutoMode,
                    onChanged: (val) {
                      setState(() {
                        currentAutoMode = val;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                  SwitchListTile(
                    title: const Text('Weather Mode'),
                    value: currentWeatherMode,
                    onChanged: (val) {
                      setState(() {
                        currentWeatherMode = val;
                      });
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            // Changed to ElevatedButton for emphasis
            onPressed: () {
              final thresholdMin = currentRangeValues.start;
              final thresholdMax = currentRangeValues.end;
              _bloc.add(
                UpdateZoneEvent(
                  zoneId: _currentZone!.zoneId!,
                  zoneName: nameController.text,
                  description: descController.text,
                  thresholdMin: thresholdMin,
                  thresholdMax: thresholdMax,
                  autoMode: currentAutoMode,
                  weatherMode: currentWeatherMode,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
