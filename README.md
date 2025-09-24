# Seniors Companion App

A Flutter-based digital companion application designed to help seniors manage their daily tasks, stay connected, and maintain their independence through an intuitive AI-powered chat interface.

## 🎯 Project Vision

To create a user-friendly mobile application that acts as a digital companion for seniors, providing a simple, conversational interface for interacting with an AI assistant that can help with reminders, appointments, and daily task management.

## ✨ Features

### ✅ Completed Features
- **Multi-Platform Authentication System**
  - Email/password registration and login with comprehensive validation
  - Google OAuth 2.0 Sign-In integration
  - Professional UI with loading states and error handling
  - Session persistence with Firebase Authentication

- **Cross-Platform Support**
  - Web application (primary platform for WSL development)
  - Linux desktop support (via web configuration)
  - Android and iOS ready (configured)
  - Windows and macOS support

- **WSL Development Environment**
  - Optimized for Windows Subsystem for Linux development
  - Proper networking configuration for web deployment
  - Python HTTP server integration for better WSL compatibility

### 🚧 In Development
- **Chat Interface**
  - Real-time messaging with Cloud Firestore
  - Message history and synchronization
  - AI assistant integration preparation

### 📋 Planned Features
- **AI Assistant Integration**
  - Natural language processing for senior-friendly interactions
  - Tool calling system for automated task execution
  - Context-aware conversation management

- **Smart Reminders System**
  - Medication reminders with notifications
  - Appointment scheduling and alerts
  - Daily task management

- **Accessibility Features**
  - Large, readable fonts optimized for seniors
  - High contrast color schemes
  - Voice input and output capabilities
  - Simplified navigation patterns

## 🛠️ Technology Stack

- **Frontend**: Flutter 3.37.0 with Dart 3.10.0
- **Backend**: Firebase (Authentication, Firestore, Cloud Functions)
- **State Management**: Provider pattern with StreamBuilder
- **UI Framework**: Material Design 3 with dynamic theming
- **Development Platform**: WSL2 with WSLg for GUI support

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.37.0+
- Dart SDK 3.10.0+
- Python 3 (for WSL development server)

### Setup
1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_chat
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**

   **For WSL (Recommended):**
   ```bash
   # Build and serve production web app
   flutter build web
   cd build/web
   python3 -m http.server 5000 --bind 0.0.0.0
   ```

   **Alternative - Flutter dev server:**
   ```bash
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
   ```

4. **Access the application**
   - Open your browser to `http://localhost:5000`

### First Time Setup
1. Create an account using email/password or Google Sign-In
2. Explore the authentication system
3. Access the chat interface (basic implementation)

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Web | ✅ Primary | Optimized for WSL development |
| Linux Desktop | ⚠️ Limited | Uses web configuration due to Firebase SDK limitations |
| Android | 🔧 Configured | Ready for development |
| iOS | 🔧 Configured | Ready for development |
| Windows | 🔧 Configured | Ready for development |
| macOS | 🔧 Configured | Ready for development |

## 🔧 Development

### WSL-Specific Commands
```bash
# Kill background Flutter processes
pkill -f "flutter.*web-server"
pkill -f "dart.*frontend_server"

# Build and serve for production
flutter build web
cd build/web
python3 -m http.server 5000 --bind 0.0.0.0

# Development with Flutter server
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
```

### Code Quality
```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

## 📚 Documentation

- **[Development Guide](docs/DEVELOPMENT_GUIDE.md)** - Complete setup and development workflow
- **[Architecture Documentation](docs/ARCHITECTURE.md)** - System design and patterns
- **[API Documentation](docs/API_DOCUMENTATION.md)** - Firebase integration and API patterns
- **[Project Context](docs/PROJECT_CONTEXT.md)** - Detailed project overview and goals
- **[Task List](docs/TASK_LIST.md)** - Development roadmap and progress tracking
- **[CLAUDE.md](CLAUDE.md)** - AI assistant instructions for project understanding

## 🎯 Target Audience

**Primary Users**: Seniors who may need assistance with managing daily routines and appointments

**Design Principles**:
- Simple, intuitive interface with minimal cognitive load
- Large, readable fonts and high contrast colors
- Clear button labels and straightforward navigation
- Voice-enabled interactions (planned)

## 🔐 Security & Privacy

- **Authentication**: Multi-factor authentication with Firebase Auth
- **Data Privacy**: HIPAA compliance considerations for health data
- **Encryption**: TLS for data in transit, considering encryption at rest
- **Access Control**: Role-based permissions for future caregiver features

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

Please read our [Development Guide](docs/DEVELOPMENT_GUIDE.md) for detailed contribution guidelines.

## 🐛 Known Issues

- WSL requires specific network configuration for web development
- Google Sign-In requires localhost:5000 in authorized domains
- Firebase SDK doesn't support Linux desktop natively
- Forgot password functionality needs implementation

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Check the [Development Guide](docs/DEVELOPMENT_GUIDE.md) for common issues
- Review [API Documentation](docs/API_DOCUMENTATION.md) for integration questions
- Open an issue for bug reports or feature requests

## 🏗️ Project Status

**Current Phase**: Authentication System Complete + Chat Interface Development
**Next Milestone**: AI Assistant Integration
**Long-term Goal**: Comprehensive seniors digital companion platform

---

Built with ❤️ for the senior community using Flutter and Firebase.
