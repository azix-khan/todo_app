import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/auth/login_screen.dart';
import 'package:todo_app/posts/add_post_screen.dart';
import 'package:todo_app/widgets/utils/utils.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('Post');
  final editingController = TextEditingController();
  final searchFilter = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Screen'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () {
                auth.signOut().then((value) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                }).onError((error, stackTrace) {
                  Utils().toastMessage(error.toString());
                });
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddPostScreen()));
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextFormField(
                controller: searchFilter,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String value) {
                  setState(() {});
                },
              ),
            ),
            Expanded(
                child: FirebaseAnimatedList(
                    query: ref,
                    defaultChild: const Center(
                      child: Text('Loading...'),
                    ),
                    itemBuilder: (context, snapshot, animation, index) {
                      final title = snapshot.child('title').value.toString();
                      if (searchFilter.text.isEmpty) {
                        return ListTile(
                          title: InkWell(
                            onTap: () {
                              showCustomBottomSheet(context, title);
                            },
                            child: Text(
                              snapshot.child('title').value.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // subtitle: Text(snapshot.child('id').value.toString()),
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
                                                snapshot
                                                    .child('id')
                                                    .value
                                                    .toString());
                                          },
                                          title: const Text('Edit'),
                                          trailing: const Icon(Icons.edit),
                                        )),
                                    PopupMenuItem(
                                        value: 1,
                                        child: ListTile(
                                          onTap: () {
                                            Navigator.pop(context);
                                            showMyDialogForDelete(snapshot
                                                .child('id')
                                                .value
                                                .toString());
                                          },
                                          title: const Text('Delete'),
                                          trailing: const Icon(Icons.delete),
                                        )),
                                  ]),
                        );
                      } else if (title.toLowerCase().contains(
                          searchFilter.text.toLowerCase().toString())) {
                        return ListTile(
                          title: Text(snapshot.child('title').value.toString()),
                          subtitle: Text(snapshot.child('id').value.toString()),
                        );
                      } else {
                        return Container();
                      }
                    })),
          ],
        ),
      ),
    );
  }

  Future<void> showMyDialog(String title, String id) async {
    editingController.text = title;
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
                    border: OutlineInputBorder(), hintText: 'Edit here'),
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
                  Navigator.pop(context);
                  ref.child(id).update({
                    'title': editingController.text.toString()
                  }).then((value) {
                    Utils().toastMessage('Post Updated');
                  }).onError((error, stackTrace) {
                    Utils().toastMessage(error.toString());
                  });
                },
                child: const Text('Update'),
              ),
            ],
          );
        });
  }

  Future<void> showMyDialogForDelete(String id) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete'),
            content: const Text('Do you really want to delete this post?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.child(id).remove().then((value) {
                    Utils().toastMessage('Post Deleted');
                  }).onError((error, stackTrace) {
                    Utils().toastMessage(error.toString());
                  });
                },
                child: const Text('Delete'),
              ),
            ],
          );
        });
  }

  void showCustomBottomSheet(BuildContext context, String title) {
    double containerHeight = 500.0; // Adjust the height as needed

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
              const Text(
                '-',
                style: TextStyle(fontSize: 20.0),
              ),
              const Divider(
                thickness: 2.0,
              ),
              const SizedBox(height: 16.0),
              Text(title),
              // const SizedBox(height: 16.0),
              // ElevatedButton(
              //   onPressed: () {
              //     Navigator.pop(context);
              //   },
              //   child: const Text('Close'),
              // ),
            ],
          ),
        );
      },
    );
  }
}
