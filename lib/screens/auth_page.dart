import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:weighty/components/buttons.dart';
import 'package:weighty/utils/constants.dart';
import 'package:weighty/utils/utils.dart';

import '../services/firebase_auth_service.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(SizeConstrains.DEFAULT_PADDING),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset("assets/svgs/illustrations/auth-illustration.svg"),
            WeiButton(
              title: "Sign up with Google",
              svgUrl: "assets/svgs/icons/google-icon.svg",
              onTap: () async {
                await AuthService.googleAuthenticator();
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConstrains.DEFAULT_PADDING),
              child: sloganText(context),
            )
          ],
        ),
      )),
    );
  }

  RichText sloganText(BuildContext context) {
    return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: "Monitor your weight",
            style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.italic,
                fontSize: calculateFontSize(factor: 18, context: context)),
            children: [
              TextSpan(
                  text: " regularly ",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold)),
              const TextSpan(text: "stay "),
              TextSpan(
                  text: " consistent",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold)),
              const TextSpan(text: "and watch your "),
              TextSpan(
                  text: " progress unfold.",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold)),
            ]));
  }
}
