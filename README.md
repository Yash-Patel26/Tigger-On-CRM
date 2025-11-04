# 🏢 TiggerOn CRM - Real Estate Management System

A comprehensive Flutter-based Customer Relationship Management (CRM) system designed specifically for real estate businesses. Features advanced call recording capabilities, cloud storage integration, persistent user sessions, and a modern Material Design interface.

## 🌟 Key Features

### 🔐 **Advanced Authentication & Session Management**
- **Persistent User Sessions**: Users stay logged in between app sessions with automatic session restoration
- **Smart Session Validation**: Automatically validates and refreshes expired tokens
- **Secure Authentication**: Built on Supabase Auth with enterprise-grade security
- **Offline Resilience**: Graceful handling of network issues with retry mechanisms
- **Reactive State Management**: Real-time authentication state updates across the app

### 📞 **Advanced Call Recording System**
- **Automatic Call Recording**: Records calls automatically when connected (OFFHOOK state)
- **Smart Audio Capture**: Uses VOICE_COMMUNICATION → VOICE_RECOGNITION → MIC fallback for optimal audio quality
- **Speakerphone Integration**: Automatically enables speakerphone during recording for better remote party pickup
- **Cloud Storage**: Automatic upload of recordings to Supabase Storage with public URL generation
- **Connectivity Monitoring**: Auto-disconnects calls when internet connection is lost
- **Permission Management**: Handles microphone, phone, and notification permissions seamlessly

### 🏠 **Real Estate CRM Features**
- **Lead Management**: Complete lead lifecycle from creation to conversion with advanced filtering
- **Customer Management**: Comprehensive customer profiles and interaction tracking
- **Vendor Management**: Vendor onboarding, KYC, and service information management
- **Project Management**: Track active projects, pricing logs, and project statistics
- **Site Visit Scheduling**: Schedule and manage property site visits
- **Booking Management**: Handle property bookings and reservations
- **Ticket System**: Support ticket management and tracking
- **Developer Management**: Manage real estate developers and their projects
- **Property Finder**: Advanced property search and filtering capabilities

### 📊 **Analytics & Reporting**
- **Dashboard Analytics**: Comprehensive dashboard with key metrics and real-time updates
- **Quick Stats**: City-wise, location-wise, and property type statistics
- **Call Statistics**: Detailed call analytics and performance metrics
- **Project Management Stats**: Project progress and performance tracking
- **Real-time Notifications**: Live updates for leads, tasks, tickets, and bookings

### 🎨 **Modern UI/UX**
- **Material Design 3**: Modern Material Design implementation
- **Dark/Light Themes**: Complete theme support with custom color schemes
- **Responsive Design**: Optimized for various screen sizes
- **Lottie Animations**: Engaging animations for better user experience
- **Smooth Transitions**: Custom page transitions for better navigation
- **Adaptive Text Scaling**: Automatic text scaling for different screen sizes

## 🛠️ Technical Stack

### **Frontend**
- **Flutter**: Cross-platform mobile development framework
- **Dart**: Programming language (SDK ^3.9.0)
- **Material Design 3**: Modern UI components and theming
- **Provider**: State management and dependency injection

### **Backend Integration**
- **Supabase**: Backend-as-a-Service for authentication, database, and storage
- **REST API**: Custom API integration (`https://api.tiggeron.com/v1`)
- **HTTP Client**: Robust HTTP client with retry mechanisms
- **Real-time Subscriptions**: Live data updates using Supabase Realtime

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
  provider: ^6.1.2             # State management
  supabase_flutter: ^2.6.0     # Backend services
  lottie: ^3.1.2               # Animations
  url_launcher: ^6.3.1         # External app launching
  permission_handler: ^12.0.1   # Permission management
  connectivity_plus: ^7.0.0    # Network connectivity
  infinite_scroll_pagination: ^5.1.1  # Pagination
  shared_preferences: ^2.2.3   # Local storage
  audioplayers: ^6.1.0         # Audio playback
  geolocator: ^14.0.2          # Location services
  file_picker: ^10.0.0         # File selection
  intl: ^0.20.2                # Internationalization
  http: ^1.2.2                 # HTTP requests
```

## 🏗️ Project Architecture

### **Clean Architecture Structure**
```
lib/
├── core/                      # Core application layer
│   ├── config/               # Configuration files
│   ├── constants/            # App constants
│   ├── errors/               # Error handling
│   ├── theme/                # Theme configuration
│   ├── utils/                # Core utilities
│   └── widgets/              # Core widgets
├── data/                     # Data layer
│   ├── api/                  # API DTOs and helpers
│   ├── datasources/          # Data sources
│   ├── models/               # Data models
│   ├── repositories/         # Repository implementations
│   └── services/             # Business logic services
├── presentation/             # Presentation layer
│   ├── pages/                # Page-level widgets
│   │   ├── auth_wrapper.dart # Authentication routing
│   │   └── splash_screen.dart
│   └── screens/              # Feature screens
│       ├── auth/             # Authentication screens
│       ├── dashboard/        # Dashboard and analytics
│       ├── leads/            # Lead management
│       ├── bookings/         # Booking management
│       ├── projects/         # Project management
│       ├── vendors/          # Vendor management
│       ├── profile/          # User profile
│       └── notifications/    # Notification system
├── shared/                   # Shared utilities
│   ├── extensions/           # Dart extensions
│   ├── helpers/              # Helper functions
│   ├── managers/             # State managers
│   ├── utils/                # Utility functions
│   └── widgets/              # Reusable widgets
└── main.dart                 # Application entry point
```

### **Key Architectural Components**

#### **Authentication System**
- **AuthStateManager**: Centralized authentication state management
- **AuthWrapper**: Smart routing based on authentication status
- **Session Persistence**: Automatic session restoration and validation
- **Reactive Updates**: Real-time authentication state changes

#### **Data Layer**
- **Repository Pattern**: Clean separation of data access logic
- **Service Layer**: Business logic and API integration
- **Model Classes**: Type-safe data models with validation
- **DTOs**: Data transfer objects for API communication

#### **State Management**
- **Provider Pattern**: Reactive state management throughout the app
- **ChangeNotifier**: Efficient UI updates and state synchronization
- **Dependency Injection**: Clean dependency management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.9.0)
- Android Studio / VS Code
- Android device/emulator (API level 21+)
- Supabase account for backend services

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
   - Update `lib/core/constants/constants.dart` with your Supabase credentials:
   ```dart
   static const String supabaseUrl = 'YOUR_SUPABASE_URL';
   static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
   ```

4. **Database Setup**
   - Follow the `database_setup_guide.md` for complete database schema setup
   - Create required tables: users, profiles, leads, customers, projects, etc.
   - Set up Row Level Security (RLS) policies

5. **Create Supabase Storage Bucket**
   - Create a bucket named `recordings` in your Supabase project
   - Set appropriate RLS policies for upload access

6. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Running on Emulators

This guide provides detailed instructions for setting up and running the app on Android emulators and iOS simulators.

### Android Emulator Setup

#### Prerequisites
- Android Studio installed
- Android SDK installed (API level 21 or higher)
- Flutter SDK properly configured

#### Step 1: Create an Android Virtual Device (AVD)

1. **Open Android Studio**
   - Launch Android Studio
   - Click on **More Actions** → **Virtual Device Manager** (or Tools → Device Manager)

2. **Create New Device**
   - Click **Create Device**
   - Select a device definition (recommended: **Pixel 6** or **Pixel 7**)
   - Click **Next**

3. **Select System Image**
   - Choose a system image (recommended: **API 33** or **API 34**)
   - If not installed, click **Download** next to the system image
   - Click **Next**

4. **Configure AVD**
   - Name your virtual device (e.g., "Pixel_6_API_33")
   - Review settings and click **Finish**

#### Step 2: Start the Emulator

**Option A: From Android Studio**
- In Virtual Device Manager, click the **Play** button next to your AVD

**Option B: From Command Line**
```bash
# List available emulators
emulator -list-avds

# Start a specific emulator (replace with your AVD name)
emulator -avd Pixel_6_API_33

# Or start emulator in background
emulator -avd Pixel_6_API_33 &
```

#### Step 3: Verify Emulator is Running

```bash
# Check connected devices
flutter devices

# You should see your emulator listed, for example:
# Pixel_6_API_33 • emulator-5554 • android-x86 • Android 13 (API 33) (emulator)
```

#### Step 4: Run the App on Android Emulator

```bash
# Navigate to project directory
cd tigger

# Install dependencies (if not done already)
flutter pub get

# Run on connected emulator
flutter run

# Or specify the device explicitly
flutter run -d emulator-5554

# Run in debug mode with hot reload
flutter run --debug

# Run in release mode
flutter run --release
```

#### Additional Android Emulator Commands

```bash
# View logs
flutter logs

# Hot reload (press 'r' in terminal or save file in IDE)
# Hot restart (press 'R' in terminal)
# Quit (press 'q' in terminal)

# Install app without running
flutter install

# Uninstall app
flutter uninstall

# Check emulator status
adb devices
```

### iOS Simulator Setup (macOS only)

#### Prerequisites
- macOS operating system
- Xcode installed (latest version recommended)
- Xcode Command Line Tools
- CocoaPods installed

#### Step 1: Install Xcode Command Line Tools

```bash
xcode-select --install
```

#### Step 2: Install CocoaPods Dependencies

```bash
cd ios
pod install
cd ..
```

#### Step 3: Open iOS Simulator

**Option A: From Xcode**
- Open Xcode
- Xcode → Open Developer Tool → Simulator

**Option B: From Command Line**
```bash
# List available simulators
xcrun simctl list devices

# Open iOS Simulator
open -a Simulator

# Or launch specific simulator
xcrun simctl boot "iPhone 15 Pro"
```

#### Step 4: Verify Simulator is Running

```bash
# Check connected devices
flutter devices

# You should see your simulator listed, for example:
# iPhone 15 Pro • ABC12345-6789-0123-4567-890123456789 • ios • com.apple.CoreSimulator.SimRuntime.iOS-17-0 (simulator)
```

#### Step 5: Run the App on iOS Simulator

```bash
# Navigate to project directory
cd tigger

# Install dependencies (if not done already)
flutter pub get

# Run on connected simulator
flutter run

# Or specify the device explicitly
flutter run -d ABC12345-6789-0123-4567-890123456789

# Run in debug mode
flutter run --debug

# Run in release mode
flutter run --release
```

### Troubleshooting Emulator Issues

#### Android Emulator Issues

**Problem: Emulator not showing in `flutter devices`**
```bash
# Solution 1: Restart ADB
adb kill-server
adb start-server

# Solution 2: Verify emulator is running
adb devices

# Solution 3: Check Android SDK path
flutter doctor -v
```

**Problem: Emulator is slow**
- Allocate more RAM to emulator (Settings → System → Advanced → Memory)
- Enable hardware acceleration (Settings → System → Advanced → Graphics)
- Use x86_64 system image instead of ARM

**Problem: App crashes on launch**
```bash
# Clear build cache
flutter clean
flutter pub get

# Rebuild app
flutter run --verbose
```

**Problem: Network connectivity issues**
- Ensure emulator has internet access
- Check firewall settings
- Verify API endpoints are accessible

#### iOS Simulator Issues

**Problem: Simulator not found**
```bash
# Reinstall CocoaPods dependencies
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..

# Verify Xcode installation
flutter doctor
```

**Problem: Build errors**
```bash
# Clean build folder
flutter clean
cd ios
pod deintegrate
pod install
cd ..

# Rebuild
flutter run
```

**Problem: App signing issues**
- Open `ios/Runner.xcworkspace` in Xcode
- Select Runner target → Signing & Capabilities
- Set your development team
- Verify Bundle Identifier is unique

### Running on Multiple Devices

You can run the app on multiple emulators/simulators simultaneously:

```bash
# List all available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Example: Run on Android emulator
flutter run -d emulator-5554

# Example: Run on iOS simulator
flutter run -d ABC12345-6789-0123-4567-890123456789
```

### Performance Tips

1. **Enable Hardware Acceleration**
   - Android: Use x86_64 system images with Intel HAXM or Windows Hypervisor
   - iOS: Ensure hardware acceleration is enabled in Xcode

2. **Optimize Emulator Settings**
   - Allocate sufficient RAM (4GB+ recommended)
   - Use SSD storage for better performance
   - Enable GPU acceleration

3. **Use Release Mode for Performance Testing**
   ```bash
   flutter run --release
   ```

4. **Monitor Performance**
   ```bash
   # Enable performance overlay
   flutter run --profile
   ```

### Quick Reference Commands

```bash
# Check Flutter setup
flutter doctor

# List all devices
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device-id>

# Hot reload (while app is running)
# Press 'r' in terminal

# Hot restart (while app is running)
# Press 'R' in terminal

# Stop app (while app is running)
# Press 'q' in terminal

# View logs
flutter logs

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Upgrade Flutter
flutter upgrade
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
- `ACCESS_FINE_LOCATION`: For location-based features
- `READ_EXTERNAL_STORAGE`: For file picker functionality

## 🔐 Authentication & Session Management

### How It Works
1. **App Startup**: AuthStateManager automatically checks for existing Supabase sessions
2. **Session Validation**: Validates session expiry and refreshes tokens if needed
3. **Smart Routing**: AuthWrapper routes users to appropriate screens based on auth status
4. **State Synchronization**: All authentication changes are reflected across the app
5. **Offline Handling**: Graceful degradation when network is unavailable

### Key Features
- **Persistent Sessions**: Users stay logged in between app sessions
- **Automatic Token Refresh**: Seamless token renewal without user intervention
- **Network Resilience**: Handles connectivity issues with retry mechanisms
- **Secure Storage**: Leverages Supabase's built-in secure session storage

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

## 📊 Database Schema

### Core Tables
- **users**: System users (admins, managers, sales executives)
- **profiles**: Extended user profile information
- **leads**: Lead management and tracking
- **customers**: Customer profiles and interactions
- **projects**: Real estate project management
- **bookings**: Property booking management
- **site_visits**: Site visit scheduling and tracking
- **tickets**: Support ticket system
- **vendors**: Vendor management and KYC
- **developers**: Real estate developer management
- **tasks**: Task management and assignment

### Key Features
- **UUID Primary Keys**: Scalable and distributed-friendly
- **JSONB Fields**: Flexible metadata storage
- **Audit Trails**: Created/updated timestamps and user tracking
- **Row Level Security**: Secure data access with RLS policies
- **Real-time Subscriptions**: Live data updates

## 🔧 Configuration

### Supabase Setup
1. Create a new Supabase project
2. Set up database schema using provided migration files
3. Create storage bucket named `recordings`
4. Configure RLS policies for data security
5. Update credentials in `lib/core/constants/constants.dart`

### API Configuration
- Update `baseUrl` in constants if using custom API
- Configure timeout and retry settings as needed
- Set up proper error handling and logging

## 🧪 Testing

### Session Persistence Test
1. Login to the application
2. Close the app completely
3. Reopen the app
4. Verify user is automatically logged in

### Call Recording Test
1. Grant all required permissions
2. Make a test call from any lead/customer screen
3. Answer the call and speak for a few seconds
4. Hang up and wait for upload confirmation
5. Check Supabase storage for the uploaded file

### Debug Information
- Check Logcat for `CallRecorderService` logs
- Monitor console for Supabase connectivity status
- Verify authentication state in debug console
- Check file existence in Android storage: `Android/data/<package>/files/Music/calls/`

## 🚨 Known Limitations

### Call Recording
- **Remote Audio**: Some Android versions/OEMs block remote party audio capture
- **Device Compatibility**: Recording quality varies across devices
- **Network Dependency**: Requires internet for cloud upload

### Session Management
- **Token Expiry**: Sessions expire based on Supabase configuration
- **Network Dependency**: Requires internet for session validation

### Recommendations
- Test on multiple devices for compatibility
- Consider VoIP SDK for guaranteed two-way audio recording
- Implement local storage backup for offline scenarios
- Monitor session expiry and implement appropriate refresh strategies

## 🔄 Recent Updates

### Session Persistence Implementation
- ✅ **AuthStateManager**: Centralized authentication state management
- ✅ **AuthWrapper**: Smart routing based on authentication status
- ✅ **Session Restoration**: Automatic session validation and refresh
- ✅ **Reactive UI**: Real-time authentication state updates
- ✅ **Error Handling**: Graceful handling of network and auth issues

### Architecture Improvements
- ✅ **Clean Architecture**: Proper separation of concerns
- ✅ **Repository Pattern**: Clean data access layer
- ✅ **Provider State Management**: Reactive state management
- ✅ **Type Safety**: Comprehensive model classes and validation

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
- Supabase for backend services and authentication
- Material Design team for UI guidelines
- Android team for native integration capabilities
- Provider package for state management

---

**Note**: This is a real estate CRM system with advanced call recording capabilities and persistent user sessions. Ensure compliance with local laws regarding call recording, data privacy, and session management when deploying in production.