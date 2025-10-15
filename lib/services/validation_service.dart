class ValidationService {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < 0 || age > 150) {
      return 'Please enter a valid age between 0 and 150';
    }

    return null;
  }

  // Height validation
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }

    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid height';
    }

    if (height < 50 || height > 300) {
      return 'Please enter a valid height between 50 and 300 cm';
    }

    return null;
  }

  // Weight validation
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid weight';
    }

    if (weight < 10 || weight > 500) {
      return 'Please enter a valid weight between 10 and 500 kg';
    }

    return null;
  }

  // Blood type validation
  static String? validateBloodType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Blood type is required';
    }

    final validBloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
    if (!validBloodTypes.contains(value.toUpperCase())) {
      return 'Please enter a valid blood type (A+, A-, B+, B-, AB+, AB-, O+, O-)';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }

    if (value.length < 10) {
      return 'Address must be at least 10 characters long';
    }

    if (value.length > 200) {
      return 'Address must be less than 200 characters';
    }

    return null;
  }

  // City validation
  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }

    if (value.length < 2) {
      return 'City must be at least 2 characters long';
    }

    if (value.length > 50) {
      return 'City must be less than 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'City can only contain letters and spaces';
    }

    return null;
  }

  // Bio validation
  static String? validateBio(String? value) {
    if (value != null && value.length > 500) {
      return 'Bio must be less than 500 characters';
    }

    return null;
  }

  // Emergency contact name validation
  static String? validateEmergencyContactName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Emergency contact name is required';
    }

    if (value.length < 2) {
      return 'Emergency contact name must be at least 2 characters long';
    }

    if (value.length > 50) {
      return 'Emergency contact name must be less than 50 characters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Emergency contact name can only contain letters and spaces';
    }

    return null;
  }

  // Emergency contact phone validation
  static String? validateEmergencyContactPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Emergency contact phone is required';
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid emergency contact phone number';
    }

    return null;
  }

  // Appointment description validation
  static String? validateAppointmentDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Appointment description is required';
    }

    if (value.length < 10) {
      return 'Description must be at least 10 characters long';
    }

    if (value.length > 500) {
      return 'Description must be less than 500 characters';
    }

    return null;
  }

  // Doctor name validation
  static String? validateDoctorName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Doctor name is required';
    }

    if (value.length < 2) {
      return 'Doctor name must be at least 2 characters long';
    }

    if (value.length > 100) {
      return 'Doctor name must be less than 100 characters';
    }

    return null;
  }

  // Doctor specialization validation
  static String? validateDoctorSpecialization(String? value) {
    if (value == null || value.isEmpty) {
      return 'Doctor specialization is required';
    }

    if (value.length < 2) {
      return 'Specialization must be at least 2 characters long';
    }

    if (value.length > 100) {
      return 'Specialization must be less than 100 characters';
    }

    return null;
  }

  // Doctor address validation
  static String? validateDoctorAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Doctor address is required';
    }

    if (value.length < 10) {
      return 'Address must be at least 10 characters long';
    }

    if (value.length > 200) {
      return 'Address must be less than 200 characters';
    }

    return null;
  }

  // Doctor phone validation
  static String? validateDoctorPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Doctor phone number is required';
    }

    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // Doctor email validation
  static String? validateDoctorEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Doctor email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Doctor rating validation
  static String? validateDoctorRating(String? value) {
    if (value == null || value.isEmpty) {
      return 'Rating is required';
    }

    final rating = double.tryParse(value);
    if (rating == null) {
      return 'Please enter a valid rating';
    }

    if (rating < 1.0 || rating > 5.0) {
      return 'Rating must be between 1.0 and 5.0';
    }

    return null;
  }

  // Doctor consultation fee validation
  static String? validateConsultationFee(String? value) {
    if (value == null || value.isEmpty) {
      return 'Consultation fee is required';
    }

    final fee = double.tryParse(value);
    if (fee == null) {
      return 'Please enter a valid consultation fee';
    }

    if (fee < 0) {
      return 'Consultation fee cannot be negative';
    }

    if (fee > 10000) {
      return 'Consultation fee cannot exceed 10,000';
    }

    return null;
  }

  // Date validation
  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    final date = DateTime.tryParse(value);
    if (date == null) {
      return 'Please enter a valid date';
    }

    if (date.isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      return 'Date cannot be in the past';
    }

    if (date.isAfter(DateTime.now().add(Duration(days: 365)))) {
      return 'Date cannot be more than 1 year in the future';
    }

    return null;
  }

  // Time validation
  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Time is required';
    }

    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    if (!timeRegex.hasMatch(value)) {
      return 'Please enter a valid time (HH:MM)';
    }

    return null;
  }

  // Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  // Minimum length validation
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    return null;
  }

  // Maximum length validation
  static String? validateMaxLength(
    String? value,
    int maxLength,
    String fieldName,
  ) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  // Numeric validation
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return 'Please enter a valid $fieldName';
    }

    return null;
  }

  // Integer validation
  static String? validateInteger(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (int.tryParse(value) == null) {
      return 'Please enter a valid $fieldName';
    }

    return null;
  }

  // URL validation
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,}(\/.*)?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // File size validation
  static String? validateFileSize(int? fileSize, int maxSizeInMB) {
    if (fileSize == null) {
      return 'File size is required';
    }

    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    if (fileSize > maxSizeInBytes) {
      return 'File size must be less than $maxSizeInMB MB';
    }

    return null;
  }

  // File type validation
  static String? validateFileType(String? fileName, List<String> allowedTypes) {
    if (fileName == null || fileName.isEmpty) {
      return 'File name is required';
    }

    final extension = fileName.split('.').last.toLowerCase();
    if (!allowedTypes.contains(extension)) {
      return 'File type must be one of: ${allowedTypes.join(', ')}';
    }

    return null;
  }
}




