// Global flag to identify if the application is running inside a test environment.
// Using a global flag is 100% web-safe and avoids importing 'dart:io' or accessing 'Platform' on Flutter Web.
bool isTesting = false;
