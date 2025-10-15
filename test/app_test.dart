import 'package:flutter_test/flutter_test.dart';
import 'package:healup/main.dart';
import 'package:healup/models/doctor_model.dart';
import 'package:healup/models/appointment_model.dart';
import 'package:healup/models/user_model.dart';
import 'package:healup/models/notification_model.dart';
import 'package:healup/models/disease_model.dart';
import 'package:healup/services/validation_service.dart';
import 'package:healup/services/utility_service.dart';

void main() {
  group('HealUp App Tests', () {
    testWidgets('App launches without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp());

      // Verify that the app starts
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    group('Doctor Model Tests', () {
      test('Doctor model creation and serialization', () {
        final doctor = Doctor(
          id: 'test-id',
          name: 'Dr. John Doe',
          type: 'Cardiologist',
          specialization: 'Heart Surgery',
          address: '123 Main St',
          phone: '+1234567890',
          email: 'john.doe@example.com',
          image: 'https://example.com/image.jpg',
          rating: 4.5,
          reviewCount: 100,
          openHour: '09:00',
          closeHour: '17:00',
          workingDays: ['Monday', 'Tuesday', 'Wednesday'],
          description: 'Experienced cardiologist',
          languages: ['English', 'Spanish'],
          experience: 10,
          education: 'MD from Harvard',
          certifications: ['Board Certified'],
          consultationFee: 150.0,
          isAvailable: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(doctor.name, 'Dr. John Doe');
        expect(doctor.type, 'Cardiologist');
        expect(doctor.rating, 4.5);
        expect(doctor.isAvailable, true);
      });

      test('Doctor model fromMap', () {
        final data = {
          'name': 'Dr. Jane Smith',
          'type': 'Dermatologist',
          'specialization': 'Skin Care',
          'address': '456 Oak Ave',
          'phone': '+1987654321',
          'email': 'jane.smith@example.com',
          'image': 'https://example.com/jane.jpg',
          'rating': 4.8,
          'reviewCount': 150,
          'openHour': '08:00',
          'closeHour': '18:00',
          'workingDays': ['Monday', 'Wednesday', 'Friday'],
          'description': 'Expert dermatologist',
          'languages': ['English', 'French'],
          'experience': 15,
          'education': 'MD from Stanford',
          'certifications': ['Board Certified', 'Fellowship'],
          'consultationFee': 200.0,
          'isAvailable': true,
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        };

        final doctor = Doctor.fromMap(data, 'test-id');
        expect(doctor.name, 'Dr. Jane Smith');
        expect(doctor.type, 'Dermatologist');
        expect(doctor.rating, 4.8);
      });
    });

    group('Appointment Model Tests', () {
      test('Appointment model creation', () {
        final appointment = Appointment(
          id: 'appointment-1',
          userId: 'user-1',
          doctorId: 'doctor-1',
          doctorName: 'Dr. John Doe',
          patientName: 'Jane Smith',
          patientPhone: '+1234567890',
          patientEmail: 'jane@example.com',
          description: 'Regular checkup',
          appointmentDate: DateTime.now().add(Duration(days: 1)),
          timeSlot: '10:00 AM',
          status: AppointmentStatus.pending,
          type: AppointmentType.consultation,
          consultationFee: 150.0,
          notes: 'Patient notes',
          prescription: 'Prescription details',
          diagnosis: 'Healthy',
          symptoms: ['None'],
          followUpInstructions: 'Follow up in 6 months',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(appointment.patientName, 'Jane Smith');
        expect(appointment.status, AppointmentStatus.pending);
        expect(appointment.isUpcoming, true);
        expect(appointment.canBeCancelled, true);
      });
    });

    group('User Model Tests', () {
      test('User model creation', () {
        final user = UserModel(
          id: 'user-1',
          email: 'user@example.com',
          name: 'John Doe',
          phone: '+1234567890',
          role: UserRole.patient,
          isEmailVerified: true,
          isPhoneVerified: false,
          allergies: ['Peanuts'],
          medicalConditions: ['Diabetes'],
          medications: ['Insulin'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(user.name, 'John Doe');
        expect(user.role, UserRole.patient);
        expect(user.isEmailVerified, true);
      });

      test('User age calculation', () {
        final user = UserModel(
          id: 'user-1',
          email: 'user@example.com',
          name: 'John Doe',
          birthDate: DateTime.now().subtract(Duration(days: 365 * 25)),
          role: UserRole.patient,
          isEmailVerified: true,
          isPhoneVerified: false,
          allergies: [],
          medicalConditions: [],
          medications: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(user.age, 25);
      });
    });

    group('Validation Service Tests', () {
      test('Email validation', () {
        expect(ValidationService.validateEmail('test@example.com'), null);
        expect(ValidationService.validateEmail('invalid-email'), isNotNull);
        expect(ValidationService.validateEmail(''), isNotNull);
      });

      test('Password validation', () {
        expect(ValidationService.validatePassword('Password123!'), null);
        expect(ValidationService.validatePassword('weak'), isNotNull);
        expect(ValidationService.validatePassword(''), isNotNull);
      });

      test('Name validation', () {
        expect(ValidationService.validateName('John Doe'), null);
        expect(ValidationService.validateName('J'), isNotNull);
        expect(ValidationService.validateName(''), isNotNull);
      });

      test('Phone validation', () {
        expect(ValidationService.validatePhone('+1234567890'), null);
        expect(ValidationService.validatePhone('123-456-7890'), null);
        expect(ValidationService.validatePhone('invalid'), isNotNull);
      });
    });

    group('Utility Service Tests', () {
      test('Date formatting', () {
        final date = DateTime(2023, 12, 25);
        expect(UtilityService.formatDate(date), '25/12/2023');
        expect(
          UtilityService.formatDate(date, pattern: 'MM/dd/yyyy'),
          '12/25/2023',
        );
      });

      test('Phone number formatting', () {
        expect(
          UtilityService.formatPhoneNumber('1234567890'),
          '(123) 456-7890',
        );
        expect(
          UtilityService.formatPhoneNumber('+11234567890'),
          '+1 (123) 456-7890',
        );
      });

      test('Currency formatting', () {
        expect(UtilityService.formatCurrency(123.45), '\$123.45');
        expect(UtilityService.formatCurrency(123.45, symbol: '€'), '€123.45');
      });

      test('File size formatting', () {
        expect(UtilityService.formatFileSize(1024), '1.0 KB');
        expect(UtilityService.formatFileSize(1024 * 1024), '1.0 MB');
        expect(UtilityService.formatFileSize(1024 * 1024 * 1024), '1.0 GB');
      });

      test('String operations', () {
        expect(UtilityService.capitalize('hello'), 'Hello');
        expect(UtilityService.capitalizeWords('hello world'), 'Hello World');
        expect(UtilityService.truncate('Hello World', 5), 'Hello...');
      });

      test('Email validation', () {
        expect(UtilityService.isValidEmail('test@example.com'), true);
        expect(UtilityService.isValidEmail('invalid-email'), false);
      });

      test('Phone validation', () {
        expect(UtilityService.isValidPhone('+1234567890'), true);
        expect(UtilityService.isValidPhone('123-456-7890'), true);
        expect(UtilityService.isValidPhone('invalid'), false);
      });

      test('Date operations', () {
        final today = DateTime.now();
        final tomorrow = today.add(Duration(days: 1));
        final yesterday = today.subtract(Duration(days: 1));

        expect(UtilityService.isToday(today), true);
        expect(UtilityService.isTomorrow(tomorrow), true);
        expect(UtilityService.isYesterday(yesterday), true);
      });
    });

    group('Notification Model Tests', () {
      test('Notification model creation', () {
        final notification = NotificationModel(
          id: 'notification-1',
          userId: 'user-1',
          title: 'Appointment Reminder',
          body: 'You have an appointment tomorrow at 10:00 AM',
          type: NotificationType.appointmentReminder,
          priority: NotificationPriority.high,
          isRead: false,
          createdAt: DateTime.now(),
        );

        expect(notification.title, 'Appointment Reminder');
        expect(notification.type, NotificationType.appointmentReminder);
        expect(notification.priority, NotificationPriority.high);
        expect(notification.isRead, false);
        expect(notification.isUrgent, false);
      });
    });

    group('Disease Model Tests', () {
      test('Disease model creation', () {
        final disease = DiseaseModel(
          id: 'disease-1',
          name: 'Common Cold',
          description: 'A viral infection of the upper respiratory tract',
          symptoms: ['Runny nose', 'Sore throat', 'Cough'],
          causes: ['Rhinovirus', 'Coronavirus'],
          riskFactors: ['Weakened immune system', 'Age'],
          complications: ['Sinusitis', 'Ear infection'],
          prevention: ['Wash hands frequently', 'Avoid close contact'],
          treatments: ['Rest', 'Fluids', 'Over-the-counter medication'],
          medications: ['Acetaminophen', 'Ibuprofen'],
          severity: DiseaseSeverity.mild,
          category: DiseaseCategory.infectious,
          isContagious: true,
          incubationPeriod: '1-3 days',
          recoveryTime: '7-10 days',
          warningSigns: ['High fever', 'Difficulty breathing'],
          whenToSeeDoctor: 'If symptoms persist for more than 10 days',
          diagnosticTests: ['Physical examination', 'Throat swab'],
          imageUrl: 'https://example.com/cold.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(disease.name, 'Common Cold');
        expect(disease.severity, DiseaseSeverity.mild);
        expect(disease.category, DiseaseCategory.infectious);
        expect(disease.isContagious, true);
        expect(disease.isSevere, false);
      });
    });
  });
}




