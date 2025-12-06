import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:app/core/constants/app_keys.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/constants/app_stores.dart';
import 'package:app/core/constants/app_theme.dart';
import 'package:app/core/helpers/general_helper.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/core/utils/globals.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/modules/app/general/app_module_routes.dart';
import 'package:app/modules/auth/general/auth_module_routes.dart';
import 'package:app/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/modules/auth/presentation/bloc/auth_event.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({super.key});

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> with WidgetsBindingObserver {
  bool _firstLoad = false;
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();
  final _authBloc = Modular.get<AuthBloc>();
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    /* always open splash first */
    final accessToken = sharedPreferenceHelper.get(key: AppStores.kAccessToken);
    if (accessToken != null) {
      Modular.setInitialRoute('${AppRoutes.moduleApp}${AppModuleRoutes.main}');

      if (FirebaseAuth.instance.currentUser != null) {
        // check if accessToken is not exp
        String? accessToken = Globals.globalAccessToken;

        if (JwtDecoder.isExpired(accessToken as String)) {
          Utils.debugLogSuccess('Access token is expired');
          FirebaseAuth.instance.currentUser?.getIdToken().then((idToken) {
            Utils.debugLogSuccess('Relogin $idToken');
            _authBloc.add(
              SignInRequest(
                token: idToken!,
                type: _authBloc.state.user?.loginType,
                email:
                    FirebaseAuth.instance.currentUser?.providerData[0].email ??
                    '',
              ),
            );
          });
        } else {
          Utils.debugLogSuccess('Access token is not expired $accessToken');
          // _authBloc.add(GetDetailUserRequested());
        }
      } else {
        /* emit logout */
        // _authBloc.add(AuthLogoutRequested());
      }
    } else {
      Modular.setInitialRoute(
        '${AppRoutes.moduleAuth}${AuthModuleRoutes.signIn}',
      );
    }
    // Modular.setInitialRoute(
    //   '${AppRoutes.moduleAuth}${AuthModuleRoutes.signIn}',
    // );
    Modular.setNavigatorKey(AppKeys.navigatorKey);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: const TextScaler.linear(1)),
      child: MaterialApp.router(
        title: GeneralHelper.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        // locale: appLanguage.locale,
        scaffoldMessengerKey: AppKeys.scaffoldMessengerKey,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: Modular.routerConfig,
        localeResolutionCallback: (locale, supportedLocales) {
          if (locale == null) return supportedLocales.first;

          for (final supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }

          return supportedLocales.first; // fallback to en
        },
        localeListResolutionCallback: (locales, supportedLocales) {
          if (locales == null || locales.isEmpty) {
            return supportedLocales.first;
          }

          for (final locale in locales) {
            for (final supported in supportedLocales) {
              if (supported.languageCode == locale.languageCode) {
                return supported;
              }
            }
          }

          return supportedLocales.first; // fallback to en
        },
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Utils.debugLog('AppLifecycleState: $state');
    if (state == AppLifecycleState.resumed) {
      // get common data
      // Modular.get<AppBloc>().add(AppConfigRequested());
    }
    super.didChangeAppLifecycleState(state);
  }
}
