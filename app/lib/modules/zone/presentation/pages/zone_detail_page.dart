import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_styles.dart';
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
import 'package:intl/intl.dart';

class ZoneDetailPage extends StatefulWidget {
  final int zoneId;
  const ZoneDetailPage({super.key, required this.zoneId});

  @override
  State<StatefulWidget> createState() => _ZoneDetailPageState();
}

class _ZoneDetailPageState extends State<ZoneDetailPage> {
  ZoneModel? _currentZone;
  final _bloc = Modular.get<ZoneBloc>();
  final _mqttService = Modular.get<MqttService>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getZoneDetail();
  }

  Future<void> _connectAndSubscribeMQTT(String deviceId) async {
    await _mqttService.connect();
    _mqttService.subscribe('device/$deviceId/#');
    Utils.debugLog('Subscribed to device/$deviceId/#');
  }

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
          Utils.debugLog(r.deviceIdentifier);
          _currentZone = r;
          _isLoading = false;
        });
        if (r.deviceIdentifier != null && r.deviceIdentifier!.isNotEmpty) {
          _connectAndSubscribeMQTT(r.deviceIdentifier!);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ZoneBloc, ZoneState>(
      bloc: _bloc,
      listener: (context, state) {
        if (_currentZone == null) return;
        final updatedZone = state.zones.firstWhere(
          (z) => z.zoneId == _currentZone!.zoneId,
          orElse: () => _currentZone!,
        );
        if (updatedZone != _currentZone) {
          setState(() {
            _currentZone = updatedZone;
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_currentZone!.zoneName ?? context.localization.zone),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentZone!.location!,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
            centerTitle: false,

            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () {
                  _showEditDialog(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white),
                onPressed: () {
                  _showDeleteConfirmDialog(context);
                },
              ),
            ],
          ),
          floatingActionButton: _currentZone!.deviceIdentifier?.isEmpty ?? true
              ? FloatingActionButton.extended(
                  onPressed: () {
                    NavigationHelper.navigate(
                      ZoneModuleRoutes.addDevice,
                      args: {'zoneId': _currentZone!.zoneId},
                    );
                  },
                  label: Text(
                    'Add Device',
                    style: Styles.medium.regular.copyWith(color: Colors.white),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  backgroundColor: AppColors.primary,
                )
              : null,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _buildInfoCard(context),
                  // const SizedBox(height: 16),
                  _buildStatusGrid(context),
                  const SizedBox(height: 16),
                  _buildLocationCard(context),
                  const SizedBox(height: 16),
                  if (_currentZone!.createdAt != null)
                    Text(
                      'Created: ${DateFormat('yyyy-MM-dd HH:mm').format(_currentZone!.createdAt!)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context) {
    if (_currentZone == null) return;
    final nameController = TextEditingController(text: _currentZone!.zoneName);
    final descController = TextEditingController(
      text: _currentZone!.description,
    );
    final thresholdController = TextEditingController(
      text: _currentZone!.thresholdValue?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Zone'),
        content: Column(
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
            TextField(
              controller: thresholdController,
              decoration: const InputDecoration(
                labelText: 'Threshold Value (%)',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newThreshold =
                  double.tryParse(thresholdController.text) ?? 0;
              _bloc.add(
                UpdateZoneEvent(
                  zoneId: _currentZone!.zoneId!,
                  zoneName: nameController.text,
                  description: descController.text,
                  thresholdValue: newThreshold,
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

  void _showDeleteConfirmDialog(BuildContext context) {
    if (_currentZone == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Zone'),
        content: const Text(
          'Are you sure you want to delete this zone? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Utils.debugLog(_currentZone!.zoneId);
              Navigator.pop(context);
              if (_currentZone!.zoneId != null) {
                _bloc.add(DeleteZoneEvent(zoneId: _currentZone!.zoneId!));
                try {
                  Navigator.pop(context); // Go back to ZonePage
                } catch (e) {
                  Utils.debugLog('Error popping: $e');
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          Text(
            _currentZone!.zoneName ?? 'Unknown Zone',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          if (_currentZone!.location != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _currentZone!.location!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ],
          if (_currentZone!.description != null &&
              _currentZone!.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              _currentZone!.description!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.primaryText,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatusItem(
          icon: Icons.water_drop,
          color: Colors.blue,
          label: 'Threshold',
          value: '${_currentZone!.thresholdValue ?? 0}%',
          onTap: () {
            _showEditDialog(context);
          },
        ),
        _buildStatusItem(
          icon: Icons.settings_suggest,
          color: Colors.orange,
          label: 'Auto Mode',
          value: (_currentZone!.autoMode ?? false) ? 'On' : 'Off',
          isActive: _currentZone!.autoMode ?? false,
          onTap: () {
            _bloc.add(
              UpdateZoneEvent(
                zoneId: _currentZone!.zoneId!,
                autoMode: !(_currentZone!.autoMode ?? false),
              ),
            );
          },
        ),
        _buildStatusItem(
          icon: Icons.cloud,
          color: Colors.purple,
          label: 'Weather Mode',
          value: (_currentZone!.weatherMode ?? false) ? 'On' : 'Off',
          isActive: _currentZone!.weatherMode ?? false,
          onTap: () {
            _bloc.add(
              UpdateZoneEvent(
                zoneId: _currentZone!.zoneId!,
                weatherMode: !(_currentZone!.weatherMode ?? false),
              ),
            );
          },
        ),
        _buildStatusItem(
          icon: Icons.power_settings_new,
          color: (_currentZone!.pumpStatus ?? false)
              ? Colors.green
              : Colors.red,
          label: 'Pump Status',
          value: (_currentZone!.pumpStatus ?? false) ? 'Running' : 'Stopped',
          isActive: _currentZone!.pumpStatus ?? false,
          onTap: () {
            _bloc.add(
              UpdateZoneEvent(
                zoneId: _currentZone!.zoneId!,
                pumpStatus: !(_currentZone!.pumpStatus ?? false),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    bool isActive = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                if (isActive)
                  const CircleAvatar(radius: 4, backgroundColor: Colors.green),
              ],
            ),
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
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    if (_currentZone!.latitude == null && _currentZone!.longitude == null) {
      return const SizedBox();
    }
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Expanded(
            child: _buildCoordinateItem(
              'Latitude',
              _currentZone!.latitude ?? 'N/A',
            ),
          ),
          Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.2)),
          Expanded(
            child: _buildCoordinateItem(
              'Longitude',
              _currentZone!.longitude ?? 'N/A',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
