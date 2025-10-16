import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/iot_provider.dart';
import 'screens/home_screen.dart';

/// IoT Demo应用主入口
/// 这是一个物联网设备管理和监控的演示应用
void main() {
  runApp(const IoTDemoApp());
}

/// 主应用类
class IoTDemoApp extends StatelessWidget {
  const IoTDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => IoTProvider(),
      child: MaterialApp(
        title: 'IoT Demo - 物联网设备管理',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 使用现代化的Material Design 3主题
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
