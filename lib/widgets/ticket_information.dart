import 'package:flutter/material.dart';
import 'package:ticket_app/widgets/qr.dart';
import 'package:ticket_app/widgets/ticket_text.dart';

class TicketInformation extends StatefulWidget {
  const TicketInformation({
    Key? key,
    required String ticketHolderName,
    required String ticketId,
    required String ticketDate,
    required String ticketTime,
    required String longitude,
    required String latitude,
    required String address,
  }) :  _ticketHolderName = ticketHolderName, _ticketId = ticketId, _ticketDate = ticketDate, _ticketTime = ticketTime, _longitude = longitude, _latitude = latitude, _address = address, super(key: key);

  final String _ticketHolderName;
  final String _ticketId;
  final String _ticketDate;
  final String _ticketTime;
  final String _longitude;
  final String _latitude;
  final String _address;

  @override
  State<TicketInformation> createState() => _TicketInformationState();
}

class _TicketInformationState extends State<TicketInformation> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TicketText(text: widget._ticketHolderName,),
            TicketText(text: 'Ticket-ID: ${widget._ticketId}'),
            TicketText(text: 'Datum: ${widget._ticketDate}'),
            TicketText(text: 'Uhrzeit: ${widget._ticketTime}'),
            Visibility(
              visible: widget._longitude != "",
              child: QRCode(
                  firebaseId: widget._ticketId,),
            ),
          ],
        ),
      ),
    );
  }
}


