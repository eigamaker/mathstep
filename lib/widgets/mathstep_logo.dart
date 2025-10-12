import 'package:flutter/material.dart';

class MathstepLogo extends StatelessWidget {
  final double? fontSize;
  final Color? textColor;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final TextAlign? textAlign;

  const MathstepLogo({
    super.key,
    this.fontSize,
    this.textColor,
    this.fontWeight,
    this.letterSpacing,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          textColor ?? Colors.white,
          (textColor ?? Colors.white).withValues(alpha: 0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        'Mathstep',
        style: TextStyle(
          fontSize: fontSize ?? 32,
          fontWeight: fontWeight ?? FontWeight.bold,
          color: textColor ?? Colors.white,
          letterSpacing: letterSpacing ?? 2,
          shadows: [
            Shadow(
              color: (textColor ?? Colors.white).withValues(alpha: 0.3),
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        textAlign: textAlign ?? TextAlign.center,
      ),
    );
  }
}
