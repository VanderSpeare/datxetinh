import 'package:flutter/material.dart';
import '/../../core/Constants.dart';
import '/../../core/Models.dart';
import '/../../widgets/CustomButton.dart';
import '/../../widgets/CustomCard.dart';
import 'package:intl/intl.dart'; // Để định dạng giá tiền

class TripDetail extends StatelessWidget {
  const TripDetail({super.key});

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)!.settings.arguments as Trip;

    // Định dạng giá tiền với dấu phân cách hàng nghìn
    final numberFormat = NumberFormat("#,##0", "vi_VN");

    // Chuyển đổi thời gian di chuyển từ phút sang giờ + phút
    String formatDuration(int? minutes) {
      if (minutes == null) return 'Không có thông tin';
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (hours == 0) return '$remainingMinutes phút';
      return '$hours giờ $remainingMinutes phút';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết chuyến đi',
          style: TextStyle(
            fontSize: Constants.fontSizeLarge,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Constants.defaultPadding),
        child: SingleChildScrollView(
          child: CustomCard(
            child: Padding(
              padding: EdgeInsets.all(Constants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề chính: Điểm đi - Điểm đến
                  Text(
                    '${trip.sourceStation?.name ?? trip.source ?? "Không có thông tin"} đến ${trip.destinationStation?.name ?? trip.destination ?? "Không có thông tin"}',
                    style: TextStyle(
                      fontSize: Constants.fontSizeLarge,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  SizedBox(height: Constants.defaultPadding),

                  // Thông tin bến xe
                  Text(
                    'Thông tin bến xe',
                    style: TextStyle(
                      fontSize: Constants.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: Constants.defaultPadding / 2),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Bến đi',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      trip.sourceStation?.name ??
                          trip.source ??
                          "Không có thông tin",
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Bến đến',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      trip.destinationStation?.name ??
                          trip.destination ??
                          "Không có thông tin",
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  Divider(),

                  // Thông tin chuyến đi
                  Text(
                    'Thông tin chuyến đi',
                    style: TextStyle(
                      fontSize: Constants.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: Constants.defaultPadding / 2),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Hãng xe',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${trip.operator ?? "N/A"} (${trip.operatorType ?? "N/A"})',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Giờ khởi hành',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${trip.departureTime ?? "N/A"} ${trip.departureDate != null ? "(${trip.departureDate})" : "(Ngày không xác định)"}',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Thời gian di chuyển',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      formatDuration(trip.duration),
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Loại xe',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      trip.busType ?? 'Không có thông tin',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Tiện nghi',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      trip.amenities != null && trip.amenities!.isNotEmpty
                          ? trip.amenities!.join(", ")
                          : 'Không có tiện nghi',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  Divider(),

                  // Thông tin giá và đánh giá
                  Text(
                    'Giá vé và đánh giá',
                    style: TextStyle(
                      fontSize: Constants.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: Constants.defaultPadding / 2),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Giá vé',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      trip.price != null
                          ? '${numberFormat.format(trip.price)} VND'
                          : 'Không có thông tin',
                      style: TextStyle(
                        fontSize: Constants.fontSizeMedium,
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Đánh giá',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: Constants.fontSizeMedium,
                        ),
                        SizedBox(width: 4),
                        Text(
                          trip.rating != null
                              ? trip.rating!.toStringAsFixed(1)
                              : 'N/A',
                          style: TextStyle(fontSize: Constants.fontSizeMedium),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Số ghế trống',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      trip.availableSeats?.toString() ?? 'N/A',
                      style: TextStyle(fontSize: Constants.fontSizeMedium),
                    ),
                  ),
                  Divider(),

                  // Khuyến nghị
                  if (trip.recommendation != null &&
                      trip.recommendation.isNotEmpty) ...[
                    Text(
                      'Khuyến nghị',
                      style: TextStyle(
                        fontSize: Constants.fontSizeMedium,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: Constants.defaultPadding / 2),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        trip.recommendation!,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: Constants.fontSizeMedium,
                        ),
                      ),
                    ),
                    Divider(),
                  ],

                  // Nút đặt vé
                  SizedBox(height: Constants.defaultPadding),
                  CustomButton(
                    text: 'Đặt vé ngay',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/booking',
                        arguments: trip,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
