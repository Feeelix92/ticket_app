import 'package:flutter/material.dart';
import 'package:ticket_app/screens/ticket_map_screen.dart';
import 'package:ticket_app/widgets/qr.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/ticket.dart';
import '../widgets/ticket_information.dart';
import '../widgets/ticket_text.dart';

import '../models/tracking.dart';

class TicketHistory extends StatefulWidget {
  final Tracking tracking;

  const TicketHistory({Key? key, required this.tracking}) : super(key: key);

  @override
  State<TicketHistory> createState() => _TicketHistoryState();
}

class _TicketHistoryState extends State<TicketHistory> {
  var ticketHelper = TicketDatabaseHelper();
  late List futureTicket;
  bool finish = false;

  _getTickets() async {
    var list = await ticketHelper.tickets();
    futureTicket = list;
    setState(() {
      finish = true;
    });
  }

  @override
  initState() {
    super.initState();
    _getTickets();
  }

  @override
  Widget build(BuildContext context) {
    if (finish) {
      return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: futureTicket.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              height: 278,
              child: Center(child: TicketBox(ticket: futureTicket[index])),
            );
          });
    }

    return const Text('TicketHistory');
  }
}

class TicketBox extends StatefulWidget {
  final Ticket ticket;

  const TicketBox({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  State<TicketBox> createState() => _TicketBoxState();
}

class _TicketBoxState extends State<TicketBox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => TicketMapScreen(ticket: widget.ticket)));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TicketText(
                          text: 'Ticket-ID: ${widget.ticket.firebaseId}'),
                      TicketText(
                          text:
                              'Datum: ${DateTime.parse(widget.ticket.startTime).day}.${DateTime.parse(widget.ticket.startTime).month}.${DateTime.parse(widget.ticket.startTime).year}'),
                    ],
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TicketText(
                          text: 'Startbahnhof: ${widget.ticket.startStation}'),
                      TicketText(
                          text:
                              'Startzeit: ${DateTime.parse(widget.ticket.startTime).hour}:${DateTime.parse(widget.ticket.startTime).minute > 10 ? DateTime.parse(widget.ticket.startTime).minute : DateTime.parse(widget.ticket.startTime).minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TicketText(
                          text: 'Endbahnhof: ${widget.ticket.endStation}'),
                      TicketText(
                          text:
                              'Endzeit: ${DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").hour}:${DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").minute > 10 ? DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").minute : DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").minute.toString().padLeft(2, '0')}'),
                    ],
                  ),
                ]),
              ),
              Row(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TicketText(text: 'Preis: ${widget.ticket.ticketPrice} €')
                  ],
                ),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Column(children: [
                  QrImage(
                      data: '${widget.ticket.firebaseId}',
                      gapless: true,
                      version: QrVersions.auto,
                      size: 100,
                      foregroundColor: Colors.black,
                      errorStateBuilder: (cxt, err) {
                        return const Center(
                          child: Text(
                            "Etwas läuft schief...",
                            textAlign: TextAlign.center,
                          ),
                        );
                      })
                ])
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
