import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:olshop/model/keranjang_model.dart';
import 'package:olshop/model/produk_model.dart';
import 'package:olshop/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:olshop/screen/user/home_detail.dart';
import 'package:olshop/screen/user/keranjang.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CariProduk extends StatefulWidget {
  const CariProduk({super.key});

  @override
  State<CariProduk> createState() => _CariProdukState();
}

class _CariProdukState extends State<CariProduk> {
  var loading = false;
  List<ProdukModel> list = [];
  List<ProdukModel> listSearch = [];
  var loadingNotif = false;
  String total = "0";
  final ex = <KeranjangModel>[];


   String? userid;
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userid = pref.getString("id");
    });
    getTotalCart();
  }

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

  final price = NumberFormat("#,##0", 'en_US');

  TextEditingController searchController = TextEditingController();

  onSearch(String text) async {
    listSearch.clear();
    if (text.isEmpty) {
      setState(() {});
    }
    for (var a in list) {
      if (a.nama!.toLowerCase().contains(text)) listSearch.add(a);
    }

    setState(() {});
  }

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
  }

  @override
  void initState() {
    super.initState();
    getProduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          child: TextField(
            textAlign: TextAlign.left,
            autofocus: true,
            controller: searchController,
            onChanged: onSearch,
            style: const TextStyle(
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: "Cari Produk",
              hintStyle: const TextStyle(fontSize: 18),
              fillColor: Colors.white,
              filled: true,
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
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        actions: [IconButton(
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
          ),],
        backgroundColor: Colors.green[800],
      ),
      body: Container(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : searchController.text.isNotEmpty || listSearch.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    itemCount: listSearch.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemBuilder: (context, i) {
                      final a = listSearch[i];
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeDetail(a, getProduct),
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
                                    blurRadius: 5, color: Colors.grey[300]!)
                              ]),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: Image.network(
                                  "${NetworkURL.server}/imageProduk/${a.gambar}",
                                  fit: BoxFit.cover,
                                  height: 180,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                a.nama!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                "Rp. ${price.format(int.parse(a.harga!))}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    })
                : Container(
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          "Silahkan Cari Nama Produk",
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ),
      ),
    );
  }
}
