import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:app/core/constants/app_configs.dart';
import 'package:app/core/utils/globals.dart';
import 'package:app/core/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GeneralHelper {
  static var appName = '';
  static var packageName = '';
  static var appVersion = '';
  static var buildNumber = '';
  static var isEmulator = false;
  static var deviceId = '';
  static var osInfo = '';
  static var osVersion = '';
  static var deviceInfo = '';
  static var appFlavor = '';
  static var deviceModel = '';
  static var deviceLanguageCode = '';

  GeneralHelper._();

  static init() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    appVersion = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    osInfo = defaultTargetPlatform.name;
    deviceLanguageCode = PlatformDispatcher.instance.locale.languageCode;

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfoPlugin.androidInfo;
      isEmulator = !androidInfo.isPhysicalDevice;
      deviceInfo = androidInfo.brand;
      osVersion = androidInfo.version.release;
      deviceModel = androidInfo.model;
      deviceId = androidInfo.id;
      final uuid = await FlutterUdid.udid;
      Globals.globalUuid = uuid;
      deviceId = uuid;

      // final uuid = Utils.generateUUIDFromAndroidID(deviceId);
      // Globals.globalUuid = uuid;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfoPlugin.iosInfo;
      isEmulator = !iosInfo.isPhysicalDevice;
      deviceInfo = iosInfo.model;
      osVersion = iosInfo.systemVersion;
      deviceModel = iosInfo.utsname.machine;
      deviceId = iosInfo.identifierForVendor ?? '';
      final uuid = await FlutterUdid.udid;
      deviceId = uuid;

      Globals.globalUuid = uuid;
    } else {
      isEmulator = false;
    }

    appFlavor = kDebugMode ? AppConfigs.flavorDev : AppConfigs.flavorProd;

    printAppInfo();
  }

  static printAppInfo() {
    Utils.debugLog(
      "App name : $appName, App package name: $packageName, App version: $appVersion, App build number: $buildNumber, App flavor = $appFlavor, Os version: $osVersion, Os info: $osInfo, Device model: $deviceModel, Device id: $deviceId, deviceLanguageCode: $deviceLanguageCode",
    );
  }
}
