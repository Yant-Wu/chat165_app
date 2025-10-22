import 'dart:async'; // For Timer

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../model/scam_type.dart';
import '../service/scam_types_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScamTypesService _scamTypesService = ScamTypesService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  List<ScamType> _scamTypes = [];
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdatedAt;
  Timer? _dashboardUpdateTimer;

  @override
  void initState() {
    super.initState();
    _fetchScamTypes(); // Initial fetch
    _dashboardUpdateTimer = Timer.periodic(Duration(minutes: 10), (timer) {
      _fetchScamTypes(showLoading: false);
    });
  }

  Future<void> _fetchScamTypes({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = null;
      });
    }

    try {
      final response = await _scamTypesService.fetchScamTypes();
      if (!mounted) return;
      setState(() {
        _scamTypes = response.scamTypes;
        _lastUpdatedAt = response.updatedAt;
        _isLoading = false;
        _errorMessage = null;
      });
    } on ScamTypesException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '發生未知錯誤，請稍後再試';
      });
    }
  }

  @override
  void dispose() {
    _dashboardUpdateTimer?.cancel(); // Cancel the timer
    _scamTypesService.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('無法撥打電話至 $phoneNumber'),
          ),
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri launchUri = Uri.parse(url);
    if (!await launchUrl(launchUri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('無法開啟網站 $url'),
          ),
        );
      }
    }
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
                    GestureDetector(
                      onTap: () => _makePhoneCall('165'),
                      child: _buildFunctionButton('我要舉報', Icons.report, Colors.red),
                    ),
                    //_buildFunctionButton('來電預警', Icons.phone_in_talk, Colors.orange), // Changed icon for variety
                    GestureDetector(
                      onTap: () => _launchURL('https://165.npa.gov.tw/#/'),
                      child: _buildFunctionButton('身份核實', Icons.verified_user, Colors.green),
                    ), // Reverted icon
                  ],
                ),
              ),
              
              // 165dashboard區
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // MODIFY: Added vertical padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            '詐騙手法排行榜',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: '重新整理',
                          onPressed: _isLoading ? null : () => _fetchScamTypes(),
                        ),
                      ],
                    ),
                    if (_lastUpdatedAt != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          '更新時間：${_dateFormat.format(_lastUpdatedAt!)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_errorMessage != null)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => _fetchScamTypes(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('重新嘗試'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_scamTypes.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('目前沒有詐騙手法資料'),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _scamTypes.length,
                        itemBuilder: (context, index) {
                          final item = _scamTypes[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            title: Text(
                              item.type,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 17,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Text(
                              '${item.count} 件',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                          );
                        },
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey[300],
                          indent: 16,
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