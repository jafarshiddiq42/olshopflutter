import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:olshop/model/kategori_user_model.dart';
import 'package:olshop/model/keranjang_model.dart';
import 'package:olshop/model/produk_model.dart';
import 'package:olshop/network/network.dart';
import 'package:olshop/screen/user/cari_produk.dart';
import 'package:olshop/screen/user/home_detail.dart';
import 'package:olshop/screen/user/keranjang.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

final price = NumberFormat("#,##0", 'en_US');

class _HomeState extends State<Home> {
  var loading = false;
  var filter = false;
  int index = 0;

  String? userid;
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userid = pref.getString("id");
    });
    getTotalCart();
  }

  //koneksi filter berdasarkan kategori
  List<KategoriUserModel> listCategory = [];
  getProductwithCategory() async {
    setState(() {
      loading = true;
    });
    listCategory.clear();
    final response = await http.get(Uri.parse(NetworkURL.kategoriFilter()));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          listCategory
              .add(KategoriUserModel.fromJson(i as Map<String, dynamic>));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }
  //tutup koneksi filter berdasarkan kategori

  //koneksi produk
  List<ProdukModel> list = [];
  getProduct() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(Uri.parse(NetworkURL.getProduk()));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          list.add(ProdukModel.fromJson(i as Map<String, dynamic>));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }
  //tutup koneksi produk

  var loadingNotif = false;
  String total = "0";
  final ex = <KeranjangModel>[];

  getTotalCart() async {
    setState(() {
      loadingNotif = true;
    });
    ex.clear();
    final response =
        await http.get(Uri.parse(NetworkURL.totalKeranjang(userid!)));
    final data = jsonDecode(response.body);
    data.forEach((api) {
      final exp = KeranjangModel(api['total']);
      ex.add(exp);
      setState(() {
        total = exp.total;
      });
    });
    setState(() {
      loadingNotif = false;
      getTotalCart();
    });
  }

  Future<void> onRefresh() async {
    getProduct();
    getProductwithCategory();
    setState(() {
      filter = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getProduct();
    getProductwithCategory();
    getPref();
    getTotalCart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CariProduk(),
              ),
            );
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.all(4),
            child: TextField(
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: "Cari Produk",
                hintStyle: const TextStyle(fontSize: 13),
                fillColor: Colors.white,
                filled: true,
                enabled: false,
                contentPadding: const EdgeInsets.only(top: 10, left: 10),
                suffixIcon: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(style: BorderStyle.none),
                ),
              ),
            ),
          ),
        ),
        backgroundColor: Colors.green[800],
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Keranjang(getTotalCart),
                ),
              );
            },
            icon: Stack(
              children: [
                const FaIcon(FontAwesomeIcons.cartShopping,color: Colors.white,size: 22,),
                total == "0"
                    ? const SizedBox()
                    : Positioned(
                        right: 0,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: Text(
                            total,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  // Kategori Produk
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: listCategory.length,
                      itemBuilder: (context, i) {
                        final a = listCategory[i];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              filter = true;
                              index = i;
                              print(filter);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, left: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20)
                                ),
                                color: Colors.green[700]),
                            child: Text(
                              a.namakategori!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  filter
                      ? listCategory[index].produk.isEmpty
                          ? Container(
                              height: 100,
                              padding: const EdgeInsets.all(16),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Maaf produk dengan kategori ini kosong",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.all(10),
                              itemCount: listCategory[index].produk.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                              ),
                              itemBuilder: (context, i) {
                                final a = listCategory[index].produk[i];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HomeDetail(a, onRefresh),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 1, color: Colors.grey[300]!),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              blurRadius: 5,
                                              color: Colors.grey[300]!)
                                        ]),
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Image.network(
                                                '${NetworkURL.server}/imageProduk/${a.gambar}',
                                                fit: BoxFit.cover,
                                                height: 180,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          a.nama!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        Text(
                                          "Rp. ${price.format(int.parse(a.harga!))}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              })
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          itemCount: list.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                          ),
                          itemBuilder: (context, i) {
                            final a = list[i];
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeDetail(a, onRefresh),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 1, color: Colors.grey[300]!),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 5,
                                          color: Colors.grey[300]!)
                                    ]),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Expanded(
                                      child: Stack(
                                        children: <Widget>[
                                          Image.network(
                                            '${NetworkURL.server}/imageProduk/${a.gambar}',
                                            fit: BoxFit.cover,
                                            height: 160,
                                            width: 160,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      a.nama!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      "Rp. ${price.format(int.parse(a.harga!))}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }
}
