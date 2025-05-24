import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // MODIFY: Consistent background color
      appBar: AppBar(
        title: const Text('我的'),
        centerTitle: false, // MODIFY: Align title to the left
        backgroundColor: Colors.grey[50], // MODIFY: AppBar background color
        elevation: 0.5, // MODIFY: Subtle elevation
        titleTextStyle: const TextStyle( // ADD: iOS-like title style
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.blue.shade700), // MODIFY: Icon theme for AppBar icons
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0), // ADD: Overall vertical padding
          child: Column(
            children: [
              // User Info Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                color: Colors.white, // ADD: White background for this section
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35, // MODIFY: Slightly smaller radius
                      backgroundColor: Colors.blue.shade600,
                      child: const Icon(Icons.person_outline, size: 35, color: Colors.white), // MODIFY: Outlined icon
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Text(
                        '用戶未登錄',
                        style: TextStyle(
                          fontSize: 20, // MODIFY: Larger font size
                          fontWeight: FontWeight.w600, // MODIFY: Font weight
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 18), // ADD: iOS-like disclosure indicator
                  ],
                ),
              ),
              const SizedBox(height: 20), // Space between sections

              // Menu Items Section 1
              _buildSection([
                _buildListTile(context, icon: Icons.login_outlined, title: '登錄/註冊', onTap: () {}),
              ]),

              const SizedBox(height: 20), // Space between sections

              // Menu Items Section 2
              _buildSection([
                _buildListTile(context, icon: Icons.settings_outlined, title: '應用設置', onTap: () {}),
                _buildListTile(context, icon: Icons.notifications_outlined, title: '通知設置', onTap: () {}),
              ]),

              const SizedBox(height: 20), // Space between sections

              // Menu Items Section 3
              _buildSection([
                _buildListTile(context, icon: Icons.help_outline, title: '幫助中心', onTap: () {}),
                _buildListTile(context, icon: Icons.info_outline, title: '關於我們', onTap: () {}),
              ]),

              const SizedBox(height: 30),

              // Logout Button Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8), // Adjust padding for button
                child: ListTile(
                  title: Center(
                    child: Text(
                      '退出應用',
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper to build a section with a white background and dividers
  Widget _buildSection(List<Widget> tiles) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: tiles.length,
        itemBuilder: (context, index) => tiles[index],
        separatorBuilder: (context, index) => Divider(
          height: 0.5,
          thickness: 0.5,
          color: Colors.grey[300],
          indent: 58, // Indent to align with title after icon
        ),
      ),
    );
  }

  // Helper to build styled ListTiles
  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0), // Adjust padding
    );
  }
}