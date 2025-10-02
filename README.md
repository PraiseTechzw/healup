# HealUp - Your Health Companion

HealUp is a comprehensive healthcare mobile application built with Flutter that connects patients with healthcare providers, manages appointments, and provides health information and resources.

## Features

### 🏥 Core Features
- **Doctor Search & Discovery**: Find and search for doctors by specialty, location, and ratings
- **Appointment Booking**: Schedule, manage, and track medical appointments
- **User Authentication**: Secure login with email/password and Google Sign-In
- **User Profile Management**: Complete user profiles with medical history and preferences
- **Real-time Notifications**: Push notifications for appointments, reminders, and updates
- **Health Information**: Access to disease information, symptoms, and treatments
- **Appointment History**: Track past and upcoming appointments
- **Doctor Profiles**: Detailed doctor information including ratings, reviews, and availability

### 🔧 Technical Features
- **Firebase Integration**: Real-time database with Firestore
- **Authentication**: Firebase Auth with Google Sign-In support
- **Push Notifications**: Firebase Cloud Messaging integration
- **Offline Support**: Local data caching and offline functionality
- **Responsive Design**: Optimized for various screen sizes
- **Modern UI/UX**: Clean, intuitive interface with Material Design
- **Error Handling**: Comprehensive error handling and validation
- **Performance Optimization**: Efficient data loading and caching

## Architecture

### 📁 Project Structure
```
lib/
├── models/                 # Data models
│   ├── doctor_model.dart
│   ├── appointment_model.dart
│   ├── user_model.dart
│   ├── notification_model.dart
│   └── disease_model.dart
├── services/              # Business logic services
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── notification_service.dart
│   ├── error_service.dart
│   ├── validation_service.dart
│   └── utility_service.dart
├── screens/               # UI screens
│   ├── firebaseAuth.dart
│   ├── signIn.dart
│   ├── register.dart
│   ├── mainPage.dart
│   ├── homePage.dart
│   ├── doctorProfile.dart
│   ├── bookingScreen.dart
│   ├── myAppointments.dart
│   ├── userProfile.dart
│   ├── userSettings.dart
│   ├── doctorsList.dart
│   ├── exploreList.dart
│   ├── disease.dart
│   ├── diseasedetail.dart
│   └── skip.dart
├── firestore-data/        # Firestore data handling
│   ├── topRatedList.dart
│   ├── searchList.dart
│   ├── myAppointmentList.dart
│   ├── appointmentHistoryList.dart
│   ├── notificationList.dart
│   └── userDetails.dart
├── models/                # UI models
│   ├── bannerModel.dart
│   └── cardModel.dart
├── main.dart              # App entry point
├── firebase_options.dart  # Firebase configuration
└── updateUserDetails.dart # User details update
```

### 🏗️ Architecture Patterns
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **Repository Pattern**: Centralized data access
- **Service Layer**: Business logic abstraction
- **Dependency Injection**: Loose coupling between components

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Firebase project setup
- Google Sign-In configuration

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/healup.git
   cd healup
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Create a Firebase project
   - Enable Authentication, Firestore, and Cloud Messaging
   - Download `google-services.json` for Android
   - Update `lib/firebase_options.dart` with your configuration

4. **Configure Google Sign-In**
   - Enable Google Sign-In in Firebase Console
   - Add your SHA-1 fingerprint for Android
   - Update OAuth client configuration

5. **Run the application**
   ```bash
   flutter run
   ```

### Firebase Setup

1. **Create Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication, Firestore, and Cloud Messaging

2. **Configure Authentication**
   - Enable Email/Password authentication
   - Enable Google Sign-In
   - Configure OAuth consent screen

3. **Configure Firestore**
   - Create Firestore database
   - Set up security rules
   - Create collections: `users`, `doctors`, `appointments`, `notifications`, `diseases`

4. **Configure Cloud Messaging**
   - Enable Cloud Messaging
   - Generate server key
   - Configure notification channels

## Usage

### For Patients
1. **Sign Up/Login**: Create an account or sign in with Google
2. **Complete Profile**: Add personal and medical information
3. **Search Doctors**: Find doctors by specialty or location
4. **Book Appointments**: Schedule appointments with preferred doctors
5. **Manage Appointments**: View, reschedule, or cancel appointments
6. **Receive Notifications**: Get reminders and updates about appointments
7. **Access Health Info**: Browse disease information and health tips

### For Doctors
1. **Create Profile**: Set up professional profile with specialties
2. **Manage Availability**: Set working hours and availability
3. **View Appointments**: See upcoming and past appointments
4. **Update Information**: Keep profile and availability updated
5. **Respond to Patients**: Manage patient communications

## API Reference

### Authentication Service
```dart
// Sign in with email and password
AuthService.signInWithEmailAndPassword(email, password)

// Create new account
AuthService.createUserWithEmailAndPassword(email, password, name)

// Sign in with Google
AuthService.signInWithGoogle()

// Sign out
AuthService.signOut()
```

### Database Service
```dart
// User operations
DatabaseService.createUser(user)
DatabaseService.getUser(userId)
DatabaseService.updateUser(user)

// Doctor operations
DatabaseService.getDoctors()
DatabaseService.searchDoctors(query)
DatabaseService.getDoctorsByType(type)

// Appointment operations
DatabaseService.createAppointment(appointment)
DatabaseService.getUserAppointments(userId)
DatabaseService.updateAppointment(appointment)
```

### Notification Service
```dart
// Send notification
NotificationService.sendNotification(userId, title, body)

// Send appointment reminder
NotificationService.sendAppointmentReminder(userId, doctorName, date, time)

// Send appointment confirmation
NotificationService.sendAppointmentConfirmation(userId, doctorName, date, time)
```

## Testing

Run the test suite:
```bash
flutter test
```

Run specific test files:
```bash
flutter test test/app_test.dart
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support, email support@healup.com or join our Slack channel.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- Material Design team for the design system
- Open source community for various packages

## Roadmap

### Version 2.0
- [ ] Video consultations
- [ ] Prescription management
- [ ] Lab test results
- [ ] Health records
- [ ] Family accounts
- [ ] Multi-language support

### Version 3.0
- [ ] AI-powered health insights
- [ ] Wearable device integration
- [ ] Telemedicine features
- [ ] Advanced analytics
- [ ] Healthcare provider dashboard
- [ ] Insurance integration

## Changelog

### Version 1.0.0
- Initial release
- Basic appointment booking
- User authentication
- Doctor search and profiles
- Push notifications
- Health information database
- User profile management

---

Made with ❤️ by the HealUp team
