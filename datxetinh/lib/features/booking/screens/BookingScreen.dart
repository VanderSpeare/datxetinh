import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../../core/Constants.dart';
import '/../../core/Models.dart';
import '/../../widgets/CustomButton.dart';
import '/../../widgets/CustomCard.dart';
import '../providers/BookingProvider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _selectedStartingPoint;
  String? _selectedDestination;
  String _selectedDate = '2025-05-12'; // Default date
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bus Recommendations', style: TextStyle(fontSize: Constants.fontSizeLarge)),
      ),
      body: Padding(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: Column(
          children: [
            // Dropdowns and Search Button
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Select Starting Point'),
                    value: _selectedStartingPoint,
                    isExpanded: true,
                    items: bookingProvider.startingPoints.map((point) {
                      return DropdownMenuItem<String>(
                        value: point,
                        child: Text(point),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStartingPoint = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: Constants.defaultPadding),
                Expanded(
                  child: DropdownButton<String>(
                    hint: Text('Select Destination'),
                    value: _selectedDestination,
                    isExpanded: true,
                    items: bookingProvider.destinations.map((dest) {
                      return DropdownMenuItem<String>(
                        value: dest,
                        child: Text(dest),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDestination = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: Constants.defaultPadding),
            CustomButton(
              text: 'Search Recommendations',
              onPressed: () async {
                if (_selectedStartingPoint == null || _selectedDestination == null) {
                  setState(() {
                    _errorMessage = 'Please select starting point and destination';
                  });
                  return;
                }
                try {
                  await bookingProvider.fetchRecommendations(
                    source: _selectedStartingPoint!,
                    destination: _selectedDestination!,
                    date: _selectedDate,
                    passengers: 1,
                    maxResults: 10,
                  );
                  setState(() {
                    _errorMessage = null;
                  });
                } catch (e) {
                  setState(() {
                    _errorMessage = 'Failed to fetch recommendations: $e';
                  });
                }
              },
            ),
            if (_errorMessage != null || bookingProvider.errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: Constants.defaultPadding / 2),
                child: Text(
                  _errorMessage ?? bookingProvider.errorMessage!,
                  style: TextStyle(
                    color: Constants.errorColor,
                    fontSize: Constants.fontSizeMedium,
                  ),
                ),
              ),
            // Recommendations
            if (bookingProvider.recommendedTrips.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Top Recommendations',
                        style: TextStyle(
                          fontSize: Constants.fontSizeMedium,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: bookingProvider.recommendedTrips.length > 5 ? 5 : bookingProvider.recommendedTrips.length,
                          itemBuilder: (context, index) {
                            final trip = bookingProvider.recommendedTrips[index];
                            return SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: CustomCard(
                                child: ListTile(
                                  title: Text('${trip.source} to ${trip.destination}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Operator: ${trip.operator}'),
                                      Text('Price: ${trip.price} VND'),
                                      Text('Duration: ${trip.duration} min'),
                                      Text('Rating: ${trip.rating.toStringAsFixed(1)}'),
                                      Text('Seats: ${trip.availableSeats}'),
                                      Text('Recommendation: ${trip.recommendation}'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (bookingProvider.recommendedTrips.length > 5)
                        Text(
                          'More Recommendations',
                          style: TextStyle(
                            fontSize: Constants.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (bookingProvider.recommendedTrips.length > 5)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: bookingProvider.recommendedTrips.length - 5,
                          itemBuilder: (context, index) {
                            final trip = bookingProvider.recommendedTrips[index + 5];
                            return CustomCard(
                              child: ListTile(
                                title: Text('${trip.source} to ${trip.destination}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Operator: ${trip.operator}'),
                                    Text('Price: ${trip.price} VND'),
                                    Text('Duration: ${trip.duration} min'),
                                    Text('Rating: ${trip.rating.toStringAsFixed(1)}'),
                                    Text('Seats: ${trip.availableSeats}'),
                                    Text('Recommendation: ${trip.recommendation}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}