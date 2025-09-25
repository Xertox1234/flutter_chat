import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:seniors_companion_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Main User Flow Integration Tests', () {
    testWidgets('complete user journey from landing to main app', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Should start with landing screen when not authenticated
      expect(find.text('Your AI Companion for Daily Living'), findsOneWidget);
      expect(find.text('Start Free Trial'), findsAtLeastNWidgets(1));
      expect(find.text('Sign In'), findsAtLeastNWidgets(1));

      // Navigate to sign in
      await tester.tap(find.text('Sign In').first);
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Navigate to registration
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Should be on registration screen
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);

      // Fill registration form
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

      // Note: In a real integration test with Firebase, you'd actually register
      // and verify the user gets to the main screen. For demo purposes,
      // we verify the form can be filled and submitted.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
      await tester.pump();

      // Verify no validation errors
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Passwords do not match'), findsNothing);
    });

    testWidgets('landing page navigation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should start with landing screen
      expect(find.text('Your AI Companion for Daily Living'), findsOneWidget);

      // Test email subscription
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -3000));
      await tester.pumpAndSettle();

      // Find email input and subscribe button
      final emailField = find.byType(TextField);
      final subscribeButton = find.text('Subscribe');

      if (emailField.evaluate().isNotEmpty && subscribeButton.evaluate().isNotEmpty) {
        // Test invalid email
        await tester.enterText(emailField, 'invalid-email');
        await tester.tap(subscribeButton);
        await tester.pump();

        expect(find.text('Please enter a valid email address'), findsOneWidget);

        // Test valid email
        await tester.enterText(emailField, 'test@example.com');
        await tester.tap(subscribeButton);
        await tester.pump();

        expect(find.text('Thank you for subscribing!'), findsOneWidget);
      }
    });

    testWidgets('FAQ interaction', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Scroll to FAQ section
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Check FAQ section exists
      expect(find.text('Frequently Asked Questions'), findsOneWidget);

      // Find and tap first FAQ item
      final faqItem = find.text('How does the medication reminder system work?');
      if (faqItem.evaluate().isNotEmpty) {
        await tester.tap(faqItem);
        await tester.pumpAndSettle();

        // Check if answer appears
        expect(
          find.textContaining('AI-powered system'),
          findsOneWidget,
        );
      }
    });

    testWidgets('responsive design behavior', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test mobile layout
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpAndSettle();

      // Should display mobile layout
      expect(find.text('Your AI Companion for Daily Living'), findsOneWidget);

      // Test tablet/desktop layout
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpAndSettle();

      // Should still display content properly
      expect(find.text('Your AI Companion for Daily Living'), findsOneWidget);

      // Reset to default
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    testWidgets('login form validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Sign In').first);
      await tester.pumpAndSettle();

      // Test empty form submission
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Should show validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      // Test invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Test valid inputs
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Should pass validation when tapped
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Should not show validation errors
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('forgot password interaction', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Sign In').first);
      await tester.pumpAndSettle();

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();

      // Should show snackbar message
      expect(find.text('Forgot password feature coming soon!'), findsOneWidget);
    });

    testWidgets('navigation between auth screens', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Start at landing → login
      await tester.tap(find.text('Sign In').first);
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);

      // Login → registration
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsOneWidget);

      // Registration → back to login
      await tester.tap(find.text('Already have an account? Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome Back'), findsOneWidget);

      // Login → back to landing (via back button)
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Your AI Companion for Daily Living'), findsOneWidget);
    });

    testWidgets('password visibility toggle', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login
      await tester.tap(find.text('Sign In').first);
      await tester.pumpAndSettle();

      // Test password visibility toggle
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Navigate to registration and test both password fields
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsNWidgets(2));

      // Toggle first password field
      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}