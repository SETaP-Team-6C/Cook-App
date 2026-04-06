import 'package:flutter/material.dart';
import 'package:frontend/core/routes.dart';

class HomePage extends StatefulWidget {
    const HomePage({super.key, required this.username, required this.newAccount});

    final String username; // changed to reflect user naem
    final bool newAccount; //check for new account
@override
    State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
    // got rid of boiler plate incrementor

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text("welcome, ${widget.username}"), //changed to welcome based on what the user puts in 
                actions: [ // actions is far right allows for buttons on appBar use leading for left
                    IconButton(
                        onPressed: () {
                            Navigator.pushNamed(
                                context, 
                                AppRoutes.profile,
                                arguments: {
                                    "username": widget.username,
                                    "newAccount": widget.newAccount
                                }
                            );     
                        }, 
                        icon: Icon(Icons.account_box_rounded)
                    ),
                    IconButton(
                        onPressed: () {
                            print("clicked on the settings button");
                        }, 
                        icon: Icon(Icons.settings)
                    )
                ],
            ),
            // need to do something here like its got no content 
            // ye lowkey i really want to start adding like actual content but i dont it to jsut be my ideas
            // my idea is smt like this
//------------------------------------------------------------
// 1                                                         1
// 1                    appBar                               1
// 1                                                         1
// 1---------------------------------------------------------1                                                         
//
// 1------------1       1-----------1       1-----------1                                                        
// 1            1       1           1       1           1                                                         
// 1            1       1           1       1           1                                                         
// 1            1       1           1       1           1                                                         
// 1            1       1           1       1           1                                                         
// 1------------1       1-----------1       1-----------1                                                        
//
//----------------recommmened-------------------------------
// 
//----------------------------------------------------------
//1                 recipe 1                               1
//----------------------------------------------------------
//----------------------------------------------------------
//1                 recipe 2                               1
//----------------------------------------------------------
//----------------------------------------------------------
//1                 recipe 3                               1
//----------------------------------------------------------
//
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        ElevatedButton.icon(
                            onPressed: () {
                                Navigator.pushNamed(
                                    context,
                                    AppRoutes.techniques,
                                );
                            },
                            icon: const Icon(Icons.menu_book_outlined),
                            label: const Text("cooking techniques")
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: () {
                                Navigator.pushNamed(
                                    context,
                                    AppRoutes.addRecipe,
                                );
                            }, 
                            child: Text("add recipe")
                        )
                    ],
                ),
            ),
        );
    }
}
