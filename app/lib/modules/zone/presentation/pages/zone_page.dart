import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/core/helpers/navigation_helper.dart';
import 'package:app/core/models/zone_model.dart';
import 'package:app/modules/zone/general/zone_module_routes.dart';
import 'package:app/modules/zone/presentation/bloc/zone_bloc.dart';
import 'package:app/modules/zone/presentation/bloc/zone_event.dart';
import 'package:app/modules/zone/presentation/bloc/zone_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

class ZonePage extends StatefulWidget {
  const ZonePage({super.key});

  @override
  State<StatefulWidget> createState() => _ZonePageState();
}

class _ZonePageState extends State<ZonePage> {
  final TextEditingController _searchController = TextEditingController();
  final _bloc = Modular.get<ZoneBloc>();

  @override
  void initState() {
    super.initState();
    _bloc.add(GetZones());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    _bloc.add(GetZones());
  }

  @override
  Widget build(BuildContext context) {
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
            onPress: () {
              NavigationHelper.navigate(
                '${AppRoutes.moduleZone}${ZoneModuleRoutes.createZone}',
              );
            },
            child: const Icon(Icons.add),
          ).paddingOnly(right: 12),
        ],
      ),
      body: BlocBuilder<ZoneBloc, ZoneState>(
        bloc: _bloc,
        builder: (context, state) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemCount: state.zones.length,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final zone = state.zones[index];
                  return _ZoneCard(zone: zone).paddingOnly(bottom: 16);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ZoneCard extends StatelessWidget {
  final ZoneModel zone;

  const _ZoneCard({required this.zone});

  @override
  Widget build(BuildContext context) {
    // Determine accent color (can be dynamic or random, logic can be added later)
    final accent = AppColors.primary;

    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on, color: accent),
        ),
        title: Text(
          zone.zoneName ?? 'Unnamed Zone',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          zone.location ?? 'Unknown location',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () {
          NavigationHelper.navigate(
            '${AppRoutes.moduleZone}${ZoneModuleRoutes.zoneDetail}',
            args: {'zoneId': zone.zoneId},
          );
        },
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

// class _Chip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color background;
//   final Color? iconColor;

//   const _Chip({
//     required this.icon,
//     required this.label,
//     this.background = const Color(0xFFF5F5F5),
//     this.iconColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       decoration: BoxDecoration(
//         color: background,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 18, color: iconColor ?? AppColors.secondaryText),
//           const SizedBox(width: 6),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               fontWeight: FontWeight.w500,
//               color: AppColors.primaryText,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
