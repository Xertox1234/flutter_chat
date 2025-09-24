# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Seniors Companion App** - A Flutter-based digital companion for seniors with AI-powered assistance, medication management, and appointment tracking.

**Core Features:**
- AI Chat with Google Gemini 2.5 Flash (multimodal: text, images, PDFs, audio)
- Medication reminder system with local notifications
- Appointment scheduling and management
- Firebase Authentication (Email/Password + Google Sign-In v7)
- Cloud Firestore for real-time data persistence
- Senior-friendly UI (large fonts 18px+, high contrast)

## Key Commands

### Development Workflow
```bash
# Install dependencies
flutter pub get

# Run for development (WSL-friendly)
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000 \
  --dart-define=GOOGLE_GENAI_API_KEY=<your-api-key>

# Alternative: Chrome (requires Chrome installed)
flutter run -d chrome --dart-define=GOOGLE_GENAI_API_KEY=<your-api-key>

# Build for production
flutter build web --dart-define=GOOGLE_GENAI_API_KEY=<your-api-key>

# Clean build artifacts (do this before fresh rebuild)
flutter clean
```

### WSL Development
```bash
# Kill old processes before starting (per user instructions)
pkill -9 dart

# Build and serve with Python (recommended for WSL)
flutter build web
cd build/web && python3 -m http.server 5000 --bind 0.0.0.0
```

### Code Quality
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Analyze code
flutter analyze

# Format code
dart format lib/
```

### Firebase Functions
```bash
cd functions && npm run deploy    # Deploy functions
cd functions && npm run serve      # Local emulator
cd functions && npm run logs       # View logs
```

## Architecture

### Feature-Based Structure
```
lib/src/features/
├── authentication/      # Auth system with Firebase Auth v6 + Google Sign-In v7
├── chat/               # AI chat interface with flutter_ai_toolkit
└── reminders/          # Medication & appointment management
```

### Authentication System (Firebase Auth v6 + Google Sign-In v7)
**Location:** `lib/src/features/authentication/`

**Key Implementation Details:**
- `services/auth_service.dart`: Firebase Auth wrapper
  - Uses Dart records for error handling: `(User?, String?)`
  - Google Sign-In v7 breaking changes handled:
    - Singleton pattern: `GoogleSignIn.instance` (not constructor)
    - Required `initialize()` before `authenticate()` (replaces `signIn()`)
    - Initialization pattern via `_ensureInitialized()`
- `screens/login_screen.dart`: Form validation, loading states, error dialogs
- `screens/registration_screen.dart`: Email regex, password confirmation (6 char min)

**Error Codes Handled:**
- Login: user-not-found, wrong-password, invalid-email, user-disabled, too-many-requests
- Registration: weak-password, email-already-in-use, invalid-email
- Google: account-exists-with-different-credential, invalid-credential

### AI Chat Integration (Gemini 2.5 Flash)
**Location:** `lib/src/services/`

**ai_service.dart** - Main AI service (singleton):
- Custom speech-to-text with optimized prompt
- Prescription image analysis with JSON extraction
- Integrates `flutter_ai_toolkit` for LlmChatView UI
- Uses `google_generative_ai` with direct API key (not `firebase_ai` - avoids 403 errors)

**gemini_provider.dart** - LlmProvider implementation:
- Extends `LlmProvider` from flutter_ai_toolkit
- Manages chat history with `ChatSession`
- Handles multimodal attachments using `DataPart` (not `InlineDataPart`)
- Streams responses with `generateContentStream`
- ChangeNotifier pattern for UI reactivity

**Speech-to-Text Prompt:**
```
"Listen to this audio and write down exactly what the person is saying.
Return only the spoken words as text, nothing else."
```

**Prescription Analysis:**
Extracts medication info from images as JSON:
```json
{
  "medicationName": "...",
  "dosage": "...",
  "timesPerDay": number,
  "instructions": "...",
  "scheduledTimes": ["08:00", "20:00", ...]
}
```

### Reminders & Medications System
**Location:** `lib/src/features/reminders/`

**Architecture:**
- `models/`: `Reminder`, `Medication`, `ReminderType` enum
- `services/reminder_service.dart`: Firestore CRUD operations
- `services/notification_service.dart`: Local notifications with timezone support
- `screens/reminders_screen.dart`: Dual-tab UI (Medications/Appointments)
- `widgets/reminder_setup_card.dart`: Unified creation dialog

**Data Models:**
- `Reminder`: One-time appointments with `scheduledTime` (DateTime), `description`
- `Medication`: Recurring meds with `scheduledTimes` (List<String>), `dosage`, `instructions`

**Firestore Collections:**
- `users/{userId}/reminders/` - Appointments
- `users/{userId}/medications/` - Medications

**UI Features:**
- Toggle-based tabs (Medications/Appointments)
- Large fonts (18-24px) for senior accessibility
- Switch widgets use Material 3 `activeTrackColor` (not deprecated `activeColor`)
- Image picker for prescription scanning
- AI-powered extraction from prescription photos

### Main App Flow
**lib/main.dart**:
1. Firebase initialization
2. Notification service setup
3. AuthWrapper checks auth state
4. MainScreen with BottomNavigationBar:
   - Chat (AI assistant)
   - Medications (reminder list)
   - Appointments (reminder list with `showAppointments: true`)

### Firebase Configuration
**Project:** flutter-chat-e4f96
- Authentication: Email/Password + Google Sign-In
- Firestore: Real-time database
- Functions: Node.js 18
- Platforms: Web, Android, iOS, macOS, Windows, Linux

**Web Setup (`web/index.html`):**
```html
<meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
```
Must match OAuth 2.0 Web Client from Google Cloud Console.

## WSL Development Notes

**Why Web Platform:**
- Firebase SDK doesn't support Linux desktop natively
- WSL2 requires `0.0.0.0` binding for network access
- Port 5000 configured for Google Sign-In (add to Firebase authorized domains)

**Process Management:**
- ALWAYS kill old Dart processes before starting: `pkill -9 dart`
- Per user instructions: "Stop opening a new port every time. Kill the old port first."

**Required Linux Dependencies (installed):**
- libsecret-1-dev, libgstreamer1.0-dev, libwebkit2gtk-4.1-dev, GTK3

## Key Dependencies

**Core (Updated):**
- `firebase_core: ^4.1.1` (v6+ migration)
- `firebase_auth: ^6.1.0` (v6+ migration)
- `google_sign_in: ^7.2.0` (v7+ breaking changes)
- `cloud_firestore: ^6.0.2` (v6+ migration)

**AI:**
- `flutter_ai_toolkit: ^0.10.0` - Chat UI components
- `google_generative_ai: ^0.4.7` - Gemini API client
- `firebase_remote_config: ^6.0.2` - Dynamic configuration

**Notifications:**
- `flutter_local_notifications: ^18.0.1`
- `timezone: ^0.9.4`
- `permission_handler: ^11.3.0`

**Media:**
- `image_picker: ^1.1.2` - Prescription photo capture
- `cross_file: ^0.3.4+2` - File handling

**Environment:**
- Dart SDK: ^3.9.2
- Flutter: 3.35.4 (stable)
- Material Design 3

## AI Integration Troubleshooting

### API Key Configuration
**Recommended:** `--dart-define` at runtime
```bash
flutter run --dart-define=GOOGLE_GENAI_API_KEY=your_key
```

**Access in code:**
```dart
const String.fromEnvironment('GOOGLE_GENAI_API_KEY')
```

### Common Issues

**1. Firebase AI 403 Forbidden**
- **Cause:** Firebase AI requires manual API enablement
- **Solution:** Use `google_generative_ai` with direct API key (already implemented)

**2. Speech-to-Text Not Working**
- **Cause:** Generic prompts confuse the model
- **Solution:** Use specific prompt (already implemented in `ai_service.dart`)

**3. Multimodal Attachments Failing**
- **Cause:** Wrong Part type (`InlineDataPart` vs `DataPart`)
- **Solution:** `google_generative_ai` uses `DataPart(mimeType, bytes)`

**4. flutter_ai_toolkit Compatibility**
- Version 0.10.0 does NOT support `modelMessageStyle` parameter
- Only `userMessageStyle` is supported in `LlmChatViewStyle`

## Flutter Best Practices (Enforced)

### Dependency Management
- **ALWAYS** update `pubspec.yaml` when adding imports
- **RUN** `flutter pub get` after dependency changes
- **VERIFY** package compatibility with SDK version

### Security
- **NEVER** store API keys in code, assets, or SharedPreferences
- **USE** `--dart-define` for build-time secrets
- **USE** Firebase Remote Config for dynamic secrets
- **USE** `flutter_secure_storage` for local sensitive data

### Performance
- **USE** `const` constructors to prevent rebuilds
- **DISPOSE** controllers, streams, subscriptions in `dispose()`
- **AVOID** expensive operations in `build()`
- **USE** `ListView.builder` for long/infinite lists
- **IMPLEMENT** proper widget keys for lists/animations

### Widget Lifecycle
- **OVERRIDE** `dispose()` in StatefulWidgets
- **USE** StatelessWidget unless state is required
- **AVOID** creating widgets in `build()` - use class members

### Logging
- **USE** `dart:developer` log() instead of print()
- **FORMAT:** `developer.log('message', name: 'ServiceName', error: e)`
- **INCLUDE** context: user ID, request ID, key parameters

### Material 3 Updates
- Switch: Use `activeTrackColor` (not deprecated `activeColor`)
- Reminder model: `scheduledTime` (not `scheduledDate`), `description` (not `notes`)
- Chat view: `Future<Widget>` (not `Future<LlmChatView>`)

## Development Protocol

### Before Making Changes
1. **ONLY** modify what is explicitly requested
2. **ASK** before changing unrelated code
3. **VERIFY** all imports have corresponding pubspec.yaml entries
4. **NO** placeholder values ("YOUR_API_KEY", "TODO", dummy data)

### Question vs Code Request
- **Question:** Provide answer - do NOT change code
- **Code request:** Look for "change", "update", "modify", "fix"

### Error Handling
- **ANALYZE** actual error messages (don't assume)
- **FIX** technical issues, not functional requirements
- **ASK** if requirements seem problematic

### Code Cleanup
- **REMOVE** unused code when making changes
- **CLEAN UP** orphaned functions, imports, variables
- **DELETE** temporary debugging code

## Emergency Protocol

**If unsure about ANY aspect:**
1. **STOP** code generation
2. **ASK** for clarification
3. **WAIT** for explicit confirmation
4. Only proceed when 100% certain

**Remember:** Better to ask than make assumptions that break everything.