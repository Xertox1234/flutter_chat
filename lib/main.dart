import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:seniors_companion_app/firebase_options.dart';
import 'package:seniors_companion_app/src/features/authentication/services/auth_service.dart';
import 'package:seniors_companion_app/src/features/chat/screens/chat_screen.dart';
import 'package:seniors_companion_app/src/features/onboarding/screens/landing_screen.dart';
import 'package:seniors_companion_app/src/features/reminders/screens/reminders_screen.dart';
import 'package:seniors_companion_app/src/features/reminders/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seniors Companion App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const MainScreen();
        }
        return const LandingScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatScreen(),
    RemindersScreen(),
    RemindersScreen(showAppointments: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedFontSize: 18,
        unselectedFontSize: 16,
        selectedItemColor: Colors.green.shade700,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, size: 32),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication, size: 32),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today, size: 32),
            label: 'Appointments',
          ),
        ],
      ),
    );
  }
}
