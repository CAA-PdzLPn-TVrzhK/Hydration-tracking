import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'hydration_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Hydration entries table
    await db.execute('''
      CREATE TABLE hydration_entries (
        id TEXT PRIMARY KEY,
        amount INTEGER NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    // User settings table
    await db.execute('''
      CREATE TABLE user_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Goals table
    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        daily_goal INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // Hydration entries methods
  static Future<void> saveHydrationEntry({
    required String id,
    required int amount,
    required String type,
    required DateTime timestamp,
    bool synced = false,
  }) async {
    await _database?.insert(
      'hydration_entries',
      {
        'id': id,
        'amount': amount,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'synced': synced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getHydrationEntries() async {
    final List<Map<String, dynamic>> maps = await _database?.query(
      'hydration_entries',
      orderBy: 'timestamp DESC',
    ) ?? [];

    return maps.map((map) {
      return {
        'id': map['id'],
        'amount': map['amount'],
        'type': map['type'],
        'timestamp': DateTime.parse(map['timestamp']),
        'synced': map['synced'] == 1,
      };
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedEntries() async {
    final List<Map<String, dynamic>> maps = await _database?.query(
      'hydration_entries',
      where: 'synced = ?',
      whereArgs: [0],
    ) ?? [];

    return maps.map((map) {
      return {
        'id': map['id'],
        'amount': map['amount'],
        'type': map['type'],
        'timestamp': DateTime.parse(map['timestamp']),
        'synced': false,
      };
    }).toList();
  }

  static Future<void> markEntryAsSynced(String id) async {
    await _database?.update(
      'hydration_entries',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User settings methods
  static Future<void> saveSetting(String key, String value) async {
    await _database?.insert(
      'user_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<String?> getSetting(String key) async {
    final List<Map<String, dynamic>> maps = await _database?.query(
      'user_settings',
      where: 'key = ?',
      whereArgs: [key],
    ) ?? [];

    if (maps.isNotEmpty) {
      return maps.first['value'] as String;
    }
    return null;
  }

  // Goals methods
  static Future<void> saveGoal({
    required String id,
    required int dailyGoal,
    required DateTime createdAt,
  }) async {
    await _database?.insert(
      'goals',
      {
        'id': id,
        'daily_goal': dailyGoal,
        'created_at': createdAt.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<int?> getCurrentGoal() async {
    final List<Map<String, dynamic>> maps = await _database?.query(
      'goals',
      orderBy: 'created_at DESC',
      limit: 1,
    ) ?? [];

    if (maps.isNotEmpty) {
      return maps.first['daily_goal'] as int;
    }
    return null;
  }

  // SharedPreferences methods
  static Future<void> saveString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> saveInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  static Future<void> saveBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  // Database cleanup
  static Future<void> close() async {
    await _database?.close();
  }

  // Data export/import
  static Future<Map<String, dynamic>> exportData() async {
    final entries = await getHydrationEntries();
    final goal = await getCurrentGoal();
    
    return {
      'entries': entries,
      'goal': goal,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    if (data['entries'] != null) {
      for (final entry in data['entries']) {
        await saveHydrationEntry(
          id: entry['id'],
          amount: entry['amount'],
          type: entry['type'],
          timestamp: DateTime.parse(entry['timestamp']),
          synced: true,
        );
      }
    }

    if (data['goal'] != null) {
      await saveGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dailyGoal: data['goal'],
        createdAt: DateTime.now(),
      );
    }
  }
} 