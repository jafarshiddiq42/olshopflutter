import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:olshop/custom/currency.dart';
import 'package:olshop/custom/customButton.dart';
import 'package:olshop/custom/datePicker.dart';
import 'package:olshop/model/kategori_model.dart';
import 'package:olshop/model/produk_model.dart';
import 'package:olshop/network/network.dart';
import 'package:olshop/screen/admin/kategori_pilih.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProdukEdit extends StatefulWidget {
  final ProdukModel model;
  final VoidCallback reload;
  const ProdukEdit(this.model, this.reload, {super.key});

  @override
  State<ProdukEdit> createState() => _ProdukEditState();
}

class _ProdukEditState extends State<ProdukEdit> {
  final _key = GlobalKey<FormState>();

  String? adminid;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      adminid = pref.getString("id");
    });
  }

  File? _imageFile;
  final picker = ImagePicker();
  _pilihcamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        print('_image: $_imageFile');
      } else {
        print('No image selected');
      }
    });
  }

  late TextEditingController kategoriController;
  late TextEditingController kategoripilihController;
  late TextEditingController namaController;
  late TextEditingController hargaController;
  late TextEditingController keteranganController;

  String? tgldate;

  setup() {
    kategoriController = TextEditingController(text: widget.model.namakategori);
    kategoripilihController = TextEditingController(text: widget.model.kategoriid);
    namaController = TextEditingController(text: widget.model.nama);
    hargaController = TextEditingController(text: widget.model.harga);
    keteranganController = TextEditingController(text: widget.model.keterangan);
    tgldate = widget.model.tanggal!;
  }

  late KategoriModel kategoriModel;
  pilihKategori() async {
    kategoriModel = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const KategoriPilih()));
    setState(() {
      kategoripilihController = kategoriController;
      kategoripilihController = TextEditingController(text: kategoriModel.id);
      kategoriController = TextEditingController(text: kategoriModel.nama!);
    });
  }

  String? pilihTanggal, labelText;
  DateTime tgl = DateTime.now();
  var formatTgl = DateFormat('yyy-MM-dd');
  final TextStyle valueStyle = const TextStyle(fontSize: 16.0);
  Future<void> _selectedDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: tgl,
        firstDate: DateTime(1992),
        lastDate: DateTime(2099));

    if (picked != null && picked != tgl) {
      setState(() {
        tgl = picked;
        tgldate = formatTgl.format(tgl);
      });
    } else {}
  }

  check() {
    final form = _key.currentState;
    if (form!.validate()) {
      form.save();
      submit();
    } else {}
  }

  submit() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PopScope(
          child: AlertDialog(
            title: Text('Processing..'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 16,
                ),
                Text("Please wait...")
              ],
            ),
          ),
        );
      },
    );

    var uri = Uri.parse(NetworkURL.produkEdit());
    var request = http.MultipartRequest("POST", uri);

    request.fields['nama'] = namaController.text.trim();
    request.fields['kategoriid'] = kategoripilihController.text;
    request.fields['harga'] = hargaController.text.replaceAll(",", "");
    request.fields['keterangan'] = keteranganController.text.trim();
    request.fields['tanggal'] = "$tgldate";
    request.fields['produkid'] = widget.model.id!;

    if (_imageFile == null) {
      request.fields['gambar'] = widget.model.gambar!;
    } else {
      var pic = await http.MultipartFile.fromPath("gambar", _imageFile!.path);
      request.files.add(pic);
    }

    var response = await request.send();
    response.stream.transform(utf8.decoder).listen((a) {
      final data = jsonDecode(a);
      int value = data['value'];
      String message = data['message'];
      if (value == 1) {
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
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Warning"),
              content: Text(message),
              actions: <Widget>[
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
          },
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Produk',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontFamily: 'MaisonNeue',
          ),
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
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            SizedBox(
              width: double.infinity,
              height: 150.0,
              child: InkWell(
                onTap: () {
                  _pilihcamera();
                },
                child: _imageFile == null
                    ? Image.network(
                        '${NetworkURL.server}/imageProduk/${widget.model.gambar}')
                    : Image.file(
                        _imageFile!,
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            InkWell(
              onTap: () {
                pilihKategori();
              },
              child: TextFormField(
                enabled: false,
                validator: (e) {
                  if (e == null || e.isEmpty) {
                    return "pilih kategori";
                  }
                  return null;
                },
                keyboardType: TextInputType.multiline,
                maxLines: 20,
                minLines: 1,
                controller: kategoriController,
                decoration: const InputDecoration(
                  hintText: "pilih kategori",
                  labelText: "Pilih Kategori",
                  icon: Icon(Icons.text_increase),
                ),
              ),
            ),
            TextFormField(
              validator: (e) {
                if (e == null || e.isEmpty) {
                  return "isikan nama produk";
                }
                return null;
              },
              keyboardType: TextInputType.multiline,
              maxLines: 20,
              minLines: 1,
              controller: namaController,
              decoration: const InputDecoration(
                hintText: "isikan nama produk",
                labelText: "Isikan Nama Produk",
                icon: Icon(Icons.text_increase),
              ),
            ),
            TextFormField(
              validator: (e) {
                if (e == null || e.isEmpty) {
                  return "isikan harga";
                }
                return null;
              },
              inputFormatters: [
                // ignore: deprecated_member_use
                FilteringTextInputFormatter.digitsOnly,
                CurrencyFormat()
              ],
              keyboardType: TextInputType.number,
              maxLines: 20,
              minLines: 1,
              controller: hargaController,
              decoration: const InputDecoration(
                hintText: "isikan harga",
                labelText: "isikan Harga",
                icon: Icon(Icons.text_increase),
              ),
            ),
            TextFormField(
              validator: (e) {
                if (e == null || e.isEmpty) {
                  return "isikan keterangan";
                }
                return null;
              },
              keyboardType: TextInputType.multiline,
              maxLines: 20,
              minLines: 1,
              controller: keteranganController,
              decoration: const InputDecoration(
                hintText: "isikan keterangan",
                labelText: "Isikan Keterangan",
                icon: Icon(Icons.text_increase),
              ),
            ),
            DateDropDown(
              labelText: "Tanggal",
              valueText: tgldate!,
              valueStyle: valueStyle,
              onPressed: () {
                _selectedDate(context);
              },
            ),
            const SizedBox(
              height: 20,
            ),
            MaterialButton(
              onPressed: () {
                check();
              },
              child: CustomButton(
                "Edit",
                color: Colors.green[800]!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
