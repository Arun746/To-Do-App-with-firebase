// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:app/config/config.dart';
import 'package:app/screens/home.dart';
import 'package:app/widgets/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

class EditTask extends StatefulWidget {
  final String doccId;
  final String initialTitle;
  final String initialDescription;

  const EditTask({
    super.key,
    required this.doccId,
    required this.initialTitle,
    required this.initialDescription,
  });

  @override
  State<EditTask> createState() => _State();
}

class _State extends State<EditTask> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle;
    _descriptionController.text = widget.initialDescription;
  }

  Future<void> _updateTask() async {
    if (_formKey.currentState!.validate()) {
      context.loaderOverlay.show();
      try {
        await FirebaseFirestore.instance
            .collection('ToDo')
            .doc(widget.doccId)
            .update({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        SnackBarMsg.showSuccess(context, "Task Updated Successfully", 1);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(),
          ),
        );
      } catch (e) {
        SnackBarMsg.showError(context, "Failedd to update task :$e", 1);
      } finally {
        context.loaderOverlay.hide();
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
          borderSide: BorderSide(color: Colors.black),
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
                        builder: (context) => Home(),
                      ),
                    );
                  },
                  child: Icon(Icons.arrow_back_ios, color: Colors.white)),
              Text(
                'Edit Task',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox()
            ],
          ),
          backgroundColor: Config.themeMainColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Text(
                      'To edit a todo task ,please edit the  title and description about your task',
                      style:
                          TextStyle(fontSize: 18, color: Colors.grey.shade500),
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
                        onPressed: _updateTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Config.themeMainColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
