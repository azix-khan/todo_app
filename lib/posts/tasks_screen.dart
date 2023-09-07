import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/auth/login_screen.dart';
import 'package:todo_app/posts/add_task_screen.dart';
import 'package:todo_app/widgets/utils/utils.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final searchFilter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final tasksCollection = FirebaseFirestore.instance.collection('tasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes Here'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              auth.signOut().then((value) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }).onError((error, stackTrace) {
                Utils().toastMessage(error.toString());
              });
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: searchFilter,
                decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0.0,
                    horizontal: 18.0,
                  ),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: tasksCollection
                    .where('userId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text('Loading...'),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No tasks found.'),
                    );
                  }
                  final tasks = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final title = tasks[index]['title'].toString();
                      if (searchFilter.text.isEmpty ||
                          title.toLowerCase().contains(
                                searchFilter.text.toLowerCase(),
                              )) {
                        return Card(
                          elevation: 4,
                          color: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 6.0,
                              horizontal: 0.0,
                            ),
                            title: InkWell(
                              onTap: () {
                                showCustomBottomSheet(context, title);
                              },
                              child: Card(
                                elevation: 4,
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    title,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            trailing: PopupMenuButton(
                              icon: const Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      showMyDialog(
                                        title,
                                        tasks[index].id,
                                      );
                                    },
                                    title: const Text('Edit'),
                                    trailing: const Icon(Icons.edit),
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    onTap: () {
                                      Navigator.pop(context);
                                      showMyDialogForDelete(
                                        tasks[index].id,
                                      );
                                    },
                                    title: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    trailing: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showMyDialog(String title, String id) async {
    final editingController = TextEditingController(text: title);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update'),
          content: Container(
            child: TextField(
              maxLines: 6,
              controller: editingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Edit here',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tasksCollection =
                    FirebaseFirestore.instance.collection('tasks');
                tasksCollection.doc(id).update({
                  'title': editingController.text.toString(),
                }).then((value) {
                  Utils().toastMessage('Task Updated');
                  Navigator.pop(context);
                }).catchError((error) {
                  Utils().toastMessage(error.toString());
                });
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showMyDialogForDelete(String id) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
          content: const Text('Do you really want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final tasksCollection =
                    FirebaseFirestore.instance.collection('tasks');
                tasksCollection.doc(id).delete().then((value) {
                  Utils().toastMessage('Task Deleted');
                  Navigator.pop(context);
                }).catchError((error) {
                  Utils().toastMessage(error.toString());
                });
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void showCustomBottomSheet(BuildContext context, String title) {
    double containerHeight = 500.0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          height: containerHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Divider(
                thickness: 5.5,
                indent: 130,
                endIndent: 130,
                color: Colors.black,
              ),
              const Divider(
                thickness: 2.0,
                color: Colors.teal,
              ),
              Container(
                height: 340,
                child: SingleChildScrollView(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
