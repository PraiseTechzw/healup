import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healup/models/doctor_model.dart';
import 'package:healup/models/appointment_model.dart';
import 'package:healup/models/revenue_model.dart';
import 'package:healup/models/chat_model.dart';

class DoctorService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Doctor Management
  static Future<Doctor?> getDoctorById(String doctorId) async {
    try {
      final doc = await _firestore.collection('doctors').doc(doctorId).get();
      if (doc.exists) {
        return Doctor.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting doctor: $e');
      return null;
    }
  }

  static Future<bool> updateDoctor(Doctor doctor) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(doctor.id)
          .update(doctor.toMap());
      return true;
    } catch (e) {
      print('Error updating doctor: $e');
      return false;
    }
  }

  static Future<List<Doctor>> getAllDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('status', isEqualTo: 'active')
          .get();

      return querySnapshot.docs
          .map((doc) => Doctor.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctors: $e');
      return [];
    }
  }

  static Future<List<Doctor>> getDoctorsBySpecialization(
    String specialization,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('specializations', arrayContains: specialization)
          .where('status', isEqualTo: 'active')
          .get();

      return querySnapshot.docs
          .map((doc) => Doctor.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctors by specialization: $e');
      return [];
    }
  }

  // Appointment Management
  static Future<List<Appointment>> getDoctorAppointments(
    String doctorId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('appointmentDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctor appointments: $e');
      return [];
    }
  }

  static Future<List<Appointment>> getDoctorAppointmentsByStatus(
    String doctorId,
    AppointmentStatus status,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: status.toString().split('.').last)
          .orderBy('appointmentDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctor appointments by status: $e');
      return [];
    }
  }

  static Future<List<Appointment>> getTodaysAppointments(
    String doctorId,
  ) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('appointmentDate', isGreaterThanOrEqualTo: startOfDay)
          .where('appointmentDate', isLessThan: endOfDay)
          .orderBy('appointmentDate', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting today\'s appointments: $e');
      return [];
    }
  }

  static Future<bool> updateAppointmentStatus(
    String appointmentId,
    AppointmentStatus status, {
    String? notes,
    String? diagnosis,
    String? treatment,
    String? prescription,
    String? cancellationReason,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
        'updatedAt': DateTime.now(),
      };

      switch (status) {
        case AppointmentStatus.confirmed:
          updateData['confirmedAt'] = DateTime.now();
          break;
        case AppointmentStatus.completed:
          updateData['completedAt'] = DateTime.now();
          if (notes != null) updateData['notes'] = notes;
          if (diagnosis != null) updateData['diagnosis'] = diagnosis;
          if (treatment != null) updateData['treatment'] = treatment;
          if (prescription != null) updateData['prescription'] = prescription;
          break;
        case AppointmentStatus.cancelled:
          updateData['cancelledAt'] = DateTime.now();
          if (cancellationReason != null) {
            updateData['cancellationReason'] = cancellationReason;
          }
          break;
        default:
          break;
      }

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update(updateData);

      return true;
    } catch (e) {
      print('Error updating appointment status: $e');
      return false;
    }
  }

  // Revenue Management
  static Future<List<Revenue>> getDoctorRevenues(String doctorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('revenues')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('paymentDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Revenue.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctor revenues: $e');
      return [];
    }
  }

  static Future<RevenueSummary> getDoctorRevenueSummary(String doctorId) async {
    try {
      final revenues = await getDoctorRevenues(doctorId);

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfDay = DateTime(now.year, now.month, now.day);

      final completedRevenues = revenues
          .where((r) => r.status == PaymentStatus.completed)
          .toList();

      final totalEarnings = completedRevenues.fold(
        0.0,
        (sum, r) => sum + r.doctorEarnings,
      );

      final monthlyEarnings = completedRevenues
          .where((r) => r.paymentDate.isAfter(startOfMonth))
          .fold(0.0, (sum, r) => sum + r.doctorEarnings);

      final weeklyEarnings = completedRevenues
          .where((r) => r.paymentDate.isAfter(startOfWeek))
          .fold(0.0, (sum, r) => sum + r.doctorEarnings);

      final dailyEarnings = completedRevenues
          .where((r) => r.paymentDate.isAfter(startOfDay))
          .fold(0.0, (sum, r) => sum + r.doctorEarnings);

      final totalPlatformFees = completedRevenues.fold(
        0.0,
        (sum, r) => sum + r.platformFee,
      );

      final pendingTransactions = revenues
          .where((r) => r.status == PaymentStatus.pending)
          .length;

      return RevenueSummary(
        totalEarnings: totalEarnings,
        totalPlatformFees: totalPlatformFees,
        netEarnings: totalEarnings - totalPlatformFees,
        totalTransactions: revenues.length,
        completedTransactions: completedRevenues.length,
        pendingTransactions: pendingTransactions,
        monthlyEarnings: monthlyEarnings,
        weeklyEarnings: weeklyEarnings,
        dailyEarnings: dailyEarnings,
        recentTransactions: revenues.take(10).toList(),
        earningsByMonth: _calculateEarningsByMonth(completedRevenues),
        transactionsByMonth: _calculateTransactionsByMonth(revenues),
      );
    } catch (e) {
      print('Error getting revenue summary: $e');
      return RevenueSummary(
        totalEarnings: 0.0,
        totalPlatformFees: 0.0,
        netEarnings: 0.0,
        totalTransactions: 0,
        completedTransactions: 0,
        pendingTransactions: 0,
        monthlyEarnings: 0.0,
        weeklyEarnings: 0.0,
        dailyEarnings: 0.0,
        recentTransactions: [],
        earningsByMonth: {},
        transactionsByMonth: {},
      );
    }
  }

  static Map<String, double> _calculateEarningsByMonth(List<Revenue> revenues) {
    final Map<String, double> earningsByMonth = {};

    for (final revenue in revenues) {
      final monthKey =
          '${revenue.paymentDate.year}-${revenue.paymentDate.month.toString().padLeft(2, '0')}';
      earningsByMonth[monthKey] =
          (earningsByMonth[monthKey] ?? 0.0) + revenue.doctorEarnings;
    }

    return earningsByMonth;
  }

  static Map<String, int> _calculateTransactionsByMonth(
    List<Revenue> revenues,
  ) {
    final Map<String, int> transactionsByMonth = {};

    for (final revenue in revenues) {
      final monthKey =
          '${revenue.paymentDate.year}-${revenue.paymentDate.month.toString().padLeft(2, '0')}';
      transactionsByMonth[monthKey] = (transactionsByMonth[monthKey] ?? 0) + 1;
    }

    return transactionsByMonth;
  }

  // Chat Management
  static Future<List<ChatRoom>> getDoctorChatRooms(String doctorId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chat_rooms')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('lastMessageAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatRoom.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting doctor chat rooms: $e');
      return [];
    }
  }

  static Future<List<ChatMessage>> getChatMessages(String chatRoomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chat_messages')
          .where('chatId', isEqualTo: chatRoomId)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Error getting chat messages: $e');
      return [];
    }
  }

  static Future<bool> sendMessage(ChatMessage message) async {
    try {
      await _firestore
          .collection('chat_messages')
          .doc(message.id)
          .set(message.toMap());

      // Update chat room
      await _firestore.collection('chat_rooms').doc(message.chatId).update({
        'lastMessage': message.content,
        'lastMessageAt': message.createdAt,
        'updatedAt': message.createdAt,
      });

      return true;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  static Future<bool> markMessagesAsRead(
    String chatRoomId,
    String doctorId,
  ) async {
    try {
      final batch = _firestore.batch();

      // Get unread messages from patients
      final unreadMessages = await _firestore
          .collection('chat_messages')
          .where('chatId', isEqualTo: chatRoomId)
          .where('senderType', isEqualTo: 'patient')
          .where('status', isEqualTo: 'delivered')
          .get();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {
          'status': 'read',
          'readAt': DateTime.now(),
        });
      }

      // Update chat room unread count
      batch.update(_firestore.collection('chat_rooms').doc(chatRoomId), {
        'unreadCount': 0,
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error marking messages as read: $e');
      return false;
    }
  }

  // Statistics
  static Future<Map<String, dynamic>> getDoctorStatistics(
    String doctorId,
  ) async {
    try {
      final appointments = await getDoctorAppointments(doctorId);
      final revenues = await getDoctorRevenues(doctorId);

      final completedAppointments = appointments
          .where((a) => a.status == AppointmentStatus.completed)
          .length;

      final totalEarnings = revenues
          .where((r) => r.status == PaymentStatus.completed)
          .fold(0.0, (sum, r) => sum + r.doctorEarnings);

      final uniquePatients = appointments
          .map((a) => a.patientId)
          .toSet()
          .length;

      final averageRating =
          appointments
              .where((a) => a.status == AppointmentStatus.completed)
              .isEmpty
          ? 0.0
          : 4.5; // Placeholder - you'd calculate from reviews

      return {
        'totalAppointments': appointments.length,
        'completedAppointments': completedAppointments,
        'totalPatients': uniquePatients,
        'totalEarnings': totalEarnings,
        'averageRating': averageRating,
        'pendingAppointments': appointments
            .where((a) => a.status == AppointmentStatus.pending)
            .length,
        'confirmedAppointments': appointments
            .where((a) => a.status == AppointmentStatus.confirmed)
            .length,
      };
    } catch (e) {
      print('Error getting doctor statistics: $e');
      return {
        'totalAppointments': 0,
        'completedAppointments': 0,
        'totalPatients': 0,
        'totalEarnings': 0.0,
        'averageRating': 0.0,
        'pendingAppointments': 0,
        'confirmedAppointments': 0,
      };
    }
  }

  // Availability Management
  static Future<bool> updateDoctorAvailability(
    String doctorId,
    bool isAvailable,
  ) async {
    try {
      await _firestore.collection('doctors').doc(doctorId).update({
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Error updating doctor availability: $e');
      return false;
    }
  }

  // Search and Filter
  static Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('doctors')
          .where('status', isEqualTo: 'active')
          .get();

      final doctors = querySnapshot.docs
          .map((doc) => Doctor.fromMap(doc.data(), doc.id))
          .toList();

      // Filter by name, specialization, or location
      return doctors.where((doctor) {
        final searchTerm = query.toLowerCase();
        return doctor.name.toLowerCase().contains(searchTerm) ||
            doctor.specialization.toLowerCase().contains(searchTerm) ||
            doctor.address.toLowerCase().contains(searchTerm) ||
            doctor.specializations.any(
              (s) => s.toLowerCase().contains(searchTerm),
            );
      }).toList();
    } catch (e) {
      print('Error searching doctors: $e');
      return [];
    }
  }
}
