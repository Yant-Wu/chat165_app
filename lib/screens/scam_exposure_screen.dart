import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class NewsItemData {
  final String title;
  final String source;
  final String date;

  const NewsItemData({required this.title, required this.source, required this.date});
}

class ScamExposureScreen extends StatefulWidget {
  const ScamExposureScreen({super.key});

  @override
  State<ScamExposureScreen> createState() => _ScamExposureScreenState();
}

class _ScamExposureScreenState extends State<ScamExposureScreen> {
  String _currentLocation = '定位中...';
  bool _isLocationLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 檢查位置權限
      PermissionStatus permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      if (permission.isPermanentlyDenied) {
        setState(() {
          _currentLocation = '無法取得定位權限';
          _isLocationLoading = false;
        });
        return;
      }

      if (permission.isGranted) {
        // 檢查位置服務是否啟用
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          setState(() {
            _currentLocation = '請開啟定位服務';
            _isLocationLoading = false;
          });
          return;
        }

        // 獲取當前位置
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );

        // 根據座標獲取地址信息
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          String city = place.administrativeArea ?? '';
          String district = place.subAdministrativeArea ?? '';
          
          setState(() {
            _currentLocation = city.isNotEmpty ? (district.isNotEmpty ? '$city$district' : city) : '未知地區';
            _isLocationLoading = false;
          });
        } else {
          setState(() {
            _currentLocation = '無法取得地址信息';
            _isLocationLoading = false;
          });
        }
      } else {
        setState(() {
          _currentLocation = '定位權限被拒絕';
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = '定位失敗';
        _isLocationLoading = false;
      });
    }
  }

  final List<NewsItemData> newsItems = const [
    NewsItemData(
      title: '假冒電信業者催繳電話費，騙取個資',
      source: '刑事警察局',
      date: '2025-05-20',
    ),
    NewsItemData(
      title: 'LINE假投資群組盛行，勿輕信高獲利話術',
      source: '165反詐騙宣導',
      date: '2025-05-15',
    ),
    NewsItemData(
      title: '網購注意！「解除分期付款」仍是常見詐騙手法',
      source: '消費者保護會',
      date: '2025-05-10',
    ),
    NewsItemData(
      title: '假冒親友借錢，務必先電話確認',
      source: '地方警察局',
      date: '2025-05-05',
    ),
    NewsItemData(
      title: '求職詐騙：海外高薪工作誘騙，小心人身安全',
      source: '勞動部',
      date: '2025-04-28',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('騙局曝光'),
        centerTitle: false,
        backgroundColor: Colors.grey[50],
        elevation: 0.5,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.blue.shade700),
      ),
      body: Column(
        children: [
          // 定位信息顯示區域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.blue[600],
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '目前位置：',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                _isLocationLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                        ),
                      )
                    : Text(
                        _currentLocation,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                const Spacer(),
                if (!_isLocationLoading && _currentLocation.contains('失敗') || _currentLocation.contains('權限') || _currentLocation.contains('服務'))
                  GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Icon(
                      Icons.refresh,
                      color: Colors.blue[600],
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
          // 新聞列表
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.separated(
                padding: const EdgeInsets.all(0),
                itemCount: newsItems.length,
                itemBuilder: (context, index) {
                  final item = newsItems[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    title: Text(
                      item.title,
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w500, color: Colors.black87),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.source,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                          Text(
                            item.date,
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
                    onTap: () {
                      // Handle news item tap - e.g., navigate to a detail screen
                    },
                  );
                },
                separatorBuilder: (context, index) => Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Colors.grey[200],
                  indent: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}