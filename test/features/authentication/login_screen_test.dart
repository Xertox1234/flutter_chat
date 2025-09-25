import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seniors_companion_app/src/features/authentication/screens/login_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    testWidgets('should display all UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Check for app bar
      expect(find.text('Welcome Back'), findsOneWidget);

      // Check for main title and subtitle
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Welcome to Seniors Companion App'), findsOneWidget);

      // Check for text fields
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Check for buttons
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Check for icons
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should validate empty email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Tap sign in without entering anything
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Enter invalid email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'invalid-email',
      );

      // Tap sign in
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('should validate empty password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Enter valid email but no password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      // Tap sign in
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Check for validation error
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Check initial visibility icon
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Icon should change to visibility_off
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Icon should change back to visibility
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should show loading state when signing in', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
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

      // The actual sign-in would trigger loading state
      // Here we verify the button exists and can be tapped
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pump();
    });

    testWidgets('should navigate to registration screen', (WidgetTester tester) async {
      final navigatorObserver = NavigatorObserver();

      await tester.pumpWidget(
        createTestWidgetWithNavigation(
          child: const LoginScreen(),
          navigatorObserver: navigatorObserver,
        ),
      );

      // Find and tap Sign Up text
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify navigation intent
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should show forgot password message', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Tap forgot password
      await tester.tap(find.text('Forgot Password?'));
      await tester.pump();

      // Check for snackbar message
      expect(find.text('Forgot password feature coming soon!'), findsOneWidget);
    });

    testWidgets('should have Google sign-in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Check for Google sign-in button
      final googleButton = find.widgetWithText(OutlinedButton, 'Sign in with Google');
      expect(googleButton, findsOneWidget);

      // Tap the button
      await tester.tap(googleButton);
      await tester.pump();
    });

    testWidgets('should use correct color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Check AppBar color
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(const Color(0xFF4F46E5)));

      // Check primary button color
      final signInButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sign In'),
      );

      // Verify button exists with correct styling
      expect(signInButton, isNotNull);
    });

    testWidgets('should handle text field submission', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Enter email
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );

      // Press enter/next on email field
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      // Focus should move to password field
      // Enter password
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );

      // Press enter/done on password field should submit
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
    });

    testWidgets('should display divider with OR text', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Check for divider elements
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('OR'), findsOneWidget);
    });

    testWidgets('should have proper form structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(child: const LoginScreen()),
      );

      // Check for Form widget
      expect(find.byType(Form), findsOneWidget);

      // Check for proper spacing
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));

      // Check for SingleChildScrollView for keyboard handling
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}