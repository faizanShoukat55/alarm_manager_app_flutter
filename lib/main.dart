import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void backgroundTask(SendPort sendPort) async {
  const MethodChannel methodChannel = MethodChannel('alarm_plugin');

  // Retrieve the saved alarm time from your app's storage
  final int savedTimestamp = DateTime.now().millisecondsSinceEpoch ~/
      1000; // Retrieve the timestamp from storage

  final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  if (currentTimestamp >= savedTimestamp) {
    // Time to trigger the alarm, show a local notification
    try {
      await methodChannel.invokeMethod('setAlarm', savedTimestamp);
      sendPort.send(true); // Notify the main isolate that the task is done
    } on PlatformException catch (e) {
      print("Error triggering alarm: ${e.message}");
      sendPort.send(false); // Notify the main isolate about the error
    }
  } else {
    sendPort.send(false); // Notify the main isolate that no action was taken
  }
}

void main() async{
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();

    final _methodChannel = MethodChannel('alarm_plugin');

    await AndroidAlarmManager.initialize();

    runApp(MyApp());

    await AndroidAlarmManager.periodic(
      const Duration(minutes: 15), // Set the interval for running the task
      0, // Alarm ID
      backgroundTask,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  } else {
    runApp(MyApp());
    final ReceivePort receivePort = ReceivePort();

    Isolate.spawn(backgroundTask, receivePort.sendPort);

    receivePort.listen((message) {
      if (message == true) {
        print('Background task completed successfully.');
      } else if (message == false) {
        print('Background task encountered an error.');
      }
    });
  }
}

class MyApp extends StatelessWidget {
  final MethodChannel _methodChannel = MethodChannel('alarm_plugin');

  Future<void> setAlarm(DateTime alarmTime) async {
    final timestamp = alarmTime.millisecondsSinceEpoch ~/ 1000;
    try {
      await _methodChannel.invokeMethod('setAlarm', timestamp);
    } on PlatformException catch (e) {
      print("Error setting alarm: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Alarm App'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Show a date picker and set the selected time
              // Call setAlarm with the selected time
            },
            child: Text('Set Alarm'),
          ),
        ),
      ),
    );
  }
}
