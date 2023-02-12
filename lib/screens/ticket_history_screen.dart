import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ticket_app/colors.dart';
import 'package:ticket_app/screens/ticket_map_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/ticket.dart';
import '../widgets/ticket_text.dart';
import '../models/tracking.dart';

class TicketHistory extends StatefulWidget {
  const TicketHistory({Key? key}) : super(key: key);

  @override
  State<TicketHistory> createState() => _TicketHistoryState();
}

class _TicketHistoryState extends State<TicketHistory> {
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(value: "1", child: Text("Januar")),
      const DropdownMenuItem(value: "2", child: Text("Februar")),
      const DropdownMenuItem(value: "3", child: Text("März")),
      const DropdownMenuItem(value: "4", child: Text("April")),
      const DropdownMenuItem(value: "5", child: Text("Mai")),
      const DropdownMenuItem(value: "6", child: Text("Juni")),
      const DropdownMenuItem(value: "7", child: Text("Juli")),
      const DropdownMenuItem(value: "8", child: Text("August")),
      const DropdownMenuItem(value: "9", child: Text("September")),
      const DropdownMenuItem(value: "10", child: Text("Oktober")),
      const DropdownMenuItem(value: "11", child: Text("November")),
      const DropdownMenuItem(value: "12", child: Text("Dezember")),
    ];
    return menuItems;
  }

  String selectedValue = DateTime.now().month.toString();
  var ticketHelper = TicketDatabaseHelper();
  late List futureTicket;
  late int futureTicketsFiltered;
  late List futureTicketsFilteredList;
  bool finish = false;
  bool visibilityController = true;
  double totalPrice = 0.00;

  _getTickets() async {
    var list = await ticketHelper.tickets();
    futureTicket = list;
    _filterTickets();
    sumTicketPrice();
    setState(() {
      finish = true;
    });
  }

  _filterTickets() {
    futureTicketsFiltered = futureTicket
        .where((t) =>
            DateTime.parse(t.startTime).month.toString() == selectedValue)
        .length;

    futureTicketsFilteredList = futureTicket
        .where((t) =>
            DateTime.parse(t.startTime).month.toString() == selectedValue)
        .toList();
  }

  sumTicketPrice() {
    var fTFiltered = futureTicket.where(
        (t) => DateTime.parse(t.startTime).month.toString() == selectedValue);

    if (fTFiltered.isNotEmpty) {
      setState(() {
        totalPrice = 0.00;
        totalPrice = fTFiltered.fold(0, (sum, item) => sum + item.ticketPrice);
        if(totalPrice >= 49.0){
          totalPrice = 49.0;
        }
      });
    } else {
      setState(() {
        totalPrice = 0.00;
      });
    }
  }

  @override
  initState() {
    super.initState();
    _getTickets();
  }

  @override
  Widget build(BuildContext context) {
    if (finish) {
      return Consumer<Tracking>(builder: (context, trackingService, child) {
        return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TicketText(text: 'Abrechnungzeitraum:'),
                    Expanded(
                        child: DropdownButton(
                            value: selectedValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValue = newValue!;
                              });
                              _filterTickets();
                              sumTicketPrice();
                            },
                            items: dropdownItems)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    const TicketText(text: 'Abrechnungsbetrag:'),
                      TicketText(text: '${totalPrice.toStringAsFixed(2)} €'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: futureTicketsFiltered > 0
                ? ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: futureTicketsFilteredList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (futureTicketsFilteredList[index].ticketPrice !=
                          null) {
                        visibilityController = true;
                        return Visibility(
                          visible: visibilityController,
                          child: FractionallySizedBox(
                            child: Center(
                                child: TicketBox(
                                    ticket: futureTicketsFilteredList[index])),
                          ),
                        );
                      } else {
                        visibilityController = false;
                        return Visibility(
                          visible: visibilityController,
                          child: FractionallySizedBox(
                            child: Center(
                                child: TicketBox(
                                    ticket: futureTicketsFilteredList[index])),
                          ),
                        );
                      }
                    })
                : Center(
                    child: Column(
                    children: [
                      Icon(
                        Icons.train,
                        color: primaryColor,
                        size: 120,
                      ),
                      const Text('In diesem Monat bist du nicht gefahren.')
                      ],
                    )),
          ],
        );
      });
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
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                                    softWrap: true,
                                  ),
                                  TicketText(
                                      text:
                                          'Datum: ${DateTime.parse(widget.ticket.startTime).day}.${DateTime.parse(widget.ticket.startTime).month}.${DateTime.parse(widget.ticket.startTime).year}'),
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
                                    softWrap: true,
                                  ),
                                  TicketText(
                                      text:
                                          'Startzeit: ${DateTime.parse(widget.ticket.startTime).hour}:${DateTime.parse(widget.ticket.startTime).minute > 10 ? DateTime.parse(widget.ticket.startTime).minute : DateTime.parse(widget.ticket.startTime).minute.toString().padLeft(2, '0')}'),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Endbahnhof: ${widget.ticket.endStation}',
                                        softWrap: true,

                                      ),TicketText(
                                          text:
                                              'Endzeit: ${DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").hour}:${DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").minute > 10 ? DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").minute : DateTime.parse(widget.ticket.endTime ?? "2012-02-27 00:00:00").minute.toString().padLeft(2, '0')}'),
                                    ],
                                  ),
                                ),
                              ]),
                        ),
                      ]),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
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
}),                      TicketText(
                          text:
                              'Preis: ${widget.ticket.ticketPrice?.toStringAsFixed(2)} €')
                    ],
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
