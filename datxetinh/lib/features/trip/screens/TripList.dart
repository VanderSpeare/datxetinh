import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../trip/providers/TripProvider.dart';
import '/../../core/Constants.dart';
import '/../../widgets/CustomButton.dart';
import '/../../widgets/CustomCard.dart';
import 'package:intl/intl.dart';

class TripList extends StatefulWidget {
  const TripList({super.key});

  @override
  _TripListState createState() => _TripListState();
}

class _TripListState extends State<TripList> {
  final _sourceController = TextEditingController(text: 'Sài Gòn TPHCM');
  final _destinationController = TextEditingController(text: 'Vũng Tàu');
  final _dateController = TextEditingController(text: '12-05-2025');
  final _passengersController = TextEditingController(text: '1');
  final _maxBudgetController = TextEditingController(text: '600000');
  String? _preferredBusType;
  String? _operatorType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchTrips() async {
    if (_sourceController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _passengersController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng điền đầy đủ các trường bắt buộc'),
          backgroundColor: Constants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final tripProvider = Provider.of<TripProvider>(context, listen: false);
      // Convert date from DD-MM-YYYY to DD-MMM-YYYY
      final dateInput = _dateController.text;
      final dateFormatter = DateFormat('dd-MM-yyyy');
      final dateParsed = dateFormatter.parse(dateInput);
      final serverDate = DateFormat('dd-MMM-yyyy').format(dateParsed);

      print('Search request: source=${_sourceController.text}, '
          'destination=${_destinationController.text}, '
          'date=$serverDate, '
          'passengers=${_passengersController.text}, '
          'maxBudget=${_maxBudgetController.text}, '
          'preferredBusType=$_preferredBusType, '
          'operatorType=$_operatorType, '
          'token=null');

      await tripProvider.searchTrips(
        source: _sourceController.text,
        destination: _destinationController.text,
        date: serverDate,
        passengers: int.parse(_passengersController.text),
        maxBudget: _maxBudgetController.text.isEmpty
            ? null
            : double.parse(_maxBudgetController.text),
        preferredBusType: _preferredBusType,
        operatorType: _operatorType,
        token: null,
      );
    } catch (e) {
      print('Search trips error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi tìm kiếm chuyến đi: $e'),
          backgroundColor: Constants.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _dateController.dispose();
    _passengersController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = Provider.of<TripProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Tìm kiếm chuyến đi',
            style: TextStyle(fontSize: Constants.fontSizeLarge)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, Constants.historyRoute);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _sourceController,
                      decoration: InputDecoration(
                        labelText: 'Điểm đi *',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.defaultBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: Constants.defaultPadding),
                    TextFormField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        labelText: 'Điểm đến *',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.defaultBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: Constants.defaultPadding),
                    TextFormField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Ngày đi (DD-MM-YYYY) *',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.defaultBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: Constants.defaultPadding),
                    TextFormField(
                      controller: _passengersController,
                      decoration: InputDecoration(
                        labelText: 'Số hành khách *',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.defaultBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: Constants.defaultPadding),
                    TextFormField(
                      controller: _maxBudgetController,
                      decoration: InputDecoration(
                        labelText: 'Ngân sách tối đa (VND, tùy chọn)',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.defaultBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: Constants.defaultPadding),
                    DropdownButtonFormField<String>(
                      value: _preferredBusType,
                      decoration: InputDecoration(
                        labelText: 'Loại xe (tùy chọn)',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.defaultBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items:
                          ['Sleeper', 'Limousine', 'Standard', 'Minivan', null]
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type ?? 'Bất kỳ'),
                                  ))
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _preferredBusType = value;
                        });
                      },
                    ),
                    SizedBox(height: Constants.defaultPadding),
                    DropdownButtonFormField<String>(
                      value: _operatorType,
                      decoration: InputDecoration(
                        labelText: 'Loại hãng xe (tùy chọn)',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              Constants.defaultBorderRadius),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: ['Small', 'Large', null]
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type ?? 'Bất kỳ'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _operatorType = value;
                        });
                      },
                    ),
                    SizedBox(height: Constants.defaultPadding),
                    if (tripProvider.errorMessage != null)
                      Text(
                        tripProvider.errorMessage!,
                        style: TextStyle(
                          color: Constants.errorColor,
                          fontSize: Constants.fontSizeMedium,
                        ),
                      ),
                    SizedBox(height: Constants.defaultPadding),
                    CustomButton(
                      text: _isLoading
                          ? 'Đang tìm kiếm...'
                          : 'Tìm kiếm chuyến đi',
                      onPressed: _isLoading ? null : _searchTrips,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Constants.defaultPadding),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (tripProvider.trips.isEmpty &&
                  tripProvider.errorMessage == null)
                Center(
                  child: Text(
                    'Không tìm thấy chuyến đi. Vui lòng thử lại với tiêu chí khác.',
                    style: TextStyle(fontSize: Constants.fontSizeMedium),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tripProvider.trips.length,
                  itemBuilder: (context, index) {
                    final trip = tripProvider.trips[index];
                    return CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${trip.sourceStation?.name ?? trip.source} đến ${trip.destinationStation?.name ?? trip.destination}',
                            style: TextStyle(
                              fontSize: Constants.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: Constants.defaultPadding / 2),
                          Text(
                              'Hãng xe: ${trip.operator} (${trip.operatorType})'),
                          Text(
                              'Khởi hành: ${trip.departureTime} (${trip.departureDate ?? "N/A"})'),
                          Text('Thời gian: ${trip.duration} phút'),
                          Text('Giá vé: ${trip.price} VND'),
                          Text('Loại xe: ${trip.busType}'),
                          Text('Tiện nghi: ${trip.amenities.join(", ")}'),
                          Text('Đánh giá: ${trip.rating.toStringAsFixed(1)}'),
                          Text('Số ghế trống: ${trip.availableSeats}'),
                          Text('Đề xuất: ${trip.recommendation}'),
                          SizedBox(height: Constants.defaultPadding / 2),
                          CustomButton(
                            text: 'Xem chi tiết',
                            onPressed: () {
                              Provider.of<TripProvider>(context, listen: false)
                                  .fetchTripById(trip.id);
                              Navigator.pushNamed(
                                context,
                                Constants.tripDetailRoute,
                                arguments: trip,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
