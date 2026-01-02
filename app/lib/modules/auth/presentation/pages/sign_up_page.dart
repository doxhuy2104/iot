import 'package:app/core/components/app_annotated_region.dart';
import 'package:app/core/components/app_dialog.dart';
import 'package:app/core/components/app_indicator.dart';
import 'package:app/core/components/buttons/button.dart';
import 'package:app/core/components/buttons/primary_button.dart';
import 'package:app/core/components/inputs/text_input.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_dimensions.dart';
import 'package:app/core/constants/app_icons.dart';
import 'package:app/core/constants/app_styles.dart';
import 'package:app/core/constants/app_validator.dart';
import 'package:app/core/extensions/localized_extension.dart';
import 'package:app/core/extensions/num_extension.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/core/helpers/navigation_helper.dart';
import 'package:app/core/helpers/shared_preference_helper.dart';
import 'package:app/core/utils/utils.dart';
import 'package:app/modules/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/modules/auth/presentation/bloc/auth_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final sharedPreferenceHelper = Modular.get<SharedPreferenceHelper>();
  final _emailFocusNode = FocusNode();
  final _usernameFocusNode = FocusNode();

  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _authBloc = Modular.get<AuthBloc>();
  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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
              top:
                  AppDimensions.insetTop(context) -
                  AppDimensions.keyboardHeight(context),
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
                  Text(context.localization.signUp, style: Styles.h3.smb),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: AppDimensions.keyboardHeight(context),
                left: 16,
                right: 16,
              ),
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
                      focusNode: _emailFocusNode,
                      nextFocusNode: _usernameFocusNode,
                    ),
                    16.verticalSpace,

                    Text('Tên đăng nhập', style: Styles.large.regular),
                    4.verticalSpace,
                    TextInput(
                      formKey: _formKey,
                      errorMessage: 'Tên đăng nhập phải từ 3-50 ký tự',
                      controller: _usernameController,
                      placeholder: 'Nhập tên đăng nhập',
                      icon: Icon(
                        Icons.person_outline,
                        color: AppColors.secondaryText,
                      ),
                      validator: (value) {
                        return value.length >= 3;
                      },
                      textInputAction: TextInputAction.next,
                      focusNode: _usernameFocusNode,
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
                      focusNode: _passwordFocusNode,
                      nextFocusNode: _confirmPasswordFocusNode,
                      textInputAction: TextInputAction.next,
                    ),

                    16.verticalSpace,
                    Text(
                      context.localization.confirmPassword,
                      style: Styles.large.regular,
                    ),
                    4.verticalSpace,

                    TextInput(
                      formKey: _formKey,
                      errorMessage: context.localization.confirmPasswordError,
                      controller: _confirmPasswordController,
                      placeholder: context.localization.enterConfirmPassword,
                      icon: SvgPicture.asset(
                        AppIcons.icLock,
                        colorFilter: ColorFilter.mode(
                          AppColors.secondaryText,
                          BlendMode.srcIn,
                        ),
                      ),
                      validator: (value) => _passwordController.text == value,
                      isSecure: true,
                      focusNode: _confirmPasswordFocusNode,
                      textInputAction: TextInputAction.done,
                    ),

                    20.verticalSpace,

                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPress: () async {
                          final process = _formKey.currentState?.validate();

                          if (process!) {
                            AppIndicator.show();

                            try {
                              // final rt = await AuthHelper.registerWithPassword(
                              //   emailAddress: _emailController.text,
                              //   password: _passwordController.text,
                              // );
                              // if (rt?.user != null) {
                              //   Utils.debugLog(
                              //     'Register success rt:${rt?.user?.email}',
                              //   );
                              _authBloc.add(
                                SignUpRequest(
                                  email: _emailController.text,
                                  username: _usernameController.text,
                                  password: _passwordController.text,
                                ),
                              );
                              // if (mounted) {
                              //   AppDialog.show(
                              //     dismissible: false,
                              //     title: context.localization.register_success,
                              //     // message: '',
                              //     type: AppDialogType.success,
                              //     confirmText: context.localization.signIn,
                              //     onConfirm: () {
                              //       NavigationHelper.replace(
                              //         '${AppRoutes.moduleAuth}${AuthModuleRoutes.signIn}',
                              //       );
                              //     },
                              //   );
                              // }
                              // }
                            } on FirebaseAuthException catch (e) {
                              Utils.debugLogError(e.code);

                              switch (e.code) {
                                case 'email-already-in-use':
                                  AppDialog.show(
                                    title: context.localization.emailInUse,
                                    // message: '',
                                    type: AppDialogType.failed,
                                  );
                                  break;
                                // case 'weak-password':
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
                              AppDialog.show(
                                title: context.localization.errorTitle,
                                message: e.toString(),
                                type: AppDialogType.failed,
                              );
                            } finally {}
                          }
                        },
                        text: context.localization.signUp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: AppDimensions.insetBottom(context) + 16,
              left: 0,
              right: 0,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '${context.localization.haveAccount} ',
                  style: Styles.normal.regular,
                  children: [
                    TextSpan(
                      text: context.localization.signIn,
                      style: Styles.normal.regular.copyWith(
                        color: AppColors.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          NavigationHelper.goBack();
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
