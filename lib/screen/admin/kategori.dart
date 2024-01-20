import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:olshop/model/kategori_model.dart';
import 'package:olshop/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:olshop/screen/admin/kategori_edit.dart';
import 'package:olshop/screen/admin/kategori_tambah.dart';

class Kategori extends StatefulWidget {
  const Kategori({super.key});

  @override
  State<Kategori> createState() => _KategoriState();
}

class _KategoriState extends State<Kategori> {
  var loading = false;
  var cekData = false;

  List<KategoriModel> list = [];

  _fetchData() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(
      Uri.parse(
        NetworkURL.getKategori(),
      ),
    );
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
            list.add(KategoriModel.fromJson(i as Map<String, dynamic>));
          }
          loading = false;
          cekData = true;
        });
      }
    } else {
      setState(() {
        loading = false;
        cekData = false;
      });
    }
  }

  dialogDelete(String id) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              shrinkWrap: true,
              children: <Widget>[
                const Text(
                  "Apakah Kamu Yakin Menghapus Data Ini?",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text("No"),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    InkWell(
                      onTap: () {
                        _delete(id);
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  _delete(String id) async {
    final response = await http
        .post(Uri.parse(NetworkURL.kategoriHapus()), body: {"kategoriid": id});
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
        _fetchData();
      });
    } else {
      print(pesan);
    }
  }

  Future<void> onRefresh() async {
    _fetchData();
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kategori',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'MaisonNeue',
          ),
        ),
        backgroundColor: Colors.green[800],
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => KategoriTambah(onRefresh),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : cekData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: list.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, i) {
                            final a = list[i];
                            return Container(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Card(
                                      child: Container(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "kategori : ${a.nama}",
                                              style: const TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: 'Source Sans Pro',
                                                  color: Colors.black),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                IconButton(
                                                  onPressed: () {
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            KategoriEdit(
                                                                a, onRefresh),
                                                      ),
                                                    );
                                                  },
                                                  icon: const Icon(Icons.edit),
                                                  color: Colors.blue,
                                                ),
                                                IconButton(
                                                  onPressed: () {
                                                    dialogDelete(a.id!);
                                                  },
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  )
                : const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Belum Ada Kategori Yang Di Tambahkan",
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
