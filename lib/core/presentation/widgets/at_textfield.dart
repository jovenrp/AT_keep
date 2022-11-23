import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keep/core/domain/utils/constants/app_colors.dart';

class ATTextfield extends StatefulWidget {
  const ATTextfield({
    Key? key,
    this.hintText,
    this.isPasswordField = false,
    this.isNumbersOnly = false,
    this.isSuffixIcon = false,
    this.onFieldSubmitted,
    this.textInputAction = TextInputAction.done,
    this.textAlign = TextAlign.left,
    this.textEditingController,
    this.focusNode,
  }) : super(key: key);

  final String? hintText;
  final bool isPasswordField;
  final bool isSuffixIcon;
  final TextAlign? textAlign;
  final TextInputAction? textInputAction;
  final Function(String?)? onFieldSubmitted;
  final TextEditingController? textEditingController;
  final FocusNode? focusNode;
  final bool isNumbersOnly;

  @override
  _ATTextfield createState() => _ATTextfield();
}

class _ATTextfield extends State<ATTextfield> {
  bool _passwordNotVisible = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: TextFormField(
        controller: widget.textEditingController,
        focusNode: widget.focusNode,
        key: widget.key,
        obscureText: widget.isPasswordField ? _passwordNotVisible : false,
        onFieldSubmitted: widget.onFieldSubmitted,
        textAlign: widget.textAlign ?? TextAlign.center,
        textInputAction: widget.textInputAction,
        inputFormatters: widget.isNumbersOnly
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'[.\-0-9]')),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    final text = newValue.text;
                    if (text.isNotEmpty) double.parse(text);
                    return newValue;
                  } catch (e) {
                    log(e.toString());
                  }
                  return oldValue;
                })
              ]
            : [],
        style: const TextStyle(fontSize: 14, color: AppColors.primary),
        decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.textFieldBorder, width: 1.0),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide:
                  BorderSide(color: AppColors.textFieldBorder, width: 1.0),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4.0),
                borderSide: const BorderSide(color: AppColors.atWarningRed)),
            hintStyle: const TextStyle(color: AppColors.onSecondary),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //hintText: widget.hintText ?? 'Enter a text here',
            labelText: widget.hintText ?? 'Enter a text here',
            labelStyle: const TextStyle(fontSize: 14.0, height: 1),
            alignLabelWithHint: true,
            fillColor: AppColors.white,
            filled: true,
            suffixIcon: widget.isSuffixIcon
                ? IconButton(
                    icon: widget.isPasswordField
                        ? Icon(
                            // Based on passwordVisible state choose the icon
                            _passwordNotVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Theme.of(context).primaryColorDark,
                          )
                        : Icon(Icons.clear,
                            color: Theme.of(context).primaryColorDark),
                    onPressed: widget.isPasswordField
                        ? () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordNotVisible = !_passwordNotVisible;
                            });
                          }
                        : () {
                            setState(() {
                              widget.textEditingController?.clear();
                            });
                          },
                  )
                : null),
      ),
    );
  }
}
