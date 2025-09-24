# Project Context: Seniors Companion App

## 1. Project Vision

To create a user-friendly mobile application that acts as a digital companion for seniors, helping them manage their daily tasks, stay connected, and maintain their independence. The app will provide a simple, conversational interface for interacting with an AI assistant.

## 2. Project Goals

* **Initial Goal:** Develop a simple one-on-one chat application where seniors can interact with an AI assistant.
* **Core Functionality:** The AI assistant will be able to understand and respond to text-based commands.
* **Tool Integration:** The AI will have the ability to call tools to perform specific tasks, such as setting reminders for appointments and medications.
* **User-Centric Design:** The app will be designed with seniors in mind, featuring a clear, simple, and accessible user interface.
* **Scalability:** The initial chat app will be the foundation for a more feature-rich application in the future.

## 3. Target Audience

The primary target audience is seniors who may need assistance with managing their daily routines and appointments. The app is designed for users who may have limited experience with technology and require a simple, intuitive interface.

## 4. Core Features (Current Implementation)

### Authentication System ✅
* **User Registration:** Email/password registration with validation:
  * Email format validation with regex
  * Password minimum 6 characters
  * Password confirmation matching
  * Real-time error feedback
* **User Login:** Multiple authentication methods:
  * Email/password login with error handling
  * Google Sign-In integration
  * Session persistence with Firebase Auth
* **Security Features:**
  * Password visibility toggles
  * Loading states during authentication
  * Proper error messages for all failure cases

### Chat Interface (In Development)
* **AI Chat Interface:** A one-on-one chat screen for users to interact with the AI assistant
* **Text-Based Interaction:** Users can send text messages to the AI
* **Real-time Communication:** Using Cloud Firestore for real-time message updates
* **Message History:** Persistent chat history stored in Firestore

### Future Tool Integration
* **AI Tool Calling:** The AI will interpret user requests and trigger actions:
  * Setting reminders for doctor's appointments
  * Setting reminders for medications
  * Calendar management
  * Emergency contacts

## 5. Architecture and Technology Stack

### Frontend
* **Framework:** [Flutter](https://flutter.dev/) (v3.37.0)
* **Programming Language:** [Dart](https://dart.dev/) (v3.10.0)
* **UI Design:** Material Design 3 with dynamic theming
* **Supported Platforms:** Web, Android, iOS, Windows, macOS, Linux

### Backend & Infrastructure
* **Backend Platform:** [Firebase](https://firebase.google.com/)
  * **Authentication:** Firebase Authentication
    - Email/Password authentication
    - Google Sign-In OAuth 2.0
    - Session management
  * **Database:** Cloud Firestore
    - Real-time NoSQL database
    - Chat message storage
    - User profile data
  * **Cloud Functions:** Node.js 18 serverless functions
    - AI integration endpoints
    - Tool execution logic
  * **Hosting:** Firebase Hosting for web deployment

### Development Tools
* **State Management:** Provider pattern via StreamBuilder (AuthWrapper)
* **Code Quality:** flutter_lints for Dart/Flutter best practices
* **Version Control:** Git
* **IDE Support:** VS Code, Android Studio, IntelliJ IDEA

## 6. Design and Development Principles

### User Experience
* **Simplicity First:** Clear, intuitive UI with minimal cognitive load
* **Accessibility:** Following WCAG guidelines for senior users:
  * Large, readable fonts
  * High contrast colors
  * Clear button labels and icons
  * Simple navigation patterns

### Code Quality
* **Clean Architecture:** Feature-based folder structure
* **Error Handling:** Comprehensive error handling with user-friendly messages
* **Type Safety:** Strong typing with Dart's type system
* **Form Validation:** Client-side validation for immediate feedback
* **Security:** No hardcoded credentials, using Firebase security rules

### Development Practices
* **Modular Architecture:** Separation of concerns with services, screens, and widgets
* **Responsive Design:** Adaptive layouts for different screen sizes
* **Progressive Enhancement:** Web platform as baseline, native features when available
* **Documentation:** Comprehensive inline documentation and README files

## 7. Current Project Status

### Completed ✅
* Firebase project setup and configuration
* Authentication system with email/password and Google Sign-In
* Professional login and registration screens
* Error handling and form validation
* WSL development environment configuration
* Web deployment setup

### In Progress 🚧
* Chat interface implementation
* Message model and Firestore integration
* Real-time message synchronization

### Planned 📋
* AI assistant integration
* Tool calling system for reminders and tasks
* User profile management
* Accessibility improvements for senior users
* Push notifications for reminders
* Offline support with local caching

## 8. Development Environment

### WSL-Specific Setup
* **Recommended Platform:** Web development on WSL
* **Server Configuration:** Python HTTP server or Flutter web-server
* **Port:** 5000 for Google Sign-In compatibility
* **Network Binding:** 0.0.0.0 for WSL networking

### Firebase Configuration
* **Project ID:** flutter-chat-e4f96
* **Region:** Default (us-central1)
* **Services Enabled:** Auth, Firestore, Functions

## 9. Security Considerations

* **Authentication:** Multi-factor authentication planned
* **Data Privacy:** HIPAA compliance considerations for health data
* **Encryption:** TLS for data in transit, considering encryption at rest
* **Access Control:** Role-based access for future caregiver features