import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:geolocator/geolocator.dart';

class NewActivityScreen extends StatefulWidget {
  @override
  final VoidCallback onUpdate;

  const NewActivityScreen({required this.onUpdate});

  _NewActivityScreenState createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController(); // Nuevo controlador para la ubicación
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

  Future<void> _selectLocation() async {
    Position? position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (position != null) {
      setState(() {
        _locationController.text = '${position.latitude},${position.longitude}';
      });
    } else {
      print('No se pudo obtener la ubicación actual.');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      print('Formulario válido. Enviando actividad...');
      String location = _locationController.text;

      print('Ubicación obtenida: $location');
      Activity newActivity = Activity(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _image?.path,
        date: _selectedDate,
        idUser: _userId,
        location: LatLng.fromJson(_parseLocation(location)), // Convertir la ubicación a LatLng
      );
      await ActivityService().addActivity(newActivity);
      widget.onUpdate();
      print('Actividad enviada correctamente.');
      Get.back();
    } else {
      print('Formulario inválido. No se puede enviar la actividad.');
    }
  }

  Map<String, dynamic> _parseLocation(String location) {
    List<String> parts = location.split(',');
    double latitude = double.parse(parts[0]);
    double longitude = double.parse(parts[1]);
    return {'latitude': latitude, 'longitude': longitude};
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
                          controller: _locationController,
                          decoration: InputDecoration(
                            labelText: 'Location',
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
                          onTap: _selectLocation,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a location';
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
              SignUpButton(onPressed: _submitForm, text: 'Post activity')
            ],
          ),
        ),
      ),
    );
  }
}
