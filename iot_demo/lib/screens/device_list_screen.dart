import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iot_provider.dart';
import '../models/iot_device.dart';
import 'device_detail_screen.dart';

/// 设备列表页面
/// 显示所有IoT设备的列表，包括在线状态、设备类型等信息
class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  String _selectedFilter = 'all'; // 设备类型过滤器
  String _sortBy = 'name'; // 排序方式

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备列表'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<IoTProvider>().refreshDevices();
            },
          ),
          // 筛选菜单
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('全部设备'),
              ),
              const PopupMenuItem(
                value: 'sensor',
                child: Text('传感器'),
              ),
              const PopupMenuItem(
                value: 'actuator',
                child: Text('执行器'),
              ),
              const PopupMenuItem(
                value: 'gateway',
                child: Text('网关'),
              ),
            ],
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

          if (iotProvider.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    iotProvider.errorMessage,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      iotProvider.refreshDevices();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          // 获取过滤后的设备列表
          List<IoTDevice> filteredDevices = _getFilteredDevices(iotProvider.devices);
          
          // 排序设备列表
          filteredDevices = _sortDevices(filteredDevices);

          return Column(
            children: [
              // 设备统计信息
              _buildDeviceStats(iotProvider),
              
              // 设备列表
              Expanded(
                child: filteredDevices.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredDevices.length,
                        itemBuilder: (context, index) {
                          final device = filteredDevices[index];
                          return _buildDeviceCard(device);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建设备统计信息卡片
  Widget _buildDeviceStats(IoTProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              '总设备',
              provider.devices.length.toString(),
              Icons.devices,
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              '在线',
              provider.onlineDeviceCount.toString(),
              Icons.wifi,
              Colors.green,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              '离线',
              provider.offlineDeviceCount.toString(),
              Icons.wifi_off,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计项目
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
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
    );
  }

  /// 获取过滤后的设备列表
  List<IoTDevice> _getFilteredDevices(List<IoTDevice> devices) {
    if (_selectedFilter == 'all') {
      return devices;
    }
    return devices.where((device) => device.type == _selectedFilter).toList();
  }

  /// 排序设备列表
  List<IoTDevice> _sortDevices(List<IoTDevice> devices) {
    switch (_sortBy) {
      case 'name':
        devices.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'type':
        devices.sort((a, b) => a.type.compareTo(b.type));
        break;
      case 'status':
        devices.sort((a, b) => b.isOnline.toString().compareTo(a.isOnline.toString()));
        break;
      case 'lastUpdate':
        devices.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
        break;
    }
    return devices;
  }

  /// 构建设备卡片
  Widget _buildDeviceCard(IoTDevice device) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: device.isOnline ? Colors.green : Colors.grey,
          child: Icon(
            _getDeviceIcon(device.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('位置: ${device.location}'),
            Text('类型: ${_getDeviceTypeName(device.type)}'),
            Text(
              '状态: ${device.isOnline ? "在线" : "离线"}',
              style: TextStyle(
                color: device.isOnline ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '最后更新: ${_formatDateTime(device.lastUpdate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'detail':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DeviceDetailScreen(device: device),
                  ),
                );
                break;
              case 'refresh':
                context.read<IoTProvider>().refreshDevices();
                break;
              case 'remove':
                _showRemoveDeviceDialog(device);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'detail',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 8),
                  Text('查看详情'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('刷新状态'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除设备', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DeviceDetailScreen(device: device),
            ),
          );
        },
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

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无设备',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请添加设备或检查网络连接',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示删除设备确认对话框
  void _showRemoveDeviceDialog(IoTDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除设备'),
        content: Text('确定要删除设备 "${device.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<IoTProvider>().removeDevice(device.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除设备 "${device.name}"')),
              );
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
