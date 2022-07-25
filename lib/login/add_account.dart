import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:gj5_rental/Utils/utils.dart';
import 'package:gj5_rental/home/home.dart';
import 'package:gj5_rental/login/login_page.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({Key? key}) : super(key: key);

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  List<dynamic> finalData = [];

  @override
  void initState() {
    super.initState();
    getAccountData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xffFB578E).withOpacity(0.2),
        Color(0xffFEA78D).withOpacity(0.15)
      ])),
      child: finalData.isNotEmpty
          ? Center(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: finalData.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        checkAccountListLoginStatus(index);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      finalData[index]['username'].toString(),
                                      style: allCardSubText,
                                    ),
                                    Text(
                                      finalData[index]['branchName'].toString(),
                                      style: allCardMainText,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      finalData[index]['serverUrl'].toString(),
                                      style: allCardMainText,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        confirmationDialogForDeleteAccount(
                                            index);
                                      },
                                      child: Icon(
                                        Icons.delete,
                                        size: 30,
                                        color: Colors.blue,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
            )
          : Container(
              child: Center(
                child: Text(
                  "No Account added",
                  style: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                      fontSize: 23),
                ),
              ),
            ),
    ));
  }

  confirmationDialogForDeleteAccount(int index) {
    return showDialog(
        context: context,
        builder: (_) {
          return Dialog(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sure , Are you want to Delete ?",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 19,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade300),
                          onPressed: () {
                            deleteAccount(index);
                            Navigator.pop(context);
                          },
                          child: Text("Ok")),
                      SizedBox(
                        width: 5,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade300),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel")),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  getAccountData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var retreiveData = preferences.getString('accountList');
    setState(() {
      finalData = jsonDecode(retreiveData ?? "");
    });
  }

  Future<void> checkAccountListLoginStatus(int index) async {
    String serverUrl = finalData[index]['serverUrl'];
    String username = finalData[index]['name'];
    String password = finalData[index]['password'];
    try {
      if (serverUrl.startsWith("192")) {
        showConnectivity().then((result) async {
          if (result == ConnectivityResult.wifi) {
            checkAccountData(index, serverUrl, username, password);
          } else {
            dialog(context, "Connect to Showroom Network", Colors.red.shade300);
          }
        });
      } else {
        checkAccountData(index, serverUrl, username, password);
      }
    } on SocketException catch (err) {
      dialog(context, "Connect to Showroom Network", Colors.red.shade300);
    }
  }

  checkAccountData(
      int index, String serverUrl, String username, String password) async {
    try {
      String dbListUrl = "http://$serverUrl/api/dblist";
      final dbListResponse = await http.get(Uri.parse(dbListUrl));
      if (dbListResponse.statusCode == 200) {
        final response =
            await http.post(Uri.parse("http://$serverUrl/api/auth/get_tokens"),
                headers: <String, String>{
                  'Content-Type': 'application/http; charset=UTF-8',
                },
                body: jsonEncode({
                  'db': dbListResponse.body,
                  'username': username.trim(),
                  'password': password.trim()
                }));

        if (response.statusCode == 200) {
          removePreference().whenComplete(() {
            final data = jsonDecode(response.body);
            checkForBioMatrics().then((value) {
              if (value == true) {
                setLogIn(true);
                setLogInData(
                        serverUrl,
                        data['access_token'],
                        data['uid'].toString(),
                        data['partner_id'].toString(),
                        data['name'].toString(),
                        data['image'].toString(),
                        data['branch_name'],
                        data['past_day_order'].toString(),
                        data['next_day_order'].toString(),
                        data['is_user'],
                        data['is_servicer'],
                        data['is_receiver'],
                        data['is_deliver'],
                        data['change_product'],
                        data['is_manager'])
                    .whenComplete(() {
                  pushRemoveUntilMethod(context, HomeScreen(userId: data['uid']));
                });
              }
            });
          });
        } else {
          pushMethod(
              context,
              LogInPage(
                savedServerUrl: serverUrl,
                savedUsername: username,
              ));
        }
      }
    } on SocketException catch (err) {
      dialog(context, "Connect to Showroom Network", Colors.red.shade300);
    }
  }

  Future<bool> checkForBioMatrics() async {
    final LocalAuthentication auth = LocalAuthentication();
    bool isDeviceSupport = await auth.canCheckBiometrics;
    bool isAvailableBioMetrics = await auth.isDeviceSupported();
    if (isAvailableBioMetrics && isDeviceSupport) {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to Logged In',
        options: AuthenticationOptions(useErrorDialogs: true, stickyAuth: true),
      );
      if (didAuthenticate) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  Future<void> deleteAccount(int index) async {
    setState(() {
      finalData.removeAt(index);
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var list = jsonEncode(finalData);
    preferences.setString('accountList', list);
    if (finalData.isEmpty) {
      pushRemoveUntilMethod(context, LogInPage());
    }
  }
}
