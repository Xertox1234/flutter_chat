import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';

// Create mock authentication instances
MockFirebaseAuth createMockFirebaseAuth({
  MockUser? mockUser,
  bool signedIn = false,
}) {
  if (signedIn && mockUser != null) {
    return MockFirebaseAuth(signedIn: true, mockUser: mockUser);
  }
  return MockFirebaseAuth();
}

// Create a mock user
MockUser createMockUser({
  String? uid,
  String? email,
  String? displayName,
  String? photoURL,
  bool? isAnonymous,
  bool? isEmailVerified,
}) {
  return MockUser(
    uid: uid ?? 'test-uid-123',
    email: email ?? 'test@example.com',
    displayName: displayName ?? 'Test User',
    photoURL: photoURL,
    isAnonymous: isAnonymous ?? false,
    isEmailVerified: isEmailVerified ?? true,
  );
}

// Create mock Google Sign In
MockGoogleSignIn createMockGoogleSignIn({
  bool cancelled = false,
  bool signedIn = false,
}) {
  final mockGoogleSignIn = MockGoogleSignIn();
  if (cancelled) {
    mockGoogleSignIn.setIsCancelled(true);
  }
  if (signedIn) {
    mockGoogleSignIn.enableLightweightAuthentication();
  }
  return mockGoogleSignIn;
}

// Create a mock Firestore instance
FakeFirebaseFirestore createMockFirestore() {
  return FakeFirebaseFirestore();
}

// Widget wrapper for testing
Widget createTestWidget({
  required Widget child,
  NavigatorObserver? navigatorObserver,
}) {
  return MaterialApp(
    home: child,
    navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
  );
}

// Widget wrapper with navigation
Widget createTestWidgetWithNavigation({
  required Widget child,
  Map<String, WidgetBuilder>? routes,
  NavigatorObserver? navigatorObserver,
}) {
  return MaterialApp(
    home: child,
    routes: routes ?? {},
    navigatorObservers: navigatorObserver != null ? [navigatorObserver] : [],
  );
}

// Create test reminder data
Map<String, dynamic> createTestReminderData({
  String? id,
  String? title,
  String? description,
  DateTime? scheduledTime,
  String? type,
}) {
  return {
    'id': id ?? 'test-reminder-1',
    'title': title ?? 'Test Reminder',
    'description': description ?? 'Test description',
    'scheduledTime': scheduledTime ?? DateTime.now().add(const Duration(hours: 1)),
    'type': type ?? 'appointment',
  };
}

// Create test medication data
Map<String, dynamic> createTestMedicationData({
  String? id,
  String? name,
  String? dosage,
  String? instructions,
  List<String>? scheduledTimes,
}) {
  return {
    'id': id ?? 'test-medication-1',
    'name': name ?? 'Test Medicine',
    'dosage': dosage ?? '10mg',
    'instructions': instructions ?? 'Take with food',
    'scheduledTimes': scheduledTimes ?? ['08:00', '20:00'],
  };
}