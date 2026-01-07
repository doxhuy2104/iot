import 'package:app/core/components/buttons/circle_button.dart';
import 'package:app/core/components/inputs/text_input.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_dimensions.dart';
import 'package:app/core/constants/app_icons.dart';
import 'package:app/core/constants/app_images.dart';
import 'package:app/core/constants/app_styles.dart';
import 'package:app/core/extensions/num_extension.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/home/presentation/bloc/home_bloc.dart';
import 'package:app/modules/home/presentation/bloc/home_event.dart';
import 'package:app/modules/home/presentation/bloc/home_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeBloc = Modular.get<HomeBloc>();
  @override
  void initState() {
    _homeBloc.add(GetWeather());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HomeBloc, HomeState>(
        bloc: _homeBloc,
        builder: (context, state) {
          Utils.debugLog('https:${_homeBloc.state.weather?.condition?.icon}');

          return Stack(
            children: [
              Positioned(
                top: -23,
                left: 0,
                right: 0,
                child: Image.asset(AppImages.imgWeather),
              ),
              Column(
                children: [
                  AppDimensions.insetTop(context).verticalSpace,
                  Column(
                    children: [
                      Row(
                        children: [
                          CircleButton(
                            onPress: () {},
                            icon: Icon(Icons.notifications_none_outlined),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Your location',
                                  style: Styles.medium.regular.copyWith(
                                    color: Colors.white,
                                  ),
                                ),

                                4.verticalSpace,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color: Colors.deepOrange,
                                      size: 18,
                                    ),
                                    Text(
                                      '${state.location?.name}, ${state.location?.country}',
                                      style: Styles.medium.regular.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          CircleButton(
                            onPress: () {},
                            icon: Icon(Icons.notifications_none_outlined),
                          ),
                        ],
                      ),
                      24.verticalSpace,
                      TextInput(icon: Icon(Iconsax.search_normal_1_copy)),
                      54.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '23°C',
                                  style: Styles.h3.bold.copyWith(
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                                4.verticalSpace,
                                Text(
                                  '${state.location?.name}, ${state.location?.country}',
                                  style: Styles.medium.regular.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),

                            state.weather?.condition?.icon != null
                                ? Image.network(
                                    'https:${state.weather?.condition?.icon ?? '//picsum.photos/200'}',
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ).paddingAll(16),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
