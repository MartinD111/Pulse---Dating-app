# Pulse - Passive Dating App MVP

A cross-platform mobile application for iOS and Android that enables passive, proximity-based matching with minimal screen interaction.

## 🎯 Features

- **Passive Discovery**: Background BLE and geofencing to detect nearby compatible users
- **Smart Matching**: Advanced algorithm considering gender, age, lifestyle, hobbies, and personality
- **Minimal Interaction**: Push notifications with "Pozdravi" or "Ignore" actions - no chat functionality
- **Beautiful UI**: Glassmorphism design with gender-based theming (pink for female, blue for male)
- **Battery Optimized**: Efficient scanning cycles and location updates
- **Privacy First**: Location and BLE data used only for proximity detection

## 🚀 Getting Started

### Prerequisites

- Node.js >= 18
- React Native development environment set up
- For iOS: Xcode 14+ and CocoaPods
- For Android: Android Studio and SDK

### Installation

1. **Clone or navigate to the project**:
   ```bash
   cd C:\Users\marti\.gemini\antigravity\scratch\pulse
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **iOS specific setup**:
   ```bash
   cd ios
   pod install
   cd ..
   ```

4. **Android specific setup**:
   - Ensure Android SDK is installed
   - Update `local.properties` with SDK path if needed

### Running the App

#### Android

```bash
# Start Metro bundler
npm start

# In a new terminal, run Android
npm run android
```

#### iOS

```bash
# Start Metro bundler
npm start

# In a new terminal, run iOS
npm run ios
```

## 📱 App Structure

```
pulse/
├── src/
│   ├── components/          # Reusable UI components
│   │   ├── common/         # GlassCard, PillButton, PillInput
│   │   ├── radar/          # RadarAnimation
│   │   └── matches/        # MatchCard
│   ├── screens/            # Main app screens
│   │   ├── radar/          # Home/Dashboard with search toggle
│   │   ├── matches/        # Match history
│   │   └── settings/       # Profile & Preferences
│   ├── services/           # Background services
│   │   ├── ble/            # Bluetooth Low Energy scanning
│   │   ├── location/       # Geofencing & proximity
│   │   ├── matching/       # Match algorithm
│   │   └── notifications/  # Push notifications
│   ├── store/              # Redux state management
│   │   └── slices/         # User, matches, preferences, app
│   ├── navigation/         # React Navigation setup
│   ├── theme/              # Design system
│   │   ├── colors.js       # Gender-based themes
│   │   ├── glassmorphism.js # Frosted glass styles
│   │   └── icons.js        # Icon mappings
│   └── App.js              # Root component
```

## 🎨 Design System

### Color Theming

- **Female Users**: Light pink glassmorphism palette
- **Male Users**: Light blue glassmorphism palette
- **Rainbow Mode**: Multi-color accents for LGBTQ+ preference
- **Dark/Light Mode**: Automatic system detection with manual toggle

### UI Components

All components use **pill-shaped** borders (fully rounded) and **glassmorphism** effects:

- `GlassCard`: Frosted glass container
- `PillButton`: Rounded button with glass effect
- `PillInput`: Text input with glass styling
- `RadarAnimation`: Animated radar with pulse waves

## 🔧 Configuration

### Permissions Required

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### iOS (`ios/Pulse/Info.plist`)

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Pulse needs your location to find nearby matches</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Pulse needs your location to find nearby matches</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Pulse uses Bluetooth to discover nearby users</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Pulse uses Bluetooth to discover nearby users</string>
```

## 🧪 Testing

### Background Service Testing

#### Android

```bash
# Build and install debug APK
npm run android

# Monitor background service logs
adb logcat | grep "BLE\|Location\|Pulse"

# Test with screen off
# 1. Start searching in the app
# 2. Lock the screen
# 3. Wait 5+ minutes
# 4. Check logs to verify scanning continues
```

#### iOS

```bash
# Run in Xcode for better debugging
npx react-native run-ios

# Simulate location changes:
# Debug → Location → Custom Location in Xcode
```

### Emulator Testing

1. **Launch app** and complete onboarding
2. **Set preferences** in Settings screen
3. **Toggle "Start Searching"** on Radar screen
4. **Verify radar animation** appears
5. **Test all sliders** (age, distance, height, personality)
6. **Toggle dark mode** and verify theme changes
7. **Enable rainbow mode** and verify accent colors

## 🔋 Battery Optimization

The app implements several battery-saving strategies:

- **BLE Scanning**: 5 seconds scan, 55 seconds sleep cycle
- **Location Updates**: Every 30 seconds with 10m distance filter
- **Low Accuracy**: Uses network location instead of GPS when possible
- **Background Throttling**: Reduces update frequency when app is backgrounded

## 📊 Matching Algorithm

The matching engine scores compatibility based on:

1. **Gender Preference** (100 points) - Must match mutually
2. **Age Range** (20 points) - Must fall within each other's ranges
3. **Lifestyle** (15 points) - Relationship type, smoking, activity, pets
4. **Hobbies** (10 points) - Overlap in selected hobbies
5. **Personality** (5 points) - Introvert/extrovert compatibility

**Match Threshold**: 70% of maximum score (105/150 points)

## 🚧 TODO / Future Enhancements

- [ ] Implement authentication screens (Google Sign-In, Email/Password)
- [ ] Create onboarding flow screens
- [ ] Add server backend for user data sync
- [ ] Implement BLE advertising (peripheral mode)
- [ ] Add profile photo upload functionality
- [ ] Implement hobby selection UI
- [ ] Add match detail view screen
- [ ] Integrate Firebase for push notifications
- [ ] Add analytics and crash reporting
- [ ] Implement user blocking/reporting
- [ ] Add privacy settings

## 📝 Notes

### iOS Limitations

Apple restricts background BLE scanning significantly. The app works best on Android. On iOS:
- Geofencing is used as the primary trigger
- BLE scanning activates when the app wakes from geofence events
- Background execution time is limited

### Development Tips

- Use `npm run lint` to check code quality
- Test on real devices for accurate BLE and location behavior
- Monitor battery usage with Android Battery Historian or iOS Instruments
- Use `react-native log-android` or `react-native log-ios` for debugging

## 📄 License

MIT License - See LICENSE file for details

## 👥 Contributing

This is an MVP project. Contributions welcome! Please follow the existing code structure and design patterns.

---

**Built with React Native** ❤️
