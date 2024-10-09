// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:app/config/config.dart';
import 'package:app/screens/addtask.dart';
import 'package:app/screens/edittask.dart';
import 'package:app/screens/login.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      SnackBarMsg.showSuccess(context, "Logged Out Successfully", 2);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      SnackBarMsg.showError(context, "$e", 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Config.themeMainColor,
        scrolledUnderElevation: 0.0,
        title: const Center(
          child: Text(
            'TO DOs',
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_outlined),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  onTap: () {
                    AwesomeDialog(
                      dialogBackgroundColor: Colors.white,
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.topSlide,
                      title: "Ohh!",
                      desc: 'Are you sure you want to logout?',
                      descTextStyle: TextStyle(
                          fontSize: 16 * (screenWidth / 360),
                          color: Colors.grey[700]),
                      btnCancelText: 'No',
                      btnCancelOnPress: () {},
                      btnOkText: 'Yes',
                      btnOkOnPress: () {
                        _logout(context);
                      },
                      btnOkColor: Config.themeMainColor,
                      btnCancelColor: Colors.grey.shade700,
                      customHeader: Icon(Icons.question_mark,
                          size: screenWidth * 0.15, color: Colors.red),
                    ).show();
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.logout),
                      SizedBox(width: screenWidth * 0.04),
                      const Text('Logout'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //search
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 224, 239, 240),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TextField(
                    onChanged: (value) => {},
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search ToDos here',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                //hd
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.02),
                  child: Text(
                    'All TODOs',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Config.themeMainColor),
                  ),
                ),
                //tasks
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('ToDo')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No tasks available'));
                      }

                      // Data is available, build ListView
                      final tasks = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          var task = tasks[index];
                          String doccId = task.id;
                          return Card(
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: ListTile(
                              title: Text(task['title'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(task['description']),
                              trailing: IconButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTask(
                                        doccId: doccId, // Pass the document ID
                                        initialTitle: task[
                                            'title'], // Pass the current title
                                        initialDescription: task[
                                            'description'], // Pass the current description
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.more_vert,
                                ),
                              ),
                              onTap: () {
                                // Show a confirmation dialog before deletion
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Delete Task'),
                                      content: Text(
                                          'Are you sure you want to delete this task?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              await FirebaseFirestore.instance
                                                  .collection('ToDo')
                                                  .doc(doccId)
                                                  .delete();
                                              Navigator.pop(context);
                                              SnackBarMsg.showSuccess(
                                                  context,
                                                  "Task Deleted Successfully",
                                                  1);
                                            } catch (e) {
                                              SnackBarMsg.showError(
                                                  context, "Failed :$e", 2);
                                            }
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: screenHeight * 0.03,
            right: screenWidth * 0.07,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTask(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(18, 55),
                backgroundColor: Config.themeMainColor,
                elevation: 10,
              ),
              child: Icon(
                Icons.add,
                size: screenWidth * 0.05,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
