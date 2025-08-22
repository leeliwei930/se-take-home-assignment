import 'dart:async';

import 'package:flutter/material.dart';

class JobTimer extends StatefulWidget {
  const JobTimer({super.key, required this.endTime});
  final DateTime endTime;

  @override
  State<JobTimer> createState() => _JobTimerState();
}

class _JobTimerState extends State<JobTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    int totalSeconds = duration.inSeconds;
    if (totalSeconds < 0) totalSeconds = 0;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final hoursStr = hours.toString().padLeft(2, '0');
    final minutesStr = minutes.toString().padLeft(2, '0');
    final secondsStr = seconds.toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.endTime.difference(DateTime.now());
    return Text(
      _formatDuration(remaining),
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}
