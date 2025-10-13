enum UserRole { patient, doctor, admin }

enum Gender { male, female, other, preferNotToSay }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImage;
  final DateTime? birthDate;
  final Gender? gender;
  final String? bio;
  final String? city;
  final String? address;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final List<String> allergies;
  final List<String> medicalConditions;
  final List<String> medications;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? bloodType;
  final double? height;
  final double? weight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImage,
    this.birthDate,
    this.gender,
    this.bio,
    this.city,
    this.address,
    required this.role,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.allergies,
    required this.medicalConditions,
    required this.medications,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.bloodType,
    this.height,
    this.weight,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'],
      profileImage: data['profileImage'],
      birthDate: data['birthDate']?.toDate(),
      gender: data['gender'] != null
          ? Gender.values.firstWhere(
              (e) => e.toString() == 'Gender.${data['gender']}',
              orElse: () => Gender.preferNotToSay,
            )
          : null,
      bio: data['bio'],
      city: data['city'],
      address: data['address'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${data['role']}',
        orElse: () => UserRole.patient,
      ),
      isEmailVerified: data['isEmailVerified'] ?? false,
      isPhoneVerified: data['isPhoneVerified'] ?? false,
      allergies: List<String>.from(data['allergies'] ?? []),
      medicalConditions: List<String>.from(data['medicalConditions'] ?? []),
      medications: List<String>.from(data['medications'] ?? []),
      emergencyContactName: data['emergencyContactName'],
      emergencyContactPhone: data['emergencyContactPhone'],
      bloodType: data['bloodType'],
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
      lastLoginAt: data['lastLoginAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'birthDate': birthDate,
      'gender': gender?.toString().split('.').last,
      'bio': bio,
      'city': city,
      'address': address,
      'role': role.toString().split('.').last,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'bloodType': bloodType,
      'height': height,
      'weight': weight,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImage,
    DateTime? birthDate,
    Gender? gender,
    String? bio,
    String? city,
    String? address,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    List<String>? allergies,
    List<String>? medicalConditions,
    List<String>? medications,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? bloodType,
    double? height,
    double? weight,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      address: address ?? this.address,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  int get age {
    if (birthDate == null) return 0;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  double? get bmi {
    if (height == null || weight == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'Unknown';
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal weight';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }
}



