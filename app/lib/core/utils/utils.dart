import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:app/core/constants/app_environment.dart';
import 'package:app/core/helpers/general_helper.dart';
import 'dart:math' as math;

import 'package:app/core/network/dio_client.dart';
import 'package:app/core/utils/globals.dart';


final class Utils {
  Utils._();

  static void debugLog(Object? object, {String? tagName}) {
    if (kDebugMode) {
      log(
        '${DateTime.now().toLocal().toString()}: $object',
        name: tagName ?? 'LOG',
      );
    }
  }

  static void debugLogSuccess(dynamic object, {String? tagName}) {
    final dateTime = DateTime.now();
    final source = tagName ?? 'LOG';
    final message =
        '[${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}] $object';
    if (kDebugMode) {
      log('\x1B[32m$message\x1B[0m', time: dateTime, name: source);
    }
  }

  static void debugLogWarning(dynamic object, {String? tagName}) {
    final dateTime = DateTime.now();
    final source = tagName ?? 'LOG';
    final message =
        '[${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}] $object';
    if (kDebugMode) {
      log('\x1B[33m$message\x1B[0m', time: dateTime, name: source);
    }
  }

  static void debugLogError(dynamic object, {String? tagName}) {
    final dateTime = DateTime.now();
    final source = tagName ?? 'LOG';
    final message =
        '[${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}] $object';
    if (kDebugMode) {
      log('\x1B[31m$message\x1B[0m', time: dateTime, name: source);
    }
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static DioClient get dioClient => Modular.get<DioClient>();

  static String formaCurrency(num? currency, [String? symbol]) {
    // Set a default symbol to an empty string if it's null
    symbol ??= '';

    NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: symbol,
    );

    String formattedAmount = currencyFormat.format(currency);

    return formattedAmount.trim();
  }

  static String convertPhoneWithSpace(String interPhone) {
    String phone = interPhone;
    if (interPhone.startsWith('84')) {
      phone = interPhone.replaceFirst("84", "0");
    } else if (interPhone.startsWith('+84')) {
      phone = interPhone.replaceFirst("+84", "0");
    }
    if (phone.length == 10) {
      phone =
          "${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7, 10)}";
    } else if (phone.length == 9) {
      phone = "0$phone";
      phone =
          "${phone.substring(0, 4)} ${phone.substring(4, 7)} ${phone.substring(7, 10)}";
    }
    return phone;
  }

  static String formatDuration(int seconds) {
    Duration duration = Duration(seconds: seconds);

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String secs = twoDigits(duration.inSeconds.remainder(60));

    return "$hours:$minutes:$secs"; // mm:ss format otherwise
  }

  static int roundUpToNearestPowerOfTen(double number) {
    int numDigits = number.toInt().toString().length;
    int roundingFactor = math.pow(10, numDigits - 1).toInt();

    return ((number + roundingFactor - 1) / roundingFactor).floor() *
        roundingFactor;
  }

  static String? decodeAppleIDToken(String idToken) {
    try {
      final parts = idToken.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = base64Url.decode(base64Url.normalize(parts[1]));
      final payloadMap = json.decode(utf8.decode(payload));

      if (payloadMap is Map<String, dynamic>) {
        final email = payloadMap['email'];
        return email;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static String generateUUIDFromAndroidID(String androidId) {
    final bytes = utf8.encode(androidId);
    final hash = sha256.convert(bytes).bytes;

    final uuid =
        [
              hash.sublist(0, 4),
              hash.sublist(4, 6),
              hash.sublist(6, 8),
              hash.sublist(8, 10),
              hash.sublist(10, 16),
            ]
            .map(
              (segment) => segment
                  .map((b) => b.toRadixString(16).padLeft(2, '0'))
                  .join(),
            )
            .join('-');

    return uuid;
  }


  static String getNameFromEmail(String email) {
    if (email.contains('@')) {
      String name = email.split('@')[0];
      // Replace dots with spaces and capitalize each word.
      return name
          .replaceAll('.', ' ')
          .split(' ')
          .map(
            (word) => word.isNotEmpty
                ? '${word[0].toUpperCase()}${word.substring(1)}'
                : '',
          )
          .join(' ');
    }
    return '';
  }

  static String hideEmail(String email) {
    try {
      String username = email.split('@')[0];
      String domain = email.split('@')[1];
      String hiddenUsername = '${username.substring(0, 1)}****';
      return '$hiddenUsername$domain';
    } catch (e) {
      return '********';
    }
  }

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return true;
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }

  static String getDateLabel(DateTime datetime) {
    final now = DateTime.now();
    if (datetime.year == now.year &&
        datetime.month == now.month &&
        datetime.day == now.day) {
      return '${DateFormat('hh:mm a').format(datetime.toLocal())} Today';
    }

    final yesterday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 1));
    if (datetime.year == yesterday.year &&
        datetime.month == yesterday.month &&
        datetime.day == yesterday.day) {
      return '${DateFormat('hh:mm a').format(datetime.toLocal())} Yesterday';
    }

    return DateFormat('hh:mm a dd/MM/yyyy').format(datetime.toLocal());
  }

  static String getMessageDateString(DateTime datetime) {
    final now = DateTime.now();
    if (datetime.year == now.year &&
        datetime.month == now.month &&
        datetime.day == now.day) {
      return DateFormat('HH:mm').format(datetime);
    }

    return DateFormat('MMM d').format(datetime);
  }

  static String convertImageUrl(String? url) {
    if ((url ?? '').startsWith('http')) {
      return (url ?? '');
    }

    return '${AppEnvironment.baseUrl}/${url ?? ''}';
  }

  // static void openEmail(String email) async {
  //   final Uri emailUri = Uri(
  //     scheme: 'mailto',
  //     path: email,
  //     query: encodeQueryParameters({
  //       'subject':
  //           "[Pixage for ${Platform.isIOS ? 'iOS' : 'Android'}] Feedback of version ${GeneralHelper.appVersion}",
  //       'body':
  //           '\n\n\n\nUUID: ${Globals.globalUuid}\nOS Version: ${GeneralHelper.osVersion}\nModel: ${GeneralHelper.deviceModel}',
  //     }),
  //   );
  //   try {
  //     await launchUrl(emailUri);
  //   } catch (e) {
  //     Utils.debugLogError(e);
  //   }
  // }

  // static void launchURL({required String urlString}) async {
  //   final Uri url = Uri.parse(urlString);
  //   try {
  //     await launchUrl(
  //       url,
  //       mode: Platform.isIOS
  //           ? LaunchMode.externalApplication
  //           : LaunchMode.platformDefault,
  //     );
  //   } catch (e) {
  //     Utils.debugLogError(e);
  //   }
  // }

  static String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  static void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.black.withOpacity(0.6),
    );
  }

  static String trimPhoneNumber(String phone) {
    return phone.substring(phone.length - 9);
  }

  static String formatBigNumber(num number) {
    if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(1)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(1)}M';
    } else if (number >= 1e3 + 100) {
      return '${(number / 1e3).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }

  static String formatCoin(num number) {
    // split thousand with '.'
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  static bool isCloseToBottom(ScrollPosition position) {
    return position.maxScrollExtent - position.pixels < 100;
  }

  // static String getTimeAgo(BuildContext context, DateTime dateTime) {
  //   final now = DateTime.now();
  //   final difference = now.difference(dateTime);

  //   if (difference.inDays > 0) {
  //     // final years = (difference.inDays / 365).floor();
  //     // return years == 1
  //     //     ? context.localization.yearAgo
  //     //     : context.localization.yearsAgo(years);
  //     return DateFormat('dd MMM yyyy hh:mm a').format(dateTime.toLocal());
  //     // } else if (difference.inDays > 30) {
  //     //   final months = (difference.inDays / 30).floor();
  //     //   return months == 1
  //     //       ? context.localization.monthAgo
  //     //       : context.localization.monthsAgo(months);
  //     // } else if (difference.inDays > 0) {
  //     //   return difference.inDays == 1
  //     //       ? context.localization.dayAgo
  //     //       : context.localization.daysAgo(difference.inDays);
  //   } else if (difference.inHours > 0) {
  //     return difference.inHours == 1
  //         ? context.localization.hourAgo
  //         : context.localization.hoursAgo(difference.inHours);
  //   } else if (difference.inMinutes > 0) {
  //     return difference.inMinutes == 1
  //         ? context.localization.minuteAgo
  //         : context.localization.minutesAgo(difference.inMinutes);
  //   } else {
  //     return context.localization.justNow;
  //   }
  // }

  static bool isRecent(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    return difference.inMinutes <= 5;
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceAll("#", ""); // remove #
    if (hex.length == 6) {
      hex = "FF$hex"; // add alpha if missing
    }
    return Color(int.parse(hex, radix: 16));
  }
}
