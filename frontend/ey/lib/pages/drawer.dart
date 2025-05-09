import 'package:flutter/material.dart';
import 'package:ey/appcolor.dart';
import 'package:ey/main.dart';
import 'package:ey/pages/settings.dart';
//import 'pages/settings.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color appcolor = AppColors.getBackground(context);

    return Drawer(
      child: Stack(
        children: [
          // Solid background color instead of image
          Container(
            color: appcolor, // Set the background color based on theme
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 50),
                  // Drawer header
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      color: AppColors.gettextcolor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your personalized settings are just one click away.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.gettextcolor(context),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Drawer menu items
                  ListTile(
                    leading: Icon(
                      Icons.home,
                      color: AppColors.gettextcolor(context),
                    ),
                    title: Text(
                      'Home',
                      style: TextStyle(color: AppColors.gettextcolor(context)),
                    ),
                    onTap: () {
                      // Handle navigation to home
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainNavigationWrapper(), //not sure
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.settings,
                      color: AppColors.gettextcolor(context),
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(color: AppColors.gettextcolor(context)),
                    ),
                    onTap: () {
                      // Handle navigation to settings
                      Navigator.pop(context); // Close the drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.help,
                      color: AppColors.gettextcolor(context),
                    ),
                    title: Text(
                      'Help',
                      style: TextStyle(color: AppColors.gettextcolor(context)),
                    ),
                    onTap: () {
                      // Handle navigation to help page
                      Navigator.pop(context); // Close the drawer
                    },
                  ),
                  SizedBox(height: 30),
                  // Log out button
                  ElevatedButton(
                    onPressed: () {
                      // Log out logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appcolor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.gettextcolor(context),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
