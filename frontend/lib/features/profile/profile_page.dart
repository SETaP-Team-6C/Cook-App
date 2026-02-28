import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';

class AccountPage extends StatelessWidget{
    final String username;
    final bool newAccount;
    const AccountPage({super.key, required this.username,required this.newAccount});

    @override
    Widget build(BuildContext context){
        return Scaffold(
           appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text("Account Page"),
                actions: [
                    IconButton(
                        onPressed: (){
                            Navigator.pushReplacementNamed(
                                context, 
                                AppRoutes.home,
                                arguments: {
                                    "username":username,
                                    "newAccount": newAccount 
                                }
                        );
                      },
                        icon: Icon(Icons.back_hand_sharp),
                    )
                ],
            )
        ); 

    }
}


