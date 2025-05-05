import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'DBhandler.dart';

class Booking {
  int? id;
  int driverId;
  int vehicleId;
  DateTime startTime;
  DateTime endTime;
  double totalCost;

  Booking({
    this.id,
    required this.driverId,
    required this.vehicleId,
    required this.startTime,
    required this.endTime,
    required this.totalCost,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "ID": id,
      "driverId": driverId,
      "vehicleId": vehicleId,
      "startTime": startTime.toUtc().toIso8601String(),
      "endTime": endTime.toUtc().toIso8601String(),
      "totalCost": totalCost,
    };
  }
}

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late TextEditingController totalCostController;

  List<int> driverIds = [];
  List<int> vehicleIds = [];

  int? selectedDriverId;
  int? selectedVehicleId;

  @override
  void initState() {
    super.initState();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    totalCostController = TextEditingController();
    _fetchData();
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    totalCostController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final vehicleList = await DBHandler.instance.getAllVehicle();
    setState(() {
      vehicleIds = vehicleList.map((vehicle) => vehicle.id!).toList();
      selectedVehicleId = vehicleIds.isNotEmpty ? vehicleIds.first : null;
    });

    final driverList = await DBHandler.instance.getAllDriver();
    setState(() {
      driverIds = driverList.map((driver) => driver.id!).toList();
      selectedDriverId = driverIds.isNotEmpty ? driverIds.first : null;
    });
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      hintText: 'Enter $label',
      labelText: 'Enter $label',
      hintStyle: const TextStyle(
        fontSize: 18,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
      ),
      labelStyle: const TextStyle(
        fontSize: 18,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
      ),
      border: const OutlineInputBorder(),
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(const Size(290, 48)),
      backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
    );
  }

  Future<void> _selectDateTime(
    BuildContext context,
    TextEditingController controller, {
    bool isDate = true,
  }) async {
    DateTime picked;
    if (isDate) {
      picked =
          (await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          )) ??
          DateTime.now();
    } else {
      TimeOfDay pickedTime =
          (await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
          )) ??
          TimeOfDay.now();
      picked = DateTime.now().add(
        Duration(hours: pickedTime.hour, minutes: pickedTime.minute),
      );
    }

    if (picked != DateTime.now()) {
      controller.text = DateFormat('yyyy-MM-dd HH:mm').format(picked);
    }
  }

  void _editBooking(BuildContext context, Booking booking) {
    TextEditingController editedStartTimeController = TextEditingController();
    TextEditingController editedEndTimeController = TextEditingController();
    TextEditingController editedTotalCostController = TextEditingController();

    // Set the initial values for the edited booking
    editedStartTimeController.text = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(booking.startTime);
    editedEndTimeController.text = DateFormat(
      'yyyy-MM-dd HH:mm',
    ).format(booking.endTime);
    editedTotalCostController.text = booking.totalCost.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                TextFormField(
                  controller: editedStartTimeController,
                  decoration: buildInputDecoration('Start Time'),
                  onTap:
                      () => _selectDateTime(context, editedStartTimeController),
                ),
                const SizedBox(height: 3),
                TextFormField(
                  controller: editedEndTimeController,
                  decoration: buildInputDecoration('End Time'),
                  onTap:
                      () => _selectDateTime(
                        context,
                        editedEndTimeController,
                        isDate: false,
                      ),
                ),
                const SizedBox(height: 3),
                TextFormField(
                  controller: editedTotalCostController,
                  decoration: buildInputDecoration('Total Cost'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    String errorMessage = '';
                    try {
                      Booking updatedBooking = Booking(
                        id: booking.id,
                        driverId: booking.driverId,
                        vehicleId: booking.vehicleId,
                        startTime: DateTime.parse(
                          editedStartTimeController.text,
                        ),
                        endTime: DateTime.parse(editedEndTimeController.text),
                        totalCost: double.parse(editedTotalCostController.text),
                      );

                      int rowsAffected = await DBHandler.instance.updateBooking(
                        updatedBooking,
                      );

                      if (rowsAffected > 0) {
                        Navigator.of(context).pop();
                        setState(() {});
                      } else {
                        errorMessage = 'Error updating data';
                      }
                    } catch (e) {
                      errorMessage = 'Error: $e';
                    }

                    if (errorMessage.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  style: buildButtonStyle(),
                  child: const Text(
                    'Update',
                    style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteBooking(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this booking?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                int rowsAffected = await DBHandler.instance.deleteBooking(
                  booking.id!,
                );

                if (rowsAffected > 0) {
                  Navigator.of(context).pop();
                  setState(() {});
                } else {
                  // Handle deletion error
                  // ...
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Booking List')),
      body: FutureBuilder<List<Booking>>(
        future: DBHandler.instance.getAllBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Booking booking = snapshot.data![index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver ID: ${booking.driverId}'),
                      Text('Vehicle ID: ${booking.vehicleId}'),
                      Text(
                        'Start Time: ${DateFormat('yyyy-MM-dd HH:mm').format(booking.startTime)}',
                      ),
                      Text(
                        'End Time: ${DateFormat('yyyy-MM-dd HH:mm').format(booking.endTime)}',
                      ),
                      Text('Total Cost: ${booking.totalCost}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editBooking(context, booking);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteBooking(context, booking);
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startTimeController.clear();
          endTimeController.clear();
          totalCostController.clear();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedDriverId,
                        items:
                            driverIds.map((int driverId) {
                              return DropdownMenuItem<int>(
                                value: driverId,
                                child: Text('Driver ID: $driverId'),
                              );
                            }).toList(),
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              selectedDriverId = value;
                            });
                          }
                        },
                        decoration: buildInputDecoration('Driver ID'),
                      ),
                      const SizedBox(height: 3),
                      DropdownButtonFormField<int>(
                        value: selectedVehicleId,
                        items:
                            vehicleIds.map((int vehicleId) {
                              return DropdownMenuItem<int>(
                                value: vehicleId,
                                child: Text('Vehicle ID: $vehicleId'),
                              );
                            }).toList(),
                        onChanged: (int? value) {
                          if (value != null) {
                            setState(() {
                              selectedVehicleId = value;
                            });
                          }
                        },
                        decoration: buildInputDecoration('Vehicle ID'),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: startTimeController,
                        decoration: buildInputDecoration('Start Time'),
                        onTap:
                            () => _selectDateTime(context, startTimeController),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: endTimeController,
                        decoration: buildInputDecoration('End Time'),
                        onTap:
                            () => _selectDateTime(
                              context,
                              endTimeController,
                              isDate: false,
                            ),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: totalCostController,
                        decoration: buildInputDecoration('Total Cost'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String errorMessage = '';
                          try {
                            Booking newBooking = Booking(
                              driverId: selectedDriverId!,
                              vehicleId: selectedVehicleId!,
                              startTime: DateTime.parse(
                                startTimeController.text,
                              ),
                              endTime: DateTime.parse(endTimeController.text),
                              totalCost: double.parse(totalCostController.text),
                            );

                            int rowId = await DBHandler.instance.insertBooking(
                              newBooking,
                            );

                            if (rowId > 0) {
                              Navigator.of(context).pop();
                              setState(() {
                                startTimeController.clear();
                                endTimeController.clear();
                                totalCostController.clear();
                              });
                            } else {
                              errorMessage = 'Error saving data';
                            }
                          } catch (e) {
                            errorMessage = 'Error: $e';
                          }

                          if (errorMessage.isNotEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        style: buildButtonStyle(),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
