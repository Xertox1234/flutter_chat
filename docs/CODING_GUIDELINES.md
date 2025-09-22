
# Flutter Coding Guidelines

This document outlines the coding style and best practices to be followed in this project. The guidelines are based on the official [Flutter style guide](https://docs.flutter.dev/development/tools/sdk/specifications/style-guide) and are intended to ensure a clean, consistent, and maintainable codebase.

## 1. Naming Conventions

* **Classes and Enums:** Use `UpperCamelCase`.

  ```dart
  class MyClass { ... }
  enum MyEnum { value1, value2 }
  ```

* **Variables, Methods, and Functions:** Use `lowerCamelCase`.

  ```dart
  String myVariable = 'hello';
  void myMethod() { ... }
  ```

* **Constants:** Use `lowerCamelCase`.

  ```dart
  const int myConstant = 100;
  ```

* **Files and Directories:** Use `snake_case`.

  ```
  my_file.dart
  my_directory/
  ```

## 2. Code Formatting

* **Line Length:** Keep lines under 80 characters to ensure readability.
* **Indentation:** Use 2 spaces for indentation.
* **Braces:** Use braces for all control flow statements, even single-line ones.

  ```dart
  // Good
  if (condition) {
    print('hello');
  }

  // Bad
  if (condition) print('hello');
  ```

* **Trailing Commas:** Use trailing commas on the last argument in a function call or the last item in a list/map to improve formatting with `dart format`.

## 3. Documentation

* **Comments:** Use `//` for single-line comments and `/* ... */` for multi-line comments.
* **Doc Comments:** Use `///` for documentation comments that can be processed by `dart doc`.

  ```dart
  /// A brief description of the function.
  ///
  /// A longer description that can span multiple lines.
  void myFunction() { ... }
  ```

## 4. Best Practices

* **`const` and `final`:** Prefer `const` for compile-time constants and `final` for variables that are assigned only once.
* **Type Annotations:** Use type annotations for all variables and function return types to improve code clarity and catch potential errors.
* **Avoid `dynamic`:** Avoid using the `dynamic` type. If you need to represent a value that can be of multiple types, consider using `Object` or a more specific type.
* **Use `async`/`await`:** Use `async`/`await` for asynchronous operations to make your code more readable and easier to follow.
* **State Management:** We will use [Riverpod](https://riverpod.dev/) for state management. Follow the best practices outlined in the Riverpod documentation.
* **Widget Structure:** Keep your widget build methods small and focused. Extract complex parts of your UI into smaller, reusable widgets.

## 5. Linting

This project uses the linting rules defined in the `analysis_options.yaml` file. These rules are based on the `flutter_lints` package and are designed to enforce the guidelines in this document. Make sure to address any linting errors or warnings before committing your code.
