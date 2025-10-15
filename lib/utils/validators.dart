class Validators {
  // Email validation
  static String? email(String? value) {
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

  // Phone number validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove all non-digit characters
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (cleanPhone.length > 15) {
      return 'Phone number must not exceed 15 digits';
    }

    return null;
  }

  // Required field validation
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  // Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.trim().length > 100) {
      return 'Name must not exceed 100 characters';
    }

    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value.trim())) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    return null;
  }

  // Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password must not exceed 128 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // PAN number validation
  static String? pan(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN number is required';
    }

    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid PAN number';
    }

    return null;
  }

  // GSTIN validation
  static String? gstin(String? value) {
    if (value == null || value.isEmpty) {
      return 'GSTIN is required';
    }

    final gstinRegex = RegExp(
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$',
    );
    if (!gstinRegex.hasMatch(value.toUpperCase())) {
      return 'Please enter a valid GSTIN';
    }

    return null;
  }

  // Aadhar number validation
  static String? aadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhar number is required';
    }

    final cleanAadhar = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanAadhar.length != 12) {
      return 'Aadhar number must be 12 digits';
    }

    return null;
  }

  // Pincode validation
  static String? pincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }

    final cleanPincode = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPincode.length != 6) {
      return 'Pincode must be 6 digits';
    }

    return null;
  }

  // Amount validation
  static String? amount(String? value, {double? minAmount, double? maxAmount}) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    if (minAmount != null && amount < minAmount) {
      return 'Amount must be at least $minAmount';
    }

    if (maxAmount != null && amount > maxAmount) {
      return 'Amount must not exceed $maxAmount';
    }

    return null;
  }

  // Date validation
  static String? date(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Future date validation
  static String? futureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isBefore(DateTime.now())) {
        return 'Date must be in the future';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // Past date validation
  static String? pastDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }

    try {
      final date = DateTime.parse(value);
      if (date.isAfter(DateTime.now())) {
        return 'Date must be in the past';
      }
      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  // URL validation
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }

    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Description validation
  static String? description(String? value, {int maxLength = 1000}) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.length > maxLength) {
      return 'Description must not exceed $maxLength characters';
    }

    return null;
  }

  // Notes validation
  static String? notes(String? value, {int maxLength = 2000}) {
    if (value == null || value.isEmpty) {
      return null; // Notes are optional
    }

    if (value.length > maxLength) {
      return 'Notes must not exceed $maxLength characters';
    }

    return null;
  }

  // Multi-select validation
  static String? multiSelect(
    List<String>? value, {
    int? minItems,
    int? maxItems,
  }) {
    if (value == null || value.isEmpty) {
      if (minItems != null && minItems > 0) {
        return 'Please select at least $minItems item(s)';
      }
      return null;
    }

    if (minItems != null && value.length < minItems) {
      return 'Please select at least $minItems item(s)';
    }

    if (maxItems != null && value.length > maxItems) {
      return 'Please select no more than $maxItems item(s)';
    }

    return null;
  }

  // File validation
  static String? file(
    String? value, {
    List<String>? allowedExtensions,
    int? maxSizeInMB,
  }) {
    if (value == null || value.isEmpty) {
      return 'File is required';
    }

    if (allowedExtensions != null) {
      final extension = value.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return 'File type not allowed. Allowed types: ${allowedExtensions.join(', ')}';
      }
    }

    // Note: File size validation would typically be done when the file is actually selected
    // This is just a placeholder for the validation logic

    return null;
  }

  // Custom validation
  static String? custom(
    String? value,
    bool Function(String) validator,
    String errorMessage,
  ) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    if (!validator(value)) {
      return errorMessage;
    }

    return null;
  }
}
