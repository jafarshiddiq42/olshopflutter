import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:olshop/screen/admin/invoice.dart';
import 'package:olshop/screen/admin/kategori.dart';
import 'package:olshop/screen/admin/produk.dart';
import 'package:olshop/screen/admin/profil_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuAdmin extends StatefulWidget {
  final VoidCallback signOut;
  const MenuAdmin(this.signOut, {super.key});

  @override
  State<MenuAdmin> createState() => _MenuAdminState();
}

class _MenuAdminState extends State<MenuAdmin> {
  int selectIndex = 0;
  signOut() {
    setState(() {
      widget.signOut();
    });
  }

  String userid = "", email = "";

  late TabController tabController;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userid = preferences.getString("id")!;
      email = preferences.getString("email")!;
    });
    print(userid);
  }

  Future<void> onRefresh() async {
    getPref();
  }

  @override
  void initState() {
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Offstage(
              offstage: selectIndex != 0,
              child: TickerMode(
                enabled: selectIndex == 0,
                child: const Kategori(),
              ),
            ),
            Offstage(
              offstage: selectIndex != 1,
              child: const Produk(),
            ),
            Offstage(
              offstage: selectIndex != 2,
              child: const Invoice(),
            ),
            Offstage(
              offstage: selectIndex != 3,
              child: const ProfilAdmin(),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
          width: 60,
          height: 60,
          child: Container(
            padding: const EdgeInsets.all(0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      selectIndex = 0;
                    });
                  },
                  child: Tab(
                    icon: FaIcon(
                      FontAwesomeIcons.shapes,
                      size: 30,
                      color: selectIndex == 0 ? Colors.blue : Colors.grey,
                    ),
                    child: Text(
                      'Kategori',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: selectIndex == 0 ? Colors.blue : Colors.grey),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      selectIndex = 1;
                    });
                  },
                  child: Tab(
                    icon: FaIcon(
                      FontAwesomeIcons.shop,
                      size: 30,
                      color: selectIndex == 1 ? Colors.blue : Colors.grey,
                    ),
                    child: Text(
                      'Produk',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: selectIndex == 1 ? Colors.blue : Colors.grey),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      selectIndex = 2;
                    });
                  },
                  child: Tab(
                    icon: FaIcon(
                      FontAwesomeIcons.fileContract,
                      size: 30,
                      color: selectIndex == 2 ? Colors.blue : Colors.grey,
                    ),
                    child: Text(
                      'Invoice',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: selectIndex == 2 ? Colors.blue : Colors.grey),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      selectIndex = 3;
                    });
                  },
                  child: Tab(
                    icon: FaIcon(
                      FontAwesomeIcons.solidCircleUser,
                      size: 30,
                      color: selectIndex == 3 ? Colors.blue : Colors.grey,
                    ),
                    child: Text(
                      'Profil',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: selectIndex == 3 ? Colors.blue : Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
