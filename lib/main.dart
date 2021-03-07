import 'package:StampChat/services/PushNotificationsService.dart';
import 'package:StampChat/services/auth/TokenRefresher.dart';
import 'package:StampChat/widgets/user/LoginScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    TokenRefresher();
    PushNotificationsService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StampChat',
      theme: ThemeData(
        primaryColor: Color(0xFF273043),
        accentColor: Color(0xFFF9F7F3),
        errorColor: Color(0xFFDF2935),
        dialogTheme: DialogTheme(
          backgroundColor: Color(0xFF273043),
          contentTextStyle: TextStyle(
            color: Color(0xFFF9F7F3),
          ),
          titleTextStyle: TextStyle(
            fontSize: 20,
            color: Color(0xFFF9F7F3),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: Color(0xFFFFFFFF),
          filled: true,
        ),
        primaryTextTheme: Typography.whiteCupertino
            .apply(
              bodyColor: Color(0xFFF9F7F3),
              displayColor: Color(0xFFF9F7F3),
            )
            .copyWith(headline6: TextStyle(fontSize: 16)),
        accentTextTheme: Typography.whiteCupertino
            .apply(
              bodyColor: Color(0xFF273043),
              displayColor: Color(0xFF273043),
            )
            .copyWith(headline6: TextStyle(fontSize: 16)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
