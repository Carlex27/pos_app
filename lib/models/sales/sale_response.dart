import 'sale_item_response.dart';

class SaleResponse {
  final int id;
  final String clientName;
  final String vendorName;
  final DateTime saleDate;
  final double total;
  final String state;
  final bool isCreditSale; // si tu API lo incluye en el mismo JSON
  final List<SaleItemResponse>? items;// si tu API los incluye en el mismo JSON
  final int itemCount;

  SaleResponse({
    required this.id,
    required this.clientName,
    required this.vendorName,
    required this.saleDate,
    required this.total,
    required this.state,
    required this.isCreditSale, // por defecto es false
    this.items,
    required this.itemCount
  });

  factory SaleResponse.fromJson(Map<String, dynamic> json) {
    return SaleResponse(
      id:         json['id']          as int,
      clientName: json['clientName']  as String,
      vendorName: json['vendorName']  as String,
      saleDate:   DateTime.parse(json['saleDate'] as String),
      total:      (json['total']     as num).toDouble(),
      state:      json['state']       as String,
      isCreditSale: json['isCreditSale'] != null
          ? json['isCreditSale'] as bool
          : false, // si no está presente, por defecto es false
      items:      json['items'] != null
          ? (json['items'] as List)
          .map((e) => SaleItemResponse.fromJson(e))
          .toList()
          : null,
      itemCount: json['itemCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    final m = {
      'id':          id,
      'clientName':  clientName,
      'vendorName':  vendorName,
      'saleDate':    saleDate.toIso8601String(),
      'total':       total,
      'state':       state,
      'isCreditSale': isCreditSale,
      'itemCount':   itemCount,
    };
    if (items != null) {
      m['items'] = items!.map((e) => e.toJson()).toList();
    }
    return m;
  }
}
