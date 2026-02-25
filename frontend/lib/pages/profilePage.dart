import 'package:flutter/material.dart';
import 'package:frontend/pages/HomePage.dart';

class AccountPage extends StatelessWidget{
    final String username;
    final bool newAccount;
    const AccountPage({super.key, required this.username,required this.newAccount});

    @override
    Widget build(BuildContext context){
        return Scaffold(
           appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text("Account Page"),
                actions: [
                    IconButton(
                        onPressed: (){
                            Navigator.pushReplacement(
                                context, 
                                MaterialPageRoute(
                                    builder: (context) => HomePage(
                                        username: username, 
                                        newAccount: newAccount
                                )
                            )
                        );
                      },
                        icon: Icon(Icons.back_hand_sharp),
                    )
                ],
            )
        ); 

    }
}

