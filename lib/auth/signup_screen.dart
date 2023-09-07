import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todo_app/auth/login_screen.dart';
import 'package:todo_app/posts/tasks_screen.dart';
import 'package:todo_app/widgets/round_button.dart';
import 'package:todo_app/widgets/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool loading = false;
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    firstNameController.dispose();
    confirmPasswordController.dispose();
  }

  void signUp() async {
    setState(() {
      loading = true;
    });

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString(),
      );

      if (userCredential != null) {
        final userId = userCredential.user!.uid;

        // Create an initial task for the new user
        final tasksCollection = FirebaseFirestore.instance.collection('tasks');
        await tasksCollection.add({
          'userId': userId,
          'title':
              'Welcome ${firstNameController.text.toString()} to the Notes App',
          'description': 'This is your first task!',
        });

        setState(() {
          loading = false;
        });

        Utils().toastMessage("Sign Up Successfully");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TasksScreen()),
        );
      }
    } catch (error) {
      debugPrint(error.toString());
      setState(() {
        loading = false;
      });
      Utils().toastMessage(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Sign Up Screen"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 200,
                    child: Image.asset('assets/signup.png'),
                  ),
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Field Required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email Required';
                      }
                      String pattern =
                          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                      RegExp regex = RegExp(pattern);
                      if (!(regex.hasMatch(value))) {
                        return 'Invalid Email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password Required';
                      }
                      String pattern =
                          r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)";
                      RegExp regex = RegExp(pattern);
                      if (!(regex.hasMatch(value))) {
                        return 'Use special characters and numbers';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    obscureText: true,
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0.0,
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Password Required';
                      }
                      String pattern =
                          r"(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*\W)";
                      RegExp regex = RegExp(pattern);
                      if (!(regex.hasMatch(value))) {
                        return 'Use special characters and numbers';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  RoundButton(
                    loading: loading,
                    title: 'Sign Up',
                    onTap: () {
                      if (_formKey.currentState!.validate()) {
                        signUp();
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        child: const Text("Log In"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
