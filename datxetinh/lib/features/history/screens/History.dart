import 'package:datxetinh/features/auth/providers/AuthProvider.dart';
import 'package:datxetinh/features/booking/providers/BookingProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../core/Models.dart';
import '/../../widgets/CustomCard.dart';
import '/../../widgets/CustomButton.dart';
import '/../../core/Constants.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Booking History',
          style: TextStyle(fontSize: Constants.fontSizeLarge),
        ),
      ),
      body: FutureBuilder(
        future: bookingProvider.fetchUserTickets(authProvider.userId ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '${Constants.genericError}: ${snapshot.error}',
                style: TextStyle(
                  color: Constants.errorColor,
                  fontSize: Constants.fontSizeMedium,
                ),
              ),
            );
          }
          if (bookingProvider.tickets.isEmpty) {
            return Center(
              child: Text(
                'No bookings found',
                style: TextStyle(fontSize: Constants.fontSizeMedium),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(Constants.defaultPadding),
            itemCount: bookingProvider.tickets.length,
            itemBuilder: (context, index) {
              final ticket = bookingProvider.tickets[index];
              final trip = ticket.trip;
              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip != null
                          ? '${trip.startStation} to ${trip.endStation}'
                          : 'Trip: Details unavailable',
                      style: TextStyle(
                        fontSize: Constants.fontSizeLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: Constants.defaultPadding / 2),
                    Text(
                      'Ticket ID: ${ticket.id}',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                    Text(
                      trip != null
                          ? 'Departure: ${trip.departureTime}'
                          : 'Departure: N/A',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                    Text(
                      'Seats: ${ticket.seats.join(', ')}',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                    Text(
                      trip != null
                          ? 'Total Price: ${(ticket.seats.length * trip.price).toStringAsFixed(0)} VND'
                          : 'Total Price: N/A',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                    Text(
                      'Status: ${ticket.status}',
                      style: TextStyle(
                        fontSize: Constants.fontSizeMedium,
                        color: ticket.status == 'confirmed'
                            ? Constants.successColor
                            : Constants.errorColor,
                      ),
                    ),
                    SizedBox(height: Constants.defaultPadding / 2),
                    if (ticket.status == 'confirmed')
                      CustomButton(
                        text: 'Cancel Booking',
                        onPressed: () async {
                          try {
                            await bookingProvider.cancelTicket(ticket.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Booking cancelled'),
                                backgroundColor: Constants.successColor,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${Constants.genericError}: $e'),
                                backgroundColor: Constants.errorColor,
                              ),
                            );
                          }
                        },
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}