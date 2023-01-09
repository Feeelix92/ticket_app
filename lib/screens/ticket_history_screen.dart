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
  const TicketHistory({Key? key, required this.tracking})
      : super(key: key);

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
            return Container(
              height: 120,
              child: Center(child: TicketBox(ticket: futureTicket[index])),
            );
          }
      );
    }

    return const Text('TicketHistory');

  }
}

class TicketBox extends StatelessWidget {
  final Ticket ticket;

  const TicketBox({
    Key? key,
    required this.ticket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>TicketMapScreen(ticket: ticket)));
    },
      child: Expanded(
        child: Card(
          child: Padding(
              padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children : [Column(
                mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TicketText(text: 'Ticket-ID: ${ticket.id}'),
                TicketText(text: 'Datum: ${DateTime.parse(ticket.startTime).day}.${DateTime.parse(ticket.startTime).month}.${DateTime.parse(ticket.startTime).year}'),
                const Spacer(),
                TicketText(text: 'Uhrzeit: ${DateTime.parse(ticket.startTime).hour}:${DateTime.parse(ticket.startTime).minute > 10 ? DateTime.parse(ticket.startTime).minute :  DateTime.parse(ticket.startTime).minute.toString().padLeft(2, '0') }'),
                const Spacer(),
                TicketText(text: 'Endzeit: ${DateTime.parse(ticket.endTime ?? "2012-02-27 00:00:00").hour}:${DateTime.parse(ticket.endTime ?? "2012-02-27 00:00:00").minute}'),
              ]
              ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                QrImage(
                data:
                'Test',
                    gapless: true,
                    version: QrVersions.auto,
                    size: 70,
                    foregroundColor: Colors.black,
                    //embeddedImage: const AssetImage('assets/images/thm.png'),
                    //embeddedImageStyle: QrEmbeddedImageStyle(
                    //size: const Size(80,80),
                    //),
                    errorStateBuilder: (cxt, err) {
                      return const Center(
                        child: Text(
                          "Etwas läuft schief...",
                          textAlign: TextAlign.center,
                        ),
                      );
                    }),
                      TicketText(text: 'Preis: 9,99€')
                    ]
                ),
      ]
          )
        ),
        ),
      ),
    );
  }
}
