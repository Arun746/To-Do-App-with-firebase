// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, unused_field
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
  User? user;
  String? uid;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();
  DateTime? lastBackPressTime;
  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    uid = user!.uid.toString();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
    return WillPopScope(
      onWillPop: () async {
        DateTime now = DateTime.now();
        if (lastBackPressTime == null ||
            now.difference(lastBackPressTime!) > Duration(seconds: 3)) {
          lastBackPressTime = now;
          SnackBarMsg.showError(context, "Press again to exit", 1);
          return Future.value(false); //
        }
        //exit app
        return Future.value(true);
      },
      child: Scaffold(
        //appbar
        appBar: AppBar(
          backgroundColor: Config.themeMainColor,
          scrolledUnderElevation: 0.0,
          title: Center(
            child: Text(
              'My TODOs',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.07,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          //actions
          actions: <Widget>[
            PopupMenuButton(
              icon: const Icon(
                Icons.more_vert_outlined,
                color: Colors.white,
              ),
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    onTap: () {
                      logoutdialog(context, screenWidth).show();
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
        //body
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //search todos with title
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 224, 239, 240),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
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
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    searchQuery = "";
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  //heading with add todo
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.02, bottom: screenHeight * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'All TODOs',
                          style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.w600,
                              color: Config.themeMainColor),
                        ),
                        //addtodo
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 224, 239, 240),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTask(uid: uid),
                                  ),
                                );
                              },
                              child: Row(
                                children: [Icon(Icons.add), Text("Add New")],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  //tasks to do
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('ToDo')
                          .where('uid', isEqualTo: uid)
                          .orderBy('createdAt', descending: true)
                          .where('title', isGreaterThanOrEqualTo: searchQuery)
                          .where('title',
                              isLessThanOrEqualTo: searchQuery + '\uf8ff')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        //if data is unavailable
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No tasks available  !!   Please  click on add button below and add your to do tasks .',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: screenWidth * 0.05,
                              ),
                            ),
                          );
                        }
                        //if data is available
                        final tasks = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            var task = tasks[index];
                            String doccId = task.id;
                            return Card(
                              color: Colors.grey.shade100,
                              shadowColor: Colors.black.withOpacity(0.9),
                              child: ListTile(
                                title: Text(task['title'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                subtitle: Text(task['description']),
                                trailing: PopupMenuButton(
                                  shadowColor: Config.themeMainColor,
                                  color:
                                      const Color.fromARGB(255, 240, 245, 244),
                                  icon: const Icon(Icons.more_vert_outlined),
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      //edit todo
                                      PopupMenuItem<String>(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditTask(
                                                doccId: doccId,
                                                initialTitle: task['title'],
                                                initialDescription:
                                                    task['description'],
                                              ),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.edit,
                                              color: Colors.blueAccent,
                                            ),
                                            SizedBox(width: screenWidth * 0.04),
                                            const Text(
                                              'Edit',
                                              style: TextStyle(
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //delete todo
                                      PopupMenuItem<String>(
                                        onTap: () {
                                          delete(context, doccId);
                                        },
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: screenWidth * 0.04),
                                            const Text(
                                              'Delete',
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
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
          ],
        ),
      ),
    );
  }

//logout dialog
  AwesomeDialog logoutdialog(BuildContext context, double screenWidth) {
    return AwesomeDialog(
      dialogBackgroundColor: Colors.white,
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.topSlide,
      title: "Ohh!",
      desc: 'Are you sure you want to logout?',
      descTextStyle: TextStyle(
          fontSize: 16 * (screenWidth / 360), color: Colors.grey[700]),
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
    );
  }

//delete method
  Future<dynamic> delete(BuildContext context, String doccId) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Task'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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

                  SnackBarMsg.showSuccess(
                      context, "Task Deleted Successfully", 1);
                } catch (e) {
                  SnackBarMsg.showError(context, "Failed :$e", 2);
                }
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
