import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:olshop/screen/user/home.dart';
import 'package:olshop/screen/user/invoice.dart';
import 'package:olshop/screen/user/profil_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuUser extends StatefulWidget {
  final VoidCallback signOut;
  const MenuUser(this.signOut, {super.key});

  @override
  State<MenuUser> createState() => _MenuUserState();
}

class _MenuUserState extends State<MenuUser> {
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
                child: const Home(),
              ),
            ),
            Offstage(
              offstage: selectIndex != 1,
              child: const Invoice(),
            ),
            Offstage(
              offstage: selectIndex != 2,
              child: const ProfilUser(),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(boxShadow: [
               BoxShadow(
                      color: Colors.grey,
                      offset: const Offset(
                        5.0,
                        5.0,
                      ),
                      blurRadius: 10.0,
                      spreadRadius: 2.0,
                    ), 
            ],color: Colors.white),
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
                      FontAwesomeIcons.house,
                      size: 20,
                      color: selectIndex == 0 ? Colors.green : Colors.grey,
                    ),
                    child: Text(
                      'Home',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: selectIndex == 0 ? Colors.green : Colors.grey),
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
                      FontAwesomeIcons.fileInvoice,
                      size: 20,
                      color: selectIndex == 1 ? Colors.green : Colors.grey,
                    ),
                    child: Text(
                      'Invoice',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: selectIndex == 1 ? Colors.green : Colors.grey),
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
                      FontAwesomeIcons.solidUser,
                      size: 20,
                      color: selectIndex == 2 ? Colors.green : Colors.grey,
                    ),
                    child: Text(
                      'Profil',
                      style: TextStyle(
                          fontSize: 10.0,
                          color: selectIndex == 2 ? Colors.green : Colors.grey),
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
