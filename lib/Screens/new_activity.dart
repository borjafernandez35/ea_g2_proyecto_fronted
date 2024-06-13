import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final MapController _mapController = MapController();

  String? _image;
  Uint8List? _imageBytes;
  DateTime _selectedDate = DateTime.now();
  String _userId = '';
  double _latitude = 41.27552212202214;
  double _longitude = 1.9863014220734023;
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
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      final bytes = await pickedImage.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _image = 'data:image/png;base64,' + base64Encode(bytes);
      });
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Future<String?> _uploadImage() async {
    if (_image == null) {
      print('No hay imagen para subir.');
      return null;
    }

    final url = Uri.parse('https://api.cloudinary.com/v1_1/dgwbrwvux/image/upload');
    final String filename = 'upload_${DateTime.now().millisecondsSinceEpoch}.png'; 
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'typvcah6'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        _imageBytes!,
        filename: filename
      ));

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonData = jsonDecode(responseData.body);
        final imageUrl = jsonData['secure_url'];

        return imageUrl;
      } else {
        print('Error al subir la imagen a Cloudinary: ${response.statusCode}');
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationController.text = '$_latitude, $_longitude';
        _locationLoaded = true;
        _mapController.move(ltld.LatLng(_latitude, _longitude), 12);
      });
    } catch (e) {
      print('No se pudo obtener la ubicación actual.');
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
        imageUrl: await _uploadImage(),
        date: _selectedDate,
        idUser: _userId,
        location: LatLng(latitude: _latitude, longitude: _longitude),
      );
      await ActivityService().addActivity(newActivity);
      widget.onUpdate();
      Get.back();
    } else {
      print('Formulario inválido. No se puede enviar la actividad.');
    }
  }

  Future<List<double>?> getCoordinatesFromAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = 'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json';

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

  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          final road = address['road'] ?? '';
          final houseNumber = address['house_number'] ?? '';
          final postcode = address['postcode'] ?? '';
          final city = address['city'] ?? address['town'] ?? address['village'] ?? '';
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white),
                        ),
                        child: _image == null
                            ? const Center(
                                child: Text(
                                  'Tap to select an image\nAccepted formats: JPG, PNG',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : Image.memory(
                                base64Decode(_image!.split(',').last),
                                height: 100,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 12.0),
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
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 12.0),
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
              _locationLoaded
                  ? Container(
                      height: 300,
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
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
                                getAddressFromCoordinates(
                                    _latitude, _longitude);
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
                                      decoration: const InputDecoration(
                                        hintText: 'Search...',
                                        border: InputBorder.none,
                                      ),
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.search,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      getCoordinatesFromAddress(
                                          _searchController.text);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(child: CircularProgressIndicator()),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.center,
                  child: SignUpButton(
                    onPressed: _submitForm,
                    text: 'Post activity',
                  ),
                ),
              ),
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
