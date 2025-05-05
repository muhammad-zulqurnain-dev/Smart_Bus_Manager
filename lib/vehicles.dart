import 'package:flutter/material.dart';
import 'DBhandler.dart';

class Vehicle {
  int? id;
  String make, model, color;
  int year;
  double price;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.color,
    required this.year,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "ID": id,
      "make": make,
      "model": model,
      "color": color,
      "year": year,
      "price": price,
    };
  }
}

class VehiclePage extends StatefulWidget {
  const VehiclePage({Key? key}) : super(key: key);

  @override
  _VehiclePageState createState() => _VehiclePageState();
}

class _VehiclePageState extends State<VehiclePage> {
  late TextEditingController makeController;
  late TextEditingController modelController;
  late TextEditingController colorController;
  late TextEditingController yearController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    makeController = TextEditingController();
    modelController = TextEditingController();
    colorController = TextEditingController();
    yearController = TextEditingController();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    makeController.dispose();
    modelController.dispose();
    colorController.dispose();
    yearController.dispose();
    priceController.dispose();
    super.dispose();
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      hintText: 'Enter $label',
      labelText: 'Enter $label',
      hintStyle: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      labelStyle: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
      border: const OutlineInputBorder(),
    );
  }

  ButtonStyle buildButtonStyle() {
    return ButtonStyle(
      minimumSize: MaterialStateProperty.all(
        const Size(290, 48),
      ),
      backgroundColor: MaterialStateProperty.all(Colors.lightBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle List'),
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: DBHandler.instance.getAllVehicle(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No vehicles available.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Vehicle vehicle = snapshot.data![index];
                return ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vehicle ID: ${vehicle.id}'),
                      Text('Make: ${vehicle.make}'),
                      Text('Model: ${vehicle.model}'),
                      Text('Color: ${vehicle.color}'),
                      Text('Year: ${vehicle.year}'),
                      Text('Price: ${vehicle.price}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: makeController..text = vehicle.make,
                                        decoration: buildInputDecoration('Make'),
                                      ),
                                      const SizedBox(height: 3),
                                      TextField(
                                        controller: modelController..text = vehicle.model,
                                        decoration: buildInputDecoration('Model'),
                                      ),
                                      const SizedBox(height: 3),
                                      TextField(
                                        controller: colorController..text = vehicle.color,
                                        decoration: buildInputDecoration('Color'),
                                      ),
                                      const SizedBox(height: 3),
                                      TextField(
                                        controller: yearController..text = vehicle.year.toString(),
                                        decoration: buildInputDecoration('Year'),
                                      ),
                                      const SizedBox(height: 3),
                                      TextField(
                                        controller: priceController..text = vehicle.price.toString(),
                                        decoration: buildInputDecoration('Price'),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          vehicle.make = makeController.text;
                                          vehicle.model = modelController.text;
                                          vehicle.color = colorController.text;
                                          vehicle.year = int.parse(yearController.text);
                                          vehicle.price = double.parse(priceController.text);

                                          int rowsAffected = await DBHandler.instance.updateVehicle(vehicle);

                                          if (rowsAffected > 0) {
                                            Navigator.of(context).pop();
                                            setState(() {});
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
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Deletion'),
                                content: Text('Are you sure you want to delete this vehicle?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      int rowsAffected = await DBHandler.instance.deleteVehicle(vehicle.id!);

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
          makeController.clear();
          modelController.clear();
          colorController.clear();
          yearController.clear();
          priceController.clear();

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      TextField(
                        controller: makeController,
                        decoration: buildInputDecoration('Make'),
                      ),
                      const SizedBox(height: 3),
                      TextField(
                        controller: modelController,
                        decoration: buildInputDecoration('Model'),
                      ),
                      const SizedBox(height: 3),
                      TextField(
                        controller: colorController,
                        decoration: buildInputDecoration('Color'),
                      ),
                      const SizedBox(height: 3),
                      TextField(
                        controller: yearController,
                        decoration: buildInputDecoration('Year'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 3),
                      TextField(
                        controller: priceController,
                        decoration: buildInputDecoration('Price'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          String errorMessage = '';
                          try {
                            Vehicle newVehicle = Vehicle(
                              make: makeController.text,
                              model: modelController.text,
                              color: colorController.text,
                              year: int.parse(yearController.text),
                              price: double.parse(priceController.text),
                            );

                            int rowId = await DBHandler.instance.insertVehicle(newVehicle);

                            if (rowId > 0) {
                              Navigator.of(context).pop();
                              setState(() {
                                makeController.clear();
                                modelController.clear();
                                colorController.clear();
                                yearController.clear();
                                priceController.clear();
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
                          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
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