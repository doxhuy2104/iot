import 'package:app/modules/account/presentation/pages/account_page.dart';
import 'package:app/modules/zone/presentation/pages/zone_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:app/core/components/app_annotated_region.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_icons.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/modules/app/general/app_module_routes.dart';
import 'package:app/modules/app/presentation/components/title_navigation_bar/navigation_bar.dart';
import 'package:app/modules/app/presentation/components/title_navigation_bar/navigation_bar_item.dart';
import 'package:app/modules/home/presentation/pages/home_page.dart';
import 'package:preload_page_view/preload_page_view.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late PreloadPageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    _pageController = PreloadPageController();

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();

    super.dispose();
  }

  List<Widget> _pageViews() {
    return [HomePage(), ZonePage(), AccountPage()];
  }

  void navigatePageView(int value) {
    _pageController.jumpToPage(value);
  }

  @override
  String get routePath => '${AppRoutes.moduleApp}${AppModuleRoutes.main}';

  @override
  onFocus() {
    final args = Modular.args;
    if (args.data != null) {
      int? index = args.data['tabIndex'] is int
          ? args.data['tabIndex']
          : int.tryParse(args.data['tabIndex'] ?? '');

      if (index != null) {
        navigatePageView(index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppAnnotatedRegion(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PreloadPageView(
          pageSnapping: true,
          controller: _pageController,
          preloadPagesCount: 2,
          // physics: const NeverScrollableScrollPhysics(),
          children: _pageViews(),
          onPageChanged: (value) {
            setState(() {
              _currentIndex = value;
            });
          },
        ),
        extendBody: true,
        bottomNavigationBar: TitledBottomNavigationBar(
          onTap: (value) {
            navigatePageView(value);
          },
          inactiveColor: Colors.white,
          activeColor: AppColors.primary,
          indicatorColor: Colors.transparent,
          currentIndex: _currentIndex,
          items: [
            TitledNavigationBarItem(
              iconPath: AppIcons.icHomeInactive,
              activeIconPath: AppIcons.icHomeActive,
              title: context.localization.home,
            ),
            TitledNavigationBarItem(
              icon: Icons.grid_view_outlined,
              activeIcon: Icons.grid_view_sharp,
              title: context.localization.zone,
            ),
            TitledNavigationBarItem(
              iconPath: AppIcons.icAccountInactive,
              activeIconPath: AppIcons.icAccountActive,
              title: context.localization.account,
            ),
            // TitledNavigationBarItem(
            //   iconPath: AppIcons.icAccountInactive,
            //   activeIconPath: AppIcons.icAccountActive,
            //   title: context.localization.account,
            // ),
          ],
        ),
      ),
    );
  }
}
