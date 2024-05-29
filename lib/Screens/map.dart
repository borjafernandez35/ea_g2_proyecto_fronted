import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';
import 'package:line_icons/line_icon.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/login_screen.dart';
import 'package:spotfinder/Utils/phone_utils.dart';
import 'package:spotfinder/Widgets/button_sign_up.dart';
import 'package:spotfinder/Widgets/paramTextBox_sign_up.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:get/get.dart';

late ActivityService activityService;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MapScreen createState() => _MapScreen();
}

class _MapScreen extends State<MapScreen> {
  final MapController mapController = Get.put(MapController());
  late List<Activity> lista_activities;
  late List<Marker> markers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    activityService = ActivityService();
    getData();
  }

  void getData() async {
    try {
      lista_activities = await activityService.getData();
      for(var actividad in lista_activities){
        markers.add(
        Marker(
          point: LatLng(actividad.latitude, actividad.longitude),
            width: 60,
            height: 60,
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SingleChildScrollView(
                        child: Card(
                          color: Pallete.primaryColor,
                          surfaceTintColor: Pallete.accentColor,
                          elevation: 5,
                          margin: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              // Left side: Image
                              Container(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                  'https://via.placeholder.com/100', // Replace with your image URL
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Right side: Title, Description, and Value
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        actividad.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Description: ${actividad.description}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'rate: ${actividad.rate.toString()} ⭐',
                                        style: const TextStyle(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(
                Icons.location_pin,
                size: 60,
                color: Pallete.salmonColor
              ),
            ),
        ),
      );
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      Get.snackbar(
        'Error',
        'No se han podido obtener los datos.',
        snackPosition: SnackPosition.BOTTOM,
      );
      if (kDebugMode) {
        print('Error al comunicarse con el backend: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(41.3874, 2.1686),
              initialZoom: 12,
              interactionOptions: InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
            ),
            children: [
              openStreetMapTileLayer,
              MarkerLayer(markers: markers),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ParamTextBox(
                      controller: mapController.searchBarController,
                      text: 'Scaperoom...',
                    ),
                    IconButton(
                      icon: const Icon(
                        size: 40,
                        color: Pallete.backgroundColor,
                        LineIcons.searchLocation
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],

    );
    }
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
);

class MapController extends GetxController {
  final TextEditingController searchBarController = TextEditingController();
}

