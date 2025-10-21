class AppConstants {
  // Color Schema - Custom Blue-Green Theme
  static const int primaryColor = 0xFF1E88E5; // accent for controls
  static const int primaryColorLight = 0xFF42A5F5;
  static const int primaryColorDark = 0xFF1565C0;
  static const int secondaryColor = 0xFF1E88E5;
  static const int accentColor = 0xFF1E88E5;
  static const int surfaceColor = 0xFFE1F0E4; // new surface/background
  static const int backgroundColor = 0xFFE1F0E4;
  static const int onSurfaceColor = 0xFF2A2A2A;
  static const int onBackgroundColor = 0xFF2A2A2A;
  static const int darkSurfaceColor = 0xFF1A1A1A;
  static const int darkBackgroundColor = 0xFF1A1A1A;
  static const int darkOnSurfaceColor = 0xFFEAF7FC;
  static const int darkOnBackgroundColor = 0xFFEAF7FC;

  // API Configuration
  // Update this per-environment. Examples:
  //  - Android emulator to local backend: http://10.0.2.2:3000/v1
  //  - iOS simulator to local backend: http://127.0.0.1:3000/v1
  //  - Staging: https://staging.your-domain.com/v1
  //  - Production: https://api.your-domain.com/v1
  static const String baseUrl = 'https://api.tiggeron.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Configuration
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 1000;

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxNotesLength = 2000;

  // Date Formats
  static const String dateFormat = 'dd-MM-yyyy';
  static const String dateTimeFormat = 'dd-MM-yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';
  static const String apiDateTimeFormat = 'yyyy-MM-ddTHH:mm:ss';

  // Currency
  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₹';

  // Supabase Configuration
  static const String supabaseUrl = 'https://tyntmzyinafmuwzirifb.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5bnRtenlpbmFmbXV3emlyaWZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAzODgxMTQsImV4cCI6MjA3NTk2NDExNH0.DMSdKcF-d17qS4u2bCUhNrsf7rExAehrug7waRTFlvc';
  static const String recordingsBucket = 'recordings';
  static const String recordingsFolder = 'calls';

  // Lead Status Colors
  static const Map<String, int> leadStatusColors = {
    'hot': 0xFF1E88E5,
    'warm': 0xFF1E88E5,
    'cold': 0xFF1E88E5,
  };

  // Lead Sub Status Colors
  static const Map<String, int> leadSubStatusColors = {
    'newLead': 0xFFE55934, // Primary Orange
    'inProgress': 0xFFE55934, // Primary Orange
    'closed': 0xFF9E9E9E, // Grey
  };

  // Booking Status Colors
  static const Map<String, int> bookingStatusColors = {
    'pending': 0xFFE55934, // Primary Orange
    'confirmed': 0xFFE55934, // Primary Orange
    'cancelled': 0xFFE55934, // Primary Orange
    'completed': 0xFFE55934, // Primary Orange
  };

  // Site Visit Status Colors
  static const Map<String, int> siteVisitStatusColors = {
    'scheduled': 0xFFE55934, // Primary Orange
    'completed': 0xFFE55934, // Primary Orange
    'cancelled': 0xFFE55934, // Primary Orange
    'rescheduled': 0xFFE55934, // Primary Orange
  };

  // Project Status Colors
  static const Map<String, int> projectStatusColors = {
    'planning': 0xFFE55934, // Primary Orange
    'underConstruction': 0xFFE55934, // Primary Orange
    'completed': 0xFFE55934, // Primary Orange
    'onHold': 0xFFE55934, // Primary Orange
    'cancelled': 0xFF9E9E9E, // Grey
  };

  // Property Types
  static const List<String> propertyTypes = [
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4 BHK',
    '5 BHK',
    'Villa',
    'Penthouse',
    'Studio',
    'Duplex',
    'Plot',
    'Commercial',
    'Office',
    'Shop',
    'Warehouse',
  ];

  // Amenities
  static const List<String> commonAmenities = [
    'Swimming Pool',
    'Gym',
    'Parking',
    'Security',
    'Lift',
    'Power Backup',
    'Water Supply',
    'Garden',
    'Playground',
    'Club House',
    'Shopping Mall',
    'Hospital',
    'School',
    'Metro Station',
    'Airport',
  ];

  // Cities
  static const List<String> majorCities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Surat',
    'Lucknow',
    'Kanpur',
    'Nagpur',
    'Indore',
    'Thane',
    'Bhopal',
    'Visakhapatnam',
    'Pimpri-Chinchwad',
    'Patna',
    'Vadodara',
  ];

  // States
  static const List<String> states = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

  // Error Messages
  static const String networkErrorMessage =
      'No internet connection. Please check your network.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String timeoutErrorMessage =
      'Request timeout. Please try again.';
  static const String unknownErrorMessage = 'An unexpected error occurred.';
  static const String validationErrorMessage =
      'Please check your input and try again.';

  // Success Messages
  static const String leadCreatedMessage = 'Lead created successfully';
  static const String leadUpdatedMessage = 'Lead updated successfully';
  static const String leadDeletedMessage = 'Lead deleted successfully';
  static const String customerCreatedMessage = 'Customer created successfully';
  static const String customerUpdatedMessage = 'Customer updated successfully';
  static const String bookingCreatedMessage = 'Booking created successfully';
  static const String siteVisitScheduledMessage =
      'Site visit scheduled successfully';

  // App Information
  static const String appName = 'TiggerOn';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Real Estate Management System';

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Debounce Duration
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration apiDebounce = Duration(milliseconds: 300);
}
