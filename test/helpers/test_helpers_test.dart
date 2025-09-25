import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'test_helpers.dart';

void main() {
  group('Test Helpers', () {
    test('should create mock Firebase Auth', () {
      final mockAuth = createMockFirebaseAuth();
      expect(mockAuth, isA<MockFirebaseAuth>());
      expect(mockAuth.currentUser, isNull);
    });

    test('should create mock Firebase Auth with user', () {
      final mockUser = createMockUser();
      final mockAuth = createMockFirebaseAuth(mockUser: mockUser, signedIn: true);

      expect(mockAuth, isA<MockFirebaseAuth>());
      expect(mockAuth.currentUser, isNotNull);
      expect(mockAuth.currentUser?.email, equals('test@example.com'));
    });

    test('should create mock user with default values', () {
      final mockUser = createMockUser();

      expect(mockUser.uid, equals('test-uid-123'));
      expect(mockUser.email, equals('test@example.com'));
      expect(mockUser.displayName, equals('Test User'));
      expect(mockUser.emailVerified, isTrue);
    });

    test('should create mock user with custom values', () {
      final mockUser = createMockUser(
        uid: 'custom-uid',
        email: 'custom@example.com',
        displayName: 'Custom User',
      );

      expect(mockUser.uid, equals('custom-uid'));
      expect(mockUser.email, equals('custom@example.com'));
      expect(mockUser.displayName, equals('Custom User'));
    });

    test('should create mock Google Sign In', () {
      final mockGoogleSignIn = createMockGoogleSignIn();
      expect(mockGoogleSignIn, isA<MockGoogleSignIn>());
    });

    test('should create mock Firestore', () {
      final mockFirestore = createMockFirestore();
      expect(mockFirestore, isA<FakeFirebaseFirestore>());
    });

    test('should create test reminder data', () {
      final reminderData = createTestReminderData();

      expect(reminderData['id'], equals('test-reminder-1'));
      expect(reminderData['title'], equals('Test Reminder'));
      expect(reminderData['description'], equals('Test description'));
      expect(reminderData['type'], equals('appointment'));
      expect(reminderData['scheduledTime'], isA<DateTime>());
    });

    test('should create test medication data', () {
      final medicationData = createTestMedicationData();

      expect(medicationData['id'], equals('test-medication-1'));
      expect(medicationData['name'], equals('Test Medicine'));
      expect(medicationData['dosage'], equals('10mg'));
      expect(medicationData['instructions'], equals('Take with food'));
      expect(medicationData['scheduledTimes'], equals(['08:00', '20:00']));
    });

    test('should create custom test data', () {
      final customData = createTestMedicationData(
        id: 'custom-med',
        name: 'Custom Medicine',
        dosage: '5mg',
        scheduledTimes: ['09:00', '21:00'],
      );

      expect(customData['id'], equals('custom-med'));
      expect(customData['name'], equals('Custom Medicine'));
      expect(customData['dosage'], equals('5mg'));
      expect(customData['scheduledTimes'], equals(['09:00', '21:00']));
    });
  });
}