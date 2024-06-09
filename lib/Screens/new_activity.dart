import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ltld;
import 'package:geocoding/geocoding.dart';


class NewActivityScreen extends StatefulWidget {
  final VoidCallback onUpdate;

  const NewActivityScreen({required this.onUpdate});

  _NewActivityScreenState createState() => _NewActivityScreenState();
}

class _NewActivityScreenState extends State<NewActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  File? _image;
  DateTime _selectedDate = DateTime.now();
  String _userId = '';
  double _latitude = 0;
  double _longitude = 0;
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _selectLocation();
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
    Position? position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position != null) {
      setState(() {
        _locationController.text = '${position.latitude},${position.longitude}';
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationLoaded = true;
      });
    } else {
      print('No se pudo obtener la ubicación actual.');
    }
  }

  Future<void> _submitForm() async {
    print("djkf");
    Activity newActivity = Activity(
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: _image?.path,
      date: _selectedDate,
      idUser: _userId,
      location: LatLng(latitude: _latitude, longitude: _longitude),
    );
    print(newActivity.location);
    if (_formKey.currentState!.validate()) {
      print('Formulario válido. Enviando actividad...');
      print('Ubicación obtenida: $_latitude, $_longitude');
      Activity newActivity = Activity(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _image?.path,
        date: _selectedDate,
        idUser: _userId,
        location: LatLng(latitude: _latitude, longitude: _longitude),
      );
      await ActivityService().addActivity(newActivity);
      widget.onUpdate();
      print('Actividad enviada correctamente.');
      Get.back();
    } else {
      print('Formulario inválido. No se puede enviar la actividad.');
    }
  }

  Future<void> _searchLocation(String address) async {
  try {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      Location location = locations.first;
      print('Coordenadas encontradas: ${location.latitude}, ${location.longitude}');
    } else {
      print('No se encontraron coordenadas para la dirección: $address');
    }
  } catch (e) {
    print('Error al obtener las coordenadas: $e');
  }
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 1,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
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
                    Flexible(
                      fit: FlexFit.loose,
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Pallete.salmonColor),
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Pallete.salmonColor),
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
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Pallete.salmonColor),
                              ),
                              floatingLabelStyle: const TextStyle(
                                color: Pallete.salmonColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
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
                              text:
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                            decoration: InputDecoration(
                              labelText: 'Date',
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              fillColor: Colors.black.withOpacity(0.7),
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Pallete.salmonColor),
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
              ),
              _locationLoaded
                  ? Stack(
                      children: [
                        Container(
                          height: 300,
                          width: 300,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: ltld.LatLng(_latitude, _longitude),
                              initialZoom: 12,
                              interactionOptions: const InteractionOptions(
                                  flags: ~InteractiveFlag.doubleTapZoom),
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _latitude = point.latitude;
                                  _longitude = point.longitude;
                                  _locationController.text =
                                      '$_latitude,$_longitude';
                                });
                              },
                            ),
                            children: [
                              openStreetMapTileLayer,
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: ltld.LatLng(_latitude, _longitude),
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 50.0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 20,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search...',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    _searchLocation(_searchController.text);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
              Align(
                  alignment: Alignment.center,
                  child: SignUpButton(
                      onPressed: _submitForm, text: 'Post activity')),
            ],
          ),
        ),
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
