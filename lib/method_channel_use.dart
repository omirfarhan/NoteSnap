import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MethodChannelUse extends StatefulWidget {
  const MethodChannelUse({super.key});

  @override
  State<MethodChannelUse> createState() => _MethodChannelUseState();
}

class _MethodChannelUseState extends State<MethodChannelUse> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Used in method channel')),
      body: Column(
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_batteryLevel,style: TextStyle(
                    color: Colors.white
                ),),
                ElevatedButton(
                  onPressed: _getBatteryLevel,
                  child: const Text('Get Batter Percentage',),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}