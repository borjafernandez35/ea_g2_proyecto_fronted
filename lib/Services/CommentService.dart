import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Models/CommentModel.dart';

class CommentService {
  final String baseUrl = "http://127.0.0.1:3000"; // URL de tu backend
  final Dio dio = Dio(); // Usa el prefijo 'Dio' para referenciar la clase Dio
  var statusCode;
  var data;

  String? getToken(){
    final box = GetStorage();
    return box.read('token');
  }

 Future<void> deleteComment(String id) async {

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
      Response res = await dio.delete('$baseUrl/comment/$id');
      return;
    } catch (e) {
      // Manejar cualquier error que pueda ocurrir durante la solicitud
      print('Error fetching data: $e');
      throw e; // Relanzar el error para que el llamador pueda manejarlo
    }
  }

Future<int> updateComment(Comment comment) async {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Obtener el token guardado
        final token = getToken();

        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        return handler.next(options);
      },
    ));

    Response response =await dio.put('$baseUrl/comment/${comment.id}', data: comment.toJson());

    data = response.data.toString();
    statusCode = response.statusCode;

    if (statusCode == 201) {
      // Si el usuario se crea correctamente, retornamos el código 201
      return 201;
    } else if (statusCode == 400) {
      // Si hay campos faltantes, retornamos el código 400

      return 400;
    } else if (statusCode == 500) {
      // Si hay un error interno del servidor, retornamos el código 500

      return 500;
    } else {
      // Otro caso no manejado

      return -1;
    }
  }

}