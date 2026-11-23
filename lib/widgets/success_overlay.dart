import '../l10n.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void showSuccessOverlay(
  BuildContext context, {
  String message = 'تمت الإضافة بنجاح',
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black45,
    builder: (_) => _SuccessDialog(message: message),
  );
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog({required this.message});
  final String message;

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog> {
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/lottie/success.json',
              width: 140,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(
                  composition.duration + Duration(milliseconds: 500),
                  () {
                    if (mounted) navigator.pop();
                  },
                );
              },
            ),
            AppText(
              widget.message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
