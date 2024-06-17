import 'package:flutter/material.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/map.dart';
import 'package:spotfinder/Screens/activity_list_page.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:spotfinder/Screens/settingsScreen.dart';
import 'profile_screen.dart';
import 'chatScreen.dart';
import 'package:latlong2/latlong.dart' as ltlg;

class HomePage extends StatefulWidget {
  final int initialIndex;

  HomePage({this.initialIndex = 0, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static HomeController homeController = Get.put(HomeController());
  int _selectedIndex = 0;

  static final ltlg.LatLng defaultLocation =
      ltlg.LatLng(41.27552212202214, 1.9863014220734023);

  static final List<Widget> _widgetOptions = <Widget>[
    MapScreen(defaultLocation: defaultLocation),
    const ActivityListPage(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Pallete.backgroundColor,
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              color: Pallete.textColor.withOpacity(0.3),
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
              color: Pallete.textColor,
              tabs: [
                GButton(
                  iconColor: Pallete.textColor,
                  icon: LineIcons.mapMarker,
                  text: "Home",
                ),
                GButton(
                  iconColor: Pallete.textColor,
                  icon: LineIcons.hiking,
                  text: "Activities",
                ),
                GButton(
                  iconColor: Pallete.textColor,
                  icon: LineIcons.comment,
                  text: "Chats",
                ),
                GButton(
                  iconColor: Pallete.textColor,
                  icon: LineIcons.user,
                  text: "Profile",
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

