# Development Guide

## Getting Started

This guide will help new developers set up and contribute to the Seniors Companion App project.

## Prerequisites

### Required Software
- **Flutter SDK**: 3.37.0 or later
- **Dart SDK**: 3.10.0 or later
- **Git**: For version control
- **VS Code or Android Studio**: Recommended IDEs

### Platform-Specific Requirements

#### WSL2 (Windows Subsystem for Linux)
- **WSL2** with **WSLg** for GUI support
- **Ubuntu 20.04+** or similar Linux distribution
- **Python 3**: For development server (`python3 -m http.server`)

#### Web Development
- **Chrome** or **Firefox**: For web testing
- **Firebase CLI**: For Firebase services management

#### Mobile Development (Optional)
- **Android Studio**: For Android development
- **Xcode**: For iOS development (macOS only)

## Project Setup

### 1. Clone the Repository
```bash
git clone <repository-url>
cd flutter_chat
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
The project is already configured with Firebase. Key files:
- `firebase.json`: Firebase project configuration
- `lib/firebase_options.dart`: Platform-specific Firebase settings
- `web/index.html`: Contains Google Sign-In meta tag

### 4. Environment Setup

#### For WSL Development (Recommended)
```bash
# Build the web app
flutter build web

# Serve using Python (better WSL networking)
cd build/web
python3 -m http.server 5000 --bind 0.0.0.0

# Access at: http://localhost:5000
```

#### Alternative: Flutter Dev Server
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
```

## Development Workflow

### 1. Branch Management
```bash
# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and commit
git add .
git commit -m "feat: descriptive commit message"

# Push to remote
git push origin feature/your-feature-name
```

### 2. Code Style Guidelines

#### Dart/Flutter Conventions
- Follow [official Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter_lints` for code analysis
- Run `flutter analyze` before committing

#### File Organization
```
lib/
├── src/
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── screens/          # UI screens
│   │   │   ├── services/         # Business logic
│   │   │   └── widgets/          # Reusable components
│   │   └── chat/
│   └── shared/
│       ├── widgets/              # Shared UI components
│       └── utils/                # Helper functions
```

#### Import Organization
```dart
// 1. Dart SDK imports
import 'dart:async';

// 2. Flutter framework imports
import 'package:flutter/material.dart';

// 3. Third-party package imports
import 'package:firebase_auth/firebase_auth.dart';

// 4. Local imports
import 'package:seniors_companion_app/src/features/auth/services/auth_service.dart';
```

### 3. Development Commands

#### Essential Commands
```bash
# Run app on web (WSL)
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000

# Run app on Linux desktop
flutter run -d linux

# Build for production
flutter build web

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

#### Kill Background Processes (WSL)
```bash
# Kill Flutter processes
pkill -f "flutter.*web-server"
pkill -f "dart.*frontend_server"

# Kill Python servers
pkill -f "python.*http.server"
```

## Feature Development

### 1. Authentication Feature (Completed)

#### Key Components
- **AuthService**: Handles Firebase authentication
- **LoginScreen**: User sign-in interface
- **RegistrationScreen**: User registration interface
- **AuthWrapper**: Session state management

#### Error Handling Pattern
```dart
Future<(User?, String?)> signInWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return (userCredential.user, null);
  } on FirebaseAuthException catch (e) {
    String errorMessage = _mapFirebaseError(e.code);
    return (null, errorMessage);
  }
}
```

### 2. Chat Feature (In Development)

#### Planned Components
- **ChatService**: Message handling and Firestore integration
- **ChatScreen**: Main chat interface
- **MessageModel**: Data structure for messages
- **MessageWidget**: Individual message display

#### Implementation Guidelines
```dart
// Message model example
class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final bool isFromUser;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.timestamp,
    required this.isFromUser,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isFromUser: data['isFromUser'] ?? false,
    );
  }
}
```

## Testing Guidelines

### 1. Unit Testing
```dart
// Test file: test/services/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:seniors_companion_app/src/features/authentication/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    test('should validate email format correctly', () {
      // Test implementation
    });
  });
}
```

### 2. Widget Testing
```dart
// Test file: test/screens/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seniors_companion_app/src/features/authentication/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginScreen()));

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
```

### 3. Integration Testing
```bash
# Run integration tests
flutter test integration_test/
```

## Debugging

### 1. Common Issues

#### WSL Networking Problems
```bash
# Symptoms: 127.0.0.0 redirects, 500 errors
# Solution: Use Python HTTP server instead of Flutter dev server
flutter build web
cd build/web
python3 -m http.server 5000 --bind 0.0.0.0
```

#### Google Sign-In Not Working
```html
<!-- Ensure this meta tag is in web/index.html -->
<meta name="google-signin-client_id" content="1015010025725-0u9hffavjvqj18v2iig9cnebj9nt8g6u.apps.googleusercontent.com">
```

#### Firebase Configuration Errors
```dart
// Check firebase_options.dart includes all platforms
static const FirebaseOptions linux = FirebaseOptions(
  apiKey: 'AIzaSyAZrZe1gQzJ6wG_SrWrZvGCIfcFJlMKqkc',
  appId: '1:1015010025725:web:350dbdd31f374c89c11e94',
  messagingSenderId: '1015010025725',
  projectId: 'flutter-chat-e4f96',
  authDomain: 'flutter-chat-e4f96.firebaseapp.com',
  storageBucket: 'flutter-chat-e4f96.firebasestorage.app',
);
```

### 2. Debug Tools

#### Flutter Inspector
```bash
# Enable Flutter Inspector in VS Code
# View > Command Palette > "Flutter: Open Flutter Inspector"
```

#### Firebase Console
- **Authentication**: Monitor user sign-ins and registrations
- **Firestore**: View real-time database contents
- **Functions**: Monitor cloud function executions

## Code Review Guidelines

### 1. Checklist
- [ ] Code follows Dart style guidelines
- [ ] All tests pass (`flutter test`)
- [ ] No analyzer warnings (`flutter analyze`)
- [ ] Error handling implemented properly
- [ ] Loading states handled appropriately
- [ ] Form validation working correctly
- [ ] Platform-specific considerations addressed

### 2. Review Focus Areas
- **Security**: No sensitive data exposure
- **Performance**: Efficient Firestore queries
- **Accessibility**: Senior-friendly UI considerations
- **Error Handling**: User-friendly error messages
- **Testing**: Adequate test coverage

## Deployment

### 1. Web Deployment
```bash
# Build for production
flutter build web

# Deploy to Firebase Hosting (when configured)
firebase deploy --only hosting
```

### 2. Mobile Deployment
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### 3. Desktop Deployment
```bash
# Linux
flutter build linux

# Windows
flutter build windows

# macOS
flutter build macos
```

## Contributing

### 1. Pull Request Process
1. Create feature branch from `main`
2. Implement feature with tests
3. Run full test suite
4. Submit pull request with clear description
5. Address review feedback
6. Merge after approval

### 2. Commit Message Format
```
feat: add user authentication with Google Sign-In
fix: resolve WSL networking issues
docs: update development guide
test: add unit tests for AuthService
refactor: improve error handling in login screen
```

### 3. Documentation Updates
- Update relevant documentation when adding features
- Include code examples for new patterns
- Update TASK_LIST.md with completed items

## Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

### Tools
- [Dart DevTools](https://dart.dev/tools/dart-devtools)
- [Firebase Console](https://console.firebase.google.com/)
- [Flutter Inspector](https://docs.flutter.dev/development/tools/flutter-inspector)