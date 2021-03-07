import 'package:StampChat/services/auth/GoogleAuthHelper.dart';
import 'package:StampChat/widgets/user/LoginScreen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "StampChat",
                style: Theme.of(context).textTheme.headline3,
              ),
              SizedBox(height: 50),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return OutlineButton(
      splashColor: Colors.grey,
      onPressed: () {
        GoogleAuthHelper().signOutGoogle();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }), ModalRoute.withName('/'));
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      highlightElevation: 0,
      borderSide: BorderSide(color: Colors.grey),
      child: Text(
        'Logout',
        style: TextStyle(
          fontSize: 20,
          color: Colors.grey,
        ),
      ),
    );
  }
}
