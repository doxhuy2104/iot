import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:app/core/components/app_dialog.dart';
import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/components/buttons/primary_button.dart';
import 'package:app/core/components/inputs/text_input.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_dimensions.dart';
import 'package:app/core/constants/app_icons.dart';
import 'package:app/core/constants/app_images.dart';
import 'package:app/core/constants/app_routes.dart';
import 'package:app/core/constants/app_styles.dart';
import 'package:app/core/constants/app_validator.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/extensions/num_extension.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/core/helpers/auth_helper.dart';
import 'package:app/core/helpers/navigation_helper.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/app/general/app_module_routes.dart';
import 'package:app/modules/app/presentation/bloc/app_bloc.dart';
import 'package:app/modules/auth/presentation/bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      // appBar: AppBar(title: Text(con, style: Styles.h3.smb)),
      body: Stack(
        children: [
          // Image.asset(AppImages.imgLogo),
          Positioned(
            top: AppDimensions.insetTop(context),
            left: 8,
            child: Row(
              children: [
                Button(
                  borderRadius: BorderRadius.circular(44),
                  onPress: () {
                    NavigationHelper.goBack();
                  },
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: SvgPicture.asset(
                      width: 10,
                      AppIcons.icArrowLeft,
                      colorFilter: ColorFilter.mode(
                        Colors.black,
                        BlendMode.srcIn,
                      ),
                    ).paddingAll(8),
                  ),
                ),
                Text(
                  context.localization.forgotPasswordT,
                  style: Styles.h3.smb,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.localization.email, style: Styles.large.regular),
                  4.verticalSpace,

                  TextInput(
                    formKey: _formKey,

                    errorMessage: context.localization.invalidEmail,
                    controller: _emailController,
                    placeholder: context.localization.enterEmail,
                    icon: SvgPicture.asset(
                      AppIcons.icEmail,
                      colorFilter: ColorFilter.mode(
                        AppColors.secondaryText,
                        BlendMode.srcIn,
                      ),
                    ),
                    validator: AppValidator.validateEmail,
                  ),
                  20.verticalSpace,

                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      onPress: () async {
                        final process = _formKey.currentState?.validate();

                        if (process!) {
                          try {
                            await AuthHelper.sendForgotPasswordEmail(
                              _emailController.text,
                            );

                            if (mounted) {
                              AppDialog.show(
                                title: context.localization.success,
                                type: AppDialogType.success,
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            Utils.debugLogError(e.code);
                            AppDialog.show(
                              title: '',
                              message: e.code,
                              type: AppDialogType.failed,
                            );
                          } catch (e) {
                            Utils.debugLogError(e);
                          }
                        }
                      },
                      text: context.localization.sendEmail,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
