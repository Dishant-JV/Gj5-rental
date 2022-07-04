import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:animations/animations.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:gj5_rental/getx/getx_controller.dart';
import 'package:gj5_rental/home/home.dart';
import 'package:gj5_rental/screen/booking%20status/booking_status.dart';
import 'package:gj5_rental/screen/quatation/quatation.dart';
import 'package:gj5_rental/screen/quatation/quotation_const/quotation_constant.dart';
import 'package:gj5_rental/screen/quatation/quotation_detail_add_product.dart';
import 'package:http/http.dart' as http;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../Utils/utils.dart';
import '../../constant/constant.dart';
import '../../constant/order_quotation_amount_card.dart';
import '../../constant/order_quotation_comman_card.dart';
import '../../constant/order_quotation_detail_card.dart';
import 'create_order.dart';

class QuatationDetailScreen extends StatefulWidget {
  final int? id;
  final bool isFromAnotherScreen;
  final bool? isFromEditScreen;

  const QuatationDetailScreen(
      {Key? key,
      this.id,
      required this.isFromAnotherScreen,
      this.isFromEditScreen})
      : super(key: key);

  @override
  State<QuatationDetailScreen> createState() => _QuatationDetailScreenState();
}

class _QuatationDetailScreenState extends State<QuatationDetailScreen> {
  @override
  void initState() {
    super.initState();
    checkQuotationAndOrderDetailData(context, widget.id ?? 0, false);
  }
  MyGetxController myGetxController = Get.put(MyGetxController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => onWillPopNavigateFunction(),
      child: Scaffold(
        floatingActionButton: CustomFABWidget(
            transitionType: ContainerTransitionType.fade, isCreateOrder: false),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: 10,
                ),
                InkWell(
                    onTap: () {
                      onWillPopNavigateFunction();
                    },
                    child: FadeInLeft(
                      child: Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.teal,
                      ),
                    )),
                SizedBox(
                  width: 10,
                ),
                FadeInLeft(
                  child: Text(
                    "Order Detail",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 23,
                        color: Colors.teal),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => myGetxController.quotationOrder.isNotEmpty
                  ? OrderQuatationCommanCard(
                      list: myGetxController.quotationOrder,
                      isOrderScreen: false,
                      backGroundColor: Colors.grey.withOpacity(0.1),
                      index: 0,
                      isDeliveryScreen: false)
                  : Container(),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Order Details : ",
                style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 21),
              ),
            ),
            Expanded(
                child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Obx(() => Column(
                    children: [
                      myGetxController.quotationDetailOrderList.isNotEmpty
                          ? ListView.builder(
                              physics: BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: myGetxController
                                  .quotationDetailOrderList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return OrderQuotationDetailCard(
                                  orderDetailsList:
                                      myGetxController.quotationDetailOrderList,
                                  index: index,
                                  productDetail: myGetxController
                                      .quotationDetailProductDetailList,
                                  isOrderScreen: false,
                                  orderId: widget.id ?? 0,
                                  isDeliveryScreen: false,
                                  isReceiveScreen: false,
                                );
                              })
                          : Container(),
                      myGetxController.quotationOrder.isNotEmpty
                          ? OrderQuotationAmountCard(
                              list: myGetxController.quotationOrder)
                          : Container(),
                      SizedBox(
                        height: 15,
                      )
                    ],
                  )),
            )),
          ],
        ),
      ),
    );
  }

  Navigate() {
    if (editQuotationCount == 1) {
      for (int i = 1; i <= editQuotationCount * 3; i++) {
        Navigator.pop(context);
      }
    } else {
      for (int i = 1;
          i <= editQuotationCount * 3 - (editQuotationCount - 1);
          i++) {
        Navigator.pop(context);
      }
    }
  }

  onWillPopNavigateFunction() {
    widget.isFromAnotherScreen == false
        ? Navigator.pop(context, true)
        : widget.isFromEditScreen == false
            ? pushMethod(context, QuatationScreen())
            : Navigate();
  }
}

class CustomFABWidget extends StatelessWidget {
  final ContainerTransitionType? transitionType;
  final bool isCreateOrder;

  CustomFABWidget({
    Key? key,
    @required this.transitionType,
    required this.isCreateOrder,
  }) : super(key: key);
  MyGetxController myGetxController = Get.find();
  double fabSize = 56;

  @override
  Widget build(BuildContext context) => OpenContainer(
        transitionDuration: Duration(milliseconds: 800),
        openBuilder: (context, _) => isCreateOrder == true
            ? CreateOrder()
            : QuotationDetailAddProduct(
                deliveryDate: DateFormat("dd/MM/yyyy").format(DateTime.parse(
                    myGetxController.quotationOrder[0]['delivery_date'])),
                returnDate: DateFormat("dd/MM/yyyy").format(DateTime.parse(
                    myGetxController.quotationOrder[0]['return_date'])),
                orderId: myGetxController.quotationOrder[0]['id'],
              ),
        closedShape: CircleBorder(),
        closedColor: Colors.teal,
        closedBuilder: (context, openContainer) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.teal,
          ),
          height: fabSize,
          width: fabSize,
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      );
}
