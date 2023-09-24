import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weighty/utils/utils.dart';

class InternetConnectivityPage extends StatelessWidget {
  const InternetConnectivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SvgPicture.asset("assets/svgs/illustrations/no-connection.svg"),
          Text(
            "No connection, please check it...",
            style: TextStyle(
                fontSize: calculateFontSize(factor: 20, context: context),
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                fontStyle: FontStyle.italic),
          )
        ],
      )),
    );
  }
}
