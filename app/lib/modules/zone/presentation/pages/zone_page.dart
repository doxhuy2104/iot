import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:flutter/material.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({super.key});

  @override
  State<StatefulWidget> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<_ZoneDetail> _zones = const [
    _ZoneDetail(
      name: 'Greenhouse A',
      location: 'North field',
      soilMoisture: 0.72,
      temperature: 24.5,
      devicesOnline: 8,
      pendingAlerts: 1,
      irrigationEnabled: true,
      accent: Color(0xFF7FC8A9),
    ),
    _ZoneDetail(
      name: 'Hydroponics Lab',
      location: 'Research wing',
      soilMoisture: 0.58,
      temperature: 22.1,
      devicesOnline: 5,
      pendingAlerts: 0,
      irrigationEnabled: false,
      accent: Color(0xFF6CA0DC),
    ),
    _ZoneDetail(
      name: 'Outdoor Plot C',
      location: 'South terrace',
      soilMoisture: 0.31,
      temperature: 30.2,
      devicesOnline: 3,
      pendingAlerts: 2,
      irrigationEnabled: true,
      accent: Color(0xFFFFC857),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalDevices =>
      _zones.fold(0, (acc, zone) => acc + zone.devicesOnline);

  int get _activeAlerts =>
      _zones.fold(0, (acc, zone) => acc + zone.pendingAlerts);

  List<_ZoneDetail> get _filteredZones {
    if (_query.isEmpty) return _zones;
    return _zones
        .where(
          (zone) =>
              zone.name.toLowerCase().contains(_query) ||
              zone.location.toLowerCase().contains(_query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredZones;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.localization.zone),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Button(
            borderRadius: BorderRadius.circular(44),
            onPress: () {},
            child: const Icon(Icons.add),
          ).paddingOnly(right: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {
                  _query = value.toLowerCase();
                }),
                decoration: InputDecoration(
                  hintText: 'Search zones',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Overview',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _OverviewGrid(
                stats: [
                  _OverviewStat(
                    label: 'Total zones',
                    value: _zones.length.toString(),
                    subtitle: 'Configured',
                    icon: Icons.layers_outlined,
                    accent: AppColors.primary.withOpacity(0.1),
                  ),
                  _OverviewStat(
                    label: 'Devices online',
                    value: _totalDevices.toString(),
                    subtitle: 'Across all zones',
                    icon: Icons.sensors,
                    accent: const Color(0xFFE1F5FE),
                  ),
                  _OverviewStat(
                    label: 'Open alerts',
                    value: _activeAlerts.toString(),
                    subtitle: 'Require attention',
                    icon: Icons.warning_amber_outlined,
                    accent: const Color(0xFFFFF4E5),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Active zones',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                _EmptyState(query: _query)
              else
                ...filtered
                    .map((zone) => _ZoneCard(zone: zone))
                    .expand((widget) => [widget, const SizedBox(height: 16)])
                    .toList()
                  ..removeLast(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoneDetail {
  final String name;
  final String location;
  final double soilMoisture;
  final double temperature;
  final int devicesOnline;
  final int pendingAlerts;
  final bool irrigationEnabled;
  final Color accent;

  const _ZoneDetail({
    required this.name,
    required this.location,
    required this.soilMoisture,
    required this.temperature,
    required this.devicesOnline,
    required this.pendingAlerts,
    required this.irrigationEnabled,
    required this.accent,
  });
}

class _ZoneCard extends StatelessWidget {
  final _ZoneDetail zone;

  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: zone.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      zone.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                zone.irrigationEnabled
                    ? Icons.water_drop
                    : Icons.water_drop_outlined,
                color: zone.irrigationEnabled
                    ? AppColors.primary
                    : AppColors.secondaryText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Moisture',
                  value: '${(zone.soilMoisture * 100).round()}%',
                  indicatorValue: zone.soilMoisture.clamp(0, 1),
                  indicatorColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'Temperature',
                  value: '${zone.temperature.toStringAsFixed(1)} °C',
                  indicatorValue: (zone.temperature / 40).clamp(0, 1),
                  indicatorColor: AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Chip(
                icon: Icons.sensors,
                label: '${zone.devicesOnline} devices',
              ),
              const SizedBox(width: 12),
              _Chip(
                icon: Icons.notification_important_outlined,
                label:
                    '${zone.pendingAlerts} alert${zone.pendingAlerts == 1 ? '' : 's'}',
                background: zone.pendingAlerts > 0
                    ? AppColors.danger.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.1),
                iconColor: zone.pendingAlerts > 0
                    ? AppColors.danger
                    : AppColors.primary,
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Details')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final double indicatorValue;
  final Color indicatorColor;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.indicatorValue,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: indicatorValue,
              backgroundColor: Colors.white,
              color: indicatorColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color? iconColor;

  const _Chip({
    required this.icon,
    required this.label,
    this.background = const Color(0xFFF5F5F5),
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColors.secondaryText),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStat {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _OverviewStat({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

class _OverviewGrid extends StatelessWidget {
  final List<_OverviewStat> stats;

  const _OverviewGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats
          .map(
            (stat) => Container(
              width: MediaQuery.of(context).size.width / 2 - 22,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: stat.accent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(stat.icon, color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    stat.label,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;

  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            size: 48,
            color: AppColors.secondaryText,
          ),
          const SizedBox(height: 12),
          Text(
            'No zone found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'We could not find "$query". Please try another keyword.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
