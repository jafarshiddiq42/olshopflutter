class NetworkURL {
  static String server = "https://c35f-180-241-44-202.ngrok-free.app/olshop_dosen/olshopWeb";

  static String login() {
    return "$server/API/login.php";
  }

  static String register() {
    return "$server/API/registrasi.php";
  }

  static String getProfil(String userid) {
    return "$server/API/profil.php?userid=$userid";
  }

  //Terbaru
  static String getKategori() {
    return "$server/API/kategori.php";
  }

  static String kategoriTambah() {
    return "$server/API/kategoriTambah.php";
  }

  static String kategoriEdit() {
    return "$server/API/kategoriEdit.php";
  }

  static String kategoriHapus() {
    return "$server/API/kategoriHapus.php";
  }

  static String getProduk() {
    return "$server/API/produk.php";
  }

  static String produkTambah() {
    return "$server/API/produkTambah.php";
  }

  static String produkEdit() {
    return "$server/API/produkEdit.php";
  }

  static String produkHapus() {
    return "$server/API/produkHapus.php";
  }

  static String kategoriFilter() {
    return "$server/API/kategoriFilter.php";
  }

  static String totalKeranjang(String userid) {
    return "$server/API/totalKeranjang.php?userid=$userid";
  }

  static String tambahKeranjang() {
    return "$server/API/tambahKeranjang.php";
  }

  static String isiKeranjang(String userid) {
    return "$server/API/isiKeranjang.php?userid=$userid";
  }

  static String summaryAmountCart(String userid) {
    return "$server/API/summaryAmountCart.php?userid=$userid";
  }

  static String updateQuantity() {
    return "$server/API/updateQuantity.php";
  }

  //Terbaru
  static String pesanan() {
    return "$server/API/pesanan.php";
  }

  static String invoice(String userid) {
    return "$server/API/invoice.php?userid=$userid";
  }
  static String invoiceadmin() {
    return "$server/API/invoiceadmin.php";
  }
}
