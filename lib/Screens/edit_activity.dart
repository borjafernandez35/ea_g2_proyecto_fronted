import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ltld;
import 'package:http/http.dart' as http;

import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/my_activities.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Models/ActivityModel.dart';

class EditActivity extends StatefulWidget {
  final VoidCallback onUpdate;
  final Activity activity;

  const EditActivity(this.activity, {required this.onUpdate});

  @override
  _EditActivityState createState() => _EditActivityState();
}

class _EditActivityState extends State<EditActivity> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  ActivityService activityService = ActivityService();

  String? _image;
  DateTime _selectedDate = DateTime.now();
  String _userId = '';
  double _latitude = 0;
  double _longitude = 0;
  bool _locationLoaded = false;
  bool _isEditing = false; 
  late TileLayer _tileLayer;

  @override
  void initState() {
    super.initState();
    _fetchUserId();
    _selectLocation();
    activityService = ActivityService();
    _setupMapTheme();

    // Inicializar los controladores con los datos de la actividad
    _nameController.text = widget.activity.name;
    _descriptionController.text = widget.activity.description;
    _latitude = widget.activity.location!.latitude;
    _longitude = widget.activity.location!.longitude;
    _image = widget.activity.imageUrl;
    _selectedDate = widget.activity.date;
  }

  Future<void> _fetchUserId() async {
    final userId = await UserService().getId();
    setState(() {
      _userId = userId!;
    });
  }

  void _setupMapTheme() async {
    final box = GetStorage();
    String? theme = box.read('theme');
    
    setState(() {
      if (theme == 'Dark') {
        _tileLayer = TileLayer(
          urlTemplate: 'https://tiles-eu.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        );
      } else {
        _tileLayer = TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'dev.fleaflet.flutter_map.example',
        );
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      await _uploadImage(bytes);
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<void> _uploadImage(Uint8List imageBytes) async {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/dgwbrwvux/image/upload');
    final String filename =
        'upload_${DateTime.now().millisecondsSinceEpoch}.png';
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'typvcah6'
      ..files.add(http.MultipartFile.fromBytes('file', imageBytes,
          filename: filename));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonData = jsonDecode(responseData.body);
        final imageUrl = jsonData['secure_url'];

        setState(() {
          _image = imageUrl;
        });

        return imageUrl;
      } else {
        print(
            'Error al subir la imagen a Cloudinary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      return null;
    }
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
        final utcDate = picked.toUtc();
        _selectedDate = utcDate;
      });
    }
  }

  Future<void> _selectLocation() async {
    try {
      setState(() {
        _latitude = widget.activity.location!.latitude;
        _longitude = widget.activity.location!.longitude;
        _locationController.text = '$_latitude, $_longitude';
        _locationLoaded = true;
        _mapController.move(ltld.LatLng(_latitude, _longitude), 12);
      });
    } catch (e) {
      setState(() {
        _locationLoaded = true;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      Activity newActivity = Activity(
        name: _nameController.text,
        description: _descriptionController.text,
        imageUrl: _image,
        date: _selectedDate,
        idUser: _userId,
        location: LatLng(latitude: _latitude, longitude: _longitude),
      );

      await activityService.editActivity(newActivity, widget.activity.id);
      widget.onUpdate();
      print('Actividad editada correctamente.');
      Get.back();
    } else {
      print('Formulario inválido. No se puede enviar la actividad.');
    }
  }

  Future<List<double>?> getCoordinatesFromAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url =
        'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          final firstResult = data.first;
          final double lat = double.parse(firstResult['lat']);
          final double lon = double.parse(firstResult['lon']);
          setState(() {
            _latitude = lat;
            _longitude = lon;
            _locationController.text = '$lat,$lon';
            _mapController.move(ltld.LatLng(_latitude, _longitude), 12);
          });
          return [lat, lon];
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener las coordenadas desde la dirección: $e');
      return null;
    }
  }

  Future<String?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          final road = address['road'] ?? '';
          final houseNumber = address['house_number'] ?? '';
          final postcode = address['postcode'] ?? '';
          final city =
              address['city'] ?? address['town'] ?? address['village'] ?? '';
          final country = address['country'] ?? '';

          List<String> parts = [];

          if (road.isNotEmpty) parts.add(road);
          if (houseNumber.isNotEmpty) parts.add(houseNumber);
          if (postcode.isNotEmpty) parts.add(postcode);
          if (city.isNotEmpty) parts.add(city);
          if (country.isNotEmpty) parts.add(country);

          String formattedAddress = parts.join(', ');
          setState(() {
            _searchController.text = formattedAddress;
          });
          return formattedAddress;
        }
      }
      return null;
    } catch (e) {
      print('Error al obtener la dirección desde las coordenadas: $e');
      return null;
    }
  }

  Future<void> _deleteActivity() async {
    await activityService.deleteActivity(widget.activity.id);
    widget.onUpdate();
    print('Actividad eliminada correctamente.');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Activity',
          style: TextStyle(
            color: Pallete.backgroundColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Pallete.backgroundColor,
          ),
          onPressed: () {
            Get.to(() => MyActivities());
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isEditing = true; // Cambiar al modo de edición
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _image == null
                          ? Container(
                              height: 100,
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
                          : Image.network(
                              _image!,
                              height: 100,
                            ),
                    ],
                  ),
                ),
              ),
              _buildTextField(
                controller: _nameController,
                labelText: 'Activity Name',
                readOnly: !_isEditing, // Controlar solo lectura según el modo de edición
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the activity name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 5,
                readOnly: !_isEditing, // Controlar solo lectura según el modo de edición
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _locationController,
                labelText: 'Location',
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: TextEditingController(
                  text:
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                labelText: 'Date',
                readOnly: true,
                onTap: () {
                  if (_isEditing) {
                    _selectDate(context); // Permitir seleccionar la fecha solo en modo de edición
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _locationLoaded
                  ? Container(
                      height: 300,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter:
                                  ltld.LatLng(_latitude, _longitude),
                              initialZoom: 12,
                              interactionOptions:
                                  const InteractionOptions(
                                      flags: ~InteractiveFlag
                                          .doubleTapZoom),
                              onTap: (tapPosition, point) {
                                if (_isEditing) {
                                  setState(() {
                                    _latitude = point.latitude;
                                    _longitude = point.longitude;
                                    _locationController.text =
                                        '$_latitude,$_longitude';
                                  });
                                  getAddressFromCoordinates(
                                      _latitude, _longitude);
                                }
                              },
                            ),
                            children: [
                              _tileLayer,
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    width: 80.0,
                                    height: 80.0,
                                    point: ltld.LatLng(
                                        _latitude, _longitude),
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
                          Positioned(
                            top: 20,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _searchController,
                                      decoration:
                                          const InputDecoration(
                                        hintText: 'Search...',
                                        border: InputBorder.none,
                                      ),
                                      style: const TextStyle(
                                          color: Colors.black),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      if (_isEditing) {
                                        getCoordinatesFromAddress(
                                            _searchController.text);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              if (_isEditing) // Mostrar botones solo en modo de edición
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Edit'),
                  ),
                ),
              if (_isEditing) // Mostrar botones solo en modo de edición
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _deleteActivity,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Background color
                    ),
                    child: Text('Delete'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool readOnly = false,
    int maxLines = 1,
    required String? Function(String?)? validator,
    Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          fillColor: Colors.black.withOpacity(0.7),
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
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
            borderSide: BorderSide(color: Pallete.salmonColor),
          ),
          floatingLabelStyle: TextStyle(
            color: Pallete.salmonColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: const TextStyle(color: Colors.white),
        validator: validator,
        onTap: onTap,
      ),
    );
  }
}

