import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:ebroker/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CustomTextFieldValidator {
  nullCheck,
  phoneNumber,
  email,
  password,
  maxFifty,
  link,
  slugId
}

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.hintText,
    this.controller,
    this.minLine,
    this.maxLine,
    this.formaters,
    this.isReadOnly,
    this.validator,
    this.fillColor,
    this.onChange,
    this.prefix,
    this.keyboard,
    this.action,
    this.suffix,
    this.dense,
    this.autovalidate,
    this.textDirection,
  });

  final String? hintText;
  final TextEditingController? controller;
  final int? minLine;
  final int? maxLine;
  final AutovalidateMode? autovalidate;
  final bool? isReadOnly;
  final List<TextInputFormatter>? formaters;
  final CustomTextFieldValidator? validator;
  final Color? fillColor;
  final Function(dynamic value)? onChange;
  final Widget? prefix;
  final TextInputAction? action;
  final TextInputType? keyboard;
  final Widget? suffix;
  final bool? dense;
  final TextDirection? textDirection;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      textDirection: textDirection,
      controller: controller,
      autovalidateMode: autovalidate,
      inputFormatters: formaters,
      textInputAction: action,
      keyboardAppearance: Brightness.light,
      readOnly: isReadOnly ?? false,
      style: TextStyle(fontSize: context.font.large),
      minLines: minLine ?? 1,
      maxLines: maxLine ?? 1,
      onChanged: onChange,
      validator: (String? value) {
        if (validator == CustomTextFieldValidator.slugId) {
          return Validator.validateSlugId(value);
        }
        if (validator == CustomTextFieldValidator.nullCheck) {
          return Validator.nullCheckValidator(value);
        }
        if (validator == CustomTextFieldValidator.link) {
          if (value?.isNotEmpty ?? false) {
            return Validator.validateUrl(value!);
          } else {
            return null;
          }
        }
        if (validator == CustomTextFieldValidator.maxFifty) {
          if ((value ??= '').length > 50) {
            return 'You can enter 50 letters max';
          } else {
            return null;
          }
        }
        if (validator == CustomTextFieldValidator.email) {
          return Validator.validateEmail(value);
        }
        if (validator == CustomTextFieldValidator.phoneNumber) {
          return Validator.validatePhoneNumber(value);
        }
        if (validator == CustomTextFieldValidator.password) {
          return Validator.validatePassword(value);
        }
        return null;
      },
      keyboardType: keyboard,
      decoration: InputDecoration(
        prefixIcon: prefix,
        isDense: dense,
        suffixIcon: suffix,
        hintText: hintText,
        hintStyle: TextStyle(
          color: context.color.textColorDark.withValues(alpha: 0.7),
          fontSize: context.font.large,
        ),
        filled: true,
        fillColor: fillColor ?? context.color.secondaryColor,
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(width: 1.5, color: context.color.tertiaryColor),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: context.color.borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(width: 1.5, color: context.color.borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
