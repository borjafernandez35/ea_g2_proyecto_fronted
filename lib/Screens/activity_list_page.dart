import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/home_page.dart';
import 'package:spotfinder/Screens/new_activity.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Widgets/activity_card.dart';
import 'package:http/http.dart' as http;
import 'package:spotfinder/Resources/pallete.dart';

late ActivityService activityService;

class ActivityListPage extends StatefulWidget {
  const ActivityListPage({Key? key}) : super(key: key);

  @override
  _ActivityListPageState createState() => _ActivityListPageState();
}

class _ActivityListPageState extends State<ActivityListPage> {
  late List<Activity> listaActivities;
  bool isLoading = true;
  double selectedDistance = 5.0; // Distancia inicial seleccionada

  @override
  void initState() {
    super.initState();
    activityService = ActivityService();
    getData();
  }

  void getData() async {
    setState(() {
      isLoading =
          true; // Mostrar indicador de carga mientras se obtienen los datos
    });
    try {
      listaActivities = await activityService.getData(selectedDistance * 1000); // Filtrar por distancia
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

  void _onDistanceChanged(double? newDistance) {
    if (newDistance != null) {
      setState(() {
        selectedDistance = newDistance;
        getData();
      });
    }
  }

  Future<String?> _getAddressFromCoordinates(
      double latitude, double longitude) async {
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons
                  .arrow_back, // Puedes cambiar este icono por otro si lo deseas
              color:
                  Pallete.backgroundColor, // Ajusta el color a tu preferencia
            ),
            onPressed: () {
              Get.to(HomePage()); // Acción personalizada para el botón
            },
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your feed',
                style: TextStyle(
                  color: Pallete.backgroundColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: selectedDistance,
                    onChanged: _onDistanceChanged,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    items: <double>[5.0, 10.0, 20.0, 50.0, 100.0]
                        .map((double value) {
                      return DropdownMenuItem<double>(
                        value: value,
                        child: Text('Hasta $value km',
                            style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    color: Pallete.backgroundColor,
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(
                          '/activity/${listaActivities[index].id}',
                          arguments: {'onUpdate': getData},
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(listaActivities[index].name),
                            subtitle: listaActivities[index].location != null
                                ? FutureBuilder<String?>(
                                    future: _getAddressFromCoordinates(
                                        listaActivities[index]
                                            .location!
                                            .latitude,
                                        listaActivities[index]
                                            .location!
                                            .longitude),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                color: Colors.red, size: 17),
                                            SizedBox(width: 4),
                                            Text('Cargando dirección...'),
                                          ],
                                        );
                                      } else if (snapshot.hasError) {
                                        return const Row(
                                          children: [
                                            Icon(Icons.location_on,
                                                color: Colors.red, size: 17),
                                            SizedBox(width: 4),
                                            Text('Error al cargar dirección'),
                                          ],
                                        );
                                      } else {
                                        return Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                color: Colors.red, size: 17),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                snapshot.data ??
                                                    'Dirección no encontrada',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  )
                                : const Text('Ubicación no disponible'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                itemCount: listaActivities.length,
              ),
            ),
          ],
        ),
        floatingActionButton: Tooltip(
          message: 'Add new activity',
          child: FloatingActionButton(
            backgroundColor: Pallete.backgroundColor,
            child: const Icon(Icons.add),
            onPressed: () {
              Get.to(() => NewActivityScreen(onUpdate: getData));
            },
          ),
        ),
      );
    }
  }
}
