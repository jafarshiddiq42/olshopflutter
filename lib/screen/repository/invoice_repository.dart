import 'dart:ui';

import 'package:olshop/model/invoice_model.dart';
import 'package:olshop/network/network.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class InvoiceRepository {
  Future fetchdata(List<InvoiceModel> list, String userid, VoidCallback reload,
      bool cekData) async {
    reload();
    list.clear();
    final response = await http.get(
      Uri.parse(
        NetworkURL.invoice(userid),
      ),
    );
    if (response.statusCode == 200) {
      reload();
      if (response.contentLength == 2) {
        cekData = false;
      } else {
        final data = jsonDecode(response.body);
        for (Map i in data) {
          list.add(InvoiceModel.fromJson(i as Map<String, dynamic>));
        }
        cekData = true;
      }
    } else {
      cekData = false;
      reload();
    }
  }
}
