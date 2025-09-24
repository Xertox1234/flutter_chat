# Architecture Documentation

## System Overview

The Seniors Companion App follows a feature-based architecture pattern using Flutter/Dart with Firebase backend services. The application is designed for cross-platform deployment with primary focus on web and mobile platforms.

## Architecture Principles

### 1. Feature-Based Structure
```
lib/
├── src/
│   ├── features/
│   │   ├── authentication/
│   │   │   ├── screens/
│   │   │   ├── services/
│   │   │   └── widgets/
│   │   └── chat/
│   │       ├── screens/
│   │       ├── models/
│   │       └── services/
│   ├── services/
│   │   ├── ai_service.dart
│   │   ├── gemini_provider.dart
│   │   ├── firebase_gemini_provider.dart
│   │   └── remote_config_service.dart
│   └── shared/
│       ├── widgets/
│       └── utils/
```

### 2. Separation of Concerns
- **Screens**: UI presentation layer
- **Services**: Business logic and external API integration
- **Models**: Data structures and validation
- **Widgets**: Reusable UI components

## Core Components

### Authentication Architecture

#### AuthService
- **Purpose**: Centralized authentication management
- **Patterns**: Dart records for error handling `(User?, String?)`
- **Methods**:
  - `signInWithEmailAndPassword()`: Email/password authentication
  - `signInWithGoogle()`: Google OAuth 2.0 integration
  - `registerWithEmailAndPassword()`: User registration
  - `signOut()`: Session termination

#### Error Handling Strategy
```dart
// Using Dart records for clean error handling
Future<(User?, String?)> signInWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return (userCredential.user, null);
  } on FirebaseAuthException catch (e) {
    return (null, _mapFirebaseError(e.code));
  }
}
```

#### Authentication Flow
1. User input validation (client-side)
2. Firebase Authentication request
3. Error mapping for user-friendly messages
4. Session state management via StreamBuilder
5. Navigation to appropriate screen

### Firebase Integration

#### Configuration
- **Multi-platform support**: Web, Android, iOS, Linux (via web config)
- **Environment-specific**: Development and production configurations
- **Security**: Client-side configuration only, sensitive operations server-side

#### Services Used
- **Firebase Auth**: User authentication and session management
- **Cloud Firestore**: Real-time database for chat messages
- **Firebase Functions**: Planned for AI integration and server-side logic

## State Management

### Current Pattern: Provider + StreamBuilder
```dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const ChatScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
```

### Benefits
- **Reactive**: Automatic UI updates on auth state changes
- **Simple**: Minimal boilerplate for current requirements
- **Firebase-native**: Direct integration with Firebase streams

## Data Flow

### Authentication Data Flow
```
User Input → Form Validation → AuthService → Firebase Auth → State Update → UI Navigation
```

### Chat Data Flow (Planned)
```
User Message → ChatService → Firestore → Real-time Stream → UI Update
AI Response ← Firebase Functions ← AI Service ← Message Processing
```

## Security Architecture

### Client-Side Security
- **Input Validation**: Email regex, password requirements
- **Error Handling**: No sensitive information exposed in error messages
- **State Management**: Secure session handling via Firebase Auth

### Server-Side Security (Planned)
- **Firebase Security Rules**: Role-based access control
- **Function Security**: Authenticated endpoints only
- **Data Validation**: Server-side input validation

## Platform-Specific Considerations

### Web Platform
- **Google Sign-In**: OAuth 2.0 meta tag configuration
- **Firebase Config**: Web-specific API keys and settings
- **WSL Development**: Specific networking configuration for Windows Subsystem for Linux

### Desktop Platforms
- **Linux**: Firebase web configuration (SDK limitations)
- **Windows/macOS**: Native Firebase SDK support planned

### Mobile Platforms
- **Android**: Firebase Android SDK with Google Services
- **iOS**: Firebase iOS SDK with proper entitlements

## Development Patterns

### Error Handling Pattern
1. **Service Level**: Catch exceptions, map to user messages
2. **UI Level**: Display user-friendly error dialogs/snackbars
3. **Logging**: Comprehensive error logging for debugging

### Form Validation Pattern
```dart
String? _validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  }
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegex.hasMatch(value)) {
    return 'Please enter a valid email address';
  }
  return null;
}
```

### Loading State Pattern
```dart
class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _performAction() async {
    setState(() => _isLoading = true);
    // Perform action
    setState(() => _isLoading = false);
  }
}
```

## Performance Considerations

### Current Optimizations
- **Form validation**: Real-time validation for immediate feedback
- **Image loading**: Error handling for external images (Google logo)
- **Stream management**: Proper disposal of controllers and streams

### Planned Optimizations
- **Firestore queries**: Pagination and query optimization
- **Image caching**: Local caching for frequently used images
- **Bundle optimization**: Code splitting for web platform

## Testing Strategy

### Unit Testing
- **Services**: Authentication service methods
- **Validators**: Form validation functions
- **Models**: Data model parsing and validation

### Integration Testing
- **Authentication flow**: Complete sign-in/sign-up process
- **Firebase integration**: Database operations and real-time updates
- **Cross-platform**: Platform-specific functionality

### Widget Testing
- **Form validation**: User input scenarios
- **Loading states**: UI behavior during async operations
- **Error handling**: Error dialog and snackbar display

## Deployment Architecture

### Development Environment
- **Local development**: Flutter dev server or Python HTTP server
- **Hot reload**: Real-time code updates during development
- **Debug tools**: Flutter Inspector, Firebase Console

### Production Environment
- **Web hosting**: Firebase Hosting for web platform
- **Mobile distribution**: App stores for mobile platforms
- **Desktop distribution**: Platform-specific installers

## AI Integration Architecture

### AI Service Layer
- **AIService**: Singleton service managing AI chat functionality
- **Model**: Google Gemini 2.5 Flash via `google_generative_ai` package
- **API Key Management**: Compile-time via `--dart-define=GOOGLE_GENAI_API_KEY`
- **UI Framework**: `flutter_ai_toolkit` for chat interface components

### Multimodal Processing
```dart
// Speech-to-Text with optimized prompts
Stream<String> _convertSpeechToText(XFile audioFile) async* {
  final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  final prompt = 'Listen to this audio and write down exactly what the person is saying...';
  final content = [Content.multi([TextPart(prompt), DataPart('audio/wav', bytes)])];
  final responseStream = model.generateContentStream(content);
  // Stream transcribed text
}
```

### LlmProvider Pattern
- **GeminiProvider**: Implements `LlmProvider` from flutter_ai_toolkit
- **ChatSession**: Maintains conversation history and context
- **ChangeNotifier**: Reactive UI updates for streaming responses
- **Attachment Handling**: DataPart for images, PDFs, audio

### Capabilities
1. **Text Generation**: Conversational AI responses
2. **Image Analysis**: Upload and discuss images with AI
3. **PDF Processing**: Extract and analyze document content
4. **Speech-to-Text**: Voice input with WAV audio transcription
5. **Real-time Streaming**: Progressive response rendering

## Future Architecture Considerations

### AI Scaling
- **Context Caching**: Reduce API costs for repeated conversations
- **Message queuing**: Async processing for high-traffic scenarios
- **Multi-modal optimization**: Compression and preprocessing for large files

### Scalability
- **Database sharding**: User-based data partitioning
- **CDN integration**: Global content delivery
- **Caching strategy**: Redis for frequently accessed data

### Monitoring and Analytics
- **Error tracking**: Crash reporting and error analytics
- **Performance monitoring**: App performance metrics
- **User analytics**: Usage patterns and feature adoption