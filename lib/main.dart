import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:healup/screens/doctorProfile.dart';
import 'package:healup/screens/firebaseAuth.dart';
import 'package:healup/mainPage.dart';
import 'package:healup/screens/myAppointments.dart';
import 'package:healup/screens/skip.dart';
import 'package:healup/screens/userProfile.dart';
import 'package:healup/screens/enhanced_user_profile.dart';
import 'package:healup/screens/medical_info_screen.dart';
import 'package:healup/firestore-data/notificationList.dart';
import 'package:healup/models/user_model.dart';
import 'package:healup/screens/doctor_auth/doctor_login_screen.dart';
import 'package:healup/screens/doctor_dashboard/doctor_dashboard.dart';
import 'package:healup/models/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healup/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'services/seed_service.dart';
import 'package:healup/screens/help_support_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    // Seed doctors for Zimbabwe environment when empty
    await SeedService.seedZimbabweDoctors();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealUp - Your Health Companion',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Lato',
      ),
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        '/login': (context) => FireBaseAuth(),
        '/doctor-login': (context) => const DoctorLoginScreen(),
        '/home': (context) => MainPage(),
        '/profile': (context) => const UserProfile(),
        '/enhanced-profile': (context) => const EnhancedUserProfile(),
        '/MyAppointments': (context) => MyAppointments(),
        '/DoctorProfile': (context) => const DoctorProfile(doctor: ''),
        '/notifications': (context) => NotificationList(),
        '/help': (context) => const HelpSupportScreen(),
        '/medical-info': (context) => MedicalInfoScreen(
          userModel: UserModel(
            id: '',
            email: '',
            name: '',
            role: UserRole.patient,
            isEmailVerified: false,
            isPhoneVerified: false,
            allergies: [],
            medicalConditions: [],
            medications: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(snapshot.data!.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                final userRole = userData['role'];

                if (userRole == 'doctor') {
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('doctors')
                        .doc(snapshot.data!.uid)
                        .get(),
                    builder: (context, doctorSnapshot) {
                      if (doctorSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (doctorSnapshot.hasData &&
                          doctorSnapshot.data!.exists) {
                        final doctor = Doctor.fromMap(
                          doctorSnapshot.data!.data() as Map<String, dynamic>,
                          doctorSnapshot.data!.id,
                        );
                        return DoctorDashboard(doctor: doctor);
                      } else {
                        return Skip();
                      }
                    },
                  );
                } else {
                  return MainPage();
                }
              } else {
                return Skip();
              }
            },
          );
        } else {
          return Skip();
        }
      },
    );
  }
}
