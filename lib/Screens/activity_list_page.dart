import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Screens/activity_detail.dart';
import 'package:spotfinder/Screens/new_activity.dart';
import 'package:get/get.dart';
import 'package:spotfinder/Services/ActivityService.dart';
import 'package:spotfinder/Widgets/activity_card.dart';
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
      isLoading = true; // Mostrar indicador de carga mientras se obtienen los datos
    });
    try {
      listaActivities = await activityService.getData(selectedDistance); // Filtrar por distancia
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

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Scaffold(
        appBar: AppBar(
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
                    items: <double>[5.0, 10.0, 20.0, 50.0, 100.0].map((double value) {
                      return DropdownMenuItem<double>(
                        value: value,
                        child: Text('Hasta $value km', style: const TextStyle(color: Colors.white)),
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
                        Get.to(() => ActivityDetail(listaActivities[index], onUpdate: getData));
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(listaActivities[index].name),
                            subtitle: Text(
                              'Position: ${listaActivities[index].location?.latitude ?? 'Unknown'}, ${listaActivities[index].location?.longitude ?? 'Unknown'}',
                            ),
                          ),
                          // Otros detalles de la actividad...
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
