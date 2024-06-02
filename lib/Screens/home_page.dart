import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Widgets/paramTextBox.dart';
import 'package:spotfinder/Screens/activity_list_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'profile_screen.dart';
import 'chatScreen.dart';
import 'package:spotfinder/Services/UserService.dart';
import 'package:spotfinder/Models/UserModel.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static HomeController homeController = Get.put(HomeController());
  int _selectedIndex = 0;
  UserService userService = UserService();

  static final List<Widget> _widgetOptions = <Widget>[
    Scaffold(
      body: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ParamTextBox(
                  controller: homeController.searchBarController,
                  text: 'Scaperoom...'
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
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    ),
    const ActivityListPage(),
    const ChatScreen(),
    const ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    homeController = Get.put(HomeController());
    _getUserLocation(); // Función para obtener la ubicación del user
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _updateUserLocation(position);
    } catch (e) {
      print('Error al obtener la ubicación del usuario: $e');
    }
  }

  Future<void> _updateUserLocation(Position position) async {
    User currentUser = await userService.getCurrentUser(); // Método para obtener el usuario actual
    User updatedUser = User(
      id: currentUser.id,
      name: currentUser.name,
      email: currentUser.email,
      phone_number: currentUser.phone_number,
      gender: currentUser.gender,
      password: currentUser.password,
      birthday: currentUser.birthday,
      activities: currentUser.activities,
      listActivities: currentUser.listActivities,
      comments: currentUser.comments,
      location: LatLng(latitude: position.latitude, longitude: position.longitude),
    );

    userService.updateUser(updatedUser).then((statusCode) {
      print('User location updated successfully');
    }).catchError((error) {
      print('Error updating user location: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Pallete.backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Pallete.backgroundColor.withOpacity(0.1),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: GNav(
              tabBorderRadius: 10,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              padding: EdgeInsets.all(10),
              gap: 8,
              activeColor: Pallete.salmonColor,
              iconSize: 28,
              tabBackgroundColor: Colors.grey[100]!,
              color: Pallete.whiteColor,
              tabs: const [
                GButton(
                  iconColor: Colors.white,
                  icon: LineIcons.mapMarker,
                  text: "Home"
                ),
                GButton(
                  iconColor: Colors.white,
                  icon: LineIcons.hiking,
                  text: "Activities"
                ),
                GButton(
                  iconColor: Colors.white,
                  icon: LineIcons.comment,
                  text: "Chats"
                ),
                GButton(
                  iconColor: Colors.white,
                  icon: LineIcons.user,
                  text: "Profile"
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatScreen()),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  final TextEditingController searchBarController = TextEditingController();
}
