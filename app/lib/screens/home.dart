// ignore_for_file: use_build_context_synchronously

import 'package:app/config/config.dart';
import 'package:app/screens/login.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      _showSnackBarSuccess('Logged Out Successfully !');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      _showSnackBarError(e.toString());
    }
  }

  void _showSnackBarError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        duration: const Duration(seconds: 2),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _showSnackBarSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Rounded corners
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // ignore: unused_local_variable
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        scrolledUnderElevation: 0.0,
        title: const Center(
          child: Text(
            'TO DOs',
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_outlined),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  onTap: () {
                    AwesomeDialog(
                      dialogBackgroundColor: Colors.white,
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.topSlide,
                      title: "Ohh!",
                      desc: 'Are you sure you want to logout?',
                      descTextStyle: TextStyle(
                          fontSize: 16 * (screenWidth / 360),
                          color: Colors.grey[700]),
                      btnCancelText: 'No',
                      btnCancelOnPress: () {},
                      btnOkText: 'Yes',
                      btnOkOnPress: () {
                        _logout(context);
                      },
                      btnOkColor: Config.themeMainColor,
                      btnCancelColor: Colors.grey.shade700,
                      customHeader: Icon(Icons.question_mark,
                          size: screenWidth * 0.15, color: Colors.red),
                    ).show();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      SizedBox(width: screenWidth * 0.04),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Center(
        child: InkWell(
          onTap: () {},
          child: const Text("Home"),
        ),
      ),
    );
  }
}
