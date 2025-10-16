import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';
import 'device_list_screen.dart';
import 'sensor_monitor_screen.dart';
import 'device_control_screen.dart';
import 'settings_screen.dart';

/// 主屏幕界面
/// 包含底部导航栏和各个功能页面的入口
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // 底部导航栏页面列表
  final List<Widget> _screens = [
    const DeviceListScreen(),
    const SensorMonitorScreen(),
    const DeviceControlScreen(),
    const SettingsScreen(),
  ];

  // 底部导航栏项目
  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.devices),
      label: '设备列表',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.analytics),
      label: '数据监控',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.control_camera),
      label: '设备控制',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.settings),
      label: '设置',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化应用数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IoTProvider>().initializeApp();
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
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}
