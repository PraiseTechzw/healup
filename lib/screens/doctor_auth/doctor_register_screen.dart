import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healup/models/doctor_model.dart';
import 'package:healup/services/validation_service.dart';
import 'package:healup/screens/doctor_dashboard/doctor_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DoctorRegisterScreen extends StatefulWidget {
  const DoctorRegisterScreen({Key? key}) : super(key: key);

  @override
  State<DoctorRegisterScreen> createState() => _DoctorRegisterScreenState();
}

class _DoctorRegisterScreenState extends State<DoctorRegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
    if (!_formKey.currentState!.validate()) {
      _showValidationErrors();
      return;
    }

    // Additional validation
    if (_selectedSpecializations.isEmpty) {
      _showErrorDialog('Please select at least one specialization');
      return;
    }

    if (_selectedWorkingDays.isEmpty) {
      _showErrorDialog('Please select your working days');
      return;
    }

    if (_selectedServices.isEmpty) {
      _showErrorDialog('Please select the services you offer');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Show progress dialog
      _showProgressDialog();

      // Create Firebase Auth user
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      if (credential.user != null) {
        final userId = credential.user!.uid;

        // Send email verification
        await credential.user!.sendEmailVerification();

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

        // Close progress dialog
        if (mounted) Navigator.pop(context);

        // Show success dialog and navigate
        _showSuccessDialog(doctor);
      }
    } on FirebaseAuthException catch (e) {
      // Close progress dialog
      if (mounted) Navigator.pop(context);

      String message = 'Registration failed. Please try again.';
      switch (e.code) {
        case 'weak-password':
          message =
              'The password provided is too weak. Please use at least 6 characters with a mix of letters and numbers.';
          break;
        case 'email-already-in-use':
          message =
              'An account already exists for this email address. Please try logging in instead.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'operation-not-allowed':
          message =
              'Email/password accounts are not enabled. Please contact support.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your internet connection and try again.';
          break;
        default:
          message = 'Registration failed: ${e.message}';
      }
      _showErrorDialog(message);
    } catch (e) {
      // Close progress dialog
      if (mounted) Navigator.pop(context);
      _showErrorDialog(
        'An unexpected error occurred. Please try again later.\n\nError: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Registration Failed',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'OK',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: CircularProgressIndicator(
                  color: Colors.blue[600],
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Creating Your Account',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we set up your doctor profile...',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(Doctor doctor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to HealUp!',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your doctor account has been created successfully.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Verification email sent to:',
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      _emailController.text.trim(),
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorDashboard(doctor: doctor),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue to Dashboard',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationErrors() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[100]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Please fill in all required fields correctly',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      // Validate current page before proceeding
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _registerDoctor();
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0: // Personal Information
        if (!_formKey.currentState!.validate()) {
          _showValidationErrors();
          return false;
        }
        break;
      case 1: // Professional Information
        if (_selectedSpecializations.isEmpty) {
          _showErrorDialog('Please select at least one specialization');
          return false;
        }
        if (_selectedLanguages.isEmpty) {
          _showErrorDialog('Please select at least one language');
          return false;
        }
        if (_selectedWorkingDays.isEmpty) {
          _showErrorDialog('Please select your working days');
          return false;
        }
        if (_bioController.text.trim().isEmpty) {
          _showErrorDialog('Please provide a professional bio');
          return false;
        }
        break;
      case 2: // Clinic Information
        if (_selectedServices.isEmpty) {
          _showErrorDialog('Please select the services you offer');
          return false;
        }
        if (_clinicNameController.text.trim().isEmpty) {
          _showErrorDialog('Please enter your clinic/hospital name');
          return false;
        }
        if (_clinicAddressController.text.trim().isEmpty) {
          _showErrorDialog('Please enter your clinic address');
          return false;
        }
        if (_consultationFeeController.text.trim().isEmpty) {
          _showErrorDialog('Please enter your consultation fee');
          return false;
        }
        break;
    }
    return true;
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[50]!, Colors.white, Colors.indigo[50]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Enhanced Header
              _buildHeader(),
              // Progress Indicator
              _buildProgressIndicator(),
              // Form Pages
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                      _animationController.reset();
                      _animationController.forward();
                    },
                    children: [
                      _buildPersonalInfoPage(),
                      _buildProfessionalInfoPage(),
                      _buildClinicInfoPage(),
                    ],
                  ),
                ),
              ),
              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Personal Information',
      'Professional Details',
      'Clinic Information',
    ];
    final subtitles = [
      'Tell us about yourself',
      'Your medical expertise',
      'Your practice details',
    ];
    final icons = [
      FontAwesomeIcons.user,
      FontAwesomeIcons.userDoctor,
      FontAwesomeIcons.hospital,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black87),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Text(
                'HealUp',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icons[_currentPage],
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titles[_currentPage],
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitles[_currentPage],
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          for (int i = 0; i < 3; i++)
            Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                decoration: BoxDecoration(
                  color: i <= _currentPage
                      ? Colors.blue[600]
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: i <= _currentPage
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _previousPage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.grey[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Previous',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.indigo[600]!],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _isLoading ? null : _nextPage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == 2
                                    ? 'Create Account'
                                    : 'Continue',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == 2
                                    ? FontAwesomeIcons.check
                                    : Icons.arrow_forward,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
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
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: ValidationService.validatePassword,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              icon: Icons.lock_outlined,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
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
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue[600], size: 20),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonFormField<dynamic>(
        value: value,
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              color: Colors.blue[600],
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<dynamic>(
            value: item,
            child: Text(item.toString(), style: GoogleFonts.lato(fontSize: 16)),
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.checklist,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${selectedItems.length} selected',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selectedItems.contains(option);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    label: Text(
                      option,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.blue[700] : Colors.grey[700],
                      ),
                    ),
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
                    backgroundColor: Colors.grey[100],
                    checkmarkColor: Colors.blue[700],
                    elevation: isSelected ? 2 : 0,
                    shadowColor: Colors.blue.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.blue[300]!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
