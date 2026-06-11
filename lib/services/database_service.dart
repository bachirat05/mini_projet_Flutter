import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
  static Database? _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initialDb();
    }
    return _db!;
  }

  Future<Database> _initialDb() async {
    String databasepath = await getDatabasesPath();
    String path = join(databasepath, 'mydb33.db');

    Database db = await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }

  // Appelé automatiquement quand la version passe de 1 → 2
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Supprimer l'ancienne table budgets (mauvaise structure)
      await db.execute('DROP TABLE IF EXISTS budgets');
      // Recréer avec la bonne structure (mois et annee en INTEGER séparés)
      await db.execute('''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          montantMax REAL NOT NULL,
          mois INTEGER NOT NULL,
          annee INTEGER NOT NULL,
          FOREIGN KEY(userId) REFERENCES users(id)
        )
      ''');
    }
  }

  // Etape 3 création des tables (éxecuté une seul fois)
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        type TEXT NOT NULL,
        montant REAL NOT NULL,
        categorie TEXT NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL,

        FOREIGN KEY(userId)
        REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        montantMax REAL NOT NULL,
        mois INTEGER NOT NULL,
        annee INTEGER NOT NULL,

        FOREIGN KEY(userId)
        REFERENCES users(id)
      )
    ''');
  }

  // en ce qui concerne users : 
  // inserer un utilisateur
  Future<int> insertUser(Map<String,dynamic> user) async {
    return await (await db).insert('users', user);
  }

  // rechercher un utilisateur par email
  Future<List<Map<String, dynamic>>> getUserByEmail(
    String email,
  ) async {
    return await (await db).query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // login 
  Future<List<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    return await (await db).query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
  }

  // en ce qui concerne transactions 
  // SELECT — lire toutes les transactions
  Future<List<Map<String, dynamic>>> getAllTransactions(int userId) async {
    return await (await db).query(
      'transactions',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  // INSERT — ajouter une transaction
  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    return await (await db).insert(
      'transactions',
       transaction,
       );
  }

  // SELECT — lire une transaction par id
  Future<List<Map<String, dynamic>>> getTransactionById(int id) async {
    return await (await db).query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // UPDATE — modifier une transaction
  Future<int> updateTransaction(int id, Map<String, dynamic> transaction) async {
    return await (await db).update(
      'transactions',
      transaction,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE — supprimer une transaction par id
  Future<int> deleteTransaction(int id) async {
    return await (await db).delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // en ce qui concerne le budget :
  // Lire le budget d'un utilisateur pour un mois et une année
  Future<List<Map<String, dynamic>>> getBudget(
    int userId,
    int mois,
    int annee,
  ) async {

    return await (await db).query(
      'budgets',
      where: 'userId = ? AND mois = ? AND annee = ?',
      whereArgs: [userId, mois, annee],
    );
  }

  // Ajouter un budget
  Future<int> insertBudget(
    Map<String, dynamic> budget,
  ) async {

    return await (await db).insert(
      'budgets',
      budget,
    );
  }

  // Modifier un budget
  Future<int> updateBudget(
    int id,
    Map<String, dynamic> budget,
  ) async {

    return await (await db).update(
      'budgets',
      budget,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Supprimer un budget
  Future<int> deleteBudget(
    int id,
  ) async {

    return await (await db).delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> debugBudgets() async {
  final data = await (await db).query('budgets');

  print('===== BUDGETS =====');

  for (final row in data) {
    print(row);
  }
}
}
