import 'package:flutter/material.dart';
import 'package:frontend/pages/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final TextEditingController _userFnameController = TextEditingController();
    final TextEditingController _userLnameController = TextEditingController();
    // async func returns Future of type void is like in rust needs 
    Future<void> _sendUser(userFname, userLname, newAccount) async {
        try {
        final response = await http.post(
            Uri.parse("http://localhost:5000/login"),
            headers: {
            "Content-Type": "application/json",
            },
            body: jsonEncode({
            "user_fname": userFname,
            "user_lname": userLname,
            }),
        );

        if (response.statusCode == 200) {
            print("yipppeee it works (hit backend) ${response.body}");
        } else {
            print("fail somewhere ${response.statusCode}");
        }
        } catch (e) {
        print("error: $e");
        }
    }

    void _handleAuth(bool newAccount) async {
        String userFname = _userFnameController.text;
        String userLname = _userLnameController.text;

        if (userFname.isEmpty || userLname.isEmpty) {
            return; // this why it needs string and "" isEmpty == true forgot abt it 
        }else {
        await _sendUser(userFname, userLname, newAccount);
        }

        String username = "$userFname $userLname";

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                username: username, // passing these to HomePage class to allow hello, username and to get newAccount
                newAccount: newAccount,
                ),
            ),
        );
    }

    @override
    void dispose() {
        // clean up 
        _userFnameController.dispose();
        _userLnameController.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
        appBar: AppBar(
            title: Text("Login"),
            centerTitle: true,
        ),
        body: Center(
            child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                TextField(
                    controller: _userFnameController, // allows use of value
                    decoration: InputDecoration(
                        labelText: "User first name",
                        border: OutlineInputBorder(),
                    ),
                ),
                SizedBox(height: 20),
                TextField(
                    controller: _userLnameController,
                    decoration: InputDecoration(
                        labelText: "User last name",
                        border: OutlineInputBorder(),
                    ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () => _handleAuth(false), // what happens on press func
                    child: Text("Login"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () => _handleAuth(true),
                    child: Text("Create Account"),
                ),
                ],
            ),
        ),
      ),
    );
  }
}
