import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healup/models/doctor_model.dart';
import 'package:healup/services/validation_service.dart';
import 'package:healup/screens/doctor_dashboard/doctor_dashboard.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Personal Information
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _licenseNumberController = TextEditingController();
  final _medicalSchoolController = TextEditingController();
  int _graduationYear = DateTime.now().year;

  // Professional Information
  final _specializationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  final _clinicPhoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _consultationFeeController = TextEditingController();

  List<String> _selectedSpecializations = [];
  List<String> _selectedLanguages = ['English'];
  List<String> _selectedWorkingDays = [];
  List<String> _selectedServices = [];
  String _selectedType = 'General Practitioner';

  final List<String> _specializationOptions = [
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'General Practice',
    'Gynecology',
    'Neurology',
    'Oncology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'Urology',
  ];

  final List<String> _languageOptions = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Chinese',
    'Japanese',
    'Korean',
    'Arabic',
    'Hindi',
  ];

  final List<String> _workingDayOptions = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<String> _serviceOptions = [
    'Consultation',
    'Follow-up',
    'Emergency Care',
    'Preventive Care',
    'Diagnostic Tests',
    'Prescription',
    'Health Checkup',
    'Vaccination',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _licenseNumberController.dispose();
    _medicalSchoolController.dispose();
    _specializationController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _clinicPhoneController.dispose();
    _bioController.dispose();
    _consultationFeeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _registerDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create Firebase Auth user
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (credential.user != null) {
        final userId = credential.user!.uid;

        // Create user document
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'email': _emailController.text.trim(),
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'doctor',
          'isEmailVerified': false,
          'isPhoneVerified': false,
          'allergies': [],
          'medicalConditions': [],
          'medications': [],
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
        });

        // Create doctor document
        final doctor = Doctor(
          id: userId,
          name: _nameController.text.trim(),
          type: _selectedType,
          specialization: _selectedSpecializations.isNotEmpty
              ? _selectedSpecializations.first
              : 'General Practice',
          address: _clinicAddressController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          image: '',
          rating: 0.0,
          reviewCount: 0,
          openHour: '09:00',
          closeHour: '17:00',
          workingDays: _selectedWorkingDays,
          description: _bioController.text.trim(),
          languages: _selectedLanguages,
          experience: int.tryParse(_experienceController.text) ?? 0,
          education: _educationController.text.trim(),
          certifications: [],
          consultationFee:
              double.tryParse(_consultationFeeController.text) ?? 100.0,
          isAvailable: true,
          status: DoctorStatus.pending,
          licenseNumber: _licenseNumberController.text.trim(),
          medicalSchool: _medicalSchoolController.text.trim(),
          graduationYear: _graduationYear,
          specializations: _selectedSpecializations,
          consultationFees: {
            'consultation':
                double.tryParse(_consultationFeeController.text) ?? 100.0,
            'followup':
                (double.tryParse(_consultationFeeController.text) ?? 100.0) *
                0.8,
            'emergency':
                (double.tryParse(_consultationFeeController.text) ?? 100.0) *
                1.5,
          },
          bio: _bioController.text.trim(),
          clinicName: _clinicNameController.text.trim(),
          clinicAddress: _clinicAddressController.text.trim(),
          clinicPhone: _clinicPhoneController.text.trim(),
          services: _selectedServices,
          socialMedia: {},
          isVerified: false,
          totalPatients: 0,
          totalAppointments: 0,
          totalEarnings: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(userId)
            .set(doctor.toMap());

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorDashboard(doctor: doctor),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed. Please try again.';
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
      }
      _showErrorDialog(message);
    } catch (e) {
      _showErrorDialog('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registration Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _registerDoctor();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Doctor Registration',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: i <= _currentPage
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Form Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildPersonalInfoPage(),
                _buildProfessionalInfoPage(),
                _buildClinicInfoPage(),
              ],
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(_currentPage == 2 ? 'Register' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us about yourself',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline,
              validator: ValidationService.validateName,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationService.validateEmail,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: ValidationService.validatePhone,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _passwordController,
              label: 'Password',
              icon: Icons.lock_outlined,
              obscureText: true,
              validator: ValidationService.validatePassword,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outlined,
              obscureText: true,
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _licenseNumberController,
              label: 'Medical License Number',
              icon: Icons.medical_services_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'License number is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _medicalSchoolController,
              label: 'Medical School',
              icon: Icons.school_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Medical school is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Graduation Year',
              value: _graduationYear,
              items: List.generate(50, (index) => DateTime.now().year - index),
              onChanged: (value) {
                setState(() {
                  _graduationYear = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your medical practice',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _specializationController,
            label: 'Primary Specialization',
            icon: Icons.medical_information_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Specialization is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildMultiSelectField(
            label: 'Specializations',
            selectedItems: _selectedSpecializations,
            options: _specializationOptions,
            onChanged: (items) {
              setState(() {
                _selectedSpecializations = items;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _experienceController,
            label: 'Years of Experience',
            icon: Icons.work_outline,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Experience is required';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _educationController,
            label: 'Education & Qualifications',
            icon: Icons.school_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Education is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildMultiSelectField(
            label: 'Languages Spoken',
            selectedItems: _selectedLanguages,
            options: _languageOptions,
            onChanged: (items) {
              setState(() {
                _selectedLanguages = items;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildMultiSelectField(
            label: 'Working Days',
            selectedItems: _selectedWorkingDays,
            options: _workingDayOptions,
            onChanged: (items) {
              setState(() {
                _selectedWorkingDays = items;
              });
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _bioController,
            label: 'Professional Bio',
            icon: Icons.description_outlined,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Bio is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClinicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Clinic Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your practice',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          _buildTextField(
            controller: _clinicNameController,
            label: 'Clinic/Hospital Name',
            icon: Icons.local_hospital_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Clinic name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _clinicAddressController,
            label: 'Clinic Address',
            icon: Icons.location_on_outlined,
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Clinic address is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _clinicPhoneController,
            label: 'Clinic Phone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: ValidationService.validatePhone,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _consultationFeeController,
            label: 'Consultation Fee (\$)',
            icon: Icons.attach_money_outlined,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Consultation fee is required';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid amount';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          _buildMultiSelectField(
            label: 'Services Offered',
            selectedItems: _selectedServices,
            options: _serviceOptions,
            onChanged: (items) {
              setState(() {
                _selectedServices = items;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required dynamic value,
    required List<dynamic> items,
    required Function(dynamic) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: DropdownButtonFormField<dynamic>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: items.map((item) {
          return DropdownMenuItem<dynamic>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> options,
    required Function(List<String>) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selectedItems.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newList = List<String>.from(selectedItems);
                    if (selected) {
                      newList.add(option);
                    } else {
                      newList.remove(option);
                    }
                    onChanged(newList);
                  },
                  selectedColor: Colors.blue[100],
                  checkmarkColor: Colors.blue,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
