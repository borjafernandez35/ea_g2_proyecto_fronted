import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Widgets/button_red.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';

class EditActivity extends StatefulWidget {
  @override
  final VoidCallback onUpdate;
  final String? id;

  const EditActivity({required this.onUpdate, required this.id});

  _EditActivity createState() => _EditActivity();
}

class _EditActivity extends State<EditActivity> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  DateTime _selectedDate = DateTime.now();
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    final userId = await UserService().getId();
    setState(() {
      _userId = userId!;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), 
      firstDate: DateTime.now(), 
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      print('Formulario válido. Enviando actividad...');
      Activity newActivity = Activity(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _image?.path,
        date: _selectedDate,
        idUser: _userId,
      );
      await ActivityService().editActivity(newActivity, widget.id);
      widget.onUpdate();
      print('Actividad enviada correctamente.');
      Get.back();
    } else {
      print('Formulario inválido. No se puede enviar la actividad.');
    }
  }

  Future<void> _deleteActivity() async {
    await ActivityService().deleteActivity(widget.id);
    widget.onUpdate();
    print('Actividad enviada correctamente.');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          _image == null
                              ? Container(
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Tap to select an image\nAccepted formats: JPG, PNG',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                              : Image.file(_image!, height: 150),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Activity Name',
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            fillColor: Colors.black.withOpacity(0.7),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Pallete.salmonColor),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Pallete.salmonColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the activity name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            fillColor: Colors.black.withOpacity(0.7),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Pallete.salmonColor),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Pallete.salmonColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24), 
                        TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            fillColor: Colors.black.withOpacity(0.7),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Pallete.salmonColor),
                            ),
                            floatingLabelStyle: const TextStyle(
                              color: Pallete.salmonColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onTap: () => _selectDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SignUpButton(onPressed: _submitForm, text: 'Edit'),
              const SizedBox(height: 10,),
              RedButton(onPressed: _deleteActivity, text: 'Delete'),
            ],
          ),
        ),
      ),
    );
  }
}
