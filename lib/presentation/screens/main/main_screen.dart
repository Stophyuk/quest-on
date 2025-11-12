import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quest_on/core/theme/app_theme.dart';
import 'package:quest_on/presentation/screens/quest/quest_list_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_screen.dart';
import 'package:quest_on/presentation/screens/vision/vision_roadmap_screen.dart';
import 'package:quest_on/presentation/screens/profile/profile_screen.dart';
import 'package:quest_on/presentation/widgets/gradient_button.dart';

/// 메인 화면 (하단 네비게이션 포함)
class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _currentIndex;

  // 각 탭의 화면들
  final List<Widget> _screens = const [
    QuestListScreen(),
    VisionScreen(),
    VisionRoadmapScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: '비전',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '로드맵',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? GradientFAB(
              onPressed: () {
                context.push('/quest/add');
              },
              gradient: AppTheme.motivationGradient,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
