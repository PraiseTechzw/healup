import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import '../models/appointment_model.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../models/disease_model.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static const String _usersCollection = 'users';
  static const String _doctorsCollection = 'doctors';
  static const String _appointmentsCollection = 'appointments';
  static const String _notificationsCollection = 'notifications';
  static const String _diseasesCollection = 'diseases';

  // User operations
  static Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static Stream<UserModel?> getUserStream(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).snapshots().map((
      doc,
    ) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Doctor operations
  static Future<void> createDoctor(Doctor doctor) async {
    try {
      await _firestore
          .collection(_doctorsCollection)
          .doc(doctor.id)
          .set(doctor.toMap());
    } catch (e) {
      throw Exception('Failed to create doctor: $e');
    }
  }

  static Future<Doctor?> getDoctor(String doctorId) async {
    try {
      final doc = await _firestore
          .collection(_doctorsCollection)
          .doc(doctorId)
          .get();

      if (doc.exists) {
        return Doctor.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get doctor: $e');
    }
  }

  static Future<List<Doctor>> getDoctors() async {
    try {
      final querySnapshot = await _firestore
          .collection(_doctorsCollection)
          .orderBy('rating', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Doctor.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get doctors: $e');
    }
  }

  static Future<List<Doctor>> searchDoctors(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_doctorsCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => Doctor.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search doctors: $e');
    }
  }

  static Future<List<Doctor>> getDoctorsByType(String type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_doctorsCollection)
          .where('type', isEqualTo: type)
          .get();

      return querySnapshot.docs
          .map((doc) => Doctor.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get doctors by type: $e');
    }
  }

  static Stream<List<Doctor>> getDoctorsStream() {
    return _firestore
        .collection(_doctorsCollection)
        .orderBy('rating', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Doctor.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Appointment operations
  static Future<void> createAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointment.id)
          .set(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to create appointment: $e');
    }
  }

  static Future<Appointment?> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .get();

      if (doc.exists) {
        return Appointment.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get appointment: $e');
    }
  }

  static Future<List<Appointment>> getUserAppointments(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('appointmentDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user appointments: $e');
    }
  }

  static Future<List<Appointment>> getDoctorAppointments(
    String doctorId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_appointmentsCollection)
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('appointmentDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get doctor appointments: $e');
    }
  }

  static Future<void> updateAppointment(Appointment appointment) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointment.id)
          .update(appointment.toMap());
    } catch (e) {
      throw Exception('Failed to update appointment: $e');
    }
  }

  static Future<void> deleteAppointment(String appointmentId) async {
    try {
      await _firestore
          .collection(_appointmentsCollection)
          .doc(appointmentId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete appointment: $e');
    }
  }

  static Stream<List<Appointment>> getUserAppointmentsStream(String userId) {
    return _firestore
        .collection(_appointmentsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Appointment.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Notification operations
  static Future<void> createNotification(NotificationModel notification) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notification.id)
          .set(notification.toMap());
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  static Future<List<NotificationModel>> getUserNotifications(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user notifications: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true, 'readAt': DateTime.now()});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  static Stream<List<NotificationModel>> getUserNotificationsStream(
    String userId,
  ) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Disease operations
  static Future<List<DiseaseModel>> getDiseases() async {
    try {
      final querySnapshot = await _firestore
          .collection(_diseasesCollection)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get diseases: $e');
    }
  }

  static Future<DiseaseModel?> getDisease(String diseaseId) async {
    try {
      final doc = await _firestore
          .collection(_diseasesCollection)
          .doc(diseaseId)
          .get();

      if (doc.exists) {
        return DiseaseModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get disease: $e');
    }
  }

  static Future<List<DiseaseModel>> searchDiseases(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection(_diseasesCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => DiseaseModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to search diseases: $e');
    }
  }

  static Stream<List<DiseaseModel>> getDiseasesStream() {
    return _firestore
        .collection(_diseasesCollection)
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => DiseaseModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  // Utility methods
  static String generateId() {
    return _firestore.collection('temp').doc().id;
  }

  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final ref = _firestore
            .collection(operation['collection'])
            .doc(operation['id']);

        switch (operation['type']) {
          case 'set':
            batch.set(ref, operation['data']);
            break;
          case 'update':
            batch.update(ref, operation['data']);
            break;
          case 'delete':
            batch.delete(ref);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch write: $e');
    }
  }
}
