import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';
import '../models/iot_device.dart';

/// 设置页面
/// 提供应用设置和系统信息
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _autoRefresh = true;
  double _refreshInterval = 5.0; // 秒

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 应用设置
          _buildSectionCard(
            '应用设置',
            [
              _buildSwitchTile(
                '深色模式',
                '启用深色主题',
                Icons.dark_mode,
                _darkMode,
                (value) {
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
              _buildSwitchTile(
                '推送通知',
                '接收设备状态通知',
                Icons.notifications,
                _notifications,
                (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                '自动刷新',
                '自动刷新设备数据',
                Icons.refresh,
                _autoRefresh,
                (value) {
                  setState(() {
                    _autoRefresh = value;
                  });
                },
              ),
              _buildSliderTile(
                '刷新间隔',
                '数据刷新间隔时间',
                Icons.timer,
                _refreshInterval,
                1.0,
                30.0,
                (value) {
                  setState(() {
                    _refreshInterval = value;
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 设备管理
          _buildSectionCard(
            '设备管理',
            [
              _buildActionTile(
                '添加设备',
                '添加新的IoT设备',
                Icons.add_circle_outline,
                () => _showAddDeviceDialog(),
              ),
              _buildActionTile(
                '刷新所有设备',
                '手动刷新所有设备状态',
                Icons.refresh,
                () => _refreshAllDevices(),
              ),
              _buildActionTile(
                '清空数据',
                '清空所有传感器数据',
                Icons.clear_all,
                () => _clearAllData(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 应用信息
          _buildSectionCard(
            '应用信息',
            [
              _buildInfoTile(
                '应用版本',
                '1.0.0',
                Icons.info,
              ),
              _buildInfoTile(
                '构建日期',
                '2024-01-01',
                Icons.calendar_today,
              ),
              _buildActionTile(
                '关于应用',
                '查看应用详细信息',
                Icons.help_outline,
                () => _showAboutDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 系统状态
          _buildSystemStatusCard(),
        ],
      ),
    );
  }

  /// 构建分组卡片
  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  /// 构建开关选项
  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// 构建滑块选项
  Widget _buildSliderTile(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: '${value.toInt()}秒',
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  /// 构建操作选项
  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// 构建信息选项
  Widget _buildInfoTile(
    String title,
    String value,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 构建系统状态卡片
  Widget _buildSystemStatusCard() {
    return Consumer<IoTProvider>(
      builder: (context, iotProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '系统状态',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusItem(
                        '总设备',
                        iotProvider.devices.length.toString(),
                        Icons.devices,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildStatusItem(
                        '在线设备',
                        iotProvider.onlineDeviceCount.toString(),
                        Icons.wifi,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusItem(
                        '离线设备',
                        iotProvider.offlineDeviceCount.toString(),
                        Icons.wifi_off,
                        Colors.red,
                      ),
                    ),
                    Expanded(
                      child: _buildStatusItem(
                        '数据记录',
                        iotProvider.sensorData.length.toString(),
                        Icons.analytics,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      iotProvider.refreshDevices();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('刷新状态'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建状态项目
  Widget _buildStatusItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// 显示添加设备对话框
  void _showAddDeviceDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    String selectedType = 'sensor';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加设备'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '设备名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: '设备位置',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: '设备类型',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'sensor', child: Text('传感器')),
                  DropdownMenuItem(value: 'actuator', child: Text('执行器')),
                  DropdownMenuItem(value: 'gateway', child: Text('网关')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
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
                if (nameController.text.isNotEmpty && locationController.text.isNotEmpty) {
                  _addDevice(
                    nameController.text,
                    locationController.text,
                    selectedType,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  /// 添加设备
  void _addDevice(String name, String location, String type) {
    final device = IoTDevice(
      id: '${type}_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      location: location,
      isOnline: true,
      lastUpdate: DateTime.now(),
      data: _getDefaultDeviceData(type),
    );

    context.read<IoTProvider>().addDevice(device);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('设备 "$name" 添加成功'),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// 获取默认设备数据
  Map<String, dynamic> _getDefaultDeviceData(String type) {
    switch (type) {
      case 'sensor':
        return {
          'temperature': 22.0,
          'humidity': 45.0,
          'motion': false,
        };
      case 'actuator':
        return {
          'power': false,
          'brightness': 50,
          'color': '#FFFFFF',
        };
      case 'gateway':
        return {
          'connectedDevices': 0,
          'signalStrength': 85,
        };
      default:
        return {};
    }
  }

  /// 刷新所有设备
  void _refreshAllDevices() {
    context.read<IoTProvider>().refreshDevices();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在刷新所有设备...'),
      ),
    );
  }

  /// 清空所有数据
  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空数据'),
        content: const Text('确定要清空所有传感器数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<IoTProvider>().clearSensorData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('数据已清空'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 显示关于对话框
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'IoT Demo',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.device_hub, size: 48),
      children: [
        const Text('这是一个物联网设备管理和监控的演示应用。'),
        const SizedBox(height: 16),
        const Text('功能特性：'),
        const Text('• 设备列表管理'),
        const Text('• 实时数据监控'),
        const Text('• 设备远程控制'),
        const Text('• 数据图表展示'),
        const SizedBox(height: 16),
        const Text('适用于学习和调试IoT应用开发。'),
      ],
    );
  }
}
