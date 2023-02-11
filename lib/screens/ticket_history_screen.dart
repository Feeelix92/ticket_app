import 'package:flutter/material.dart';
import 'package:ticket_app/colors.dart';
import 'package:ticket_app/screens/ticket_map_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket.dart';
import '../widgets/dropdown.dart';
import '../widgets/ticket_text.dart';

import '../models/tracking.dart';

class TicketHistory extends StatefulWidget {
  const TicketHistory({Key? key}) : super(key: key);

  @override
  State<TicketHistory> createState() => _TicketHistoryState();
}

class _TicketHistoryState extends State<TicketHistory> {
  // @TODO make billingList dynamic
  List<String> billingList = <String>['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];
  var ticketHelper = TicketDatabaseHelper();
  late List futureTicket;
  bool finish = false;
  bool visibilityController = true;

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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TicketText(text: 'Abrechnungzeitraum:'),
                    // @TODO add dynamic date
                    Expanded(child: DynamicDropdownButton(list: billingList)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    TicketText(text: 'Abrechnungsbetrag:'),
                    // @TODO add dynamic amount
                    TicketText(text: '0.00 €'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: futureTicket.length,
                  itemBuilder: (BuildContext context, int index) {
                    if(futureTicket[index].ticketPrice != null){
                      visibilityController = true;
                      return Visibility(
                        visible: visibilityController,
                        child: FractionallySizedBox(

                          child: Center(child: TicketBox(ticket: futureTicket[index])),
                        ),
                      );
                    }else{
                      visibilityController = false;
                      return Visibility(
                        visible: visibilityController,
                        child: FractionallySizedBox(
                          child: Center(child: TicketBox(ticket: futureTicket[index])),
                        ),
                      );
                    }
                  })
          ),
        ],
      );
    }
    return Center(
        child: CircularProgressIndicator(
          color: secondaryColor,
        ));
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
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: secondaryColor,
          ),
          borderRadius: BorderRadius.circular(20.0), //<-- SEE HERE
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
              mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                 'Ticket-ID: ${widget.ticket.firebaseId}',
                            softWrap:true,
                            ),
                            TicketText(
                                text:
                                'Datum: ${DateTime
                                    .parse(widget.ticket.startTime)
                                    .day}.${DateTime
                                    .parse(widget.ticket.startTime)
                                    .month}.${DateTime
                                    .parse(widget.ticket.startTime)
                                    .year}'),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Startbahnhof: ${widget.ticket.startStation}',
                              softWrap:true,),
                            TicketText(
                                text:
                                'Startzeit: ${DateTime
                                    .parse(widget.ticket.startTime)
                                    .hour}:${DateTime
                                    .parse(widget.ticket.startTime)
                                    .minute > 10 ? DateTime
                                    .parse(widget.ticket.startTime)
                                    .minute : DateTime
                                    .parse(widget.ticket.startTime)
                                    .minute
                                    .toString()
                                    .padLeft(2, '0')}'),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Endbahnhof: ${widget.ticket.endStation}',
                              softWrap:true,),
                            TicketText(
                                text:
                                'Endzeit: ${DateTime
                                    .parse(
                                    widget.ticket.endTime ?? "2012-02-27 00:00:00")
                                    .hour}:${DateTime
                                    .parse(
                                    widget.ticket.endTime ?? "2012-02-27 00:00:00")
                                    .minute > 10 ? DateTime
                                    .parse(
                                    widget.ticket.endTime ?? "2012-02-27 00:00:00")
                                    .minute : DateTime
                                    .parse(
                                    widget.ticket.endTime ?? "2012-02-27 00:00:00")
                                    .minute
                                    .toString()
                                    .padLeft(2, '0')}'),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  ]),),

                  Expanded(
                    flex: 2,
                    child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                              }),

                          TicketText(text: 'Preis: ${widget.ticket.ticketPrice} €')
                        ],
                      ),
                ),]
              ),
            ),
          ),
        );
  }
}
