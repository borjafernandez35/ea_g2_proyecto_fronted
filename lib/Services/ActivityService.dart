import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:dio/dio.dart'; // Usa un prefijo 'Dio' para importar la clase Response desde Dio
import 'package:get_storage/get_storage.dart';


class ActivityService {
  final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend
  final Dio dio = Dio(); // Usa el prefijo 'Dio' para referenciar la clase Dio
  var statusCode;
  var data;

  String? getToken(){
    final box = GetStorage();
    return box.read('token');
  }
  String? getId() {
    final box = GetStorage();
    return box.read('id');
  }

  Future<List<Activity>> getData() async {
  print('getData');
    // Interceptor para agregar el token a la cabecera 'x-access-token'
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Obtener el token guardado
        final token = getToken();

        print(token);
        
        // Si el token está disponible, agregarlo a la cabecera 'x-access-token'
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        return handler.next(options);
      },
    ));
    
    try {
      var res = await dio.get('$baseUrl/activity/1/10');
      final List<dynamic> responseData = res.data['activities']; // Obtener los datos de la respuesta
      print(res.data);
      // Convertir los datos en una lista de objetos Place
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      print("aqui aun funciona");
      
      return activities; // Devolver la lista de actividadess
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

  Future<int> joinActivity(String? aId) async {
    // Interceptor para agregar el token a la cabecera 'x-access-token'
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Obtener el token guardado
        final token = getToken();

        print(token);
        
        // Si el token está disponible, agregarlo a la cabecera 'x-access-token'
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        return handler.next(options);
      },
    ));
    
    try {
      final id = getId();
      var res = await dio.put('$baseUrl/activity/$id/$aId');
      
      data = res.data.toString();
      print('Data: $data');

      statusCode = res.statusCode;
      print('Status code: $statusCode');

      return statusCode;
    
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }
  Future<Activity> getActivity(String id) async {

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = getToken();

        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        return handler.next(options);
      },
    ));

    try {
      Response res = await dio.get('$baseUrl/activity/$id');
      Activity activity = Activity.fromJson(res.data['data']);
      return activity;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }
}