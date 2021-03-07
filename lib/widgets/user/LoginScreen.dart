import 'package:StampChat/services/PushNotificationsService.dart';
import 'package:StampChat/services/auth/GoogleAuthHelper.dart';
import 'package:StampChat/services/auth/UserToken.dart';
import 'package:StampChat/widgets/chat/ChatListScreen.dart';
import 'package:StampChat/widgets/user/login_buttons/GoogleLoginButton.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool authInitialized = false;
  bool authInitializing = true;

  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _initializeAuth() async {
    bool hasLoggedIn = false;
    try {
      await Firebase.initializeApp();
      authInitialized = true;
      if ((await GoogleAuthHelper().getCurrentUser()) != null) {
        _onLogin(true, false, null);
        UserToken userToken = await GoogleAuthHelper().signInWithGoogle();
        _onLogin(true, false, userToken);
        hasLoggedIn = true;
      }
    } catch (e) {} finally {
      if (!hasLoggedIn) {
        setState(() {
          authInitialized = true;
          authInitializing = false;
        });
        _onLogin(false, false, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: authInitializing || _isLoading
          ? _buildLoadingState()
          : authInitialized
              ? _buildLoginScreen()
              : _buildErrorState(),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          size: 40,
          color: Theme.of(context).errorColor,
        ),
        Container(
          padding: EdgeInsets.only(top: 16),
        ),
        Text("Error starting up"),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        ),
        Container(
          padding: EdgeInsets.only(top: 16),
        ),
        Text(authInitializing ? "Starting up" : "Logging in"),
      ],
    );
  }

  Widget _buildLoginScreen() {
    return Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/app/logo.png',
              color: Theme.of(context).primaryColor,
              width: 60,
              height: 60,
            ),
            Padding(padding: EdgeInsets.only(top: 12)),
            Text(
              "StampChat",
              style: Theme.of(context)
                  .textTheme
                  .headline3
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
            Padding(padding: EdgeInsets.only(top: 20)),
            Visibility(
              visible: _hasError,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    size: 40,
                    color: Theme.of(context).errorColor,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 16),
                  ),
                  Text("Error logging in"),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
            ),
            GoogleLoginButton(
              loginLoading: _onLogin,
            ),
          ],
        ),
      ),
    );
  }

  void _onLogin(bool isLoading, bool hasError, UserToken userToken) {
    if (userToken != null) {
      PushNotificationsService.getToken().then((token) {
        PushNotificationsService.registerToken(token);
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return ChatListScreen();
          },
        ),
      );
    } else {
      setState(() {
        _isLoading = isLoading;
        _hasError = hasError;
      });
    }
  }
}
