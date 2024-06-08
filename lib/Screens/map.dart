import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ltlg;
import 'package:flutter/foundation.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Widgets/paramTextBox_sign_up.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/UserService.dart';
late UserService userService;
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
  Position? position;
  @override
  void initState() {
    super.initState();
    activityService = ActivityService();
    userService =UserService();
    getData();
  }

  void getData() async {
    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await userService.updateLocation(position);
      double distance = 10.0; // Distancia por defecto
      lista_activities = await activityService.getData(distance);
      markers.add(
        Marker(
          point: ltlg.LatLng(position!.latitude, position!.longitude),
          width: 60,
          height: 60,
          alignment: Alignment.centerLeft,
          child: const Icon(
            Icons.circle,
            size: 20,
            color: Pallete.salmonColor
          ),
        )
      );
      for(var actividad in lista_activities){
        markers.add(
        Marker(
          point: ltlg.LatLng(actividad.location!.latitude, actividad.location!.longitude),
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
            child: const Icon(
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
      return const Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: ltlg.LatLng(position!.latitude, position!.longitude),
              initialZoom: 12,
              interactionOptions: const InteractionOptions(flags: ~InteractiveFlag.doubleTapZoom),
            ),
            children: [
              openStreetMapTileLayer,
              MarkerLayer(
                markers: markers
              ),
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
