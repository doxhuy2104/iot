import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';
import 'package:app/core/components/app_annotated_region.dart';
import 'package:app/core/components/app_dialog.dart';
import 'package:app/core/components/app_indicator.dart';
import 'package:app/core/components/buttons/secondary_button.dart';
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
import 'package:app/modules/auth/general/auth_module_routes.dart';
import 'package:app/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/modules/auth/presentation/bloc/auth_event.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();
  final _authBloc = Modular.get<AuthBloc>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppAnnotatedRegion(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.background,
        // appBar: AppBar(
        //   title: Text(context.localization.signIn, style: Styles.h3.smb),
        // ),
        body: Stack(
          children: [
            // Image.asset(AppImages.imgLogo),
            Positioned(
              top: AppDimensions.insetTop(context),
              left: 16,
              child: Text(context.localization.signIn, style: Styles.h3.smb),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.localization.email,
                      style: Styles.large.regular,
                    ),
                    4.verticalSpace,
                    TextInput(
                      formKey: _formKey,
                      errorMessage: context.localization.invalidEmail,
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      placeholder: context.localization.enterEmail,
                      icon: SvgPicture.asset(
                        AppIcons.icEmail,
                        colorFilter: ColorFilter.mode(
                          AppColors.secondaryText,
                          BlendMode.srcIn,
                        ),
                      ),
                      validator: AppValidator.validateEmail,
                      textInputAction: TextInputAction.next,
                      nextFocusNode: _passwordFocusNode,
                    ),

                    16.verticalSpace,
                    Text(
                      context.localization.password,
                      style: Styles.large.regular,
                    ),
                    4.verticalSpace,

                    TextInput(
                      formKey: _formKey,

                      errorMessage: context.localization.passwordMustLeast8Char,
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      placeholder: context.localization.enterPassword,
                      icon: SvgPicture.asset(
                        AppIcons.icLock,
                        colorFilter: ColorFilter.mode(
                          AppColors.secondaryText,
                          BlendMode.srcIn,
                        ),
                      ),
                      validator: AppValidator.validatePassword,
                      isSecure: true,
                      textInputAction: TextInputAction.done,
                    ),
                    8.verticalSpace,
                    Container(
                      width: double.infinity,
                      alignment: AlignmentGeometry.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          NavigationHelper.push(
                            '${AppRoutes.moduleAuth}${AuthModuleRoutes.forgotPassword}',
                          );
                        },
                        child: Text(
                          context.localization.forgotPassword,
                          style: Styles.medium.regular.copyWith(
                            color: AppColors.contentText,
                          ),
                        ).paddingSymmetric(v: 4),
                      ),
                    ),
                    16.verticalSpace,

                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPress: () async {
                          final process = _formKey.currentState?.validate();
                          if (process!) {
                            try {
                              AppIndicator.show();
                              final rt = await AuthHelper.signInWithPassword(
                                emailAddress: _emailController.text,
                                password: _passwordController.text,
                              );

                              String? token;
                              if (rt?.user != null) {
                                Utils.debugLog(
                                  'Login email idToken:${token = await rt?.user?.getIdToken()}',
                                );
                              }
                              _authBloc.add(
                                SignInRequest(
                                  email: _emailController.text,
                                  token: token ?? '',
                                  type: 'email',
                                ),
                              );
                            } on FirebaseAuthException catch (e) {
                              Utils.debugLogError(e.code);
                              // switch case show e.code: sign-in
                              switch (e.code) {
                                case 'invalid-credential':
                                  AppDialog.show(
                                    title: context
                                        .localization
                                        .invalidEmailOrPassword,
                                    // message: '',
                                    type: AppDialogType.failed,
                                  );
                                  break;
                                // case 'account-exists-with-different-credential':
                                //   AppDialog.show(
                                //     title: '',
                                //     message: '',
                                //     type: AppDialogType.failed,
                                //     confirmText: '',
                                //   );
                                //   break;
                                default:
                                  AppDialog.show(
                                    title: context.localization.errorTitle,
                                    message: e.code,
                                    type: AppDialogType.failed,
                                  );
                                  break;
                              }
                            } catch (e) {
                              Utils.debugLogError(e);
                            } finally {
                              AppIndicator.hide();
                            }
                          }
                        },
                        text: context.localization.signIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: AppDimensions.insetBottom(context) + 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 1,
                        decoration: BoxDecoration(color: AppColors.contentText),
                      ),
                      Text(
                        context.localization.ortherLogin,
                        style: Styles.medium.regular.copyWith(
                          color: AppColors.contentText,
                        ),
                      ).paddingSymmetric(h: 8),
                      Container(
                        width: 60,
                        height: 1,
                        decoration: BoxDecoration(color: AppColors.contentText),
                      ),
                    ],
                  ),
                  12.verticalSpace,
                  SecondaryButton(
                    widget: Stack(
                      children: [
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: SvgPicture.asset(AppIcons.icGoogle),
                        ),
                        Center(child: Text(context.localization.googleLogin)),
                      ],
                    ),
                    onPress: () async {
                      try {
                        AppIndicator.show();
                        final rt = await AuthHelper.signInWithGoogle();
                        String? token;
                        if (rt.user != null) {
                          Utils.debugLogSuccess(
                            'Login google. idToken: ${token = await rt.user?.getIdToken()}',
                          );

                          _authBloc.add(
                            SignInRequest(token: token!, type: 'GOOGLE'),
                          );
                        }
                      } catch (e) {
                        Utils.debugLogError(e);
                      } finally {
                        AppIndicator.hide();
                      }
                    },
                  ),
                  24.verticalSpace,
                  RichText(
                    text: TextSpan(
                      text: '${context.localization.dontHaveAccount} ',
                      style: Styles.normal.regular,
                      children: [
                        TextSpan(
                          text: context.localization.signUp,
                          style: Styles.normal.regular.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              NavigationHelper.navigate(
                                '${AppRoutes.moduleAuth}${AuthModuleRoutes.signUp}',
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
