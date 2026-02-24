# Pulse - Passive Dating App MVP

A cross-platform mobile application for iOS and Android built with Flutter that enables passive, proximity-based matching with minimal screen interaction.

## 🎯 Features

- **Passive Discovery**: Background proximity sensing (to be implemented via BLE/Geofencing)
- **Smart Matching**: Advanced algorithm considering gender, age, lifestyle, hobbies, and personality
- **Minimal Interaction**: Push notifications with actions - no chat functionality
- **Beautiful UI**: Glassmorphism design with gender-based theming (pink for female, blue for male)
- **Battery Optimized**: Efficient scanning cycles and location updates
- **Privacy First**: Location data used only for proximity detection

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-started/sdk)
- Android Studio / Xcode for mobile development

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd pulse
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

## 📱 App Structure

```
lib/
├── main.dart               # Entry point
└── src/
    ├── features/           # Feature-based architecture
    │   ├── auth/           # Authentication & Onboarding
    │   ├── dashboard/      # Home/Radar screen
    │   ├── map/            # Proximity visualization
    │   ├── matches/        # Match history & Discovery
    │   └── settings/       # User profile & Preferences
    ├── common_widgets/     # Reusable UI components (GlassCard, PillButton)
    ├── constants/          # App constants & Themes
    ├── routing/            # Navigation (GoRouter)
    └── utils/              # Helper functions
```

## 🎨 Design System

All components use **pill-shaped** borders (fully rounded) and **glassmorphism** effects:

- `GlassCard`: Frosted glass container
- `PillButton`: Rounded button with glass effect
- `PillInput`: Text input with glass styling
- `RadarAnimation`: Animated radar with pulse waves

## 🚧 TODO / Future Enhancements

- [ ] Complete background service implementation (BLE/Geofencing)
- [ ] Implement secure authentication (Firebase/Supabase)
- [ ] Add server backend for user data sync
- [ ] Integrate Firebase for push notifications
- [ ] Add analytics and crash reporting

## 📄 License

MIT License - See LICENSE file for details
