class ResumeVentas {
  final int totalVentas;
  final double totalIngresos;


  ResumeVentas({
    required this.totalVentas,
    required this.totalIngresos,
  });

  factory ResumeVentas.fromJson(Map<String, dynamic> json) {
    return ResumeVentas(
      totalVentas: json['totalVentas'] as int,
      totalIngresos: (json['totalIngresos'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalVentas': totalVentas,
    'totalIngresos': totalIngresos,
  };
}