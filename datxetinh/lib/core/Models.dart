import 'package:flutter/material.dart';

class Station {
  final String id;
  final String name;

  Station({
    required this.id,
    required this.name,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Trip {
  final String id;
  final String source;
  final String destination;

  final String? sourceStationId;
  final String? destinationStationId;
  final Station? sourceStation; // Khôi phục nếu cần
  final Station? destinationStation; // Khôi phục nếu cần
  final String departureTime;
  final String? departureDate;
  final int price;
  final int duration;
  final String busType;
  final String operator;
  final String operatorType;
  final List<String> amenities;
  final double rating;
  final double rankScore;
  final int availableSeats;
  final String recommendation;

  String get startStation => sourceStation?.name ?? source;
  String get endStation => destinationStation?.name ?? destination;

  Trip({
    required this.id,
    required this.source,
    required this.destination,
    this.sourceStationId,
    this.destinationStationId,
    this.sourceStation,
    this.destinationStation,
    required this.departureTime,
    this.departureDate,
    required this.price,
    required this.duration,
    required this.busType,
    required this.operator,
    required this.operatorType,
    required this.amenities,
    required this.rating,
    this.rankScore = 0.0,
    this.availableSeats = 40,
    required this.recommendation,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          DateTime.now().toString(),
          source: json['source']?.toString() ?? '',
          destination: json['destination']?.toString() ?? '',
          sourceStationId: json['source_station_id']?.toString(),
          destinationStationId: json['destination_station_id']?.toString(),
          sourceStation: json['source_station'] != null
          ? Station.fromJson(
              {'id': json['source_station_id'], 'name': json['source_station']})
          : null,
      destinationStation: json['destination_station'] != null
          ? Station.fromJson({
              'id': json['destination_station_id'],
              'name': json['destination_station']
            })
          : null,
      departureTime: json['departure_time']?.toString() ?? '',
      departureDate: json['departure_date']?.toString(),
      price: json['price'] != null
          ? int.tryParse(json['price'].toString()) ?? 0
          : 0,
      duration: json['duration'] != null
          ? int.tryParse(json['duration'].toString()) ?? 0
          : 0,
      busType: json['bus_type']?.toString() ?? '',
      operator: json['operator']?.toString() ?? '',
      operatorType: json['operator_type']?.toString() ?? '',
      amenities:
          json['amenities'] != null ? List<String>.from(json['amenities']) : [],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString()) ?? 0.0
          : 0.0,
      rankScore: json['rank_score'] != null
          ? double.tryParse(json['rank_score'].toString()) ?? 0.0
          : 0.0,
      availableSeats: json['available_seats'] != null
          ? int.tryParse(json['available_seats'].toString()) ?? 40
          : 40,
      recommendation: json['recommendation']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'destination': destination,
      'source_station_id': sourceStationId,
      'destination_station_id': destinationStationId,
      'source_station': sourceStation?.name,
      'destination_station': destinationStation?.name,
      'departure_time': departureTime,
      'departure_date': departureDate,
      'price': price,
      'duration': duration,
      'bus_type': busType,
      'operator': operator,
      'operator_type': operatorType,
      'amenities': amenities,
      'rating': rating,
      'rank_score': rankScore,
      'available_seats': availableSeats,
      'recommendation': recommendation,
    };
  }
}

class Ticket {
  final String id;
  final String userId;
  final String tripId;
  final List<int> seats;
  final Trip? trip;
  final String status;

  Ticket({
    required this.id,
    required this.userId,
    required this.tripId,
    required this.seats,
    this.trip,
    required this.status,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          DateTime.now().toString(),
      userId: json['userId']?.toString() ?? '',
      tripId: json['tripId'] is String
          ? json['tripId']
          : json['tripId']?['_id']?.toString() ?? '',
      seats: json['seats'] != null
          ? List<int>.from(json['seats'].map((x) => int.parse(x.toString())))
          : [],
      trip: json['tripId'] is Map<String, dynamic>
          ? Trip.fromJson(json['tripId'])
          : null,
      status: json['status']?.toString() ?? 'confirmed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'tripId': tripId,
      'seats': seats,
      'trip': trip?.toJson(),
      'status': status,
    };
  }
}
