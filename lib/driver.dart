import 'package:flutter/material.dart';
import 'DBHandler.dart';
import 'vehicles.dart';

class Driver {
  int? id;
  String name;
  String email;
  int phonenumber;
  String licensenumber;
  String availability;
  int assignedVehicleId;

  Driver({
    this.id,
    required this.name,
    required this.email,
    required this.phonenumber,
    required this.licensenumber,
    required this.availability,
    required this.assignedVehicleId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "ID": id,
      "name": name,
      "email": email,
      "phonenumber": phonenumber,
      "licensenumber": licensenumber,
      "availability": availability,
      "assignedVehicleId": assignedVehicleId,
    };
  }
}

class DriverPage extends StatefulWidget {
  const DriverPage({Key? key}) : super(key: key);

  @override
  _DriverPageState createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phonenumberController;
  late TextEditingController licensenumberController;
  late TextEditingController availabilityController;
  late TextEditingController assignVehicleController;

  List<Vehicle> vehicles = [];
  List<Driver> drivers = [];
  int? selectedVehicleId;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phonenumberController = TextEditingController();
    licensenumberController = TextEditingController();
    availabilityController = TextEditingController();
    assignVehicleController = TextEditingController();

    _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch the list of vehicles
    final vehicleList = await DBHandler.instance.getAllVehicle();
    setState(() {
      vehicles = vehicleList;
      selectedVehicleId = vehicleList.isNotEmpty ? vehicleList[0].id : null;
    });

    // Fetch the list of drivers
    final driverList = await DBHandler.instance.getAllDriver();
    setState(() {
      drivers = driverList;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phonenumberController.dispose();
    licensenumberController.dispose();
    availabilityController.dispose();
    assignVehicleController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver List')),
      body:
          drivers.isEmpty
              ? const Center(child: Text('No drivers available.'))
              : ListView.builder(
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  Driver driver = drivers[index];
                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver ID: ${driver.id}'),
                        Text('Name: ${driver.name}'),
                        Text('Email: ${driver.email}'),
                        Text('Phone Number: ${driver.phonenumber}'),
                        Text('License Number: ${driver.licensenumber}'),
                        Text('Availability: ${driver.availability}'),
                        Text('Assigned VehicleId: ${driver.assignedVehicleId}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _buildEditDialog(driver);
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return _buildDeleteDialog(driver);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildAddDialog();
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEditDialog(Driver driver) {
    nameController.text = driver.name;
    emailController.text = driver.email;
    phonenumberController.text = driver.phonenumber.toString();
    licensenumberController.text = driver.licensenumber;
    availabilityController.text = driver.availability;
    assignVehicleController.text = driver.assignedVehicleId.toString();

    return AlertDialog(
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: buildInputDecoration('Name'),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: emailController,
              decoration: buildInputDecoration('Email'),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: phonenumberController,
              decoration: buildInputDecoration('Phone Number'),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: licensenumberController,
              decoration: buildInputDecoration('License Number'),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: availabilityController,
              decoration: buildInputDecoration('Availability'),
            ),
            const SizedBox(height: 3),
            DropdownButton<int>(
              value: selectedVehicleId,
              items:
                  vehicles.map((Vehicle vehicle) {
                    return DropdownMenuItem<int>(
                      value: vehicle.id!,
                      child: Text('${vehicle.id}'),
                    );
                  }).toList(),
              onChanged: (int? value) {
                setState(() {
                  selectedVehicleId = value;
                  assignVehicleController.text = value.toString();
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  driver.name = nameController.text;
                  driver.email = emailController.text;
                  driver.phonenumber = int.parse(phonenumberController.text);
                  driver.licensenumber = licensenumberController.text;
                  driver.availability = availabilityController.text;
                  driver.assignedVehicleId = int.parse(
                    assignVehicleController.text,
                  );
                });

                int rowsAffected = await DBHandler.instance.updateDriver(
                  driver,
                );

                if (rowsAffected > 0) {
                  Navigator.of(context).pop();
                  _fetchData(); // Update the data after editing
                } else {
                  // Handle update error
                  // ...
                }
              },
              style: buildButtonStyle(),
              child: const Text(
                'update',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteDialog(Driver driver) {
    return AlertDialog(
      title: const Text('Confirm Deletion'),
      content: const Text('Are you sure you want to delete this driver?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            int rowsAffected = await DBHandler.instance.deleteDriver(
              driver.id!,
            );

            if (rowsAffected > 0) {
              Navigator.of(context).pop();
              _fetchData(); // Update the data after deletion
            } else {
              // Handle deletion error
              // ...
            }
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Widget _buildAddDialog() {
    // Clear text controllers to prevent displaying previous values
    nameController.clear();
    emailController.clear();
    phonenumberController.clear();
    licensenumberController.clear();
    availabilityController.clear();
    assignVehicleController.text = selectedVehicleId?.toString() ?? '';

    return AlertDialog(
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: buildInputDecoration('Name'),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: emailController,
              decoration: buildInputDecoration('Email'),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: phonenumberController,
              decoration: buildInputDecoration('Phone Number'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 3),
            TextField(
              controller: licensenumberController,
              decoration: buildInputDecoration('License Number'),
            ),
            const SizedBox(height: 3),
            TextField(
              controller: availabilityController,
              decoration: buildInputDecoration('Availability'),
            ),
            const SizedBox(height: 3),
            DropdownButton<int>(
              value: selectedVehicleId,
              items:
                  vehicles.map((Vehicle vehicle) {
                    return DropdownMenuItem<int>(
                      value: vehicle.id!,
                      child: Text('${vehicle.id}'),
                    );
                  }).toList(),
              onChanged: (int? value) {
                setState(() {
                  selectedVehicleId = value;
                  assignVehicleController.text = value.toString();
                });
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                String errorMessage = '';
                try {
                  Driver newDriver = Driver(
                    name: nameController.text,
                    email: emailController.text,
                    phonenumber: int.parse(phonenumberController.text),
                    licensenumber: licensenumberController.text,
                    availability: availabilityController.text,
                    assignedVehicleId: int.parse(assignVehicleController.text),
                  );

                  int rowId = await DBHandler.instance.insertDriver(newDriver);

                  if (rowId > 0) {
                    Navigator.of(context).pop();
                    _fetchData(); // Update the data after adding
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
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
