import 'dart:async';

import 'package:app/core/components/app_indicator.dart';
import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/zone/data/repositories/zone_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:location/location.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

class AddDevicePage extends StatefulWidget {
  final dynamic zoneId;
  const AddDevicePage({super.key, this.zoneId});

  @override
  State<StatefulWidget> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  List<WiFiAccessPoint> _wifis = [];
  bool shouldCheckCan = true;
  bool _isLoading = false;
  StreamSubscription<List<WiFiAccessPoint>>? _subscription;
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _subscription = WiFiScan.instance.onScannedResultsAvailable.listen((
      results,
    ) {
      if (mounted) {
        setState(() {
          _wifis = results;
        });
      }
    });
    _scanWifi();
    _startPeriodicScan();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicScan() {
    _scanTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _scanWifi();
    });
  }

  Future<void> _scanWifi() async {
    try {
      if (shouldCheckCan) {
        // check if can-startScan
        var can = await WiFiScan.instance.canStartScan();
        // if can-not, then show error
        Utils.debugLog(can.toString());
        if (can == CanStartScan.noLocationServiceDisabled) {
          final location = Location();
          final serviceEnabled = await location.requestService();
          if (serviceEnabled) {
            can = await WiFiScan.instance.canStartScan();
          }
        } else if (can == CanStartScan.noLocationPermissionRequired ||
            can == CanStartScan.noLocationPermissionDenied) {
          final location = Location();
          final permission = await location.requestPermission();
          if (permission == PermissionStatus.granted ||
              permission == PermissionStatus.grantedLimited) {
            can = await WiFiScan.instance.canStartScan();
          }
        }

        if (can != CanStartScan.yes) {
          return;
        }
      }
      await WiFiScan.instance.startScan();
      final results = await WiFiScan.instance.getScannedResults();
      if (mounted) {
        setState(() {
          _wifis = results;
        });
      }
      Utils.debugLog(_wifis.toString());
    } catch (e) {
      Utils.debugLog('Error scanning wifi: $e');
    }
  }

  Future<void> _connectWifi(String ssid, {String password = ''}) async {
    AppIndicator.show();
    try {
      bool success = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        security: password.isEmpty ? NetworkSecurity.NONE : NetworkSecurity.WPA,
        withInternet: false, // IoT devices typically don't have internet
        joinOnce: true,
      );

      if (success) {
        await WiFiForIoTPlugin.forceWifiUsage(true);
        print('Kết nối WiFi thành công');
        if (mounted) {
          _showProvisioningDialog();
        }
      } else {
        print('Kết nối WiFi thất bại');
      }
      AppIndicator.hide();
    } catch (e) {
      AppIndicator.hide();
      print('Lỗi kết nối WiFi: $e');
    }
  }

  Future<void> _showProvisioningDialog() async {
    final ssidController = TextEditingController();
    final passController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cấu hình WiFi cho thiết bị'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ssidController,
              decoration: const InputDecoration(
                labelText: 'Tên WiFi (SSID)',
                hintText: 'Nhập tên WiFi nhà bạn',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passController,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu',
                hintText: 'Nhập mật khẩu WiFi',
              ),
              obscureText: false,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: AppColors.danger)),
          ),
          TextButton(
            onPressed: () async {
              // Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });
              final rt = await Modular.get<ZoneRepository>().sendWifi(
                ssid: ssidController.text,
                password: passController.text,
              );
              rt.fold((l) => Utils.debugLog(l), (r) async {
                Utils.debugLog(r);
                Navigator.pop(context); // Close dialog
                if (r['status'] == 'success') {
                  final mac = r['mac'];
                  final zoneId = widget.zoneId;
                  if (mac != null && zoneId != null) {
                    final int? pId = zoneId is int
                        ? zoneId
                        : int.tryParse(zoneId.toString());
                    if (pId != null) {
                      final createRes = await Modular.get<ZoneRepository>()
                          .createDevice(
                            deviceName: 'esp32',
                            identifier: mac,
                            zoneId: pId,
                            type: 'ESP32_CONTROLLER',
                          );
                      createRes.fold(
                        (f) {
                          setState(() {
                            _isLoading = false;
                          });
                          Utils.showToast(
                            'Failed to create device: ${f.reason}',
                          );
                        },
                        (s) {
                          setState(() {
                            _isLoading = false;
                          });
                          Utils.debugLog(s);
                          Utils.showToast('Device created successfully');
                          // Navigate back to previous page (ZonePage)
                          Navigator.pop(context);
                        },
                      );
                    }
                  }
                }
              });
            },
            child: const Text('Gửi cấu hình'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendConfigToEsp32(String ssid, String pass) async {
    print('Sending config to ESP32: SSID=$ssid, Pass=$pass');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Connect device'),
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
        child: RefreshIndicator(
          onRefresh: () async {
            await _scanWifi();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_wifis.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _wifis.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final wifi = _wifis[index];
                      return Button(
                        borderRadius: BorderRadius.circular(12),
                        onPress: () {
                          _connectWifi(wifi.ssid, password: '00000000');
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.wifi,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              wifi.ssid.isNotEmpty ? wifi.ssid : 'Unknown SSID',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              // Handle tap
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
