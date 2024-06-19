import 'package:spotfinder/Models/ActivityModel.dart';
import 'package:spotfinder/Models/UserModel.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:spotfinder/Services/TokenService.dart';

class UserService {
  final String baseUrl = "http://127.0.0.1:3000";
  final Dio dio = DioSingleton.instance;
  var statusCode;
  var data;
  final TokenRefreshService tokenRefreshService = TokenRefreshService(); 

  UserService(){
    dio.interceptors.add(tokenRefreshService.dio.interceptors.first);
  }

  void saveToken(String token, String refreshToken) {
    final box = GetStorage();
    box.write('token', token);
    box.write('refresh_token', refreshToken);
  }

  String? getToken() {
    final box = GetStorage();
    return box.read('token');
  }

  void saveId(String id) {
    final box = GetStorage();
    box.write('id', id);
  }

  String? getId() {
    final box = GetStorage();
    return box.read('id');
  }

  void logout() {
    final box = GetStorage();
    box.remove('token');
    box.remove('refresh_token');
    box.remove('id');
  }

  Future<int> createUser(User newUser) async {
    Response response = await dio.post('$baseUrl/user', data: newUser.toJson());
    data = response.data.toString();
    statusCode = response.statusCode;

    if (statusCode == 201) {
      return 201;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  }

  Future<int> updateUser(User user) async {
    Response response = await dio.put('$baseUrl/user/${user.id}', data: user.toJson());
    data = response.data.toString();
    statusCode = response.statusCode;

    if (statusCode == 201) {
      return 201;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  }

  Future<int> updateLocation(Position? location) async {
    final json ={
      'location': {
        'type': 'Point',
        'coordinates': [location!.longitude, location.latitude],
      }
    };
    Response response = await dio.put('$baseUrl/user/${getId()}', data: json);
    data = response.data.toString();
    statusCode = response.statusCode;

    if (statusCode == 201) {
      return 201;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  }

  Future<User> getUser() async {
    final id = getId();
    try {
      Response res = await dio.get('$baseUrl/user/$id');
      User user = User.fromJson(res.data['data']);
      return user;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<User> getAnotherUser(String? id) async {
    try {
      Response res = await dio.get('$baseUrl/user/$id');
      User user = User.fromJson(res.data['data']);
      return user;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<List<Activity>> getData() async {
    try {
      var res = await dio.get('$baseUrl/place');
      List<dynamic> responseData = res.data;
      List<Activity> activities = responseData.map((data) => Activity.fromJson(data)).toList();
      return activities;
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<int> logIn(logIn) async {
    Response response = await dio.post('$baseUrl/signin', data: logInToJson(logIn));
    data = response.data.toString();
    statusCode = response.statusCode;

    if (statusCode == 201) {
      var token = response.data['token'];
      var refresh_token = response.data['refreshToken'];
      var id = response.data['id'];
      saveToken(token, refresh_token);
      saveId(id);
      return 201;
    } else if (statusCode == 400) {
      return 400;
    } else if (statusCode == 500) {
      return 500;
    } else {
      return -1;
    }
  }

  Map<String, dynamic> logInToJson(logIn) {
    return {'email': logIn.email, 'password': logIn.password};
  }

  Future<void> deleteUser() async {
    final id = getId();
    try {
      Response response = await dio.put('$baseUrl/user/delete/$id');
      statusCode = response.statusCode;
      logout();
    } catch (e) {
      print('Error fetching data: $e');
      throw e;
    }
  }

  Future<int> updateUserLocation(String userId, double latitude, double longitude) async {
    final data = {
      'latitude': latitude,
      'longitude': longitude,
    };
    try {
      Response response = await dio.put('$baseUrl/user/location/$userId', data: data);
      statusCode = response.statusCode;
      return statusCode;
    } catch (e) {
      print('Error updating user location: $e');
      return -1;
    }
  }

  Future<User> getCurrentUser() async {
    final id = getId();
    try {
      Response res = await dio.get('$baseUrl/user/$id');
      User user = User.fromJson(res.data['data']);
      return user;
    } catch (e) {
      print('Error fetching user data: $e');
      throw e;
    }
  }

  Future<void> recoverPassword(String email) async {
    try {
      Response response = await dio.post('$baseUrl/recover_password', data: {'email': email});
      statusCode = response.statusCode;

      if (statusCode != 200) {
        throw Exception('Failed to send recovery email');
      }
    } catch (e) {
      print('Error sending recovery email: $e');
      throw e;
    }
  }
}
