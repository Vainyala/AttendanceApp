import 'package:attendanceapp/manager/core/view_models/theme_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/button_view_model.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonState = Provider.of<ButtonState>(context);
    final actualIsLoading = isLoading || buttonState.isLoading;
    final actualIsDisabled = isDisabled || buttonState.isDisabled;

    return ElevatedButton(
      onPressed: actualIsDisabled || actualIsLoading ? null : onPressed,
      style: AppButtonStyles.primary(context),
      child: actualIsLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonState = Provider.of<ButtonState>(context);
    final actualIsLoading = isLoading || buttonState.isLoading;
    final actualIsDisabled = isDisabled || buttonState.isDisabled;

    return ElevatedButton(
      onPressed: actualIsDisabled || actualIsLoading ? null : onPressed,
      style: AppButtonStyles.secondary(context),
      child: actualIsLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  const CustomOutlineButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonState = Provider.of<ButtonState>(context);
    final actualIsLoading = isLoading || buttonState.isLoading;
    final actualIsDisabled = isDisabled || buttonState.isDisabled;

    return OutlinedButton(
      onPressed: actualIsDisabled || actualIsLoading ? null : onPressed,
      style: AppButtonStyles.outline(context),
      child: actualIsLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? textColor;

  const CustomTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonState = Provider.of<ButtonState>(context);
    final actualIsLoading = isLoading || buttonState.isLoading;
    final actualIsDisabled = isDisabled || buttonState.isDisabled;

    return TextButton(
      onPressed: actualIsDisabled || actualIsLoading ? null : onPressed,
      style: AppButtonStyles.text(context),
      child: actualIsLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  textColor ?? AppColors.primary,
                ),
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.primary,
              ),
            ),
    );
  }
}
