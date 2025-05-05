import 'package:flutter/material.dart';
import 'vehicles.dart';
import 'driver.dart';
import 'booking.dart';
import 'bookingexpense.dart';
import 'report.dart';
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          height: 300,
          width: 300,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: ()=>
                {
                Navigator.of(context).push(
                MaterialPageRoute(
                builder: (context) => const VehiclePage(),
                ),
                ),
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(290, 48),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),                        // You can add more properties to customize other aspects of the button
                ),
                child: const Text(
                  'Vehicles',
                  style: TextStyle(fontSize: 18,fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 5,),
              ElevatedButton(
                onPressed: ()=>
                {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DriverPage(),
                    ),
                  ),
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(290, 48),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),                        // You can add more properties to customize other aspects of the button
                ),
                child: const Text(
                  'Drivers',
                  style: TextStyle(fontSize: 18,fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 5,),
              ElevatedButton(
                onPressed: ()=>{
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BookingPage(),
                    ),
                  ),
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(290, 48),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),                        // You can add more properties to customize other aspects of the button
                ),
                child: const Text(
                  'Bookings',
                  style: TextStyle(fontSize: 18,fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 5,),
              ElevatedButton(
                onPressed: ()=>
                {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const BookingExpensePage(),
                    ),
                  ),
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(290, 48),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),                        // You can add more properties to customize other aspects of the button
                ),
                child: const Text(
                  'Expenses',
                  style: TextStyle(fontSize: 18,fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 5,),
              ElevatedButton(
                onPressed: ()=>
                {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookingReportScreen(),
                    ),
                  ),
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(290, 48),
                  ),
                  backgroundColor: MaterialStateProperty.all(Colors.lightBlue),                        // You can add more properties to customize other aspects of the button
                ),
                child: const Text(
                  'Report',
                  style: TextStyle(fontSize: 18,fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
