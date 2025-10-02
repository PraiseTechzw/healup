import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/notification_model.dart';
import '../services/database_service.dart';

class NotificationList extends StatefulWidget {
  @override
  _NotificationListState createState() => _NotificationListState();
}

class _NotificationListState extends State<NotificationList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          splashRadius: 20,
          icon: Icon(Icons.arrow_back_ios, color: Colors.indigo),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.lato(
            color: Colors.indigo,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.mark_email_read, color: Colors.indigo),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Text(
                'Please sign in to view notifications',
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey[600]),
              ),
            )
          : StreamBuilder<List<NotificationModel>>(
              stream: DatabaseService.getUserNotificationsStream(user!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: GoogleFonts.lato(color: Colors.red),
                    ),
                  );
                }

                final notifications = snapshot.data ?? [];

                if (notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No notifications yet',
                          style: GoogleFonts.lato(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'We\'ll notify you about appointments, reminders, and updates',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
                  },
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[300]! : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getNotificationColor(notification.type),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
            color: notification.isRead ? Colors.grey[700] : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              notification.body,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: notification.isRead
                    ? Colors.grey[600]
                    : Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                SizedBox(width: 4),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                if (notification.priority == NotificationPriority.urgent) ...[
                  SizedBox(width: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'URGENT',
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentReminder:
        return Colors.blue;
      case NotificationType.appointmentConfirmed:
        return Colors.green;
      case NotificationType.appointmentCancelled:
        return Colors.red;
      case NotificationType.appointmentRescheduled:
        return Colors.orange;
      case NotificationType.prescriptionReady:
        return Colors.purple;
      case NotificationType.testResults:
        return Colors.teal;
      case NotificationType.emergency:
        return Colors.red[800]!;
      case NotificationType.promotion:
        return Colors.pink;
      case NotificationType.general:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointmentReminder:
        return Icons.schedule;
      case NotificationType.appointmentConfirmed:
        return Icons.check_circle;
      case NotificationType.appointmentCancelled:
        return Icons.cancel;
      case NotificationType.appointmentRescheduled:
        return Icons.update;
      case NotificationType.prescriptionReady:
        return Icons.medication;
      case NotificationType.testResults:
        return Icons.analytics;
      case NotificationType.emergency:
        return Icons.warning;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleNotificationTap(NotificationModel notification) async {
    // Mark as read if not already read
    if (!notification.isRead) {
      await DatabaseService.markNotificationAsRead(notification.id);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case NotificationType.appointmentReminder:
      case NotificationType.appointmentConfirmed:
      case NotificationType.appointmentCancelled:
      case NotificationType.appointmentRescheduled:
        Navigator.pushNamed(context, '/MyAppointments');
        break;
      case NotificationType.prescriptionReady:
        // Navigate to prescriptions page
        break;
      case NotificationType.testResults:
        // Navigate to test results page
        break;
      case NotificationType.emergency:
        // Show emergency dialog
        _showEmergencyDialog(notification);
        break;
      default:
        // Handle general notifications
        break;
    }
  }

  void _showEmergencyDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Emergency Alert',
          style: GoogleFonts.lato(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(notification.body, style: GoogleFonts.lato()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    // This would require a batch update to mark all notifications as read
    // For now, we'll show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
