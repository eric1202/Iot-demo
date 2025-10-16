import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';
import '../models/iot_device.dart';

/// 设备控制页面
/// 提供对IoT设备的远程控制功能
class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备控制'),
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
          if (iotProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 获取可控制的设备（执行器和在线设备）
          final controllableDevices = iotProvider.devices
              .where((device) => device.type == 'actuator' && device.isOnline)
              .toList();

          if (controllableDevices.isEmpty) {
            return _buildEmptyState();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 控制面板标题
              Text(
                '设备控制面板',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // 设备控制卡片列表
              ...controllableDevices.map((device) => _buildDeviceControlCard(device)),
            ],
          );
        },
      ),
    );
  }

  /// 构建设备控制卡片
  Widget _buildDeviceControlCard(IoTDevice device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 设备信息头部
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '位置: ${device.location}',
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
            
            // 设备状态显示
            _buildDeviceStatus(device),
            
            const SizedBox(height: 16),
            
            // 控制按钮
            _buildControlButtons(device),
          ],
        ),
      ),
    );
  }

  /// 构建设备状态显示
  Widget _buildDeviceStatus(IoTDevice device) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前状态',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (device.data.containsKey('power'))
            _buildStatusItem(
              '电源',
              device.data['power'] == true ? '开启' : '关闭',
              device.data['power'] == true ? Colors.green : Colors.red,
              Icons.power,
            ),
          if (device.data.containsKey('brightness'))
            _buildStatusItem(
              '亮度',
              '${device.data['brightness']}%',
              Theme.of(context).colorScheme.primary,
              Icons.brightness_6,
            ),
          if (device.data.containsKey('color'))
            _buildStatusItem(
              '颜色',
              device.data['color'],
              _parseColor(device.data['color']),
              Icons.palette,
            ),
        ],
      ),
    );
  }

  /// 构建状态项目
  Widget _buildStatusItem(String label, String value, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButtons(IoTDevice device) {
    return Column(
      children: [
        // 电源控制
        if (device.data.containsKey('power'))
          _buildPowerControl(device),
        
        const SizedBox(height: 12),
        
        // 亮度控制
        if (device.data.containsKey('brightness'))
          _buildBrightnessControl(device),
        
        const SizedBox(height: 12),
        
        // 颜色控制
        if (device.data.containsKey('color'))
          _buildColorControl(device),
      ],
    );
  }

  /// 构建电源控制
  Widget _buildPowerControl(IoTDevice device) {
    final isOn = device.data['power'] == true;
    
    return Row(
      children: [
        Expanded(
          child: Text(
            '电源控制',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _togglePower(device),
          icon: Icon(isOn ? Icons.power_off : Icons.power),
          label: Text(isOn ? '关闭' : '开启'),
          style: ElevatedButton.styleFrom(
            backgroundColor: isOn ? Colors.red : Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 构建亮度控制
  Widget _buildBrightnessControl(IoTDevice device) {
    final currentBrightness = (device.data['brightness'] ?? 50.0).toDouble();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '亮度控制',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${currentBrightness.round()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: currentBrightness,
          min: 0,
          max: 100,
          divisions: 100,
          onChanged: (value) {
            _setBrightness(device, value);
          },
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => _setBrightness(device, 0),
              child: const Text('关闭'),
            ),
            TextButton(
              onPressed: () => _setBrightness(device, 25),
              child: const Text('25%'),
            ),
            TextButton(
              onPressed: () => _setBrightness(device, 50),
              child: const Text('50%'),
            ),
            TextButton(
              onPressed: () => _setBrightness(device, 75),
              child: const Text('75%'),
            ),
            TextButton(
              onPressed: () => _setBrightness(device, 100),
              child: const Text('100%'),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建颜色控制
  Widget _buildColorControl(IoTDevice device) {
    final colors = [
      {'name': '白色', 'value': '#FFFFFF', 'color': Colors.white},
      {'name': '红色', 'value': '#FF0000', 'color': Colors.red},
      {'name': '绿色', 'value': '#00FF00', 'color': Colors.green},
      {'name': '蓝色', 'value': '#0000FF', 'color': Colors.blue},
      {'name': '黄色', 'value': '#FFFF00', 'color': Colors.yellow},
      {'name': '紫色', 'value': '#FF00FF', 'color': Colors.purple},
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '颜色控制',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((colorInfo) {
            final isSelected = device.data['color'] == colorInfo['value'];
            return GestureDetector(
              onTap: () => _setColor(device, colorInfo['value'] as String),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: (colorInfo['color'] as Color).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 切换电源
  void _togglePower(IoTDevice device) {
    final command = DeviceCommand(
      deviceId: device.id,
      command: 'toggle_power',
      parameters: {},
    );
    
    context.read<IoTProvider>().sendDeviceCommand(command).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} 电源${device.data['power'] == true ? '关闭' : '开启'}成功'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} 电源控制失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  /// 设置亮度
  void _setBrightness(IoTDevice device, double brightness) {
    final command = DeviceCommand(
      deviceId: device.id,
      command: 'set_brightness',
      parameters: {'brightness': brightness.round()},
    );
    
    context.read<IoTProvider>().sendDeviceCommand(command).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} 亮度设置为 ${brightness.round()}%'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} 亮度设置失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  /// 设置颜色
  void _setColor(IoTDevice device, String color) {
    final command = DeviceCommand(
      deviceId: device.id,
      command: 'set_color',
      parameters: {'color': color},
    );
    
    context.read<IoTProvider>().sendDeviceCommand(command).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} 颜色设置成功'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} 颜色设置失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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

  /// 解析颜色
  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.control_camera_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无可控设备',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请确保有执行器设备且设备在线',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
