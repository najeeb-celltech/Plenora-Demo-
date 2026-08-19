import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double height;
  final double borderRadius;
  final bool isLoading;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textWhite,
    this.leadingIcon,
    this.trailingIcon,
    this.height = 54.0,
    this.borderRadius = 30.0,
    this.isLoading = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0),
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null && !widget.isLoading;
    final bool isSmall = widget.height <= 40;
    final bool isExtraSmall = widget.height <= 30;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: enabled && widget.backgroundColor == AppColors.primary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.22),
                    blurRadius: isSmall ? 6 : 16,
                    offset: Offset(0, isSmall ? 2 : 6),
                  ),
                ]
              : const [],
        ),
        child: GestureDetector(
          onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
          onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.textColor,
              elevation: 0,
              padding: widget.padding,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                side: BorderSide.none,
              ),
            ),
            child: widget.isLoading
                ? SizedBox(
                    width: isSmall ? 16 : 22,
                    height: isSmall ? 16 : 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(widget.textColor),
                    ),
                  )
                : FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.leadingIcon != null) ...[
                          Icon(
                            widget.leadingIcon,
                            size: isExtraSmall ? 12 : (isSmall ? 13.5 : 18),
                            color: widget.textColor,
                          ),
                          SizedBox(width: isSmall ? 4 : 8),
                        ],
                        Text(
                          widget.text,
                          style: AppTypography.buttonText.copyWith(
                            color: widget.textColor,
                            fontSize: isExtraSmall
                                ? 11.5
                                : (isSmall ? 12.5 : 15.5),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (widget.trailingIcon != null) ...[
                          SizedBox(width: isSmall ? 4 : 8),
                          Icon(
                            widget.trailingIcon,
                            size: isExtraSmall ? 12 : (isSmall ? 13.5 : 18),
                            color: widget.textColor,
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
