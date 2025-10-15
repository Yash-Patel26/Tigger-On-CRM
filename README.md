# 🏢 TiggerOn CRM - Real Estate Management System

A comprehensive Flutter-based Customer Relationship Management (CRM) system designed specifically for real estate businesses. Features advanced call recording capabilities, cloud storage integration, and a modern Material Design interface.

## 🌟 Key Features

### 📞 **Advanced Call Recording System**
- **Automatic Call Recording**: Records calls automatically when connected (OFFHOOK state)
- **Smart Audio Capture**: Uses VOICE_COMMUNICATION → VOICE_RECOGNITION → MIC fallback for optimal audio quality
- **Speakerphone Integration**: Automatically enables speakerphone during recording for better remote party pickup
- **Cloud Storage**: Automatic upload of recordings to Supabase Storage with public URL generation
- **Connectivity Monitoring**: Auto-disconnects calls when internet connection is lost
- **Permission Management**: Handles microphone, phone, and notification permissions seamlessly

### 🏠 **Real Estate CRM Features**
- **Lead Management**: Complete lead lifecycle from creation to conversion
- **Customer Management**: Comprehensive customer profiles and interaction tracking
- **Vendor Management**: Vendor onboarding, KYC, and service information management
- **Project Management**: Track active projects, pricing logs, and project statistics
- **Site Visit Scheduling**: Schedule and manage property site visits
- **Booking Management**: Handle property bookings and reservations
- **Ticket System**: Support ticket management and tracking
- **Developer Management**: Manage real estate developers and their projects

### 📊 **Analytics & Reporting**
- **Dashboard Analytics**: Comprehensive dashboard with key metrics
- **Quick Stats**: City-wise, location-wise, and property type statistics
- **Call Statistics**: Detailed call analytics and performance metrics
- **Project Management Stats**: Project progress and performance tracking

### 🎨 **Modern UI/UX**
- **Material Design 3**: Modern Material Design implementation
- **Dark/Light Themes**: Complete theme support with custom color schemes
- **Responsive Design**: Optimized for various screen sizes
- **Lottie Animations**: Engaging animations for better user experience
- **Smooth Transitions**: Custom page transitions for better navigation

## 🛠️ Technical Stack

### **Frontend**
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language (SDK ^3.9.0)
- **Material Design 3**: Modern UI components and theming

### **Backend Integration**
- **Supabase**: Backend-as-a-Service for authentication and storage
- **REST API**: Custom API integration (`https://api.tiggeron.com/v1`)
- **HTTP Client**: Robust HTTP client with retry mechanisms

### **Native Android Integration**
- **Kotlin**: Android native development
- **MediaRecorder**: Audio recording capabilities
- **TelephonyManager**: Call state monitoring
- **Foreground Service**: Background recording service
- **MethodChannel**: Flutter-Native communication

### **Key Dependencies**
```yaml
dependencies:
  flutter_svg: ^2.2.1          # SVG support
  lottie: ^3.1.2               # Animations
  url_launcher: ^6.3.1         # External app launching
  permission_handler: ^12.0.1  # Permission management
  connectivity_plus: ^7.0.0   # Network connectivity
  supabase_flutter: ^2.6.0     # Backend services
  infinite_scroll_pagination: ^5.1.1  # Pagination
  shared_preferences: ^2.2.3   # Local storage
  audioplayers: ^6.1.0         # Audio playback
  http: ^1.2.2                 # HTTP requests
```

## 📱 Screenshots

### Main Features
- **Dashboard**: Overview of key metrics and quick actions
- **Lead Management**: Lead creation, editing, and tracking
- **Call Recording**: Automatic recording with cloud upload
- **Project Management**: Project tracking and analytics
- **Vendor Management**: Vendor onboarding and management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.0)
- Android Studio / VS Code
- Android device/emulator (API level 21+)
- Supabase account for cloud storage

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Yash-Patel26/Tigger-On-CRM.git
   cd Tigger-On-CRM
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Update `lib/utils/constants.dart` with your Supabase credentials:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Create Supabase Storage Bucket**
   - Create a bucket named `recordings` in your Supabase project
   - Set appropriate RLS policies for upload access

5. **Run the application**
   ```bash
   flutter run
   ```

### Android Permissions
The app requires the following permissions (automatically requested):
- `RECORD_AUDIO`: For call recording
- `CALL_PHONE`: For making phone calls
- `READ_PHONE_STATE`: For call state monitoring
- `POST_NOTIFICATIONS`: For recording notifications
- `FOREGROUND_SERVICE`: For background recording service
- `FOREGROUND_SERVICE_MICROPHONE`: For microphone access in background
- `FOREGROUND_SERVICE_PHONE_CALL`: For phone call service

## 🏗️ Project Structure

```
lib/
├── api_helper/           # API helper utilities
├── api_modal/           # API data transfer objects
├── api_network/         # Network layer
├── features/           # Feature-specific modules
├── models/              # Data models
├── onboarding/          # Authentication screens
├── repositories/        # Data repositories
├── screens/             # UI screens
├── services/            # Business logic services
├── splash/              # Splash screen
├── utils/               # Utility functions and constants
└── main.dart           # Application entry point
```

### Key Files
- `lib/main.dart`: App initialization and theme configuration
- `lib/utils/helpers.dart`: Call recording and utility functions
- `lib/services/supabase_service.dart`: Supabase integration
- `android/app/src/main/kotlin/com/example/tigger/CallRecorderService.kt`: Android recording service
- `android/app/src/main/kotlin/com/example/tigger/MainActivity.kt`: Android native integration

## 📞 Call Recording System

### How It Works
1. **Call Initiation**: User taps call button → permissions requested → native call started
2. **Recording Start**: Service monitors call state → starts recording on OFFHOOK
3. **Audio Capture**: Uses optimal audio source with fallback chain
4. **Call End**: Recording stops on IDLE state → file saved locally
5. **Cloud Upload**: File uploaded to Supabase Storage → public URL generated
6. **User Feedback**: Success/failure notification shown to user

### Technical Details
- **Audio Sources**: VOICE_COMMUNICATION → VOICE_RECOGNITION → MIC
- **File Format**: MPEG-4 (.m4a) with AAC encoding
- **Quality**: 44.1kHz sampling rate, 96kbps bitrate
- **Storage**: Local Android storage → Supabase cloud storage
- **Fallback**: 5-second timeout if OFFHOOK not detected

## 🔧 Configuration

### Supabase Setup
1. Create a new Supabase project
2. Create a storage bucket named `recordings`
3. Set RLS policies for upload access
4. Update credentials in `lib/utils/constants.dart`

### API Configuration
- Update `baseUrl` in `lib/utils/constants.dart` if using custom API
- Configure timeout and retry settings as needed

## 🧪 Testing

### Call Recording Test
1. Grant all required permissions
2. Make a test call from any lead/customer screen
3. Answer the call and speak for a few seconds
4. Hang up and wait for upload confirmation
5. Check Supabase storage for the uploaded file

### Debug Information
- Check Logcat for `CallRecorderService` logs
- Monitor console for Supabase connectivity status
- Verify file existence in Android storage: `Android/data/<package>/files/Music/calls/`

## 🚨 Known Limitations

### Call Recording
- **Remote Audio**: Some Android versions/OEMs block remote party audio capture
- **Device Compatibility**: Recording quality varies across devices
- **Network Dependency**: Requires internet for cloud upload

### Recommendations
- Test on multiple devices for compatibility
- Consider VoIP SDK for guaranteed two-way audio recording
- Implement local storage backup for offline scenarios

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Yash Patel**
- GitHub: [@Yash-Patel26](https://github.com/Yash-Patel26)
- Repository: [Tigger-On-CRM](https://github.com/Yash-Patel26/Tigger-On-CRM)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for backend services
- Material Design team for UI guidelines
- Android team for native integration capabilities

---

**Note**: This is a real estate CRM system with advanced call recording capabilities. Ensure compliance with local laws regarding call recording and data privacy when deploying in production.