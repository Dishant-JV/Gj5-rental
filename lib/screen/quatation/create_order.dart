import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:gj5_rental/getx/getx_controller.dart';
import 'package:gj5_rental/screen/booking%20status/booking_status.dart';
import 'package:gj5_rental/screen/quatation/quatation.dart';
import 'package:gj5_rental/screen/quatation/quotation_detail.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Utils/utils.dart';
import '../../constant/constant.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({Key? key}) : super(key: key);

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  TextEditingController nameController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController number2Controller = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController remarkController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String returnDate = "";
  String deliveryDate = "";
  String DformatedDate = "";
  String RformatedDate = "";
  DateTime? returnNotFormatedDate;
  DateTime deliveryNotFormatedDate = DateTime.now();
  bool initialValidDDate = true;
  bool initialValidRDate = true;
  bool isValidDDate = true;
  bool isValidRDate = true;
  bool isBtnLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          children: [
            allScreenInitialSizedBox(context),
            ScreenAppBar(screenName: "Create Order"),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: getWidth(0.04, context)),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Name : ",
                              style: primaryStyle,
                            ),
                            Container(
                              width: getWidth(0.65, context),
                              child: textFieldWidget(
                                  "Name",
                                  nameController,
                                  false,
                                  false,
                                  Colors.grey.withOpacity(0.1),
                                  TextInputType.text,
                                  0,
                                  Colors.greenAccent,
                                  1),
                            )
                          ],
                        ), //name
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Address : ",
                              style: primaryStyle,
                            ),
                            Container(
                              width: getWidth(0.65, context),
                              child: textFieldWidget(
                                  "Address",
                                  addressController,
                                  false,
                                  false,
                                  Colors.grey.withOpacity(0.1),
                                  TextInputType.text,
                                  0,
                                  Colors.greenAccent,
                                  3),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Mobile : ",
                              style: primaryStyle,
                            ),
                            Container(
                              width: getWidth(0.65, context),
                              child: numberValidatorTextfield(
                                  numberController, "Mobile number"),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),
                        //number
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mobile2 : ",
                        style: primaryStyle,
                      ),
                      FittedBox(
                        child: Container(
                          width: getWidth(0.65, context),
                          child: numberValidatorTextfield(
                              number2Controller, "Mobile number2"),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  remarkContainer(context, remarkController, 0.65, 0,
                      MainAxisAlignment.spaceBetween),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "D Date : ",
                        style: primaryStyle,
                      ),
                      InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          pickedDate(context).then((value) {
                            if (value != null) {
                              deliveryNotFormatedDate = value;
                              setState(() {
                                isValidDDate = true;
                                initialValidDDate = true;
                                deliveryDate = DateFormat('MM/dd/yyyy')
                                    .format(deliveryNotFormatedDate);
                                DformatedDate = DateFormat('dd/MM/yyyy')
                                    .format(deliveryNotFormatedDate);
                              });
                            }
                          });
                        },
                        child: Container(
                          width: getWidth(0.65, context),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 48,
                          decoration: BoxDecoration(
                            border: isValidDDate == true &&
                                    initialValidDDate == true
                                ? null
                                : Border.all(color: Colors.red),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              calenderIcon,
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                DformatedDate,
                                style: primaryStyle,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "R Date : ",
                        style: primaryStyle,
                      ),
                      InkWell(
                        onTap: () async {
                          FocusScope.of(context).unfocus();
                          pickedDate(context).then((value) {
                            if (value != null) {
                              returnNotFormatedDate = value;
                              setState(() {
                                isValidRDate = true;
                                initialValidRDate = true;
                                returnDate = DateFormat('MM/dd/yyyy')
                                    .format(returnNotFormatedDate!);
                                RformatedDate = DateFormat('dd/MM/yyyy')
                                    .format(returnNotFormatedDate!);
                              });
                            }
                          });
                        },
                        child: Container(
                          width: getWidth(0.65, context),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          height: 48,
                          decoration: BoxDecoration(
                            border: isValidRDate == true &&
                                    initialValidRDate == true
                                ? null
                                : Border.all(color: Colors.red),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              calenderIcon,
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                RformatedDate,
                                style: primaryStyle,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            isBtnLoading == false
                ? Container(
                    width: double.infinity,
                    height: 45,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 25),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primary2Color),
                        onPressed: () {
                          if (_formKey.currentState?.validate() == true &&
                              nameController.text.isNotEmpty &&
                              numberController.text.isNotEmpty &&
                              addressController.text.isNotEmpty) {
                            checkValidation();
                          }
                        },
                        child: Text("CREATE ORDER")),
                  )
                : Padding(
                    padding: EdgeInsets.all(25),
                    child: CenterCircularProgressIndicator(),
                  ),
            Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10))
          ],
        ),
      ),
    );
  }

  checkValidation() {
    if (returnDate == "" || deliveryDate == "") {
      setState(() {
        isValidDDate = false;
        isValidRDate = false;
        initialValidDDate = false;
        initialValidRDate = false;
      });
    } else {
      if (deliveryNotFormatedDate
              .isBefore(returnNotFormatedDate ?? DateTime.now()) ==
          true) {
        checkWifiForCreateOrder();
      } else {
        setState(() {
          isValidRDate = false;
        });
        showInSnackBar(
            "You can not select Delivery date bigger than Return Date!",
            context);
      }
    }
  }

  checkWifiForCreateOrder() {
    getStringPreference('apiUrl').then((value) async {
      try {
        getStringPreference('accessToken').then((token) async {
          if (value.toString().startsWith("192")) {
            showConnectivity().then((result) async {
              if (result == ConnectivityResult.wifi) {
                createOrder(value, token.toString());
              } else {
                dialog(context, "Connect to Showroom Network",
                    Colors.red.shade300);
              }
            });
          } else {
            createOrder(value, token);
          }
        });
      } on SocketException catch (err) {
        dialog(context, "Connect to Showroom Network", Colors.red.shade300);
      }
    });
  }

  Future<void> createOrder(String apiUrl, String token) async {
    MyGetxController myGetxController = Get.find();
    setState(() {
      isBtnLoading = true;
    });
    final partnerIdResponse =
        await http.post(Uri.parse("http://$apiUrl/api/res.customer"),
            headers: {'Access-Token': token},
            body: jsonEncode({
              'name': nameController.text,
              'mobile1': numberController.text,
              'address': addressController.text
            }));
    Map data = jsonDecode(partnerIdResponse.body);
    var body = {
      'partner_id': data['id'],
      'mobile1': numberController.text,
      'mobile2': number2Controller.text,
      'delivery_address': addressController.text,
      'delivery_date': deliveryDate,
      'return_date': returnDate,
      'remarks': remarkController.text
    };
    final response =
        await http.post(Uri.parse("http://$apiUrl/api/rental.rental"),
            headers: {
              'Access-Token': token,
            },
            body: jsonEncode(body));

    Map datas = jsonDecode(response.body);
    setState(() {
      isBtnLoading = false;
    });
    if (response.statusCode == 200) {
      myGetxController.quotationData.clear();
      quotationOffset = 0;
      getDraftOrderData(context, apiUrl, token, 0).whenComplete(() {
        pushMethod(
            context,
            QuatationDetailScreen(
              id: datas['id'],
              isFromAnotherScreen: false,
            ));
      });
    } else {
      dialog(context, "Error in Order Creation !", Colors.red.shade300);
    }
  }
}
