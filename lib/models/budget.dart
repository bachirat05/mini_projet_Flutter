class Budget {
  final int? id;
  final int userId;
  final double montantMax;
  final int annee;
  final int mois;

  const Budget({
    this.id,
    required this.userId,
    required this.montantMax,
    required this.annee,
    required this.mois,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()),

      userId: json['userId'] is int
          ? json['userId']
          : int.tryParse(json['userId'].toString()) ?? 0,

      montantMax: (json['montantMax'] as num).toDouble(),

      annee: json['annee'] is int
          ? json['annee']
          : int.tryParse(json['annee'].toString()) ?? 0,

      mois: json['mois'] is int
          ? json['mois']
          : int.tryParse(json['mois'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'userId': userId,
        'montantMax': montantMax,
        'annee': annee,
        'mois': mois,
      };

// getter pour avoir le mois/annee 
  String get periode =>
    '${mois.toString().padLeft(2, '0')}/$annee';
}