import 'package:flutter/material.dart';

class Constants {
  // App Metadata
  static const String appName = 'Bus Ticketing App';
  static const String appVersion = '1.0.0';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000', // FastAPI server
  );
  static const String authBaseUrl = String.fromEnvironment(
    'AUTH_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // Express auth server
  );
  static const String socketUrl = String.fromEnvironment(
    'SOCKET_URL',
    defaultValue: 'ws://10.0.2.2:8000',
  );
  static const String wsTripsEndpoint = '/ws/trips';
  // API Endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String logoutEndpoint = '';
  static const String tripsEndpoint =
      '/api/trips'; // FastAPI endpoint for trips
  static const String searchTripsEndpoint = '/api/trips/search';
  static const String bookingsEndpoint =
      '/api/bookings'; // FastAPI endpoint for bookings
  static const String feedbackEndpoint =
      ''; // Not supported by FastAPI server yet
  static const String aiEndpoint = ''; // Not supported by FastAPI server yet
  static const int apiTimeoutSeconds = 60;
  static const String authTokenKey = 'auth_token';

  // Storage Keys
  static const String jwtTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String backgroundImageKey = 'background_image_path';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String tripsRoute = '/trips';
  static const String historyRoute = '/history';
  static const String bookingConfirmationRoute = '/booking-confirmation';
  static const String tripDetailRoute = '/trip-detail';
  static const String bookingRoute = '/booking';

  // UI Constants
  static const String defaultBackgroundImage = 'assets/images/background.jpg';
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double buttonHeight = 48.0;
  static const double cardElevation = 4.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeSmall = 14.0;

  // Colors
  static const Color primaryColor = Color(0xFF1976D2); // Blue
  static const Color accentColor = Color(0xFFFFC107); // Amber
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light grey
  static const Color errorColor = Color(0xFFD32F2F); // Red
  static const Color successColor = Color(0xFF388E3C); // Green
  static const Color seatSelectedColor =
      Color(0xFF1976D2); // Blue for selected seats
  static const Color seatAvailableColor =
      Color(0xFFB0BEC5); // Grey for available seats
  static const Color seatBookedColor =
      Color(0xFFD32F2F); // Red for booked seats

  // Booking Constants
  static const int maxSeatsPerBooking = 4; // Max seats a user can book at once
  static const double seatGridSpacing = 8.0; // Spacing for seat selection grid
  static const int seatGridCrossAxisCount = 4; // Columns in seat selection grid

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noTripSelected = 'No trip selected';
  static const String noSeatsSelected = 'Please select at least one seat';
  static const String bookingFailed = 'Booking failed';
  static const String loginFailed = 'Login failed';
  static const String registrationFailed = 'Registration failed';
}
