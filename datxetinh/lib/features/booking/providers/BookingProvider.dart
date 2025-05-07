import 'package:flutter/material.dart';
import '/../../core/Models.dart';
import '/../../core/services/Api.dart';

class BookingProvider with ChangeNotifier {
  final Api _api;
  Ticket? _recentTicket;
  String? _errorMessage;
  List<String> _startingPoints = [];
  List<String> _destinations = [];
  List<Trip> _recommendedTrips = [];
  List<Ticket> _tickets = [];
  String? get errorMessage => _errorMessage;
  List<String> get startingPoints => _startingPoints;
  List<String> get destinations => _destinations;
  List<Trip> get recommendedTrips => _recommendedTrips;

  BookingProvider(this._api);

  Ticket? get recentTicket => _recentTicket;

  List<Ticket> get tickets => _tickets;

  Future<void> bookTrip(String tripId, List<int> seats) async {
    try {
      _errorMessage = null;
      final response = await _api.bookTrip(tripId, seats);
      // Fetch trip details to populate ticket.trip
      final tripData = await _api.getTripById(tripId);
      _recentTicket = Ticket(
        id: response['id']?.toString() ?? DateTime.now().toString(),
        userId: response['userId']?.toString() ?? '',
        tripId: tripId,
        seats: seats,
        trip: Trip.fromJson(tripData),
        status: response['status']?.toString() ?? 'confirmed',
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchUserTickets(String userId) async {
    try {
      _errorMessage = null;
      _tickets = await _api.getUserTickets(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelTicket(String ticketId) async {
    try {
      _errorMessage = null;
      await _api.cancelTicket(ticketId);
      final userId = await _api.getUserId();
      if (userId != null) {
        await fetchUserTickets(userId);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearRecentTicket() {
    _recentTicket = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchLocations() async {
    try {
      final response = await _api.getLocations();
      _startingPoints = response['starting_points'].cast<String>();
      _destinations = response['destinations'].cast<String>();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch locations: $e';
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations({
    required String source,
    required String destination,
    required String date,
    required int passengers,
    double? maxBudget,
    String? preferredBusType,
    String? operatorType,
    int maxResults = 10,
  }) async {
    try {
      final response = await _api.recommendTrips(
        source: source,
        destination: destination,
        date: date,
        passengers: passengers,
        maxBudget: maxBudget,
        preferredBusType: preferredBusType,
        operatorType: operatorType,
        maxResults: maxResults,
      );
      _recommendedTrips = response.map((json) => Trip.fromJson(json)).toList();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch recommendations: $e';
      notifyListeners();
    }
  }
}
