import 'package:datxetinh/features/booking/screens/BookingConfirmation.dart';
import 'package:datxetinh/features/booking/screens/BookingScreen.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/Login.dart';
import '../features/auth/screens/Register.dart';
import '../features/trip/screens/TripList.dart';
import '../features/trip/screens/TripDetail.dart';
import '../features/history/screens/History.dart';
import '../core/Constants.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String trips = '/trips';
  static const String tripDetail = '/trip-detail';
  static const String booking = '/booking';
  static const String history = '/history';
  static const bookingConfirmation = '/bookingConfirmation';
  static const historyRoute = 'BookingHistory';
 
  static Map<String, WidgetBuilder> routes = {
    login: (context) => Login(),
    register: (context) => Register(),
    trips: (context) => TripList(),
    tripDetail: (context) => TripDetail(),
    Constants.historyRoute: (context) => History(),
    booking: (context) => BookingScreen(),
    bookingConfirmation: (context) => BookingConfirmation(),
    
  };
}
