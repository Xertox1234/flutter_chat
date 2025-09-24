# API Documentation

## Overview

This document describes the API integration patterns and Firebase service configurations used in the Seniors Companion App.

## Firebase Authentication API

### Configuration

#### Web Platform
```html
<!-- Google Sign-In Meta Tag in web/index.html -->
<meta name="google-signin-client_id" content="1015010025725-0u9hffavjvqj18v2iig9cnebj9nt8g6u.apps.googleusercontent.com">
```

#### Platform Options
```dart
// firebase_options.dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAZrZe1gQzJ6wG_SrWrZvGCIfcFJlMKqkc',
  appId: '1:1015010025725:web:350dbdd31f374c89c11e94',
  messagingSenderId: '1015010025725',
  projectId: 'flutter-chat-e4f96',
  authDomain: 'flutter-chat-e4f96.firebaseapp.com',
  storageBucket: 'flutter-chat-e4f96.firebasestorage.app',
  measurementId: 'G-8RJXF4CQJY',
);
```

### Authentication Methods

#### 1. Email/Password Authentication

##### Sign Up
```dart
Future<(User?, String?)> registerWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return (userCredential.user, null);
  } on FirebaseAuthException catch (e) {
    return (null, _mapFirebaseError(e.code));
  } catch (e) {
    return (null, 'An unexpected error occurred. Please try again.');
  }
}
```

**Request Parameters:**
- `email`: String (required) - Valid email address
- `password`: String (required) - Minimum 6 characters

**Response:**
- Success: `(User, null)`
- Error: `(null, String)` - Error message

**Error Codes:**
- `weak-password`: Password is too weak
- `email-already-in-use`: Email is already registered
- `invalid-email`: Email format is invalid

##### Sign In
```dart
Future<(User?, String?)> signInWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return (userCredential.user, null);
  } on FirebaseAuthException catch (e) {
    return (null, _mapFirebaseError(e.code));
  } catch (e) {
    return (null, 'An unexpected error occurred. Please try again.');
  }
}
```

**Request Parameters:**
- `email`: String (required) - Registered email address
- `password`: String (required) - User password

**Response:**
- Success: `(User, null)`
- Error: `(null, String)` - Error message

**Error Codes:**
- `user-not-found`: No user found with this email
- `wrong-password`: Incorrect password
- `user-disabled`: User account has been disabled
- `too-many-requests`: Too many failed login attempts

#### 2. Google OAuth 2.0 Authentication

```dart
Future<(User?, String?)> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      return (null, 'Google sign-in was cancelled.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    return (userCredential.user, null);
  } on FirebaseAuthException catch (e) {
    return (null, _mapFirebaseError(e.code));
  } catch (e) {
    return (null, 'An unexpected error occurred during Google sign-in.');
  }
}
```

**Flow:**
1. User clicks "Sign in with Google"
2. Google OAuth popup opens
3. User authenticates with Google
4. Google returns access token and ID token
5. Firebase creates/authenticates user with Google credentials

**Response:**
- Success: `(User, null)`
- Cancelled: `(null, 'Google sign-in was cancelled.')`
- Error: `(null, String)` - Error message

#### 3. Sign Out

```dart
Future<void> signOut() async {
  await Future.wait([
    _auth.signOut(),
    GoogleSignIn().signOut(),
  ]);
}
```

### Error Mapping

```dart
String _mapFirebaseError(String code) {
  switch (code) {
    case 'weak-password':
      return 'The password provided is too weak. Please choose a stronger password.';
    case 'email-already-in-use':
      return 'An account already exists with this email address.';
    case 'invalid-email':
      return 'Please enter a valid email address.';
    case 'user-not-found':
      return 'No user found with this email address.';
    case 'wrong-password':
      return 'Incorrect password. Please try again.';
    case 'user-disabled':
      return 'This account has been disabled. Please contact support.';
    case 'too-many-requests':
      return 'Too many failed attempts. Please try again later.';
    default:
      return 'Authentication failed. Please try again.';
  }
}
```

## Cloud Firestore API

### Database Structure

#### Users Collection
```typescript
// /users/{userId}
interface User {
  id: string;
  email: string;
  displayName?: string;
  photoURL?: string;
  createdAt: Timestamp;
  lastSignIn: Timestamp;
  preferences?: {
    notifications: boolean;
    voiceEnabled: boolean;
    fontSize: 'small' | 'medium' | 'large';
  };
}
```

#### Messages Collection (Planned)
```typescript
// /chats/{chatId}/messages/{messageId}
interface Message {
  id: string;
  text: string;
  senderId: string;
  senderType: 'user' | 'ai';
  timestamp: Timestamp;
  chatId: string;
  metadata?: {
    tokens?: number;
    model?: string;
    toolCalls?: ToolCall[];
  };
}
```

#### Chat Sessions Collection (Planned)
```typescript
// /chats/{chatId}
interface ChatSession {
  id: string;
  userId: string;
  title: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  messageCount: number;
  isActive: boolean;
}
```

### Firestore Queries

#### Real-time Message Stream
```dart
Stream<List<Message>> getMessages(String chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Message.fromFirestore(doc))
          .toList());
}
```

#### Send Message
```dart
Future<void> sendMessage(String chatId, String text, String userId) async {
  final message = {
    'text': text,
    'senderId': userId,
    'senderType': 'user',
    'timestamp': FieldValue.serverTimestamp(),
    'chatId': chatId,
  };

  await FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .add(message);
}
```

### Security Rules

#### Authentication Required
```javascript
// Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Chat messages require authentication
    match /chats/{chatId}/messages/{messageId} {
      allow read, write: if request.auth != null;
      allow create: if request.auth != null &&
                   request.auth.uid == resource.data.senderId;
    }
  }
}
```

## Firebase Functions API (Planned)

### AI Integration Endpoint

#### Process User Message
```typescript
// functions/src/index.ts
import { onCall } from 'firebase-functions/v2/https';
import { getAuth } from 'firebase-admin/auth';

export const processMessage = onCall(async (request) => {
  // Verify authentication
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { message, chatId } = request.data;

  // Process with AI service
  const aiResponse = await callAIService(message);

  // Save AI response to Firestore
  await saveMessage(chatId, aiResponse, 'ai');

  return { response: aiResponse };
});
```

**Request:**
```typescript
{
  message: string;
  chatId: string;
}
```

**Response:**
```typescript
{
  response: string;
  metadata?: {
    tokens: number;
    model: string;
  };
}
```

#### Tool Calling Endpoint
```typescript
export const executeToolCall = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { toolName, parameters, chatId } = request.data;

  switch (toolName) {
    case 'createReminder':
      return await createReminder(parameters, request.auth.uid);
    case 'scheduleAppointment':
      return await scheduleAppointment(parameters, request.auth.uid);
    default:
      throw new HttpsError('invalid-argument', 'Unknown tool');
  }
});
```

## Authentication State Management

### Stream-based State Management
```dart
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const ChatScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
```

### User Data Access
```dart
class UserService {
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  static Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
    }
  }
}
```

## Error Handling Patterns

### Service Layer Error Handling
```dart
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isLoading;

  const ApiResponse({this.data, this.error, this.isLoading = false});

  bool get hasError => error != null;
  bool get hasData => data != null;
}
```

### UI Error Display
```dart
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

## API Rate Limits and Quotas

### Firebase Authentication
- **Daily quota**: 100,000 operations per day (free tier)
- **Rate limit**: 1,000 operations per minute per IP

### Cloud Firestore
- **Read operations**: 50,000 per day (free tier)
- **Write operations**: 20,000 per day (free tier)
- **Delete operations**: 20,000 per day (free tier)

### Firebase Functions
- **Invocations**: 125,000 per month (free tier)
- **GB-seconds**: 40,000 per month (free tier)

## Testing API Integration

### Mock Authentication Service
```dart
class MockAuthService extends AuthService {
  @override
  Future<(User?, String?)> signInWithEmailAndPassword(String email, String password) async {
    if (email == 'test@example.com' && password == 'password123') {
      return (MockUser(), null);
    }
    return (null, 'Invalid credentials');
  }
}
```

### Firestore Emulator
```bash
# Start Firestore emulator for testing
firebase emulators:start --only firestore

# Configure app to use emulator
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
```

## Production Considerations

### Security
- Implement proper Firestore security rules
- Use Firebase App Check for API protection
- Enable audit logging for sensitive operations

### Performance
- Implement query pagination for large datasets
- Use Firestore offline persistence
- Cache frequently accessed data

### Monitoring
- Set up Firebase Performance Monitoring
- Configure Crashlytics for error tracking
- Monitor API usage and quotas