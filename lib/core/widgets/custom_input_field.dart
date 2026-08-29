import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode autovalidateMode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.focusNode,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;
  FormFieldState<String>? _fieldState;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void didUpdateWidget(CustomInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _internalFocusNode.removeListener(_onFocusChange);
        _internalFocusNode.dispose();
      }
      _internalFocusNode = widget.focusNode ?? FocusNode();
      _internalFocusNode.addListener(_onFocusChange);
    }
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onControllerChange);
      widget.controller.addListener(_onControllerChange);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    if (widget.focusNode == null) {
      _internalFocusNode.removeListener(_onFocusChange);
      _internalFocusNode.dispose();
    } else {
      _internalFocusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  void _onControllerChange() {
    if (_fieldState != null && _fieldState!.value != widget.controller.text) {
      _fieldState!.didChange(widget.controller.text);
      if (_fieldState!.hasError) {
        _fieldState!.validate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator != null
          ? (value) => widget.validator!(widget.controller.text)
          : null,
      autovalidateMode: widget.autovalidateMode,
      builder: (FormFieldState<String> fieldState) {
        _fieldState = fieldState;
        final bool hasError = fieldState.hasError &&
            fieldState.errorText != null &&
            fieldState.errorText!.isNotEmpty;
        final String? errorText = fieldState.errorText;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                      child: hasError
                          ? Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 13,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      errorText ?? '',
                                      key: ValueKey<String>(errorText ?? ''),
                                      style: GoogleFonts.nunito(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.error,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasError
                      ? AppColors.error.withValues(alpha: 0.55)
                      : (_isFocused
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : Colors.transparent),
                  width: 1.2,
                ),
                boxShadow: hasError
                    ? [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : (_isFocused
                        ? const [
                            BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]),
              ),
              child: TextField(
                controller: widget.controller,
                focusNode: _internalFocusNode,
                obscureText: widget.isPassword ? _obscureText : false,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onFieldSubmitted,
                onChanged: (val) {
                  fieldState.didChange(val);
                  if (fieldState.hasError) {
                    fieldState.validate();
                  }
                  widget.onChanged?.call(val);
                },
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 14.5,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 17,
                  ),
                  suffixIcon: widget.isPassword
                      ? IconButton(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              _obscureText
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              key: ValueKey<bool>(_obscureText),
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
