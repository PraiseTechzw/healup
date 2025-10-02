enum DoctorStatus { active, inactive, suspended, pending }

class Doctor {
  final String id;
  final String name;
  final String type;
  final String specialization;
  final String address;
  final String phone;
  final String email;
  final String image;
  final double rating;
  final int reviewCount;
  final String openHour;
  final String closeHour;
  final List<String> workingDays;
  final String description;
  final List<String> languages;
  final int experience;
  final String education;
  final List<String> certifications;
  final double consultationFee;
  final bool isAvailable;
  final DoctorStatus status;
  final String? licenseNumber;
  final String? medicalSchool;
  final int graduationYear;
  final List<String> specializations;
  final Map<String, double>
  consultationFees; // Different fees for different types
  final String? bio;
  final String? clinicName;
  final String? clinicAddress;
  final String? clinicPhone;
  final List<String> services;
  final Map<String, String> socialMedia;
  final bool isVerified;
  final DateTime? lastActiveAt;
  final int totalPatients;
  final int totalAppointments;
  final double totalEarnings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Doctor({
    required this.id,
    required this.name,
    required this.type,
    required this.specialization,
    required this.address,
    required this.phone,
    required this.email,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.openHour,
    required this.closeHour,
    required this.workingDays,
    required this.description,
    required this.languages,
    required this.experience,
    required this.education,
    required this.certifications,
    required this.consultationFee,
    required this.isAvailable,
    required this.status,
    this.licenseNumber,
    this.medicalSchool,
    required this.graduationYear,
    required this.specializations,
    required this.consultationFees,
    this.bio,
    this.clinicName,
    this.clinicAddress,
    this.clinicPhone,
    required this.services,
    required this.socialMedia,
    required this.isVerified,
    this.lastActiveAt,
    required this.totalPatients,
    required this.totalAppointments,
    required this.totalEarnings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromMap(Map<String, dynamic> data, String id) {
    return Doctor(
      id: id,
      name: data['name'] ?? '',
      type: data['type'] ?? '',
      specialization: data['specialization'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      image: data['image'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      openHour: data['openHour'] ?? '',
      closeHour: data['closeHour'] ?? '',
      workingDays: List<String>.from(data['workingDays'] ?? []),
      description: data['description'] ?? '',
      languages: List<String>.from(data['languages'] ?? []),
      experience: data['experience'] ?? 0,
      education: data['education'] ?? '',
      certifications: List<String>.from(data['certifications'] ?? []),
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      isAvailable: data['isAvailable'] ?? true,
      status: DoctorStatus.values.firstWhere(
        (e) => e.toString() == 'DoctorStatus.${data['status']}',
        orElse: () => DoctorStatus.pending,
      ),
      licenseNumber: data['licenseNumber'],
      medicalSchool: data['medicalSchool'],
      graduationYear: data['graduationYear'] ?? DateTime.now().year,
      specializations: List<String>.from(data['specializations'] ?? []),
      consultationFees: Map<String, double>.from(
        data['consultationFees'] ?? {},
      ),
      bio: data['bio'],
      clinicName: data['clinicName'],
      clinicAddress: data['clinicAddress'],
      clinicPhone: data['clinicPhone'],
      services: List<String>.from(data['services'] ?? []),
      socialMedia: Map<String, String>.from(data['socialMedia'] ?? {}),
      isVerified: data['isVerified'] ?? false,
      lastActiveAt: data['lastActiveAt']?.toDate(),
      totalPatients: data['totalPatients'] ?? 0,
      totalAppointments: data['totalAppointments'] ?? 0,
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'specialization': specialization,
      'address': address,
      'phone': phone,
      'email': email,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'openHour': openHour,
      'closeHour': closeHour,
      'workingDays': workingDays,
      'description': description,
      'languages': languages,
      'experience': experience,
      'education': education,
      'certifications': certifications,
      'consultationFee': consultationFee,
      'isAvailable': isAvailable,
      'status': status.toString().split('.').last,
      'licenseNumber': licenseNumber,
      'medicalSchool': medicalSchool,
      'graduationYear': graduationYear,
      'specializations': specializations,
      'consultationFees': consultationFees,
      'bio': bio,
      'clinicName': clinicName,
      'clinicAddress': clinicAddress,
      'clinicPhone': clinicPhone,
      'services': services,
      'socialMedia': socialMedia,
      'isVerified': isVerified,
      'lastActiveAt': lastActiveAt,
      'totalPatients': totalPatients,
      'totalAppointments': totalAppointments,
      'totalEarnings': totalEarnings,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Doctor copyWith({
    String? id,
    String? name,
    String? type,
    String? specialization,
    String? address,
    String? phone,
    String? email,
    String? image,
    double? rating,
    int? reviewCount,
    String? openHour,
    String? closeHour,
    List<String>? workingDays,
    String? description,
    List<String>? languages,
    int? experience,
    String? education,
    List<String>? certifications,
    double? consultationFee,
    bool? isAvailable,
    DoctorStatus? status,
    String? licenseNumber,
    String? medicalSchool,
    int? graduationYear,
    List<String>? specializations,
    Map<String, double>? consultationFees,
    String? bio,
    String? clinicName,
    String? clinicAddress,
    String? clinicPhone,
    List<String>? services,
    Map<String, String>? socialMedia,
    bool? isVerified,
    DateTime? lastActiveAt,
    int? totalPatients,
    int? totalAppointments,
    double? totalEarnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Doctor(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      specialization: specialization ?? this.specialization,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openHour: openHour ?? this.openHour,
      closeHour: closeHour ?? this.closeHour,
      workingDays: workingDays ?? this.workingDays,
      description: description ?? this.description,
      languages: languages ?? this.languages,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certifications: certifications ?? this.certifications,
      consultationFee: consultationFee ?? this.consultationFee,
      isAvailable: isAvailable ?? this.isAvailable,
      status: status ?? this.status,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      medicalSchool: medicalSchool ?? this.medicalSchool,
      graduationYear: graduationYear ?? this.graduationYear,
      specializations: specializations ?? this.specializations,
      consultationFees: consultationFees ?? this.consultationFees,
      bio: bio ?? this.bio,
      clinicName: clinicName ?? this.clinicName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      clinicPhone: clinicPhone ?? this.clinicPhone,
      services: services ?? this.services,
      socialMedia: socialMedia ?? this.socialMedia,
      isVerified: isVerified ?? this.isVerified,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      totalPatients: totalPatients ?? this.totalPatients,
      totalAppointments: totalAppointments ?? this.totalAppointments,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
