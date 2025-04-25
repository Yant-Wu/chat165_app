import 'package:flutter/material.dart';
import '../../widgets/news_card.dart';

class ScamExposureScreen extends StatelessWidget {
  const ScamExposureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('騙局曝光'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NewsCard(
            title: '最新電信詐騙手法曝光：冒充快遞員實施詐騙',
            source: '公安機關',
            date: '2023-07-15',
          ),
          SizedBox(height: 12),
          NewsCard(
            title: '警惕！新型投資理財詐騙卷土重來',
            source: '金融監管部門',
            date: '2023-07-10',
          ),
          SizedBox(height: 12),
          NewsCard(
            title: '網絡交友詐騙案例分析：如何識別"殺豬盤"',
            source: '網絡安全中心',
            date: '2023-07-05',
          ),
          SizedBox(height: 12),
          NewsCard(
            title: '假冒公檢法詐騙再現 警方發布緊急預警',
            source: '市公安局',
            date: '2023-06-28',
          ),
        ],
      ),
    );
  }
}