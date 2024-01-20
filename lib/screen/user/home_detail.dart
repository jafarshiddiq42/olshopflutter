import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:olshop/model/produk_model.dart';
import 'package:olshop/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeDetail extends StatefulWidget {
  final ProdukModel model;
  final VoidCallback reload;
  const HomeDetail(this.model, this.reload, {super.key});

  @override
  State<HomeDetail> createState() => _HomeDetailState();
}

final price = NumberFormat("#,##0", 'en_US');

class _HomeDetailState extends State<HomeDetail> {
  String? userid;
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userid = pref.getString("id");
    });
  }

  addCart() async {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text("Processing"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 4,
                ),
                Text("Loading...")
              ],
            ),
          );
        });
    final response = await http.post(
        Uri.parse(
          NetworkURL.tambahKeranjang(),
        ),
        body: {
          "userid": userid,
          "produkid": widget.model.id,
        });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String message = data['message'];
    if (value == 1) {
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Information"),
              content: Text(message),
              actions: <Widget>[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(
                      width: 2,
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      Navigator.pop(context);
                      widget.reload();
                    });
                  },
                  child: const Text(
                    "Ok",
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            );
          });
    } else {
      if (!mounted) return;
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Warning"),
              content: Text(message),
              actions: <Widget>[
                // ignore: deprecated_member_use
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(
                      width: 2,
                      color: Colors.red,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Ok",
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            );
          });
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
        title: Text(
          widget.model.nama!,
          style: const TextStyle(
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                Image.network(
                  "${NetworkURL.server}/imageProduk/${widget.model.gambar}",
                  fit: BoxFit.fitHeight,
                  height: 220,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  widget.model.nama!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Divider(
                    color: Colors.grey,
                  ),
                ),
                Text(
                  widget.model.keterangan!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: const Divider(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container( 
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "Rp. ${price.format(int.parse(widget.model.harga!))}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    addCart();
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.orange),
                    child: const Row(
                      children: [
                        Text(
                          "Tambah ke Keranjang",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.cartPlus,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
