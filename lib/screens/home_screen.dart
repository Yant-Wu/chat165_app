import 'package:flutter/material.dart';
import 'dart:async'; // For Timer
import 'dart:math'; // For Random

// ADD: DashboardItem class definition
class DashboardItem {
  final int rank;
  final String name;
  final int numericValue;
  String get displayValue => '$numericValue 分';

  DashboardItem({required this.rank, required this.name, required this.numericValue});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables for dashboard
  List<DashboardItem> _dashboardItems = [];
  bool _isLoadingDashboard = true;
  Timer? _dashboardUpdateTimer;

  @override
  void initState() {
    super.initState();
    // REMOVE: _initSpeech(); // This was for the removed voice risk detection
    // ADD: Initialize and start timer for dashboard data
    _fetchDashboardData(); // Initial fetch
    _dashboardUpdateTimer = Timer.periodic(Duration(minutes: 10), (timer) {
      _fetchDashboardData();
    });
  }

  // Method to fetch/simulate dashboard data
  Future<void> _fetchDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingDashboard = true;
    });

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(400)));

    final random = Random();
    List<DashboardItem> newItems = List.generate(5, (index) {
      return DashboardItem(
        rank: 0, // Will be set after sorting
        name: '詐騙手法 ${String.fromCharCode(65 + random.nextInt(10))}${index + 1}',
        numericValue: random.nextInt(2000) + 500,
      );
    });

    newItems.sort((a, b) => b.numericValue.compareTo(a.numericValue));

    _dashboardItems = List.generate(newItems.length, (index) {
      return DashboardItem(
        rank: index + 1,
        name: newItems[index].name,
        numericValue: newItems[index].numericValue,
      );
    });
    
    if (!mounted) return;
    setState(() {
      _isLoadingDashboard = false;
    });
  }

  @override
  void dispose() {
    _dashboardUpdateTimer?.cancel(); // Cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // MODIFY: Scaffold background color
      appBar: AppBar(
        title: const Text('國家反詐中心'),
        centerTitle: false, // MODIFY: Align title to the left
        backgroundColor: Colors.grey[50], // MODIFY: AppBar background color
        elevation: 0.5, // MODIFY: Subtle elevation
        titleTextStyle: const TextStyle( // ADD: iOS-like title style
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.blue), // ADD: Icon theme for AppBar icons
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 功能按鈕區
              Container(
                color: Colors.white, // MODIFY: Background color for function button area
                padding: const EdgeInsets.symmetric(vertical: 20), // MODIFY: Padding for the area
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFunctionButton('我要舉報', Icons.report, Colors.red),
                    _buildFunctionButton('來電預警', Icons.phone_in_talk, Colors.orange), // Changed icon for variety
                    _buildFunctionButton('身份核實', Icons.verified_user, Colors.green), // Reverted icon
                  ],
                ),
              ),
              
              // 165dashboard區
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // MODIFY: Added vertical padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '165dashboard',
                      style: TextStyle( // MODIFY: iOS-like section title
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // MODIFY: Dashboard UI using ListView.separated
                    if (_isLoadingDashboard)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ))
                    else if (_dashboardItems.isEmpty)
                      const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('目前沒有排行榜資料'),
                      ))
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _dashboardItems.length,
                        itemBuilder: (context, index) {
                          final item = _dashboardItems[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200], // MODIFY: Subtle background for rank
                              child: Text(
                                '#${item.rank}',
                                style: TextStyle(
                                  color: Colors.grey[700], // MODIFY: Muted text color for rank
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              item.name,
                              style: const TextStyle( // MODIFY: iOS-like title style
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.black87
                              )
                            ),
                            trailing: Text(
                              item.displayValue,
                              style: TextStyle( // MODIFY: iOS-like detail text style
                                color: Colors.grey[600],
                                fontSize: 16
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0), // MODIFY: Adjust vertical padding
                          );
                        },
                        separatorBuilder: (context, index) => Divider( // ADD: Separator for list items
                          height: 1,
                          thickness: 0.5, // Thinner divider
                          color: Colors.grey[300], // Lighter separator color
                          indent: 16, // Align with ListTile content (approx)
                          endIndent: 0,
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MODIFY: _buildFunctionButton for Apple-like style
  Widget _buildFunctionButton(String text, IconData icon, Color iconColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15), // Subtle background using icon color
            borderRadius: BorderRadius.circular(16), // Rounded rectangle
          ),
          child: Icon(icon, size: 28, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.black87, // Darker text for light background
            fontWeight: FontWeight.w500, // Medium weight
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}