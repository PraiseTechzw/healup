import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';
import 'database_service.dart';

class SeedService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedZimbabweDoctors() async {
    // Skip if there is already at least one doctor
    final existing = await _firestore.collection('doctors').limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final List<Doctor> doctors = [
      _zwDoctor(
        name: 'Dr. Tendai Moyo',
        type: 'General Practitioner',
        specialization: 'Primary Care',
        address: '35 Jason Moyo Ave, Harare',
        phone: '+263 77 123 4567',
        email: 'tendai.moyo@harareclinic.co.zw',
        city: 'Harare',
        languages: ['English', 'Shona'],
        experience: 12,
      ),
      _zwDoctor(
        name: 'Dr. Nqobile Ndlovu',
        type: 'Pediatrician',
        specialization: 'Child Health',
        address: '12 Leopold Takawira St, Bulawayo',
        phone: '+263 71 555 2211',
        email: 'nqobile.ndlovu@byohealth.co.zw',
        city: 'Bulawayo',
        languages: ['English', 'Ndebele'],
        experience: 9,
      ),
      _zwDoctor(
        name: 'Dr. Chenai Chikore',
        type: 'Obstetrician-Gynecologist',
        specialization: 'OB/GYN',
        address: 'Victoria Chitepo St, Mutare Provincial Hospital, Mutare',
        phone: '+263 78 224 0099',
        email: 'chenai.chikore@mutarecare.co.zw',
        city: 'Mutare',
        languages: ['English', 'Shona'],
        experience: 11,
      ),
      _zwDoctor(
        name: 'Dr. Tafadzwa Nyathi',
        type: 'Cardiologist',
        specialization: 'Cardiology',
        address: 'Fourth St, Gweru Provincial Hospital, Gweru',
        phone: '+263 78 990 1102',
        email: 'tafadzwa.nyathi@gweruheart.co.zw',
        city: 'Gweru',
        languages: ['English', 'Shona'],
        experience: 14,
      ),
      _zwDoctor(
        name: 'Dr. Sibusiso Mpala',
        type: 'Dentist',
        specialization: 'Dental Surgery',
        address: 'Robert Mugabe Way, Masvingo',
        phone: '+263 77 888 3344',
        email: 'sibusiso.mpala@masvingodental.co.zw',
        city: 'Masvingo',
        languages: ['English', 'Ndebele'],
        experience: 7,
      ),
    ];

    for (final doc in doctors) {
      await DatabaseService.createDoctor(doc);
    }
  }

  static Doctor _zwDoctor({
    required String name,
    required String type,
    required String specialization,
    required String address,
    required String phone,
    required String email,
    required String city,
    required List<String> languages,
    required int experience,
  }) {
    final String id = _firestore.collection('doctors').doc().id;
    return Doctor(
      id: id,
      name: name,
      type: type,
      specialization: specialization,
      address: '$address, $city, Zimbabwe',
      phone: phone,
      email: email,
      image: 'assets/doc.png',
      rating: 4.6,
      reviewCount: 0,
      openHour: '08:00',
      closeHour: '17:00',
      workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      description:
          'Experienced $type based in $city, Zimbabwe. Providing compassionate, high-quality care.',
      languages: languages,
      experience: experience,
      education: 'MBChB (UZ)',
      certifications: ['HPCZ Registered'],
      consultationFee: 25.0,
      isAvailable: true,
      status: DoctorStatus.active,
      graduationYear: DateTime.now().year - (experience + 6),
      specializations: [specialization],
      consultationFees: {'in_person': 25.0, 'virtual': 15.0},
      bio: 'Passionate about patient-centered care and community health.',
      clinicName: '$city Medical Centre',
      clinicAddress: '$address, $city',
      clinicPhone: phone,
      services: ['Consultation', 'Follow-up', 'Telehealth'],
      socialMedia: {},
      isVerified: true,
      lastActiveAt: DateTime.now(),
      totalPatients: 0,
      totalAppointments: 0,
      totalEarnings: 0.0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

