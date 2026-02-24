import 'package:flutter/material.dart';
import 'package:frontend/pages/HomePage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatefulWidget { // mutable state 
    const LoginPage({super.key});

    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    // controller 
    final TextEditingController _user_f_nameController = TextEditingController(); // final = like a const ptr no reassign but obj can change
    final TextEditingController _user_l_nameController = TextEditingController(); // final = like a const ptr no reassign but obj can change

    @override
    void dispose(){
        //clean up (for next screen or page (homepage))
        _user_f_nameController.dispose();
        _user_l_nameController.dispose();
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
                            controller: _user_f_nameController,
                            decoration: InputDecoration(
                            labelText: "User first name",
                            border: OutlineInputBorder(),
                        ),
                    ),
                        SizedBox(height: 20,),  // vertical spacing 
                        TextField(
                            controller: _user_l_nameController,
                            decoration: InputDecoration(
                            labelText: "User last name",
                            border: OutlineInputBorder(),
                        ),
                    ),
                        SizedBox(height: 20,),  // vertical spacing 
                        ElevatedButton(
                                onPressed: () async { // waits for be to respnd 
                                    String user_fname = _user_f_nameController.text; // like elem.value in js fields ik abt null but js eg
                                    String user_lname = _user_l_nameController.text; // like elem.value in js fields ik abt null but js eg
                                    if (user_fname.isEmpty || user_lname.isEmpty){
                                        return;
                                    }
                                    else{
                                        try{
                                            final response = await http.post(
                                                Uri.parse("http://localhost:5000/login"), // will need to change for mobile jsut testing so used web
                                                headers: {
                                                    "Content-Type": "application/json"
                                                },
                                                body:jsonEncode( {
                                                    "user_fname": user_fname,   
                                                    "user_lname": user_lname
                                                })
                                            );
                                            if (response.statusCode == 200){
                                                print("yipppeee it works (hit backend) ${response.body}");
                                            }else{
                                                print("fail somewhere ${response.statusCode}");
                                            }
                                        } catch (e){
                                            print("error: ${e}");
                                        }
                                    }
                                    print("the user ented :$user_fname " "$user_lname");
                                    String username = user_fname + " " + user_lname;

                                    Navigator.pushReplacement(
                                        context, 
                                        MaterialPageRoute(
                                            builder: (context) => HomePage(username: username)
                                        )
                                    );
                                }, 
                                child: 
                                    Text("Login"),
                            )
                        ],
                    )
                ),
            ),
        );
    }
}
