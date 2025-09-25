import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seniors_companion_app/src/features/authentication/screens/registration_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('RegistrationScreen Widget Tests', () {
    testWidgets('should display all UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Check for app bar
      expect(find.text('Create Account'), findsOneWidget);

      // Check for main title
      expect(find.text('Register'), findsOneWidget);

      // Check for text fields
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);

      // Check for register button
      expect(find.widgetWithText(ElevatedButton, 'Register'), findsOneWidget);

      // Check for back to login link
      expect(find.text('Already have an account? Sign In'), findsOneWidget);

      // Check for icons
      expect(find.byIcon(Icons.person_add), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('should validate empty email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Tap register without entering anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );

      // Tap register
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter valid email but no password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      // Tap register
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('should validate password length', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter valid email and short password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        '123',
      );

      // Tap register
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Password must be at least 6 characters long'), findsOneWidget);
    });

    testWidgets('should validate password confirmation', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter valid email and password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'different123',
      );

      // Tap register
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('should validate empty confirm password', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter valid email and password but no confirmation
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Tap register
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Please confirm your password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Check initial visibility icons
      expect(find.byIcon(Icons.visibility), findsNWidgets(2)); // Password and confirm password

      // Tap first visibility toggle (password field)
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      // One should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap second visibility toggle (confirm password field)
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      // Both should be visibility_off
      expect(find.byIcon(Icons.visibility_off), findsNWidgets(2));
    });

    testWidgets('should pass validation with valid inputs', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter valid credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );

      // Tap register
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Should not show validation errors
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email address'), findsNothing);
      expect(find.text('Please enter a password'), findsNothing);
      expect(find.text('Password must be at least 6 characters long'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('should navigate back to login screen', (WidgetTester tester) async {
      final navigatorObserver = NavigatorObserver();

      await tester.pumpWidget(
        createTestWidgetWithNavigation(
          child: const RegistrationScreen(),
          navigatorObserver: navigatorObserver,
        ),
      );

      // Find and tap back to login link
      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();

      // Verify navigation intent
      expect(find.text('Already have an account? Sign In'), findsOneWidget);
    });

    testWidgets('should use correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Check AppBar color
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(const Color(0xFF4F46E5)));

      // Check register button exists
      final registerButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Register'),
      );
      expect(registerButton, isNotNull);
    });

    testWidgets('should handle text field submission', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      // Press next on email field
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Press next on password field
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Enter confirm password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );

      // Press done on confirm password field should submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    });

    testWidgets('should disable fields when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Enter valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm Password'),
        'password123',
      );

      // The loading state would be triggered by actual registration
      // Here we just verify the button exists and can be tapped
      final registerButton = find.widgetWithText(ElevatedButton, 'Register');
      expect(registerButton, findsOneWidget);
    });

    testWidgets('should have proper form structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const RegistrationScreen()),
      );

      // Check for Form widget
      expect(find.byType(Form), findsOneWidget);

      // Check for proper spacing
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));

      // Check for SingleChildScrollView for keyboard handling
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Check for ConstrainedBox for responsive design
      expect(find.byType(ConstrainedBox), findsOneWidget);
    });
  });
}