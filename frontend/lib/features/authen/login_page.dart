import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';
import 'package:http/http.dart' as http;

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
                Uri.parse("http://localhost:5000/authenticate"), // need to change per create account and login :) 
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded", // changed as backend requests form
                },
                body: { // removed json encode as again form backend
                    "user_fname": userFname,
                    "user_lname": userLname,
                },
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
        } else {
            await _sendUser(userFname, userLname, newAccount);
        }

        String username = "$userFname $userLname";

        Navigator.pushReplacementNamed(  // uses named routing now instead of direct calling
            context,
            AppRoutes.home,
            arguments:{
                "username": username,
                "newAccount":newAccount
            }
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
                automaticallyImplyLeading: false,
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
                                controller: _userLnameController, // like fields in html so need .value to get value
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
