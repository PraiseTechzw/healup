import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:healup/models/doctor_model.dart';
import 'package:healup/services/validation_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DoctorProfileManagementScreen extends StatefulWidget {
  final Doctor doctor;
  final Function(Doctor) onDoctorUpdated;

  const DoctorProfileManagementScreen({
    Key? key,
    required this.doctor,
    required this.onDoctorUpdated,
  }) : super(key: key);

  @override
  State<DoctorProfileManagementScreen> createState() =>
      _DoctorProfileManagementScreenState();
}

class _DoctorProfileManagementScreenState
    extends State<DoctorProfileManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _selectedImage;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;
  late TextEditingController _experienceController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _medicalSchoolController;
  late TextEditingController _clinicNameController;
  late TextEditingController _clinicAddressController;
  late TextEditingController _clinicPhoneController;
  late TextEditingController _consultationFeeController;
  late TextEditingController _openHourController;
  late TextEditingController _closeHourController;

  // Lists
  List<String> _selectedSpecializations = [];
  List<String> _selectedLanguages = [];
  List<String> _selectedWorkingDays = [];
  List<String> _selectedServices = [];
  List<String> _certifications = [];
  Map<String, String> _socialMedia = {};

  // Options
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
    _tabController = TabController(length: 4, vsync: this);
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.doctor.name);
    _phoneController = TextEditingController(text: widget.doctor.phone);
    _bioController = TextEditingController(text: widget.doctor.bio ?? '');
    _educationController = TextEditingController(text: widget.doctor.education);
    _experienceController = TextEditingController(
      text: widget.doctor.experience.toString(),
    );
    _licenseNumberController = TextEditingController(
      text: widget.doctor.licenseNumber ?? '',
    );
    _medicalSchoolController = TextEditingController(
      text: widget.doctor.medicalSchool ?? '',
    );
    _clinicNameController = TextEditingController(
      text: widget.doctor.clinicName ?? '',
    );
    _clinicAddressController = TextEditingController(
      text: widget.doctor.clinicAddress ?? '',
    );
    _clinicPhoneController = TextEditingController(
      text: widget.doctor.clinicPhone ?? '',
    );
    _consultationFeeController = TextEditingController(
      text: widget.doctor.consultationFee.toString(),
    );
    _openHourController = TextEditingController(text: widget.doctor.openHour);
    _closeHourController = TextEditingController(text: widget.doctor.closeHour);

    _selectedSpecializations = List.from(widget.doctor.specializations);
    _selectedLanguages = List.from(widget.doctor.languages);
    _selectedWorkingDays = List.from(widget.doctor.workingDays);
    _selectedServices = List.from(widget.doctor.services);
    _certifications = List.from(widget.doctor.certifications);
    _socialMedia = Map.from(widget.doctor.socialMedia);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _experienceController.dispose();
    _licenseNumberController.dispose();
    _medicalSchoolController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _clinicPhoneController.dispose();
    _consultationFeeController.dispose();
    _openHourController.dispose();
    _closeHourController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create updated doctor object
      final updatedDoctor = widget.doctor.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        education: _educationController.text.trim(),
        experience: int.tryParse(_experienceController.text) ?? 0,
        licenseNumber: _licenseNumberController.text.trim(),
        medicalSchool: _medicalSchoolController.text.trim(),
        clinicName: _clinicNameController.text.trim(),
        clinicAddress: _clinicAddressController.text.trim(),
        clinicPhone: _clinicPhoneController.text.trim(),
        consultationFee:
            double.tryParse(_consultationFeeController.text) ?? 0.0,
        openHour: _openHourController.text.trim(),
        closeHour: _closeHourController.text.trim(),
        specializations: _selectedSpecializations,
        languages: _selectedLanguages,
        workingDays: _selectedWorkingDays,
        services: _selectedServices,
        certifications: _certifications,
        socialMedia: _socialMedia,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor.id)
          .update(updatedDoctor.toMap());

      // Update user document as well
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.doctor.id)
          .update({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'updatedAt': DateTime.now(),
          });

      widget.onDoctorUpdated(updatedDoctor);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile Management',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.blue,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Professional'),
            Tab(text: 'Clinic'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildPersonalTab(),
            _buildProfessionalTab(),
            _buildClinicTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Picture
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : widget.doctor.image.isNotEmpty
                      ? NetworkImage(widget.doctor.image)
                      : null,
                  child: widget.doctor.image.isEmpty && _selectedImage == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Personal Information
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: ValidationService.validateName,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: ValidationService.validatePhone,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildProfessionalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _buildCertificationsSection(),
        ],
      ),
    );
  }

  Widget _buildClinicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _buildTextField(
            controller: _clinicPhoneController,
            label: 'Clinic Phone',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: ValidationService.validatePhone,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _openHourController,
                  label: 'Opening Hour',
                  icon: Icons.access_time,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Opening hour is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _closeHourController,
                  label: 'Closing Hour',
                  icon: Icons.access_time,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Closing hour is required';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
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
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusCard(),
          const SizedBox(height: 24),
          const Text(
            'Social Media Links',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSocialMediaSection(),
          const SizedBox(height: 24),
          const Text(
            'Availability',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildAvailabilityToggle(),
          const SizedBox(height: 24),
          const Text(
            'Account Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildAccountActions(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
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

  Widget _buildCertificationsSection() {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Certifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: _addCertification,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
          ),
          if (_certifications.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No certifications added yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...(_certifications
                .map(
                  (cert) => ListTile(
                    title: Text(cert),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _certifications.remove(cert);
                        });
                      },
                    ),
                  ),
                )
                .toList()),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.doctor.isVerified
                      ? Colors.green[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.doctor.isVerified ? Icons.verified : Icons.pending,
                  color: widget.doctor.isVerified
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.doctor.isVerified
                          ? 'Verified Doctor'
                          : 'Pending Verification',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.doctor.isVerified
                          ? 'Your account is verified and active'
                          : 'Your account is under review',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusItem(
                  'Status',
                  widget.doctor.status.toString().split('.').last.toUpperCase(),
                  _getStatusColor(widget.doctor.status),
                ),
              ),
              Expanded(
                child: _buildStatusItem(
                  'Rating',
                  '${widget.doctor.rating.toStringAsFixed(1)} ⭐',
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSocialMediaSection() {
    final platforms = ['LinkedIn', 'Twitter', 'Facebook', 'Instagram'];

    return Container(
      padding: const EdgeInsets.all(16),
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
        children: platforms.map((platform) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              initialValue: _socialMedia[platform.toLowerCase()] ?? '',
              decoration: InputDecoration(
                labelText: '$platform URL',
                prefixIcon: Icon(_getSocialIcon(platform)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isNotEmpty) {
                    _socialMedia[platform.toLowerCase()] = value;
                  } else {
                    _socialMedia.remove(platform.toLowerCase());
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(
            widget.doctor.isAvailable ? Icons.check_circle : Icons.cancel,
            color: widget.doctor.isAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available for Appointments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  widget.doctor.isAvailable
                      ? 'Patients can book appointments with you'
                      : 'You are currently unavailable for new appointments',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: widget.doctor.isAvailable,
            onChanged: (value) async {
              try {
                await FirebaseFirestore.instance
                    .collection('doctors')
                    .doc(widget.doctor.id)
                    .update({
                      'isAvailable': value,
                      'updatedAt': DateTime.now(),
                    });

                widget.onDoctorUpdated(
                  widget.doctor.copyWith(isAvailable: value),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating availability: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.lock_outline, color: Colors.blue),
          title: const Text('Change Password'),
          subtitle: const Text('Update your account password'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Implement change password
          },
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Deactivate Account'),
          subtitle: const Text('Temporarily disable your account'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Implement account deactivation
          },
        ),
      ],
    );
  }

  void _addCertification() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Certification'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Certification Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _certifications.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Color _getStatusColor(DoctorStatus status) {
    switch (status) {
      case DoctorStatus.active:
        return Colors.green;
      case DoctorStatus.pending:
        return Colors.orange;
      case DoctorStatus.suspended:
        return Colors.red;
      case DoctorStatus.inactive:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'linkedin':
        return Icons.business;
      case 'twitter':
        return Icons.alternate_email;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      default:
        return Icons.link;
    }
  }
}
