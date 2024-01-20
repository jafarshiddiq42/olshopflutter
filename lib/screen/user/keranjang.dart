// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:olshop/model/keranjang_isi_model.dart';
import 'package:olshop/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Keranjang extends StatefulWidget {
  final VoidCallback method;
  const Keranjang(this.method, {super.key});

  @override
  State<Keranjang> createState() => _KeranjangState();
}

final price = NumberFormat("#,##0", 'en_US');

class _KeranjangState extends State<Keranjang> {
  String? userid;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userid = pref.getString("id");
    });
    _fetchData();
  }

  var loading = false;
  var cekData = false;
  List<KeranjangIsiModel> list = [];

  _fetchData() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response =
        await http.get(Uri.parse(NetworkURL.isiKeranjang(userid!)));
    if (response.statusCode == 200) {
      if (response.contentLength == 2) {
        setState(() {
          loading = false;
          cekData = false;
        });
      } else {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          for (Map i in data) {
            list.add(KeranjangIsiModel.fromJson(i as Map<String, dynamic>));
          }
          loading = false;
          cekData = true;
        });
        _getSummaryAmount();
      }
    } else {
      setState(() {
        loading = false;
        cekData = false;
      });
    }
  }

  var totalPrice = "0";
  _getSummaryAmount() async {
    setState(() {
      loading = true;
    });
    final response = await http.get(
      Uri.parse(
        NetworkURL.summaryAmountCart(userid!),
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)[0];
      String total = data['total'];
      setState(() {
        loading = false;
        totalPrice = total;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
  }

  _addQuantity(KeranjangIsiModel model, String tipe) async {
    await http.post(Uri.parse(NetworkURL.updateQuantity()), body: {
      "keranjangid": model.id,
      "userid": userid,
      "tipe": tipe,
    });
    setState(() {
      widget.method();
      _fetchData();
    });
  }

  kirimKeranjang() async {
    final response = await http.post(
        Uri.parse(
          NetworkURL.pesanan(),
        ),
        body: {
          "userid": userid,
          "total": totalPrice,
        });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      setState(() {
        widget.method();
        _fetchData();
      });
      showDialog(
        context: context,
        builder: (context) {
          return Platform.isAndroid
              ? AlertDialog(
                  title: const Text("Information"),
                  content: Text(message),
                  actions: [
                    // ignore: deprecated_member_use
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      child: const Text("Ok"),
                    ),
                  ],
                )
              : CupertinoAlertDialog(
                  title: const Text("Information"),
                  content: Text(message),
                  actions: [
                    // ignore: deprecated_member_use
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                      child: const Text("Ok"),
                    ),
                  ],
                );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return Platform.isAndroid
              ? AlertDialog(
                  title: const Text("Warning"),
                  content: Text(message),
                  actions: [
                    // ignore: deprecated_member_use
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Ok"),
                    ),
                  ],
                )
              : CupertinoAlertDialog(
                  title: const Text("Warning"),
                  content: Text(message),
                  actions: [
                    // ignore: deprecated_member_use
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Ok"),
                    ),
                  ],
                );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Keranjang",
          style: TextStyle(
              fontSize: 20.0,
              color: Colors.white,
              fontFamily: 'MaisonNeue',
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[800],
        leading: GestureDetector(
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : cekData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                          itemCount: list.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, i) {
                            final a = list[i];
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Text(
                                          a.namaproduk!,
                                          style: const TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: 'MaisonNeue',
                                              color: Colors.black),
                                        ),
                                        Text(
                                          "Harga : Rp. ${price.format(int.parse(a.harga!))}",
                                          style: const TextStyle(
                                              fontSize: 15.0,
                                              fontFamily: 'MaisonNeue',
                                              color: Colors.black),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          child: const Divider(
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    color: Colors.blue[600],
                                    onPressed: () {
                                      _addQuantity(a, "tambah");
                                    },
                                    icon: const Icon(Icons.add_box,
                                        color: Colors.green),
                                  ),
                                  Text(a.qty!),
                                  IconButton(
                                    color: Colors.red[600],
                                    onPressed: () {
                                      _addQuantity(a, "Kurang");
                                    },
                                    icon: const Icon(
                                        Icons.indeterminate_check_box,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      totalPrice == "0"
                          ? const SizedBox()
                          : Container(
                            padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    )
                                  ]),
                              child: Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "Total Harga : Rp. ${price.format(int.parse(totalPrice))}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    
                                    ),
                                  ),
                                 
                                  Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        kirimKeranjang();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.orange),
                                        child:const Row(
                                          children: [
                                             Text(
                                              "Check Out",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),SizedBox(width: 10,),
                                            FaIcon(FontAwesomeIcons.bagShopping, color: Colors.white ,)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ],
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Isi Keranjang Masih Kosong",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
      ),
    );
  }
}
