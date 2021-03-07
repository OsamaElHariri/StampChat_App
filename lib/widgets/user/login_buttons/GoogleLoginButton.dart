import 'package:StampChat/services/auth/GoogleAuthHelper.dart';
import 'package:StampChat/services/auth/UserToken.dart';
import 'package:flutter/material.dart';

class GoogleLoginButton extends StatelessWidget {
  final Function(bool, bool, UserToken) loginLoading;
  GoogleLoginButton({@required this.loginLoading});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return RaisedButton(
      onPressed: () {
        loginLoading(true, false, null);
        GoogleAuthHelper().signInWithGoogle().then((result) {
          loginLoading(false, false, result);
        }).catchError((error) {
          loginLoading(false, true, null);
          print(error);
          GoogleAuthHelper().signOutGoogle();
        });
      },
      color: theme.primaryColor,
      child: Text(
        'Sign in with Google',
        style: theme.textTheme.headline6.copyWith(color: theme.accentColor),
      ),
    );
  }
}
