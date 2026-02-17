import 'package:flutter/material.dart';
import 'package:frontend/pages/HomePage.dart';

class LoginPage extends StatefulWidget { // mutable state 
    const LoginPage({super.key});

    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    // controller 
    final TextEditingController _usernameController = TextEditingController(); // final = like a const ptr no reassign but obj can change

    @override
    void dispose(){
        //clean up (for next screen or page (homepage))
        _usernameController.dispose();
        super.dispose();
    }

    @override
      Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text("Login"),
                centerTitle: true,  // centers title idk why they made it diff frim the center
            ),
            body:  Center(
            child: Padding(
                padding: EdgeInsets.all(20),
                child: Column( // stacks Widget vertically so it goes title -> field -> login
                    mainAxisSize: MainAxisSize.min,
                    children: [  // list allows more then one child to be in the coloum
                        TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(),
                        ),
                    ),
                        SizedBox(height: 20,),  // vertical spacing 
                        ElevatedButton(
                                onPressed: () {
                                    String? username = _usernameController.text; // like elem.value in js fields ik abt null but js eg
                                    print("the user ented :$username");

                                    Navigator.pushReplacement(
                                        context, 
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(username: username)
                                        )
                                    );
                                }, 
                                child: 
                                    Text("LOgin"),
                            )
                        ],
                    )
                ),
            ),
        );
    }
}
