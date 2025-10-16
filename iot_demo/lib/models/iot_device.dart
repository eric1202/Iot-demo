/// IoT设备数据模型
/// 用于表示物联网设备的基本信息和状态
class IoTDevice {
  final String id;           // 设备唯一标识
  final String name;         // 设备名称
  final String type;         // 设备类型（传感器、执行器、网关等）
  final String location;     // 设备位置
  final bool isOnline;       // 设备在线状态
  final DateTime lastUpdate; // 最后更新时间
  final Map<String, dynamic> data; // 设备数据（传感器读数、状态等）

  IoTDevice({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.isOnline,
    required this.lastUpdate,
    required this.data,
  });

  /// 从JSON创建设备对象
  factory IoTDevice.fromJson(Map<String, dynamic> json) {
    return IoTDevice(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      location: json['location'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'location': location,
      'isOnline': isOnline,
      'lastUpdate': lastUpdate.toIso8601String(),
      'data': data,
    };
  }

  /// 复制设备对象并更新部分属性
  IoTDevice copyWith({
    String? id,
    String? name,
    String? type,
    String? location,
    bool? isOnline,
    DateTime? lastUpdate,
    Map<String, dynamic>? data,
  }) {
    return IoTDevice(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      isOnline: isOnline ?? this.isOnline,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      data: data ?? this.data,
    );
  }
}

/// 传感器数据类型枚举
enum SensorType {
  temperature,  // 温度传感器
  humidity,     // 湿度传感器
  pressure,     // 压力传感器
  light,        // 光照传感器
  motion,       // 运动传感器
  sound,        // 声音传感器
}

/// 传感器数据模型
class SensorData {
  final String deviceId;     // 设备ID
  final SensorType type;     // 传感器类型
  final double value;        // 传感器数值
  final String unit;        // 数值单位
  final DateTime timestamp; // 时间戳

  SensorData({
    required this.deviceId,
    required this.type,
    required this.value,
    required this.unit,
    required this.timestamp,
  });

  /// 从JSON创建传感器数据对象
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      deviceId: json['deviceId'] ?? '',
      type: SensorType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => SensorType.temperature,
      ),
      value: (json['value'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'type': type.toString().split('.').last,
      'value': value,
      'unit': unit,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 设备控制命令模型
class DeviceCommand {
  final String deviceId;     // 目标设备ID
  final String command;      // 命令类型
  final Map<String, dynamic> parameters; // 命令参数

  DeviceCommand({
    required this.deviceId,
    required this.command,
    required this.parameters,
  });

  /// 从JSON创建命令对象
  factory DeviceCommand.fromJson(Map<String, dynamic> json) {
    return DeviceCommand(
      deviceId: json['deviceId'] ?? '',
      command: json['command'] ?? '',
      parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'command': command,
      'parameters': parameters,
    };
  }
}
