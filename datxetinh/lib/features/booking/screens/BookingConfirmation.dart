import 'package:datxetinh/core/Constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/BookingProvider.dart';
import '/../../core/Models.dart';
import '/../../widgets/CustomButton.dart';
import '/../../widgets/CustomCard.dart';

class BookingConfirmation extends StatelessWidget {
  const BookingConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final Ticket? ticket = bookingProvider.recentTicket;

    if (ticket == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Confirmation')),
        body: const Center(child: Text('No booking found')),
      );
    }

    final trip = ticket.trip;

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmation')),
      body: Padding(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: Constants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Constants.defaultPadding),
              Text('Ticket ID: ${ticket.id}'),
              Text(
                trip != null
                    ? 'Trip: ${trip.startStation} to ${trip.endStation}'
                    : 'Trip: Details unavailable',
              ),
              Text('Seats: ${ticket.seats.join(', ')}'),
              Text(
                trip != null
                    ? 'Departure: ${trip.departureTime}'
                    : 'Departure: N/A',
              ),
              Text(
                trip != null
                    ? 'Total Price: ${(ticket.seats.length * trip.price).toStringAsFixed(0)} VND'
                    : 'Total Price: N/A',
              ),
              Text('Status: ${ticket.status}'),
              SizedBox(height: Constants.defaultPadding),
              CustomButton(
                text: 'View Booking History',
                onPressed: () {
                  Navigator.pushNamed(context, Constants.historyRoute);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}