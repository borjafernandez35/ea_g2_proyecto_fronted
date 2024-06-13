import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:spotfinder/Services/TokenService.dart';


class ActivityService {
  final String baseUrl = "http://127.0.0.1:3000";
  final Dio dio = DioSingleton.instance;
  var statusCode;
  var data;
  final TokenRefreshService tokenRefreshService = TokenRefreshService(); 

  ActivityService() {
    dio.interceptors.add(tokenRefreshService.dio.interceptors.first);
  }

  String? getToken() {
    final box = GetStorage();
    return box.read('token');
  }

  String? getId() {
    final box = GetStorage();
    return box.read('id');
  }

  Future<List<Activity>> getData(double selectedDistance, int page, int limit) async {
    print('getData');
    

    try {
      var res = await dio.get('$baseUrl/activity/$page/$limit');
      final List<dynamic> responseData = res.data['activities'];
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      return activities;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<int> joinActivity(String? aId) async {
    

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
   
    try {
      print (activity.toJson());
      var res = await dio.post('$baseUrl/activity', data: activity.toJson());
      statusCode = res.statusCode;
      print('Status code: $statusCode');
    } catch (e) {
      print('Error adding activity: $e');
      throw e;
    }
  }

  Future<void> editActivity(Activity activity, String? id) async {
   
    try {
      var res = await dio.put('$baseUrl/activity/$id', data: activity.toJson());
      statusCode = res.statusCode;
      print('Status code: $statusCode');
    } catch (e) {
      print('Error adding activity: $e');
      throw e;
    }
  }

  Future<void> deleteActivity(String? id) async {
  
    try {
      print("deleting activity");
      var res = await dio.put('$baseUrl/activity/delete/$id');
      statusCode = res.statusCode;
      print('Status code: $statusCode');
    } catch (e) {
      print('Error adding activity: $e');
      throw e;
    }
  }
}
