class ProdukModel {
  final String? id;
  final String? kategoriid;
  final String? nama;
  final String? harga;
  final String? keterangan;
  final String? gambar;
  final String? tanggal;
  final String? namakategori;

  ProdukModel({
    this.id,
    this.kategoriid,
    this.nama,
    this.harga,
    this.keterangan,
    this.gambar,
    this.tanggal,
    this.namakategori,
  });

  factory ProdukModel.fromJson(Map<String, dynamic>json){
    return ProdukModel(
      id: json['id'],
      kategoriid: json['kategoriid'],
      nama: json['nama'],
      harga: json['harga'],
      keterangan: json['keterangan'],
      gambar: json['gambar'],
      tanggal: json['tanggal'],
      namakategori: json['namakategori'],
    );
  }
}
