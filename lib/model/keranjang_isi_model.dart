class KeranjangIsiModel {
  final String? id;
  final String? userid;
  final String? produkid;
  final String? qty;
  final String? harga;
  final String? namaproduk;

  KeranjangIsiModel({
    this.id,
    this.userid,
    this.produkid,
    this.qty,
    this.harga,
    this.namaproduk,
  });

  factory KeranjangIsiModel.fromJson(Map<String, dynamic> json) {
    return KeranjangIsiModel(
      id: json['id'],
      userid: json['userid'],
      produkid: json['produkid'],
      qty: json['qty'],
      harga: json['harga'],
      namaproduk: json['namaproduk'],
    );
  }
}
