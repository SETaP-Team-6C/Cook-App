# frontend

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### so far what is there

main func is entry point and runApp() tells flutter to start here where the widet inside becomes the root the CookApp widget is not mutable so it doesnt change as it doesntchange anything after intial setup home: LoginPage home defines the first screen when app opens so it starts by loading the login page 

#### login

creates a stateful widet as it is going to get the text from the input field and trigger navigation when the button is clicked 
 _loginPageState stores a texteditingconroller which allows us to read text in the input field also we overide the dispose method to clean up the widet once its removes always call super.dispose after your call aswell 

we then build the main widget i have put in in commments in code so i wont go into too much detail but important is navigator allows us to replace login screen with homepage and pass the stroed username to the homepage contstructor

#### home

i cleaned up a bit here just removed stuff that wasnt in use and changed it to use the username instead of title other than that its the same 




