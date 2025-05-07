import 'package:datxetinh/features/auth/providers/AuthProvider.dart';
import 'package:datxetinh/features/booking/providers/BookingProvider.dart';
import 'package:datxetinh/features/trip/providers/TripProvider.dart';
import 'package:datxetinh/features/booking/screens/BookingConfirmation.dart';
import 'package:datxetinh/features/booking/screens/BookingScreen.dart';
import 'package:datxetinh/features/history/screens/History.dart';
import 'package:datxetinh/features/trip/screens/TripDetail.dart';
import 'package:datxetinh/features/trip/screens/TripList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/Api.dart';
import 'core/services/Auth.dart';
import 'core/Constants.dart';
import 'features/auth/screens/Login.dart';
import 'features/auth/screens/Register.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => Api()),
        Provider(create: (context) => AuthService(context.read<Api>())),
        ChangeNotifierProvider(
            create: (context) => AuthProvider(context.read<AuthService>())),
        ChangeNotifierProvider(
            create: (context) => BookingProvider(context.read<Api>())),
        ChangeNotifierProvider(
            create: (context) => TripProvider(context.read<Api>())),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Log constants to debug null values
    print('Constants.appName: ${Constants.appName}');
    print('Constants.loginRoute: ${Constants.loginRoute}');
    print('Constants.primaryColor: ${Constants.primaryColor}');
    print('Constants.backgroundColor: ${Constants.backgroundColor}');

    return MaterialApp(
      title: Constants.appName ?? 'Dat Xe Tinh', // Fallback if null
      theme: ThemeData(
        primaryColor: Constants.primaryColor ?? Colors.blue,
        scaffoldBackgroundColor: Constants.backgroundColor ?? Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.primaryColor ?? Colors.blue,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          // Áp dụng font TimesNewRoman cho các kiểu chữ
          bodyLarge: TextStyle(fontFamily: 'TimesNewRoman'),
          bodyMedium: TextStyle(fontFamily: 'TimesNewRoman'),
          titleLarge: TextStyle(fontFamily: 'TimesNewRoman'),
          titleMedium: TextStyle(fontFamily: 'TimesNewRoman'),
          titleSmall: TextStyle(fontFamily: 'TimesNewRoman'),
          bodySmall: TextStyle(fontFamily: 'TimesNewRoman'),
          labelLarge: TextStyle(fontFamily: 'TimesNewRoman'),
          labelMedium: TextStyle(fontFamily: 'TimesNewRoman'),
          labelSmall: TextStyle(fontFamily: 'TimesNewRoman'),
        ),
      ),
      initialRoute: Constants.loginRoute ?? '/login', // Fallback if null
      routes: {
        Constants.loginRoute ?? '/login': (context) => const Login(),
        Constants.registerRoute ?? '/register': (context) => const Register(),
        Constants.tripsRoute ?? '/trips': (context) => const TripList(),
        Constants.tripDetailRoute ?? '/trip-detail': (context) =>
            const TripDetail(),
        Constants.bookingRoute ?? '/booking': (context) =>
            const BookingScreen(),
        Constants.bookingConfirmationRoute ?? '/bookingConfirmation':
            (context) => const BookingConfirmation(),
        Constants.historyRoute: (context) => const History(),
      },
    );
  }
}
