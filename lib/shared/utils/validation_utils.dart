import 'package:intl/intl.dart';

class ValidationUtils {
  /// Validates Aadhar number - must be exactly 12 digits
  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhar number is required';
    }

    // Remove any spaces or special characters
    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedValue.length != 12) {
      return 'Aadhar number must be exactly 12 digits';
    }

    // Check if all digits are the same (invalid Aadhar)
    if (cleanedValue.split('').every((digit) => digit == cleanedValue[0])) {
      return 'Invalid Aadhar number';
    }

    return null;
  }

  /// Validates PAN card number - must be 10 characters in format: AAAAA9999A
  static String? validatePAN(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN number is required';
    }

    final cleanedValue = value.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );

    if (cleanedValue.length != 10) {
      return 'PAN number must be exactly 10 characters';
    }

    // PAN format: AAAAA9999A (5 letters, 4 digits, 1 letter)
    final panPattern = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panPattern.hasMatch(cleanedValue)) {
      return 'Invalid PAN format. Should be like: ABCDE1234F';
    }

    return null;
  }

  /// Validates Date of Birth - must be at least 18 years old
  static String? validateDOB(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }

    try {
      final dob = DateTime.parse(value);
      final now = DateTime.now();
      final age = now.year - dob.year;

      // Check if birthday has occurred this year
      final birthdayThisYear = DateTime(now.year, dob.month, dob.day);
      final actualAge = birthdayThisYear.isAfter(now) ? age - 1 : age;

      if (actualAge < 18) {
        return 'You must be at least 18 years old';
      }

      if (actualAge > 100) {
        return 'Please enter a valid date of birth';
      }

      return null;
    } catch (e) {
      return 'Please enter a valid date';
    }
  }

  /// Validates phone number - basic validation for Indian numbers
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedValue.length < 10 || cleanedValue.length > 12) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailPattern = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailPattern.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates pincode - must be 6 digits
  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Pincode is required';
    }

    final cleanedValue = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanedValue.length != 6) {
      return 'Pincode must be exactly 6 digits';
    }

    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Formats Aadhar number with spaces for display
  static String formatAadhar(String aadhar) {
    final cleaned = aadhar.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 12) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 8)} ${cleaned.substring(8, 12)}';
    }
    return aadhar;
  }

  /// Formats PAN number for display
  static String formatPAN(String pan) {
    final cleaned = pan.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (cleaned.length == 10) {
      return '${cleaned.substring(0, 5)}${cleaned.substring(5, 9)}${cleaned.substring(9)}';
    }
    return pan;
  }

  /// Formats date for display
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Calculates age from date of birth
  static int calculateAge(String dobString) {
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;

      // Check if birthday has occurred this year
      final birthdayThisYear = DateTime(now.year, dob.month, dob.day);
      if (birthdayThisYear.isAfter(now)) {
        age--;
      }

      return age;
    } catch (e) {
      return 0;
    }
  }
}
