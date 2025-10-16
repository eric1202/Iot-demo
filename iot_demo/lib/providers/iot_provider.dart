import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/iot_device.dart';

/// IoT设备状态管理类
/// 使用Provider模式管理应用状态
class IoTProvider with ChangeNotifier {
  List<IoTDevice> _devices = [];
  List<SensorData> _sensorData = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<IoTDevice> get devices => _devices;
  List<SensorData> get sensorData => _sensorData;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// 获取在线设备数量
  int get onlineDeviceCount => _devices.where((device) => device.isOnline).length;

  /// 获取离线设备数量
  int get offlineDeviceCount => _devices.where((device) => !device.isOnline).length;

  /// 根据类型获取设备列表
  List<IoTDevice> getDevicesByType(String type) {
    return _devices.where((device) => device.type == type).toList();
  }

  /// 根据ID获取设备
  IoTDevice? getDeviceById(String id) {
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 初始化应用数据
  Future<void> initializeApp() async {
    _setLoading(true);
    try {
      // 从本地存储加载设备数据
      await _loadDevicesFromStorage();
      
      // 如果没有设备数据，创建一些示例设备
      if (_devices.isEmpty) {
        await _createSampleDevices();
      }
      
      // 开始模拟数据更新
      _startDataSimulation();
      
      _setError('');
    } catch (e) {
      _setError('初始化失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 从本地存储加载设备数据
  Future<void> _loadDevicesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = prefs.getString('iot_devices');
      
      if (devicesJson != null) {
        final List<dynamic> devicesList = json.decode(devicesJson);
        _devices = devicesList.map((json) => IoTDevice.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('加载设备数据失败: $e');
    }
  }

  /// 保存设备数据到本地存储
  Future<void> _saveDevicesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final devicesJson = json.encode(_devices.map((device) => device.toJson()).toList());
      await prefs.setString('iot_devices', devicesJson);
    } catch (e) {
      debugPrint('保存设备数据失败: $e');
    }
  }

  /// 创建示例设备数据
  Future<void> _createSampleDevices() async {
    final sampleDevices = [
      IoTDevice(
        id: 'temp_001',
        name: '客厅温度传感器',
        type: 'sensor',
        location: '客厅',
        isOnline: true,
        lastUpdate: DateTime.now(),
        data: {'temperature': 22.5, 'humidity': 45.0},
      ),
      IoTDevice(
        id: 'light_001',
        name: '智能灯泡',
        type: 'actuator',
        location: '卧室',
        isOnline: true,
        lastUpdate: DateTime.now(),
        data: {'brightness': 80, 'color': '#FFFFFF', 'power': true},
      ),
      IoTDevice(
        id: 'motion_001',
        name: '人体感应器',
        type: 'sensor',
        location: '走廊',
        isOnline: false,
        lastUpdate: DateTime.now().subtract(const Duration(minutes: 5)),
        data: {'motion': false, 'lastMotion': DateTime.now().subtract(const Duration(hours: 2))},
      ),
      IoTDevice(
        id: 'gateway_001',
        name: '智能网关',
        type: 'gateway',
        location: '客厅',
        isOnline: true,
        lastUpdate: DateTime.now(),
        data: {'connectedDevices': 3, 'signalStrength': 85},
      ),
    ];

    _devices = sampleDevices;
    await _saveDevicesToStorage();
    notifyListeners();
  }

  /// 开始模拟数据更新
  void _startDataSimulation() {
    // 每5秒更新一次设备数据
    Future.delayed(const Duration(seconds: 5), () {
      if (_devices.isNotEmpty) {
        _simulateDataUpdate();
        _startDataSimulation(); // 递归调用以持续更新
      }
    });
  }

  /// 模拟设备数据更新
  void _simulateDataUpdate() {
    final random = Random();
    
    for (int i = 0; i < _devices.length; i++) {
      final device = _devices[i];
      
      // 随机改变设备在线状态（10%概率）
      bool isOnline = device.isOnline;
      if (random.nextDouble() < 0.1) {
        isOnline = !isOnline;
      }
      
      // 更新设备数据
      Map<String, dynamic> newData = Map.from(device.data);
      
      switch (device.type) {
        case 'sensor':
          if (device.id.contains('temp')) {
            // 温度传感器数据更新
            double currentTemp = (device.data['temperature'] ?? 22.0).toDouble();
            double newTemp = currentTemp + (random.nextDouble() - 0.5) * 2.0;
            newData['temperature'] = newTemp.clamp(15.0, 35.0);
            newData['humidity'] = (newData['humidity'] ?? 45.0) + (random.nextDouble() - 0.5) * 5.0;
          } else if (device.id.contains('motion')) {
            // 运动传感器数据更新
            newData['motion'] = random.nextBool();
            if (newData['motion'] == true) {
              newData['lastMotion'] = DateTime.now().toIso8601String();
            }
          }
          break;
        case 'actuator':
          // 执行器设备状态保持不变，除非手动控制
          break;
        case 'gateway':
          // 网关设备更新连接设备数量
          newData['connectedDevices'] = _devices.where((d) => d.isOnline).length;
          newData['signalStrength'] = 70 + random.nextInt(30);
          break;
      }
      
      _devices[i] = device.copyWith(
        isOnline: isOnline,
        lastUpdate: DateTime.now(),
        data: newData,
      );
    }
    
    // 生成传感器数据记录
    _generateSensorData();
    
    notifyListeners();
    _saveDevicesToStorage();
  }

  /// 生成传感器数据记录
  void _generateSensorData() {
    final random = Random();
    final now = DateTime.now();
    
    // 为每个传感器设备生成数据
    for (final device in _devices.where((d) => d.type == 'sensor' && d.isOnline)) {
      if (device.id.contains('temp')) {
        _sensorData.add(SensorData(
          deviceId: device.id,
          type: SensorType.temperature,
          value: device.data['temperature'] ?? 22.0,
          unit: '°C',
          timestamp: now,
        ));
      } else if (device.id.contains('motion')) {
        _sensorData.add(SensorData(
          deviceId: device.id,
          type: SensorType.motion,
          value: (device.data['motion'] ?? false) ? 1.0 : 0.0,
          unit: 'detected',
          timestamp: now,
        ));
      }
    }
    
    // 只保留最近100条数据记录
    if (_sensorData.length > 100) {
      _sensorData = _sensorData.skip(_sensorData.length - 100).toList();
    }
  }

  /// 添加新设备
  Future<void> addDevice(IoTDevice device) async {
    _devices.add(device);
    await _saveDevicesToStorage();
    notifyListeners();
  }

  /// 更新设备信息
  Future<void> updateDevice(IoTDevice updatedDevice) async {
    final index = _devices.indexWhere((device) => device.id == updatedDevice.id);
    if (index != -1) {
      _devices[index] = updatedDevice;
      await _saveDevicesToStorage();
      notifyListeners();
    }
  }

  /// 删除设备
  Future<void> removeDevice(String deviceId) async {
    _devices.removeWhere((device) => device.id == deviceId);
    await _saveDevicesToStorage();
    notifyListeners();
  }

  /// 发送设备控制命令
  Future<bool> sendDeviceCommand(DeviceCommand command) async {
    try {
      final device = getDeviceById(command.deviceId);
      if (device == null) return false;
      
      // 模拟命令执行
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 根据命令类型更新设备状态
      Map<String, dynamic> newData = Map.from(device.data);
      
      switch (command.command) {
        case 'toggle_power':
          newData['power'] = !(device.data['power'] ?? false);
          break;
        case 'set_brightness':
          newData['brightness'] = command.parameters['brightness'] ?? device.data['brightness'];
          break;
        case 'set_color':
          newData['color'] = command.parameters['color'] ?? device.data['color'];
          break;
      }
      
      await updateDevice(device.copyWith(data: newData));
      return true;
    } catch (e) {
      _setError('命令执行失败: $e');
      return false;
    }
  }

  /// 刷新设备状态
  Future<void> refreshDevices() async {
    _setLoading(true);
    try {
      // 模拟网络请求延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 随机更新一些设备的在线状态
      final random = Random();
      for (int i = 0; i < _devices.length; i++) {
        if (random.nextDouble() < 0.3) {
          _devices[i] = _devices[i].copyWith(
            isOnline: random.nextBool(),
            lastUpdate: DateTime.now(),
          );
        }
      }
      
      await _saveDevicesToStorage();
      _setError('');
    } catch (e) {
      _setError('刷新失败: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// 清空传感器数据
  void clearSensorData() {
    _sensorData.clear();
    notifyListeners();
  }

  /// 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误信息
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
}
