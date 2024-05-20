import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class ActivityService {
  final String baseUrl = "http://127.0.0.1:3000";
  final Dio dio = Dio();
  var statusCode;
  var data;

  String? getToken() {
    final box = GetStorage();
    return box.read('token');
  }

  String? getId() {
    final box = GetStorage();
    return box.read('id');
  }

  Future<List<Activity>> getData() async {
    print('getData');
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = getToken();
        print(token);
        if (token != null) {
          options.headers['x-access-token'] = token;
        }
        return handler.next(options);
      },
    ));

    try {
      var res = await dio.get('$baseUrl/activity/1/10');
      final List<dynamic> responseData = res.data['activities'];
      print(res.data);
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      print("aqui aun funciona");
      return activities;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<int> joinActivity(String? aId) async {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = getToken();
        print(token);
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
      print('Error fetching data: $e');
      throw e;
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
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<List<Activity>> getUserActivities() async {
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
      final id = getId();
      Response res = await dio.get('$baseUrl/activities/$id');
      final List<dynamic> responseData = res.data['data'];
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      return activities;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<void> addActivity(Activity activity) async {
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
      var res = await dio.post('$baseUrl/activity', data: activity.toJson());
      statusCode = res.statusCode;
      print('Status code: $statusCode');
    } catch (e) {
      print('Error adding activity: $e');
      throw e;
    }
  }
}
