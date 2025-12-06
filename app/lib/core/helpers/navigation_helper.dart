import 'package:flutter_modular/flutter_modular.dart';

class NavigationHelper {
  /// navigate push
  static void navigate(
    String route, {
    Map<String, dynamic> args = const {'': null},
  }) {
    List<String> routes = Modular.to.navigateHistory
        .map((e) => e.name)
        .toList();

    if (routes.contains(route)) {
      return replace(route, args: args);
    }
    Modular.to.pushNamed(route, arguments: args);
    // AppKeys.navigatorKey.currentState?.pushNamed(route, arguments: args);
    // Navigator.pushNamed(
    //   context ?? AppKeys.navigatorKey.currentContext!,
    //   route,
    //   arguments: args,
    // );
  }

  static Future<void> asyncNavigate(String route) async {
    await Modular.to.pushNamed(route);
  }

  static void push(
    String route, {
    Map<String, dynamic> args = const {'': null},
  }) {
    Modular.to.pushNamed(route, arguments: args);
    // AppKeys.navigatorKey.currentState?.pushNamed(route, arguments: args);
    // Navigator.pushNamed(
    //   context ?? AppKeys.navigatorKey.currentContext!,
    //   route,
    //   arguments: args,
    // );
  }

  /// navigate replace
  static void replace(
    String route, {
    Map<String, dynamic> args = const {'': null},
  }) {
    // Navigator.pushReplacementNamed(
    //   AppKeys.navigatorKey.currentContext!,
    //   route,
    //   arguments: args,
    // );
    // AppKeys.navigatorKey.currentState?.pushReplacementNamed(route, arguments: args);
    Modular.to.pushReplacementNamed(route, arguments: args);
  }

  /// navigate reset
  static void reset(
    String route, {
    Map<String, dynamic> args = const {'': null},
  }) {
    // Navigator.pushNamedAndRemoveUntil(
    //   AppKeys.navigatorKey.currentContext!,
    //   route,
    //   (route) => false,
    //   arguments: args,
    // );
    // AppKeys.navigatorKey.currentState?.pushNamedAndRemoveUntil(route, (route) => false, arguments: args);
    Modular.to.pushNamedAndRemoveUntil(
      route,
      (route) => false,
      arguments: args,
    );
  }

  static void goBack() {
    // Navigator.pop(AppKeys.navigatorKey.currentContext!);
    // AppKeys.navigatorKey.currentState?.pop();
    if (Modular.to.canPop()) {
      Modular.to.pop();
    }
  }
}
