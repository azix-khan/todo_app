import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/widgets/round_button.dart';
import 'package:todo_app/widgets/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final postController = TextEditingController();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            TextFormField(
              maxLines: 4,
              controller: postController,
              decoration: const InputDecoration(
                labelText: 'Note something down',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            RoundButton(
              loading: loading,
              title: 'Add Task',
              onTap: () {
                setState(() {
                  loading = true;
                });

                final tasksCollection =
                    FirebaseFirestore.instance.collection('tasks');

                // Create a new task document in Firestore with the user's ID
                tasksCollection.add({
                  'userId': user?.uid,
                  'title': postController.text.toString(),
                }).then((_) {
                  postController.text = '';
                  Utils().toastMessage('Task Added');
                  setState(() {
                    loading = false;
                  });
                }).catchError((error) {
                  Utils().toastMessage(error.toString());
                  setState(() {
                    loading = false;
                  });
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
