import 'package:flutter/material.dart';

import '../models/tracking.dart';

class TicketHistory extends StatefulWidget {
  final Tracking tracking;
  const TicketHistory({Key? key, required this.tracking})
      : super(key: key);

  @override
  State<TicketHistory> createState() => _TicketHistoryState();
}

class _TicketHistoryState extends State<TicketHistory> {
  @override
  Widget build(BuildContext context) {
    return const Text('TicketHistory');
  }
}
