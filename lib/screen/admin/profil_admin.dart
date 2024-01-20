import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:olshop/custom/customButton.dart';
import 'package:olshop/custom/info_card.dart';
import 'package:olshop/model/user_model.dart';
import 'package:olshop/network/network.dart';
import 'package:olshop/screen/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilAdmin extends StatefulWidget {
  const ProfilAdmin({super.key});

  @override
  State<ProfilAdmin> createState() => _ProfilAdminState();
}

class _ProfilAdminState extends State<ProfilAdmin> {
  signOut() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.getInt("value") ?? 0;
    pref.setString("level", "");
    pref.remove("id");
    pref.remove("email");
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  late String userid;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      userid = preferences.getString("id")!;
    });
    getProfil();
  }

  var loading = false;
  List<UserModel> list = [];

  getProfil() async {
    setState(() {
      loading = true;
    });
    list.clear();
    final response = await http.get(
      Uri.parse(
        NetworkURL.getProfil(userid),
      ),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      setState(() {
        for (Map i in data) {
          list.add(UserModel.fromJson(i as Map<String, dynamic>));
        }
        loading = false;
      });
    } else {
      setState(() {
        loading = false;
      });
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profil Admin",
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
            icon: const Icon(Icons.logout),
            color: Colors.white,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Warning"),
                    content: const Text("Apakah Anda Yakin Inggin Keluar?"),
                    actions: <Widget>[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('No'),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          signOut();
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) {
                        final a = list[i];
                        return Container(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    // Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) =>
                                    //         ProfilUserGambar(a, onRefresh),
                                    //   ),
                                    // );
                                  },
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      '${NetworkURL.server}../imageUser/${a.gambar}',
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) =>
                                  //         ProfilAdminEditGambar(a, onRefresh),
                                  //   ),
                                  // );
                                },
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                ),
                                color: Colors.green,
                              ),
                              Text(
                                a.nama!,
                                style: const TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'MaisonNeue',
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                width: 200,
                                child: Divider(
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              InfoCard(
                                warna: Colors.green,
                                text: a.email!,
                                icon: Icons.email,
                                onPressed: () {},
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              InkWell(
                                  onTap: () {
                                    // Navigator.of(context).push(
                                    //     // MaterialPageRoute(
                                    //     //   builder: (context) =>
                                    //     //       ProfilAdminEdit(a, onRefresh),
                                    //     // ),
                                    //     );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),color: Colors.green[700]
                                    ),
                                    child: TextButton.icon(
                                      onPressed: () {},
                                      icon: Icon(Icons.edit,color: Colors.white,),
                                      label: Text('EDIT PROFIL',style: TextStyle(color: Colors.white),)),
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
