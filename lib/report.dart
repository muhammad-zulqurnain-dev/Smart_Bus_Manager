import 'package:flutter/material.dart';
import 'DBhandler.dart';
class BookingReportScreen extends StatefulWidget {
  @override
  _BookingReportScreenState createState() => _BookingReportScreenState();
}

class _BookingReportScreenState extends State<BookingReportScreen> {
  List<Map<String, dynamic>> bookingReport = [];

  @override
  void initState() {
    super.initState();
    loadBookingReport();
  }

  Future<void> loadBookingReport() async {
    List<Map<String, dynamic>> report = await DBHandler.instance.getBookingReport();
    setState(() {
      bookingReport = report;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Report'),
      ),
      body: ListView.builder(
        itemCount: bookingReport.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> booking = bookingReport[index];
          return ListTile(
            title: Text('Driver: ${booking['driverName']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vehicle: ${booking['vehicleMake']}'),
                Text('Start Time: ${booking['startTime']}'),
                Text('End Time: ${booking['endTime']}'),
                Text('Total Cost: ${booking['totalCost']}'),
                Text('Expense Type: ${booking['expenseType']}'),
                Text('Amount: ${booking['amount']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}