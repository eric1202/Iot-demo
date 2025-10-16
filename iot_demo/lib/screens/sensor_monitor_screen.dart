import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/iot_provider.dart';
import '../models/iot_device.dart';

/// 传感器数据监控页面
/// 显示传感器数据的图表和实时监控信息
class SensorMonitorScreen extends StatefulWidget {
  const SensorMonitorScreen({super.key});

  @override
  State<SensorMonitorScreen> createState() => _SensorMonitorScreenState();
}

class _SensorMonitorScreenState extends State<SensorMonitorScreen> {
  String _selectedDeviceId = '';
  String _selectedDataType = 'temperature';
  int _timeRange = 24; // 时间范围（小时）

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据监控'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              context.read<IoTProvider>().clearSensorData();
            },
            tooltip: '清空数据',
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

          // 获取传感器设备
          final sensorDevices = iotProvider.getDevicesByType('sensor');
          
          if (sensorDevices.isEmpty) {
            return _buildEmptyState();
          }

          // 设置默认选中的设备
          if (_selectedDeviceId.isEmpty && sensorDevices.isNotEmpty) {
            _selectedDeviceId = sensorDevices.first.id;
          }

          return Column(
            children: [
              // 控制面板
              _buildControlPanel(sensorDevices),
              
              // 实时数据显示
              _buildRealTimeData(iotProvider),
              
              // 图表显示
              Expanded(
                child: _buildChart(iotProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel(List<IoTDevice> sensorDevices) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '监控设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 设备选择 - 使用卡片式选择器
                _buildSelectorCard(
                  '设备选择',
                  Icons.devices,
                  _getSelectedDeviceName(sensorDevices),
                  () => _showDeviceSelector(sensorDevices),
                ),
                
                const SizedBox(height: 16),
                
                // 数据类型选择 - 使用芯片选择器
                _buildDataTypeSelector(),
                
                const SizedBox(height: 16),
                
                // 时间范围选择 - 使用分段控制器
                _buildTimeRangeSelector(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建选择器卡片
  Widget _buildSelectorCard(String title, IconData icon, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数据类型选择器
  Widget _buildDataTypeSelector() {
    final dataTypes = [
      {'key': 'temperature', 'name': '温度', 'icon': Icons.thermostat, 'color': Colors.red},
      {'key': 'humidity', 'name': '湿度', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'key': 'motion', 'name': '运动检测', 'icon': Icons.directions_run, 'color': Colors.green},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '数据类型',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: dataTypes.map((type) {
            final isSelected = _selectedDataType == type['key'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDataType = type['key'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? (type['color'] as Color).withOpacity(0.2)
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? type['color'] as Color
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      type['icon'] as IconData,
                      size: 16,
                      color: isSelected 
                          ? type['color'] as Color
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type['name'] as String,
                      style: TextStyle(
                        color: isSelected 
                            ? type['color'] as Color
                            : Theme.of(context).colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 构建时间范围选择器
  Widget _buildTimeRangeSelector() {
    final timeRanges = [
      {'value': 1, 'label': '1小时', 'icon': Icons.access_time},
      {'value': 6, 'label': '6小时', 'icon': Icons.schedule},
      {'value': 24, 'label': '1天', 'icon': Icons.today},
      {'value': 168, 'label': '7天', 'icon': Icons.date_range},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.timeline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '时间范围',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: timeRanges.map((range) {
              final isSelected = _timeRange == range['value'];
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _timeRange = range['value'] as int;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          range['icon'] as IconData,
                          size: 16,
                          color: isSelected 
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          range['label'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected 
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 获取选中设备名称
  String _getSelectedDeviceName(List<IoTDevice> sensorDevices) {
    if (_selectedDeviceId.isEmpty && sensorDevices.isNotEmpty) {
      return sensorDevices.first.name;
    }
    try {
      final device = sensorDevices.firstWhere(
        (device) => device.id == _selectedDeviceId,
      );
      return device.name;
    } catch (e) {
      return sensorDevices.isNotEmpty ? sensorDevices.first.name : '暂无设备';
    }
  }

  /// 显示设备选择器
  void _showDeviceSelector(List<IoTDevice> sensorDevices) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              '选择设备',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ...sensorDevices.map((device) {
              final isSelected = device.id == _selectedDeviceId;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.sensors,
                      color: isSelected 
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  title: Text(device.name),
                  subtitle: Text('位置: ${device.location}'),
                  trailing: isSelected 
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedDeviceId = device.id;
                    });
                    Navigator.pop(context);
                  },
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 构建实时数据显示
  Widget _buildRealTimeData(IoTProvider provider) {
    final device = provider.getDeviceById(_selectedDeviceId);
    if (device == null) return const SizedBox.shrink();

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
      child: Column(
        children: [
          Text(
            '实时数据',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDataCard(
                  '温度',
                  '${device.data['temperature']?.toStringAsFixed(1) ?? '--'}°C',
                  Icons.thermostat,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDataCard(
                  '湿度',
                  '${device.data['humidity']?.toStringAsFixed(1) ?? '--'}%',
                  Icons.water_drop,
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDataCard(
                  '运动检测',
                  device.data['motion'] == true ? '检测到' : '无运动',
                  Icons.directions_run,
                  device.data['motion'] == true ? Colors.green : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDataCard(
                  '设备状态',
                  device.isOnline ? '在线' : '离线',
                  Icons.wifi,
                  device.isOnline ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建数据卡片
  Widget _buildDataCard(String label, String value, IconData icon, Color color) {
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
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图表
  Widget _buildChart(IoTProvider provider) {
    final filteredData = _getFilteredSensorData(provider);
    
    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请等待传感器数据更新',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

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
      child: Column(
        children: [
          Text(
            '${_getDataTypeName(_selectedDataType)}趋势图',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatTimeLabel(value, filteredData.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toStringAsFixed(1)}${_getDataUnit(_selectedDataType)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                minX: 0,
                maxX: (filteredData.length - 1).toDouble(),
                minY: _getMinValue(filteredData),
                maxY: _getMaxValue(filteredData),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateSpots(filteredData),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取过滤后的传感器数据
  List<dynamic> _getFilteredSensorData(IoTProvider provider) {
    final now = DateTime.now();
    final cutoffTime = now.subtract(Duration(hours: _timeRange));
    
    return provider.sensorData
        .where((data) {
          return data.deviceId == _selectedDeviceId &&
                 data.timestamp.isAfter(cutoffTime) &&
                 _matchesDataType(data);
        })
        .toList();
  }

  /// 检查数据类型是否匹配
  bool _matchesDataType(dynamic data) {
    switch (_selectedDataType) {
      case 'temperature':
        return data.type.toString().contains('temperature');
      case 'humidity':
        return data.type.toString().contains('humidity');
      case 'motion':
        return data.type.toString().contains('motion');
      default:
        return true;
    }
  }

  /// 生成图表数据点
  List<FlSpot> _generateSpots(List<dynamic> data) {
    return data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value.toDouble());
    }).toList();
  }

  /// 获取最小值
  double _getMinValue(List<dynamic> data) {
    if (data.isEmpty) return 0;
    final values = data.map((d) => d.value.toDouble()).toList();
    return values.reduce((a, b) => a < b ? a : b) - 1;
  }

  /// 获取最大值
  double _getMaxValue(List<dynamic> data) {
    if (data.isEmpty) return 10;
    final values = data.map((d) => d.value.toDouble()).toList();
    return values.reduce((a, b) => a > b ? a : b) + 1;
  }

  /// 格式化时间标签
  String _formatTimeLabel(double value, int totalPoints) {
    if (totalPoints == 0) return '';
    
    final index = value.toInt();
    if (index >= totalPoints) return '';
    
    final now = DateTime.now();
    final time = now.subtract(Duration(hours: _timeRange - (index * _timeRange ~/ totalPoints)));
    
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 获取数据类型名称
  String _getDataTypeName(String type) {
    switch (type) {
      case 'temperature':
        return '温度';
      case 'humidity':
        return '湿度';
      case 'motion':
        return '运动检测';
      default:
        return '数据';
    }
  }

  /// 获取数据单位
  String _getDataUnit(String type) {
    switch (type) {
      case 'temperature':
        return '°C';
      case 'humidity':
        return '%';
      case 'motion':
        return '';
      default:
        return '';
    }
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sensors_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            '暂无传感器设备',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先添加传感器设备',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
