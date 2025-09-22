// import 'package:flutter/material.dart';
// import 'package:cashfree_pg/cashfree_pg.dart';
//
// class CashfreePaymentPage extends StatefulWidget {
//   final String orderId;
//   final String orderToken;
//   final String orderAmount;
//
//   const CashfreePaymentPage({
//     super.key,
//     required this.orderId,
//     required this.orderToken,
//     required this.orderAmount,
//   });
//
//   @override
//   State<CashfreePaymentPage> createState() => _CashfreePaymentPageState();
// }
//
// class _CashfreePaymentPageState extends State<CashfreePaymentPage> {
//   @override
//   void initState() {
//     super.initState();
//     _startPayment();
//   }
//
//   void _startPayment() async {
//     try {
//       var result = await CashfreePGSDK.doPayment({
//         "orderId": widget.orderId,
//         "orderAmount": widget.orderAmount,
//         "tokenData": widget.orderToken,
//         "orderCurrency": "INR",
//         "appId": "<YOUR_CASHFREE_APP_ID>", // sandbox/live
//         "customerPhone": "9999999999",
//         "customerEmail": "test@example.com",
//       });
//
//       debugPrint("Payment Result: $result");
//       // You can navigate to success/failure page here
//     } catch (e) {
//       debugPrint("Payment error: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
