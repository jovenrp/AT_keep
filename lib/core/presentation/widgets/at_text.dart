import 'package:flutter/cupertino.dart';
import 'package:keep/core/domain/utils/constants/app_colors.dart';

class ATText extends StatelessWidget {
  const ATText({Key? key, this.text, this.overflow, this.fontColor, this.fontSize, this.style, this.weight, this.textAlign}) : super(key: key);

  final String? text;
  final TextOverflow? overflow;
  final Color? fontColor;
  final double? fontSize;
  final TextStyle? style;
  final FontWeight? weight;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(text ?? '',
        overflow: overflow,
        textAlign: textAlign ?? TextAlign.left,
        style: style ?? TextStyle(color: fontColor ?? AppColors.black, fontSize: fontSize ?? 14, fontWeight: weight ?? FontWeight.normal));
  }
}
