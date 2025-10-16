import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';
import '../models/iot_device.dart';

/// 设备详情页面
/// 显示单个设备的详细信息，包括实时数据和历史记录
class DeviceDetailScreen extends StatefulWidget {
  final IoTDevice device;

  const DeviceDetailScreen({
    super.key,
    required this.device,
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<IoTProvider>().refreshDevices();
            },
          ),
        ],
      ),
      body: Consumer<IoTProvider>(
        builder: (context, iotProvider, child) {
          // 获取最新的设备信息
          final device = iotProvider.getDeviceById(widget.device.id) ?? widget.device;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 设备基本信息卡片
                _buildDeviceInfoCard(device),
                
                const SizedBox(height: 16),
                
                // 设备状态卡片
                _buildDeviceStatusCard(device),
                
                const SizedBox(height: 16),
                
                // 设备数据卡片
                _buildDeviceDataCard(device),
                
                const SizedBox(height: 16),
                
                // 操作按钮
                _buildActionButtons(device),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 构建设备信息卡片
  Widget _buildDeviceInfoCard(IoTDevice device) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getDeviceIcon(device.type),
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getDeviceTypeName(device.type),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: device.isOnline ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    device.isOnline ? '在线' : '离线',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('设备ID', device.id),
            _buildInfoRow('位置', device.location),
            _buildInfoRow('最后更新', _formatDateTime(device.lastUpdate)),
          ],
        ),
      ),
    );
  }

  /// 构建设备状态卡片
  Widget _buildDeviceStatusCard(IoTDevice device) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '设备状态',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    '连接状态',
                    device.isOnline ? '已连接' : '已断开',
                    device.isOnline ? Colors.green : Colors.red,
                    Icons.wifi,
                  ),
                ),
                Expanded(
                  child: _buildStatusItem(
                    '设备类型',
                    _getDeviceTypeName(device.type),
                    Theme.of(context).colorScheme.primary,
                    Icons.category,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建设备数据卡片
  Widget _buildDeviceDataCard(IoTDevice device) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '设备数据',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (device.data.isEmpty)
              const Text('暂无数据')
            else
              ...device.data.entries.map((entry) => _buildDataItem(entry.key, entry.value)),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons(IoTDevice device) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: device.isOnline ? () => _sendDeviceCommand(device) : null,
            icon: const Icon(Icons.send),
            label: const Text('发送命令'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<IoTProvider>().refreshDevices();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('刷新状态'),
          ),
        ),
      ],
    );
  }

  /// 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建状态项目
  Widget _buildStatusItem(String label, String value, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 构建数据项目
  Widget _buildDataItem(String key, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _getDataLabel(key),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _formatDataValue(value),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取设备图标
  IconData _getDeviceIcon(String type) {
    switch (type) {
      case 'sensor':
        return Icons.sensors;
      case 'actuator':
        return Icons.smart_toy;
      case 'gateway':
        return Icons.router;
      default:
        return Icons.device_hub;
    }
  }

  /// 获取设备类型中文名称
  String _getDeviceTypeName(String type) {
    switch (type) {
      case 'sensor':
        return '传感器';
      case 'actuator':
        return '执行器';
      case 'gateway':
        return '网关';
      default:
        return '未知';
    }
  }

  /// 获取数据标签
  String _getDataLabel(String key) {
    switch (key) {
      case 'temperature':
        return '温度';
      case 'humidity':
        return '湿度';
      case 'brightness':
        return '亮度';
      case 'color':
        return '颜色';
      case 'power':
        return '电源';
      case 'motion':
        return '运动检测';
      case 'lastMotion':
        return '最后运动时间';
      case 'connectedDevices':
        return '连接设备数';
      case 'signalStrength':
        return '信号强度';
      default:
        return key;
    }
  }

  /// 格式化数据值
  String _formatDataValue(dynamic value) {
    if (value is bool) {
      return value ? '是' : '否';
    } else if (value is double) {
      return value.toStringAsFixed(1);
    } else if (value is String && value.contains('T')) {
      // 处理ISO日期时间字符串
      try {
        final dateTime = DateTime.parse(value);
        return _formatDateTime(dateTime);
      } catch (e) {
        return value;
      }
    } else {
      return value.toString();
    }
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// 发送设备命令
  void _sendDeviceCommand(IoTDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('发送命令'),
        content: const Text('选择要发送的命令类型：'),
        actions: [
          if (device.type == 'actuator') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _sendTogglePowerCommand(device);
              },
              child: const Text('开关电源'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showBrightnessDialog(device);
              },
              child: const Text('调节亮度'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 发送开关电源命令
  void _sendTogglePowerCommand(IoTDevice device) {
    final command = DeviceCommand(
      deviceId: device.id,
      command: 'toggle_power',
      parameters: {},
    );
    
    context.read<IoTProvider>().sendDeviceCommand(command).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('命令发送成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('命令发送失败')),
        );
      }
    });
  }

  /// 显示亮度调节对话框
  void _showBrightnessDialog(IoTDevice device) {
    double currentBrightness = (device.data['brightness'] ?? 50.0).toDouble();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('调节亮度'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('当前亮度: ${currentBrightness.round()}%'),
              Slider(
                value: currentBrightness,
                min: 0,
                max: 100,
                divisions: 100,
                onChanged: (value) {
                  setState(() {
                    currentBrightness = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _sendBrightnessCommand(device, currentBrightness);
              },
              child: const Text('确定'),
            ),
          ],
        ),
      ),
    );
  }

  /// 发送亮度调节命令
  void _sendBrightnessCommand(IoTDevice device, double brightness) {
    final command = DeviceCommand(
      deviceId: device.id,
      command: 'set_brightness',
      parameters: {'brightness': brightness.round()},
    );
    
    context.read<IoTProvider>().sendDeviceCommand(command).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('亮度调节成功')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('亮度调节失败')),
        );
      }
    });
  }
}
