import 'package:sqflite/sqflite.dart';
import 'vehicles.dart';
import 'driver.dart';
import 'booking.dart';
import 'bookingexpense.dart';

class DBHandler {
  DBHandler._privateConstructor();
  Database? _database;
  static DBHandler instance = DBHandler._privateConstructor();

  Future<Database> get database async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  Future<Database> initializeDatabase() async {
    String dbPath = await getDatabasesPath();
    dbPath = "$dbPath/AppDatabase.db";
    Database db = await openDatabase(dbPath, version: 1, onCreate: _createDB);
    return db;
  }

  _createDB(Database db, int v) async {
    await _createVehicleTable(db);
    await _createDriverTable(db);
    await _createBookingTable(db);
    await _createBookingExpenseTable(db); // Create the BookingExpense table
  }

  Future<void> _createVehicleTable(Database db) async {
    await db.execute('''
      CREATE TABLE Vehicle(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        make TEXT,
        model TEXT,
        color TEXT,
        year INTEGER,
        price REAL
      )
    ''');
  }

  Future<void> _createDriverTable(Database db) async {
    await db.execute('''
      CREATE TABLE Driver(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        licensenumber TEXT,
        phonenumber INTEGER,
        availability TEXT,
        assignedVehicleId INTEGER,
        FOREIGN KEY (assignedVehicleId) REFERENCES Vehicle (ID)
      )
    ''');
  }

  Future<void> _createBookingTable(Database db) async {
    await db.execute('''
      CREATE TABLE Booking(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        driverId INTEGER,
        vehicleId INTEGER,
        startTime TEXT,
        endTime TEXT,
        totalCost REAL,
        FOREIGN KEY (driverId) REFERENCES Driver (ID),
        FOREIGN KEY (vehicleId) REFERENCES Vehicle (ID)
      )
    ''');
  }

  Future<void> _createBookingExpenseTable(Database db) async {
    await db.execute('''
      CREATE TABLE BookingExpense(
        ID INTEGER PRIMARY KEY AUTOINCREMENT,
        bookingId INTEGER,
        expenseType TEXT,
        amount REAL,
        FOREIGN KEY (bookingId) REFERENCES Booking (ID)
      )
    ''');
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    Database db = await database;
    int rowId = await db.insert('Vehicle', vehicle.toMap());
    return rowId;
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    Database db = await database;
    return await db.update('Vehicle', vehicle.toMap(), where: 'ID = ?', whereArgs: [vehicle.id]);
  }

  Future<int> deleteVehicle(int id) async {
    Database db = await database;
    return await db.delete('Vehicle', where: 'ID = ?', whereArgs: [id]);
  }

  Future<List<Vehicle>> getAllVehicle() async {
    Database db = await database;
    List<Map<String, dynamic>> rows = await db.query('Vehicle');
    List<Vehicle> vehicleList = rows.map(
          (e) => Vehicle(
        id: e["ID"],
        make: e["make"],
        model: e["model"],
        color: e["color"],
        year: e["year"],
        price: e["price"],
      ),
    ).toList();
    return vehicleList;
  }

  Future<int> insertDriver(Driver driver) async {
    Database db = await database;
    int rowId = await db.insert('Driver', driver.toMap());
    return rowId;
  }

  Future<int> updateDriver(Driver driver) async {
    Database db = await database;
    return await db.update('Driver', driver.toMap(), where: 'ID = ?', whereArgs: [driver.id]);
  }

  Future<int> deleteDriver(int id) async {
    Database db = await database;
    return await db.delete('Driver', where: 'ID = ?', whereArgs: [id]);
  }

  Future<List<Driver>> getAllDriver() async {
    Database db = await database;
    List<Map<String, dynamic>> rows = await db.query('Driver');
    List<Driver> driverList = rows.map(
          (e) => Driver(
        id: e["ID"],
        name: e["name"],
        email: e["email"],
        phonenumber: e["phonenumber"],
        licensenumber: e["licensenumber"],
        availability: e["availability"],
        assignedVehicleId: e["assignedVehicleId"],
      ),
    ).toList();
    return driverList;
  }

  Future<int> insertBooking(Booking booking) async {
    Database db = await database;
    int rowId = await db.insert('Booking', booking.toMap());
    return rowId;
  }

  Future<int> updateBooking(Booking booking) async {
    Database db = await database;
    return await db.update('Booking', booking.toMap(), where: 'ID = ?', whereArgs: [booking.id]);
  }

  Future<int> deleteBooking(int id) async {
    Database db = await database;
    return await db.delete('Booking', where: 'ID = ?', whereArgs: [id]);
  }

  Future<List<Booking>> getAllBookings() async {
    Database db = await database;
    List<Map<String, dynamic>> rows = await db.query('Booking');
    List<Booking> bookingList = rows.map(
          (e) => Booking(
        id: e["ID"],
        driverId: e["driverId"],
        vehicleId: e["vehicleId"],
        startTime: DateTime.parse(e["startTime"]),
        endTime: DateTime.parse(e["endTime"]),
        totalCost: e["totalCost"],
      ),
    ).toList();
    return bookingList;
  }

  Future<int> insertBookingExpense(BookingExpense bookingExpense) async {
    Database db = await database;
    int rowId = await db.insert('BookingExpense', bookingExpense.toMap());
    return rowId;
  }

  Future<int> updateBookingExpense(BookingExpense bookingExpense) async {
    Database db = await database;
    return await db.update('BookingExpense', bookingExpense.toMap(), where: 'ID = ?', whereArgs: [bookingExpense.id]);
  }

  Future<int> deleteBookingExpense(int id) async {
    Database db = await database;
    return await db.delete('BookingExpense', where: 'ID = ?', whereArgs: [id]);
  }

  Future<List<BookingExpense>> getAllBookingExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> rows = await db.query('BookingExpense');
    List<BookingExpense> bookingExpenseList = rows.map(
          (e) => BookingExpense(
        id: e["ID"],
        bookingId: e["bookingId"],
        expenseType: e["expenseType"],
        amount: e["amount"],
      ),
    ).toList();
    return bookingExpenseList;
  }


  Future<List<Map<String, dynamic>>> getBookingReport() async {
    Database db = await database;
    return await db.rawQuery('''
    SELECT Booking.ID as bookingId, Driver.name as driverName, Vehicle.make as vehicleMake,
    Booking.startTime, Booking.endTime, Booking.totalCost, BookingExpense.expenseType, BookingExpense.amount
    FROM Booking
    LEFT JOIN Driver ON Booking.driverId = Driver.ID
    LEFT JOIN Vehicle ON Booking.vehicleId = Vehicle.ID
    LEFT JOIN BookingExpense ON Booking.ID = BookingExpense.bookingId
  ''');
  }



}

