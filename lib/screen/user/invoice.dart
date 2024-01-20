import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:olshop/custom/info_card.dart';
import 'package:olshop/model/invoice_model.dart';
import 'package:olshop/screen/user/invoice_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/invoice_repository.dart';

class Invoice extends StatefulWidget {
  const Invoice({super.key});

  @override
  State<Invoice> createState() => _InvoiceState();
}

final price = NumberFormat("#,##0", 'en_US');

class _InvoiceState extends State<Invoice> {
  String? userid;

  InvoiceRepository invoiceRepository = InvoiceRepository();
  List<InvoiceModel> list = [];

  var loading = false;
  var cekData = false;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userid = pref.getString("id")!;
    });
    await invoiceRepository.fetchdata(list, userid!, () {
      setState(() {
        loading = true;
      });
    }, cekData);
    print("List 0 : ${list[0].invoice}");
  }

  Future<void> refresh() async {
    getPref();
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
          "Invoice",
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
            fontFamily: 'MaisonNeue',
            fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: Colors.green[800],
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: [
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, i) {
                final a = list[i];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InvoiceDetail(a)));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InfoCard(text: '${a.invoice}', icon: Icons.receipt ,warna: Colors.green, onPressed:(){}),
                      const Padding(
                        padding: EdgeInsets.only(top: 5.0),
                      ),
                     
                    ],
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
