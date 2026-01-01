import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app/core/constants/app_colors.dart';
import 'package:app/core/constants/app_icons.dart';
import 'package:app/core/constants/app_styles.dart';
import 'package:app/core/extensions/widget_extension.dart';
import 'package:app/core/utils/utils.dart';

class TextInput extends StatefulWidget {
  final TextInputType? keyboardType;
  final String? initialText;
  final String? placeholder;
  final TextEditingController? controller;
  final bool Function(String)? validator;
  final Widget? icon;
  final double? height;
  final String? errorMessage;
  final FocusNode? focusNode;
  final bool isSecure;
  final GlobalKey<FormState>? formKey;
  final TextInputAction? textInputAction;
  final FocusNode? nextFocusNode;
  const TextInput({
    super.key,
    this.keyboardType,
    this.initialText,
    this.placeholder,
    this.controller,
    this.icon,
    this.validator,
    this.height,
    this.errorMessage,
    this.focusNode,
    this.isSecure = false,
    this.formKey,
    this.textInputAction,
    this.nextFocusNode,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  String _errorMessage = '';
  late FocusNode _focus;
  bool _isFocused = false;
  bool _showClearIcon = false;

  bool _isHide = true;
  void _setFocusState() {
    if (_focus.hasFocus == false) {
      setState(() {
        _isFocused = false;
      });
    } else {
      setState(() {
        _isFocused = true;
      });
    }
  }

  void _setShowClearIcon() {
    if (_focus.hasFocus == false || widget.controller?.text == "") {
      setState(() {
        _showClearIcon = false;
      });
    } else {
      setState(() {
        _showClearIcon = true;
      });
    }
  }

  void _clearInput() {
    widget.controller?.clear();
    setState(() {
      _errorMessage = '';
    });
  }

  @override
  void initState() {
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(() {
      if (mounted) {
        _setFocusState();
        _setShowClearIcon();
      }
      if (_focus.hasFocus) {
        if (_errorMessage.isNotEmpty) {
          Future.delayed(Duration(milliseconds: 50), () {
            widget.formKey?.currentState!.reset();
          });
        }
      }
    });
    widget.controller?.addListener(_onChange);

    super.initState();
  }

  void _onChange() {
    if (mounted) {
      _setShowClearIcon();
      _setFocusState();
    }
    // _onSubmit();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focus.dispose();
    }
    widget.controller?.removeListener(_onChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadiusGeometry.circular(20),
          child: GestureDetector(
            onTap: () {
              _focus.requestFocus();
            },
            child: Container(
              height: widget.height ?? 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _errorMessage.isNotEmpty
                      ? AppColors.fail
                      : _isFocused
                      ? AppColors.primary
                      : AppColors.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.icon != null) ...[
                    Padding(
                      padding: EdgeInsets.only(left: 24, right: 8),
                      child: Center(child: widget.icon!),
                    ),
                  ],
                  Expanded(
                    child: TextFormField(
                      controller: widget.controller,
                      textAlignVertical: TextAlignVertical.center,
                      style: Styles.medium.regular,
                      onTapOutside: (event) => Utils.hideKeyboard(),
                      cursorColor: AppColors.primary,
                      keyboardType: widget.keyboardType,

                      validator: (value) {
                        Utils.debugLog(value);
                        bool isTrue =
                            widget.validator?.call(value ?? '') ?? true;
                        String errorMessage = !isTrue
                            ? widget.errorMessage ?? ""
                            : "";
                        setState(() {
                          _errorMessage = errorMessage;
                        });

                        return errorMessage.isEmpty ? null : errorMessage;
                      },
                      focusNode: _focus,
                      onChanged: (value) {
                        // widget.validator?.call(value);
                        if (_errorMessage.isNotEmpty) {
                          setState(() {
                            _errorMessage = '';
                          });
                        }
                      },
                      obscureText: widget.isSecure ? _isHide : false,
                      textInputAction: widget.textInputAction,
                      onFieldSubmitted: (_) {
                        if (widget.textInputAction == TextInputAction.next) {
                          if (widget.nextFocusNode != null) {
                            widget.nextFocusNode!.requestFocus();
                          } else {
                            FocusScope.of(context).nextFocus();
                          }
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 13,
                          bottom: 13,
                          left: 12,
                          right: 12,
                        ),
                        errorText: null, // or null
                        errorStyle: TextStyle(
                          height: 0, // 👈 hides error text layout
                          fontSize: 0.001, // 👈 makes it invisible
                          color: Colors.transparent, // 👈 hide just in case
                        ),
                        hintText: widget.placeholder,
                        hintStyle: Styles.medium.secondary,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        isCollapsed: false,
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _showClearIcon
                                ? SizedBox(
                                    height: 44,
                                    width: 44,
                                    child: IconButton(
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      icon: SvgPicture.asset(
                                        AppIcons.icClose,
                                        width: 20,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.black,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                      onPressed: _clearInput,
                                    ),
                                  )
                                : SizedBox.shrink(),
                            widget.isSecure && _showClearIcon
                                ? Text('|')
                                : SizedBox.shrink(),
                            widget.isSecure
                                ? _isHide
                                      ? SizedBox(
                                          height: 44,
                                          width: 44,
                                          child: IconButton(
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: SvgPicture.asset(
                                              AppIcons.icHide,
                                              width: 20,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isHide = !_isHide;
                                              });
                                            },
                                          ),
                                        )
                                      : SizedBox(
                                          height: 44,
                                          width: 44,
                                          child: IconButton(
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: SvgPicture.asset(
                                              AppIcons.icShow,
                                              width: 20,
                                              height: 20,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isHide = !_isHide;
                                              });
                                            },
                                          ),
                                        )
                                : SizedBox.shrink(),
                          ],
                        ),
                        // icon: widget.icon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 52,
          child: Container(
            child: _errorMessage.isNotEmpty
                ? Text(
                    _errorMessage,
                    style: const TextStyle(fontSize: 11, color: AppColors.fail),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
