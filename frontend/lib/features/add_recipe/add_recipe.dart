import 'package:flutter/material.dart';

class AddRecipe extends StatefulWidget{
    const AddRecipe({super.key});

    @override
    State<AddRecipe> createState() => _AddRecipe();
}
class _AddRecipe extends State<AddRecipe> {
    final TextEditingController _recipeNameController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    final List<TextEditingController> _ingredientsController = [];
    final List<TextEditingController> _stepsController = [];

    @override
    void initState(){
        super.initState();

        for (int i = 0; i < 3; i++){
            _ingredientsController.add(TextEditingController());
            _stepsController.add(TextEditingController());
        }
    }
    @override
    void dispose(){
        super.dispose();
    }


    @override
    Widget build(BuildContext context){
        return Scaffold(
           appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                title: Text("add reciep Page"),
            ),
            body: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            // name
                            TextFormField(
                                controller: _recipeNameController,
                                decoration: InputDecoration(
                                    labelText: "recipe name",
                                    border: OutlineInputBorder(),
                                ),
                                validator: (value){
                                    if (value == null || value.isEmpty){
                                        return "please enter a name";
                                    }
                                    return null;
                                },
                            ),
                            SizedBox(height: 20),

                            Text("ingredients"),
                            
                            SizedBox(height: 20),

                            ..._ingredientsController.asMap().entries.map((entry){
                                int index = entry.key;
                                TextEditingController controller = entry.value;
                                return Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: TextFormField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                            labelText: "ingredient ${index + 1}:",
                                            border: OutlineInputBorder(),
                                        ),
                                        validator: (value){
                                            if (value == null || value.isEmpty){
                                                return "enter ingredients";
                                            }
                                            return null;
                                        },
                                    )
                                );
                            }
                       ),

                            ElevatedButton(
                                onPressed: (){
                                    setState(() {
                                        _ingredientsController.add(TextEditingController());
                                    });
                                }, 
                                child: Text(" add ingredient")
                            ),

                            SizedBox(height: 20),

                            Text("Enter steps (in order)"),

                            SizedBox(height: 20),

                            ..._stepsController.asMap().entries.map((entry){
                                int index = entry.key;
                                TextEditingController controller = entry.value;
                                return Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: TextFormField(
                                        controller: controller,
                                        maxLines: 3,
                                        decoration: InputDecoration(
                                            labelText: "step ${index+ 1}:",
                                            border: OutlineInputBorder(),
                                        ),
                                        validator: (value){
                                            if (value == null || value.isEmpty){
                                                return "enter step";
                                            }
                                            return null;
                                        },
                                    )
                                );
                            }
                       ),

                            ElevatedButton(
                                onPressed: (){
                                    setState(() {
                                        _stepsController.add(TextEditingController());
                                    });
                                }, 
                                child: Text(" add step")
                            ),



                            SizedBox(height: 20),
                            Center(
                                child: ElevatedButton(
                                    onPressed: (){
                                        if (_formKey.currentState!.validate()){
                                            final name = _recipeNameController.text;

                                            final ingredients = _ingredientsController.map((c) => c.text).toList();

                                            final steps = _stepsController.map((c) => c.text).toList();

                                            print("name: ${_recipeNameController.text}");        

                                            print("ingredients: ${ingredients}");

                                            print("steps: ${steps}");
                                        }
                                    }, 
                                    child: Text("save recipe")
                                )
                            )
                        ],
                    ),
                )
            ),
        ); 

    }
    
}


