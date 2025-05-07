import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '/../../core/services/Api.dart';
import '/../../core/Models.dart';

class TripProvider with ChangeNotifier {
  final Api _api;
  List<Trip> _trips = [];
  Trip? _selectedTrip;
  String? _errorMessage;

  TripProvider(this._api);

  List<Trip> get trips => _trips;
  Trip? get selectedTrip => _selectedTrip;
  String? get errorMessage => _errorMessage;

  Future<void> searchTrips({
    required String source,
    required String destination,
    required String date,
    required int passengers,
    double? maxBudget,
    String? preferredBusType,
    String? operatorType,
    int maxResults = 5,
    required String? token,
  }) async {
    try {
      _errorMessage = null;
      final response = await _api.searchTrips(
        source: source,
        destination: destination,
        date: date,
        passengers: passengers,
        maxBudget: maxBudget,
        preferredBusType: preferredBusType,
        operatorType: operatorType,
        maxResults: maxResults,
        token: token,
      );
      _trips = response.map((tripData) => Trip.fromJson(tripData)).toList();
      notifyListeners();
    } catch (e) {
      developer.log('Search Trips error: $e');
      String error = e.toString().replaceFirst('Exception: ', '');
      if (error.contains('<DOCTYPE html>')) {
        error =
            'Server trả về HTML thay vì JSON. Kiểm tra endpoint API hoặc trạng thái server.';
      }
      _errorMessage = error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchTripById(String id) async {
    try {
      _errorMessage = null;
      _selectedTrip = _trips.firstWhere(
        (trip) => trip.id == id,
        orElse: () => throw Exception(
            'Không tìm thấy chuyến đi trong kết quả tìm kiếm hiện tại'),
      );
      notifyListeners();
    } catch (e) {
      final data = await _api.getTripById(id);
      _selectedTrip = Trip.fromJson(data);
      developer.log('Fetch Trip by ID error: $e');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  void clearSelectedTrip() {
    _selectedTrip = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearTrips() {
    _trips = [];
    _errorMessage = null;
    notifyListeners();
  }
}
