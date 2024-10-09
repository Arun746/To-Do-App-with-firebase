// lib/widgets/snack_bar_widgets.dart

import 'package:flutter/material.dart';

class SnackBarMsg {
  static void showSuccess(BuildContext context, String message, int stime) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        duration: Duration(seconds: stime),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message, int stime) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        duration: Duration(seconds: stime),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
