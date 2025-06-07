import 'package:by_faith_app/database/database.dart';

class DatabaseProvider {
  static AppDatabase? _dbInstance;

  // Private constructor to prevent direct instantiation
  DatabaseProvider._internal();

  // Static getter to provide the singleton instance of AppDatabase
  static AppDatabase get instance {
    if (_dbInstance == null) {
      _dbInstance = AppDatabase(AppDatabase.openConnection());
    }
    return _dbInstance!;
  }

  // Close the database when the app is disposed
  static Future<void> close() async {
    if (_dbInstance != null) {
      await _dbInstance?.close();
      _dbInstance = null;
    }
  }
}