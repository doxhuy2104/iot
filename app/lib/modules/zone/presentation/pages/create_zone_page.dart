import 'package:app/core/components/app_indicator.dart';
import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/components/inputs/text_input.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_routes.dart'; // Re-inserting if missing
import 'package:app/core/helpers/navigation_helper.dart'; // Re-inserting if missing
import 'package:app/core/utils/globals.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/zone/general/zone_module_routes.dart'; // Re-inserting if missing
import 'package:app/modules/zone/presentation/bloc/zone_bloc.dart';
import 'package:app/modules/zone/presentation/bloc/zone_event.dart';
import 'package:app/modules/zone/presentation/bloc/zone_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

class CreateZonePage extends StatefulWidget {
  const CreateZonePage({super.key});

  @override
  State<CreateZonePage> createState() => _CreateZonePageState();
}

class _CreateZonePageState extends State<CreateZonePage> {
  final _zoneNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  // final _latitudeController = TextEditingController();
  // final _longitudeController = TextEditingController();
  final _minThresholdController = TextEditingController(text: '20');
  final _maxThresholdController = TextEditingController(text: '40');
  RangeValues _currentRangeValues = const RangeValues(20, 40);

  bool _autoMode = false;
  bool _weatherMode = false;

  final _bloc = Modular.get<ZoneBloc>();
  bool _gettingLocation = false;

  // Future<void> _getCurrentLocation() async {
  //   setState(() => _gettingLocation = true);
  //   try {
  //     final location = Location();

  //     bool serviceEnabled = await location.serviceEnabled();
  //     if (!serviceEnabled) {
  //       serviceEnabled = await location.requestService();
  //       if (!serviceEnabled) {
  //         return;
  //       }
  //     }

  //     PermissionStatus permissionGranted = await location.hasPermission();
  //     if (permissionGranted == PermissionStatus.denied) {
  //       permissionGranted = await location.requestPermission();
  //       if (permissionGranted != PermissionStatus.granted) {
  //         return;
  //       }
  //     }

  //     final locData = await location.getLocation();
  //     setState(() {
  //       _latitudeController.text = locData.latitude.toString();
  //       _longitudeController.text = locData.longitude.toString();
  //     });
  //   } catch (e) {
  //     Utils.showToast('Error getting location: $e');
  //   } finally {
  //     setState(() => _gettingLocation = false);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    //     Utils.debugLog(Globals.globalLocation)
    // ;    if (Globals.globalLocation != null) {
    //       _latitudeController.text = Globals.globalLocation!.latitude.toString();
    //       _longitudeController.text = Globals.globalLocation!.longitude.toString();
    //     }
  }

  @override
  void dispose() {
    _zoneNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minThresholdController.dispose();
    _maxThresholdController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final zoneName = _zoneNameController.text;
    if (zoneName.isEmpty) {
      Utils.showToast('Zone name cannot be empty');
      return;
    }
    AppIndicator.show();
    _bloc.add(
      CreateZone(
        zoneName: zoneName,
        description: _descriptionController.text,
        location: _locationController.text,
        latitude: Globals.globalLocation!.latitude.toString(),
        longitude: Globals.globalLocation!.longitude.toString(),
        thresholdMin: _currentRangeValues.start,
        thresholdMax: _currentRangeValues.end,
        autoMode: _autoMode,
        weatherMode: _weatherMode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create New Zone'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<ZoneBloc, ZoneState>(
        bloc: _bloc,
        listenWhen: (previous, current) {
          return previous.zones.length < current.zones.length;
        },
        listener: (context, state) {
          // Only navigate if a new zone was actually added (length increased)
          final newZone = state.zones.last;
          Utils.showToast('Zone created successfully');
          NavigationHelper.replace(
            '${AppRoutes.moduleZone}${ZoneModuleRoutes.addDevice}',
            args: {
              'zoneId': newZone.zoneId,
              'threshold': newZone.thresholdMin ?? 0.0,
            },
          );
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(
                  controller: _zoneNameController,
                  placeholder: 'Zone Name',
                  errorMessage: '',
                ),
                const SizedBox(height: 16),
                TextInput(
                  controller: _descriptionController,
                  placeholder: 'Description',
                ),
                const SizedBox(height: 16),
                TextInput(
                  controller: _locationController,
                  placeholder: 'Location',
                  // keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 16),
                const SizedBox(height: 8),
                Text(
                  // 'Threshold Range: ${_currentRangeValues.start.round()}% - ${_currentRangeValues.end.round()}%',
                  'Threshold Range:',

                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                RangeSlider(
                  values: _currentRangeValues,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primary.withOpacity(0.2),
                  labels: RangeLabels(
                    _currentRangeValues.start.round().toString(),
                    _currentRangeValues.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _currentRangeValues = values;
                      _minThresholdController.text = values.start
                          .round()
                          .toString();
                      _maxThresholdController.text = values.end
                          .round()
                          .toString();
                    });
                  },
                ),
                // const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            final val =
                                double.tryParse(_minThresholdController.text) ??
                                0;
                            if (val >= 0 && val < _currentRangeValues.end) {
                              setState(() {
                                _currentRangeValues = RangeValues(
                                  val,
                                  _currentRangeValues.end,
                                );
                              });
                            } else {
                              _minThresholdController.text = _currentRangeValues
                                  .start
                                  .round()
                                  .toString();
                            }
                          }
                        },
                        child: TextInput(
                          controller: _minThresholdController,
                          placeholder: 'Min (%)',
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final v = double.tryParse(val);
                            if (v != null &&
                                v >= 0 &&
                                v < _currentRangeValues.end) {
                              setState(() {
                                _currentRangeValues = RangeValues(
                                  v,
                                  _currentRangeValues.end,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            final val =
                                double.tryParse(_maxThresholdController.text) ??
                                100;
                            if (val > _currentRangeValues.start && val <= 100) {
                              setState(() {
                                _currentRangeValues = RangeValues(
                                  _currentRangeValues.start,
                                  val,
                                );
                              });
                            } else {
                              _maxThresholdController.text = _currentRangeValues
                                  .end
                                  .round()
                                  .toString();
                            }
                          }
                        },
                        child: TextInput(
                          controller: _maxThresholdController,
                          placeholder: 'Max (%)',
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            final v = double.tryParse(val);
                            if (v != null &&
                                v > _currentRangeValues.start &&
                                v <= 100) {
                              setState(() {
                                _currentRangeValues = RangeValues(
                                  _currentRangeValues.start,
                                  v,
                                );
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // SwitchListTile(
                //   title: const Text('Auto Mode'),
                //   value: _autoMode,
                //   onChanged: (val) => setState(() => _autoMode = val),
                //   activeColor: AppColors.primary,
                // ),
                // SwitchListTile(
                //   title: const Text('Weather Mode'),
                //   value: _weatherMode,
                //   onChanged: (val) => setState(() => _weatherMode = val),
                //   activeColor: AppColors.primary,
                // ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Button(
                    onPress: _onSubmit,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: const Text(
                          'Create Zone',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
