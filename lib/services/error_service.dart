import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorService {
  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_outlined, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[600],
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Confirm',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.pop(context);
  }

  // Show retry dialog
  static Future<bool?> showRetryDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.refresh, color: Colors.orange),
            SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Retry',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Handle network errors
  static void handleNetworkError(BuildContext context) {
    showErrorSnackBar(
      context,
      'Network error. Please check your internet connection.',
    );
  }

  // Handle authentication errors
  static void handleAuthError(BuildContext context, String message) {
    showErrorSnackBar(context, 'Authentication error: $message');
  }

  // Handle database errors
  static void handleDatabaseError(BuildContext context, String message) {
    showErrorSnackBar(context, 'Database error: $message');
  }

  // Handle validation errors
  static void handleValidationError(BuildContext context, String message) {
    showWarningSnackBar(context, 'Validation error: $message');
  }

  // Handle permission errors
  static void handlePermissionError(BuildContext context, String message) {
    showWarningSnackBar(context, 'Permission error: $message');
  }

  // Handle file errors
  static void handleFileError(BuildContext context, String message) {
    showErrorSnackBar(context, 'File error: $message');
  }

  // Handle camera errors
  static void handleCameraError(BuildContext context, String message) {
    showErrorSnackBar(context, 'Camera error: $message');
  }

  // Handle location errors
  static void handleLocationError(BuildContext context, String message) {
    showErrorSnackBar(context, 'Location error: $message');
  }

  // Handle notification errors
  static void handleNotificationError(BuildContext context, String message) {
    showWarningSnackBar(context, 'Notification error: $message');
  }

  // Handle payment errors
  static void handlePaymentError(BuildContext context, String message) {
    showErrorSnackBar(context, 'Payment error: $message');
  }

  // Handle appointment errors
  static void handleAppointmentError(BuildContext context, String message) {
    showErrorSnackBar(context, 'Appointment error: $message');
  }

  // Handle doctor errors
  static void handleDoctorError(BuildContext context, String message) {
    showErrorSnackBar(context, 'Doctor error: $message');
  }

  // Handle user errors
  static void handleUserError(BuildContext context, String message) {
    showErrorSnackBar(context, 'User error: $message');
  }

  // Handle general errors
  static void handleGeneralError(BuildContext context, String message) {
    showErrorSnackBar(context, 'An error occurred: $message');
  }

  // Handle unknown errors
  static void handleUnknownError(BuildContext context) {
    showErrorSnackBar(
      context,
      'An unknown error occurred. Please try again later.',
    );
  }

  // Handle timeout errors
  static void handleTimeoutError(BuildContext context) {
    showErrorSnackBar(context, 'Request timed out. Please try again.');
  }

  // Handle server errors
  static void handleServerError(BuildContext context, int statusCode) {
    String message;
    switch (statusCode) {
      case 400:
        message = 'Bad request. Please check your input.';
        break;
      case 401:
        message = 'Unauthorized. Please sign in again.';
        break;
      case 403:
        message =
            'Forbidden. You don\'t have permission to perform this action.';
        break;
      case 404:
        message = 'Not found. The requested resource was not found.';
        break;
      case 500:
        message = 'Internal server error. Please try again later.';
        break;
      case 502:
        message = 'Bad gateway. Please try again later.';
        break;
      case 503:
        message = 'Service unavailable. Please try again later.';
        break;
      default:
        message = 'Server error (${statusCode}). Please try again later.';
    }
    showErrorSnackBar(context, message);
  }
}




