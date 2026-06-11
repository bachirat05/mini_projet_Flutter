// Le modèle représente une transaction financière (revenu ou dépense).
// Il contient fromJson/toJson pour communiquer avec SQLite et les APIs REST.

class Transaction {
  final int?   id;          // null avant insertion en base
  final int    userId;      // lien vers l'utilisateur connecté
  final String type;        // 'income' ou 'expense'
  final double montant;      // montant en MAD
  final String categorie;    // ex : 'Alimentation', 'Salaire'
  final String description; // note libre
  final String date;        // format ISO : '2025-06-01'

  const Transaction({
    this.id,
    required this.userId,
    required this.type,
    required this.montant,
    required this.categorie,
    required this.description,
    required this.date,
  });

  //  Depuis un Map (SQLite row ou JSON API) 
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      // int.tryParse gère les deux cas : id int (SQLite) ou id String (MockAPI)
      id:          json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      userId:      json['userId'] is int ? json['userId'] : int.tryParse(json['userId'].toString()) ?? 0,
      type:        json['type']        as String,
      montant:      (json['montant'] as num).toDouble(),
      categorie:    json['categorie']    as String,
      description: json['description'] as String,
      date:        json['date']        as String,
    );
  }

  //  Vers un Map (pour INSERT SQLite ou body HTTP POST) 
  // On n'inclut pas l'id pour les créations (la base l'assigne automatiquement)
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'userId':      userId,
    'type':        type,
    'montant':      montant,
    'categorie':    categorie,
    'description': description,
    'date':        date,
  };


  bool get isIncome  => type == 'income';
  bool get isExpense => type == 'expense';
}