class TicketSettings {
  final int id;
  final String nombreNegocio;
  final String direccion;
  final String telefono;
  final String rfc;
  final String mensajeFinal;
  final String url;

  TicketSettings({
    this.id = 0,
    required this.nombreNegocio,
    required this.direccion,
    required this.telefono,
    required this.rfc,
    required this.mensajeFinal,
    required this.url,
  });

  factory TicketSettings.fromJson(Map<String, dynamic> json) {
    return TicketSettings(
      id: json['id'] as int,
      nombreNegocio: json['nombreNegocio'] as String,
      direccion: json['direccion'] as String,
      telefono: json['telefono'] as String,
      rfc: json['rfc'] as String,
      mensajeFinal: json['mensajeFinal'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreNegocio': nombreNegocio,
      'direccion': direccion,
      'telefono': telefono,
      'rfc': rfc,
      'mensajeFinal': mensajeFinal,
      'url': url,
    };
  }
}