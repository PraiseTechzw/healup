import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healup/models/user_model.dart';
import 'package:healup/services/database_service.dart';
import 'package:healup/services/validation_service.dart';
import 'package:healup/services/utility_service.dart';
import 'package:healup/services/error_service.dart';
import 'dart:io';

class ProfileEditScreen extends StatefulWidget {
  final UserModel userModel;

  const ProfileEditScreen({Key? key, required this.userModel})
    : super(key: key);

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  File? _selectedImage;
  String? _selectedAvatarAsset;
  bool _isLoading = false;
  DateTime? _selectedBirthDate;
  Gender? _selectedGender;
  String? _selectedBloodType;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.userModel.name;
    _emailController.text = widget.userModel.email;
    _phoneController.text = widget.userModel.phone ?? '';
    _bioController.text = widget.userModel.bio ?? '';
    _cityController.text = widget.userModel.city ?? '';
    _addressController.text = widget.userModel.address ?? '';
    _birthDateController.text = widget.userModel.birthDate != null
        ? UtilityService.formatDate(widget.userModel.birthDate!)
        : '';
    _emergencyContactNameController.text =
        widget.userModel.emergencyContactName ?? '';
    _emergencyContactPhoneController.text =
        widget.userModel.emergencyContactPhone ?? '';
    _selectedGender = widget.userModel.gender;
    _selectedBloodType = widget.userModel.bloodType;
    _selectedBirthDate = widget.userModel.birthDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.indigo[600],
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImageSection(),
                    SizedBox(height: 24),
                    _buildBasicInfoSection(),
                    SizedBox(height: 24),
                    _buildPersonalInfoSection(),
                    SizedBox(height: 24),
                    _buildMedicalInfoSection(),
                    SizedBox(height: 24),
                    _buildEmergencyContactSection(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Profile Photo',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_selectedAvatarAsset != null
                          ? AssetImage(_selectedAvatarAsset!)
                          : (widget.userModel.profileImage != null
                                    ? (widget.userModel.profileImage!
                                              .startsWith('assets/')
                                          ? AssetImage(
                                              widget.userModel.profileImage!,
                                            )
                                          : CachedNetworkImageProvider(
                                              widget.userModel.profileImage!,
                                            ))
                                    : null)
                                as ImageProvider<Object>?),
                child:
                    _selectedImage == null &&
                        _selectedAvatarAsset == null &&
                        widget.userModel.profileImage == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _openAvatarPicker,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _openAvatarPicker,
                icon: Icon(Icons.person, size: 18),
                label: Text('Choose Avatar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[100],
                  foregroundColor: Colors.indigo,
                  elevation: 0,
                ),
              ),
              if (_selectedImage != null ||
                  _selectedAvatarAsset != null ||
                  widget.userModel.profileImage != null)
                ElevatedButton.icon(
                  onPressed: _removeImage,
                  icon: Icon(Icons.delete, size: 18),
                  label: Text('Remove'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red,
                    elevation: 0,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      icon: FontAwesomeIcons.user,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Full Name',
          icon: Icons.person,
          validator: ValidationService.validateName,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          icon: Icons.email,
          enabled: false, // Email cannot be changed
          validator: ValidationService.validateEmail,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Phone Number',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: ValidationService.validatePhone,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: 'Bio',
          icon: Icons.info,
          maxLines: 3,
          validator: ValidationService.validateBio,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      title: 'Personal Information',
      icon: FontAwesomeIcons.idCard,
      children: [
        _buildTextField(
          controller: _cityController,
          label: 'City',
          icon: Icons.location_city,
          validator: ValidationService.validateCity,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: 'Address',
          icon: Icons.home,
          maxLines: 2,
          validator: ValidationService.validateAddress,
        ),
        SizedBox(height: 16),
        _buildDateField(),
        SizedBox(height: 16),
        _buildGenderDropdown(),
        SizedBox(height: 16),
        _buildBloodTypeDropdown(),
      ],
    );
  }

  Widget _buildMedicalInfoSection() {
    return _buildSection(
      title: 'Medical Information',
      icon: FontAwesomeIcons.heartPulse,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Text(
                    'Medical Information',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'For detailed medical information including allergies, conditions, and medications, please use the Medical Information section.',
                style: GoogleFonts.lato(fontSize: 14, color: Colors.blue[600]),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Navigate to medical info screen
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/medical-info');
                },
                child: Text('Manage Medical Info'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyContactSection() {
    return _buildSection(
      title: 'Emergency Contact',
      icon: FontAwesomeIcons.phone,
      children: [
        _buildTextField(
          controller: _emergencyContactNameController,
          label: 'Emergency Contact Name',
          icon: Icons.person,
          validator: ValidationService.validateEmergencyContactName,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _emergencyContactPhoneController,
          label: 'Emergency Contact Phone',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: ValidationService.validateEmergencyContactPhone,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.indigo[600], size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
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
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.indigo[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo[600]!),
        ),
        filled: true,
        fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: _selectBirthDate,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.indigo[600]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _birthDateController.text.isEmpty
                    ? 'Select Birth Date'
                    : _birthDateController.text,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: _birthDateController.text.isEmpty
                      ? Colors.grey[500]
                      : Colors.grey[800],
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<Gender>(
      value: _selectedGender,
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.person, color: Colors.indigo[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: Gender.values.map((Gender gender) {
        return DropdownMenuItem<Gender>(
          value: gender,
          child: Text(gender.toString().split('.').last),
        );
      }).toList(),
      onChanged: (Gender? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
    );
  }

  Widget _buildBloodTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: InputDecoration(
        labelText: 'Blood Type',
        prefixIcon: Icon(Icons.bloodtype, color: Colors.indigo[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: _bloodTypes.map((String bloodType) {
        return DropdownMenuItem<String>(
          value: bloodType,
          child: Text(bloodType),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedBloodType = newValue;
        });
      },
    );
  }

  // Removed image picking from gallery/camera in favor of predefined avatars

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedAvatarAsset = null;
    });
  }

  void _openAvatarPicker() {
    final List<String> avatarAssets = [
      'assets/person.jpg',
      'assets/doc.png',
      'assets/vector-doc.jpg',
      'assets/vector-doc2.jpg',
      'assets/19835.jpg',
      'assets/19834.jpg',
      'assets/image-medical.jpg',
      'assets/image-medical-2.jpg',
    ];
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.all(16),
            height: 360,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose an Avatar',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: avatarAssets.length,
                    itemBuilder: (context, index) {
                      final asset = avatarAssets[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatarAsset = asset;
                            _selectedImage = null;
                          });
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(backgroundImage: AssetImage(asset)),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedBirthDate ??
          DateTime.now().subtract(Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
        _birthDateController.text = UtilityService.formatDate(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final String? newProfileImage =
          _selectedAvatarAsset ?? widget.userModel.profileImage;

      final updatedUser = widget.userModel.copyWith(
        name: _nameController.text,
        phone: _phoneController.text,
        bio: _bioController.text,
        city: _cityController.text,
        address: _addressController.text,
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        bloodType: _selectedBloodType,
        emergencyContactName: _emergencyContactNameController.text,
        emergencyContactPhone: _emergencyContactPhoneController.text,
        profileImage: newProfileImage,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.updateUser(updatedUser);

      // Update Firebase Auth display name
      if (widget.userModel.name != _nameController.text) {
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          _nameController.text,
        );
      }

      ErrorService.showSuccessSnackBar(
        context,
        'Profile updated successfully!',
      );
      Navigator.pop(context, true);
    } catch (e) {
      ErrorService.showErrorSnackBar(context, 'Failed to update profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
