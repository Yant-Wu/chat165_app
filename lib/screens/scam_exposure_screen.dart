import 'package:flutter/material.dart';

class NewsItemData {
  final String title;
  final String source;
  final String date;

  const NewsItemData({required this.title, required this.source, required this.date});
}

class ScamExposureScreen extends StatelessWidget {
  const ScamExposureScreen({super.key});

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
      body: Container(
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
    );
  }
}