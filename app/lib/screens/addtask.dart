
import 'package:app/config/config.dart';
import 'package:app/screens/home.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AddTask extends StatefulWidget {
  final String? uid;
  const AddTask({super.key, required this.uid});

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addTask() async {
    if (_formKey.currentState!.validate()) {
      context.loaderOverlay.show();
      Map<String, dynamic> taskData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'uid': widget.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };
      try {
        await FirebaseFirestore.instance.collection('ToDo').add(taskData);
        context.loaderOverlay.hide();
        SnackBarMsg.showSuccess(context, "Task Added Successfully !", 1);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      } catch (e) {
        context.loaderOverlay.hide();
        SnackBarMsg.showError(context, "Failed to add task :$e", 1);
      }
    }
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    int maxLines = 1,
    int minLines = 1,
    String hintText = '',
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
            color: Config.themeMainColor,
            fontSize: 15 * (screenWidth / 360),
            fontWeight: FontWeight.bold),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a $labelText';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return LoaderOverlay(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Home(),
                        ),
                      );
                    },
                    child:
                        const Icon(Icons.arrow_back_ios, color: Colors.white)),
                const Text(
                  'Add Task',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox()
              ],
            ),
            backgroundColor: Config.themeMainColor,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                // form
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Text(
                        'To create a todo task ,please add title and description about your task',
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade500),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      _buildTextField(
                        labelText: 'Task Title',
                        controller: _titleController,
                        hintText: 'Add task title',
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      _buildTextField(
                        labelText: 'Task Description',
                        controller: _descriptionController,
                        maxLines: 8,
                        minLines: 4,
                        hintText: 'Describe your task',
                      ),
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      Center(
                        child: ElevatedButton(
                          onPressed: _addTask,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Config.themeMainColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Add Task'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
