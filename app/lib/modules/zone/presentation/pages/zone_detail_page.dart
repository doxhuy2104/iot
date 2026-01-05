import 'dart:async';
import 'dart:convert';

import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/helpers/navigation_helper.dart';
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
  double _manualWateringDuration = 5.0; // Minutes
  StreamSubscription? _mqttSubscription;
  double _currentHumidity = 0.0;
  String _selectedMode = 'Manual'; // Manual, Auto, Schedule

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectAndPublishOnline();
    _getZoneDetail();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _connectAndPublishOnline();
    } else if (state == AppLifecycleState.paused) {
      _mqttService.publish('irrigation/status/${widget.zoneId}', 'offline');
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
    // Connect with LWT for this zone
    await _mqttService.connect(
      willTopic: 'irrigation/status/${widget.zoneId}',
      willMessage: 'offline',
    );
    _mqttService.publish('irrigation/status/${widget.zoneId}', 'online');
    _mqttService.subscribe('irrigation/sensor/zone/${widget.zoneId}');

    _mqttSubscription = _mqttService.updates?.listen((
      List<MqttReceivedMessage<MqttMessage>> c,
    ) {
      final recMess = c[0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      if (c[0].topic == 'irrigation/sensor/zone/${widget.zoneId}') {
        try {
          final doc = jsonDecode(pt);
          final humidity = doc['humidity'];
          final pumpStatus = doc['pump'];

          if (mounted) {
            setState(() {
              if (humidity != null) {
                _currentHumidity = (humidity as num).toDouble();
              }
              if (pumpStatus != null) {
                // Update pump status in _currentZone
                bool isPumpOn = pumpStatus == 'on';
                if (_currentZone != null) {
                  _currentZone = _currentZone!.copyWith(pumpStatus: isPumpOn);
                }
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
        });
        // if (r.deviceIdentifier != null && r.deviceIdentifier!.isNotEmpty) {
        //   _connectAndSubscribeMQTT();
        // }
        // Initialize mode based on data
        if (_currentZone!.autoMode == true) {
          _selectedMode = 'Auto';
        } else {
          // If not auto, default to Manual for now
          // We could check if schedules exist to default to Schedule,
          // but Manual is a safer default.
          _selectedMode = 'Manual';
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Utils.debugLog('Disposing ZoneDetailPage - Publishing offline status');
    _mqttService.publish('irrigation/status/${widget.zoneId}', 'offline');
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
            if (_currentZone!.autoMode == true && _selectedMode != 'Auto') {
              _selectedMode = 'Auto';
            } else if (_currentZone!.autoMode == false &&
                _selectedMode == 'Auto') {
              // Fallback to Manual if Auto turned off externally
              _selectedMode = 'Manual';
            }
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
                _buildSensorMonitoringSection(),
                const SizedBox(height: 16),
                // _buildWaterUsageSummary(),
                // const SizedBox(height: 16),
                // _buildControlPanel(context),
                _buildControlPanel(context),
                // const SizedBox(height: 16),
                // _buildSchedulesSection(),
                const SizedBox(height: 16),
                _buildDeleteSection(),
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
        // Status Indicator
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.wifi,
                size: 14,
                color: _currentZone!.deviceIdentifier != null
                    ? Colors.greenAccent
                    : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _currentZone!.deviceIdentifier != null ? 'Online' : 'Offline',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
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
    String status = 'Optimal';
    Color statusColor = Colors.green;
    // Real-time humidity from MQTT
    double currentHumidity = _currentHumidity;

    // Logic: Based on user provided table
    if (currentHumidity < 10) {
      status = 'Very Dry';
      statusColor = Colors.red;
    } else if (currentHumidity < 20) {
      status = 'Dry';
      statusColor = Colors.orange;
    } else if (currentHumidity < 40) {
      status = 'Optimal';
      statusColor = Colors.green;
    } else if (currentHumidity < 60) {
      status = 'Moist';
      statusColor = Colors.blue;
    } else if (currentHumidity < 80) {
      status = 'Slightly Waterlogged';
      statusColor = Colors.indigo;
    } else {
      status = 'Waterlogged';
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
                const Text(
                  'Real-time Humidity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
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
            const SizedBox(height: 10),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
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

  Widget _buildControlPanel(BuildContext context) {
    // Determine active mode based on zone state
    // Default priority: Auto > Schedule > Manual (if pump is on)
    // Or we can add a 'mode' field to the model if backend supports it.
    // For now, let's assume we manage it via UI state or derive it.

    // Let's create a local state for the selected mode to show the UI
    // In a real app, this might be persisted.
    // However, looking at the user request "lựa chọn 1 trong 3",
    // it implies we should have a selector.

    // REVISING APPROACH:
    // Use SegmentedButton (Material 3) for clean look.
    // Modes: { Manual, Auto, Schedule }
    // Logic:
    // - Select Auto: Update zone autoMode = true.
    // - Select Manual: Update zone autoMode = false. (User can toggle pump)
    // - Select Schedule: Update zone autoMode = false. (User manages schedules)

    // Note: The backend model 'ZoneModel' currently has 'autoMode' (bool).
    // It does not have 'scheduleMode'.
    // If 'Auto' is off, it can be Manual OR Schedule.
    // We might need to persist this choice locally or infer it?
    // Or maybe 'weatherMode' was for something else?

    // Let's use a local state variable `_selectedMode` in the State class to track user intention
    // while on this screen, and sync with `_currentZone.autoMode`.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Operating Mode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 4) / 3;
              return Row(
                children: [
                  _buildModeButton(
                    'Manual',
                    _selectedMode == 'Manual',
                    width,
                    onTap: () {
                      setState(() {
                        _selectedMode = 'Manual';
                      });
                      if (_currentZone!.autoMode == true) {
                        _bloc.add(
                          UpdateZoneEvent(
                            zoneId: _currentZone!.zoneId!,
                            autoMode: false,
                          ),
                        );
                      }
                    },
                  ),
                  _buildModeButton(
                    'Auto',
                    _selectedMode == 'Auto',
                    width,
                    onTap: () {
                      setState(() {
                        _selectedMode = 'Auto';
                      });
                      if (_currentZone!.autoMode != true) {
                        _bloc.add(
                          UpdateZoneEvent(
                            zoneId: _currentZone!.zoneId!,
                            autoMode: true,
                          ),
                        );
                      }
                    },
                  ),
                  _buildModeButton(
                    'Schedule',
                    _selectedMode == 'Schedule',
                    width,
                    onTap: () {
                      setState(() {
                        _selectedMode = 'Schedule';
                      });
                      if (_currentZone!.autoMode == true) {
                        _bloc.add(
                          UpdateZoneEvent(
                            zoneId: _currentZone!.zoneId!,
                            autoMode: false,
                          ),
                        );
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Conditional Rendering based on Mode
        if (_selectedMode == 'Manual') _buildManualControl(),
        if (_selectedMode == 'Auto') _buildAutoSettings(),
        if (_selectedMode == 'Schedule') _buildSchedulesSection(),
      ],
    );
  }

  Widget _buildModeButton(
    String label,
    bool isSelected,
    double width, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 40,
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildManualControl() {
    bool isPumpRunning = _currentZone!.pumpStatus ?? false;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isPumpRunning
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shower,
                color: isPumpRunning ? Colors.blue : Colors.grey,
              ),
            ),
            title: const Text('Manual Watering'),
            subtitle: Text(
              isPumpRunning
                  ? 'Watering in progress...'
                  : 'Tap to start watering',
            ),
            trailing: Switch(
              value: isPumpRunning,
              activeColor: Colors.blue,
              onChanged: (value) {
                _bloc.add(
                  UpdateZoneEvent(
                    zoneId: _currentZone!.zoneId!,
                    pumpStatus: value,
                  ),
                );
              },
            ),
          ),
          if (!isPumpRunning) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Timer (Minutes)'),
                      Text(
                        '${_manualWateringDuration.toInt()} min',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _manualWateringDuration,
                    min: 1,
                    max: 60,
                    divisions: 59,
                    activeColor: Colors.blue,
                    label: '${_manualWateringDuration.toInt()} min',
                    onChanged: (value) {
                      setState(() {
                        _manualWateringDuration = value;
                      });
                    },
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _bloc.add(
                          UpdateZoneEvent(
                            zoneId: _currentZone!.zoneId!,
                            pumpStatus: true,
                          ),
                        );
                      },
                      icon: const Icon(Icons.timer_outlined),
                      label: const Text('Start Timer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoSettings() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.settings_suggest, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Auto Mode Enabled',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'The system will automatically water when soil moisture drops below the minimum threshold.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => _showEditDialog(context),
              child: const Text('Adjust Thresholds'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedulesSection() {
    // Mock schedules
    final List<Map<String, dynamic>> schedules = [
      {'time': '07:00 AM', 'days': 'Daily', 'isActive': true},
      {'time': '06:00 PM', 'days': 'Mon, Wed, Fri', 'isActive': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () {
                NavigationHelper.push(
                  '${AppRoutes.moduleZone}${ZoneModuleRoutes.schedules}',
                  args: {'zoneId': _currentZone!.zoneId},
                );
              },
              child: Row(
                children: const [
                  Text(
                    'Upcoming Schedules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () {
                NavigationHelper.push(
                  '${AppRoutes.moduleZone}${ZoneModuleRoutes.createSchedule}',
                  args: {'zoneId': _currentZone!.zoneId},
                );
              },
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...schedules.map(
          (schedule) => Card(
            color: Colors.white,
            elevation: 1,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                Icons.schedule,
                color: schedule['isActive'] ? Colors.blue : Colors.grey,
              ),
              title: Text(
                schedule['time'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(schedule['days']),
              trailing: Switch(
                value: schedule['isActive'],
                onChanged: (val) {
                  // Update schedule status
                },
              ),
            ),
          ),
        ),
      ],
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
                    'Threshold Range: ${currentRangeValues.start.round()}% - ${currentRangeValues.end.round()}%',
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
