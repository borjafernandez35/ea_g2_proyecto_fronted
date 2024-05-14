import 'package:flutter/material.dart';
import 'package:spotfinder/Screens/chatScreen.dart';
import 'package:spotfinder/Screens/home_users.dart';
import 'package:spotfinder/Resources/pallete.dart';
import 'package:spotfinder/Screens/register_screen.dart';
import 'package:spotfinder/Widgets/paramTextBox.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';


class HomePage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  HomePage({super.key});

  @override
  State<HomePage> createState() => _nameState();
}

// ignore: camel_case_types
class _nameState extends State<HomePage> {
  static HomeController homeController = Get.put(HomeController());
  int _selectedIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    const gradientStart = Colors.black;
    const gradientEnd = Colors.transparent;

    final _gradient = LinearGradient(
      colors: [gradientStart, gradientEnd],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0, 0.3]
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: Drawer(
        backgroundColor: Pallete.greyColor,

  static final List<Widget> _widgetOptions = <Widget>[
    Container(
      child: Align(
        alignment: Alignment.topCenter,
        child: Column(
          children: [
            DrawerHeader(
              child: Image.asset(
                'logo.png',
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Divider(
                color:Pallete.backgroundColor,
              ),
            ),
            Padding(
              
              //onPressed:NavigationDestination(icon: icon, label: label),
              padding: EdgeInsets.only(left:25.0),
              child: ListTile(
                leading: Icon(
                  Icons.home,
                  color: Colors.white,
                ),
                title: Text(
                  'Home',
                  style: TextStyle(color: Colors.white),
                  ),
                onTap: () {
                  Get.to(() => HomePage());
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left:25.0),
              child: ListTile(
                leading: Icon(
                  Icons.flood_outlined,
                  color: Colors.white,

                ),
                title: Text(
                'Activities',
                style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.to(() => UserListPage());
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left:25.0),
              child: ListTile(
                leading: Icon(
                  Icons.book,
                  color: Colors.white,

                ),
                title: Text(
                  'Chat',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.to(() =>ChatScreen());
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left:25.0),
              child: ListTile(
                leading: Icon(
                  Icons.ad_units,
                  color: Colors.white,

                ),
                title: Text(
                'Register',
                style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Get.to(() =>RegisterScreen());
                },
              ),
            ),
          ],
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centers widgets horizontally
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ParamTextBox(controller: homeController.searchBarController, text: 'Scaperoom...'),
                IconButton(
                  icon: Icon(
                    size: 40,
                    color: Pallete.backgroundColor,
                    LineIcons.searchLocation
                  ),
                  onPressed: (){

                  },
                ),
              ],
            ),
            const SizedBox(height: 20,),
          ],
        ),
      ),
    ),
    Text("Activities"),
    Text("Chats"),
    Text("Profile"),
  ];
  
  @override
  Widget build(BuildContext context) {
    const gradientStart = Colors.black;
    const gradientEnd = Colors.transparent;

    final _gradient = LinearGradient(
      colors: [gradientStart, gradientEnd],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0, 0.3]
    );
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GNav(
              tabBorderRadius: 10,
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Pallete.salmonColor,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 200, vertical: 12),
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
              onTabChange: (index){
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: _gradient),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Pallete.salmonColor,
              ),
              onPressed: (){
                Scaffold.of(context).openDrawer();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  final TextEditingController searchBarController = TextEditingController();
}