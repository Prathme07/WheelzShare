import 'package:carpol/authentication/login_scren.dart';
import 'package:carpol/methods/common_method.dart';
import 'package:carpol/widgets/loading_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key); // Fixed super call

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController usertextEditingController = TextEditingController();
  TextEditingController userPhoneEditingController =
      TextEditingController(); // Added TextEditingController for user phone
  TextEditingController emailtextEditingController = TextEditingController();
  TextEditingController passwordtextEditingController = TextEditingController();
  CommonMethods cMethod = CommonMethods();

  get userNametextEditingController => null;

  void checkIfNetworkIsAvailable() {
    cMethod.checkConnectivity(context);

    signUpForValidation(); // Call signUpForValidation function
  }

  void signUpForValidation() {
    if (usertextEditingController.text.trim().length < 4) {
      cMethod.displaySnackBar(
          "Your Name must be at least 4 characters or more.", context);
    } else if (userPhoneEditingController.text.trim().length != 10) {
      cMethod.displaySnackBar("Your Number must be 10 digits.", context);
    } else if (!emailtextEditingController.text.contains("@")) {
      cMethod.displaySnackBar("Please write a valid email.", context);
    } else if (passwordtextEditingController.text.trim().length < 6) {
      cMethod.displaySnackBar(
          "Password must have at least 6 characters or more.", context);
    } else {
      registerNewUser();
    }
  }

  registerNewUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>
          LoadingDialog(messageText: "Register yourself here"),
    );
    final User? userFirebase = (await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
      email: emailtextEditingController.text.trim(),
      password: passwordtextEditingController.text.trim(),
    )
            .catchError((errorMsg) {
      cMethod.displaySnackBar(errorMsg.toString(), context);
    }))
        .user;
    if (!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef =
        FirebaseDatabase.instance.ref().child("users").child(userFirebase!.uid);
    Map userDataMap = {
      "name": userNametextEditingController.text.trim(),
      "email": emailtextEditingController.text.trim(),
      "phone": userPhoneEditingController.text.trim(),
      "id": userFirebase.uid,
      "blockeStatus": "no",
    };
    usersRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c) => const SignUpScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Image.asset("assets/images/logo.png"),
              const SizedBox(height: 20), // Added SizedBox for spacing
              const Text(
                "Create a User's Account",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    TextField(
                      controller: usertextEditingController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "User Name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: emailtextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "User Email",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: userPhoneEditingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "User Number",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 22,
                    ),
                    TextField(
                      controller: passwordtextEditingController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "User Password",
                        labelStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ElevatedButton(
                      onPressed: () {
                        checkIfNetworkIsAvailable();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.purple, // Fixed deprecated property
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 10),
                      ),
                      child: const Text("Sign Up"),
                    ),
                    const SizedBox(height: 12), // Added SizedBox for spacing
                    TextButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (c) => const LoginScreen()));
                      },
                      child: const Text(
                        "Already have an Account? Login Here",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
