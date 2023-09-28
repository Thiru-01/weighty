import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:weighty/components/buttons.dart';
import 'package:weighty/models/wei_model.dart';
import 'package:weighty/services/firestore_service.dart';
import 'package:weighty/utils/constants.dart';
import 'package:weighty/utils/utils.dart';

class WeiCard extends StatelessWidget {
  final WeiData model;
  final VoidCallback? onNavigationEnd;
  const WeiCard({super.key, required this.model, this.onNavigationEnd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeConstrains.DEFAULT_PADDING),
      child: InkWell(
        onTap: () async {
          await Get.to(() => WeiCardDetail(
                data: model,
              ));
          if (onNavigationEnd != null) {
            onNavigationEnd!(); //Calling for refersh callback
          }
        },
        child: Container(
          width: double.infinity,
          height: calculateHeight(factor: 0.08, context: context),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  blurRadius: 2,
                  offset: const Offset(0, 0),
                  spreadRadius: 0.01)
            ],
            borderRadius: BorderRadius.circular(1),
          ),
          child: buildCard(context),
        ),
      ),
    );
  }

  Row buildCard(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft:
                          Radius.circular(SizeConstrains.DEFAULT_BORDER_RADIUS),
                      topLeft: Radius.circular(
                          SizeConstrains.DEFAULT_BORDER_RADIUS))),
            )),
        Expanded(
            flex: 99,
            child: Container(
              padding: EdgeInsets.all(SizeConstrains.DEFAULT_PADDING),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      model.date,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RichText(
                        text: TextSpan(
                            text: model.weight,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: calculateFontSize(
                                    factor: 14, context: context),
                                color: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.color ??
                                    Colors.black),
                            children: [
                          TextSpan(
                              text: " KG",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w900))
                        ]))
                  ],
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Description: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Flexible(
                      child: Text(
                        model.description ?? "--",
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(fontWeight: FontWeight.w100),
                      ),
                    )
                  ],
                )
              ]),
            ))
      ],
    );
  }
}

class WeiCardDetail extends StatelessWidget {
  final WeiData data;
  const WeiCardDetail({super.key, required this.data});
  @override
  Widget build(BuildContext context) {
    FirestoreCURDService service = FirestoreCURDService(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wei Page"),
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
        child: Column(
          children: [
            _buildRowOfData(title: "Date", result: data.date, context: context),
            _buildRowOfData(
                title: "Weight", result: data.weight, context: context),
            _buildRowOfData(
                title: "Description",
                result: data.description ?? "--",
                context: context),
            if (data.imagePath != null)
              _buildColumOfImage(
                  title: "Image", link: data.imagePath!, context: context),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConstrains.DEFAULT_PADDING),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeiButton(
                    title: "Delete",
                    icon: FontAwesomeIcons.trash,
                    color: Colors.red,
                    onTap: () async {
                      DateTime dateOfParsed =
                          DateFormat("dd/MM/yyyy").parse(data.date);
                      User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser != null) {
                        await service.delete(
                            path:
                                "${currentUser.uid}/${BasicUtils.calculateWeekOfYear(dateOfParsed)}-${dateOfParsed.year}");
                      }
                      Get.back();
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildColumOfImage(
      {required String title,
      required String link,
      required BuildContext context}) {
    printInfo(info: link);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(vertical: SizeConstrains.DEFAULT_PADDING),
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: calculateFontSize(factor: 22, context: context)),
          ),
        ),
        Padding(
          padding:
              EdgeInsets.symmetric(vertical: SizeConstrains.DEFAULT_PADDING),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(SizeConstrains.DEFAULT_BORDER_RADIUS),
            child: CachedNetworkImage(
              imageUrl: link,
              height: calculateHeight(factor: 0.4, context: context),
              width: double.maxFinite,
              fit: BoxFit.cover,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRowOfData(
      {required String title,
      required String result,
      required BuildContext context}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConstrains.DEFAULT_PADDING),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 30,
            child: Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: calculateFontSize(factor: 22, context: context)),
            ),
          ),
          Expanded(
            flex: 70,
            child: Text(
              result,
              textAlign: TextAlign.right,
              style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.bold,
                  fontSize: calculateFontSize(factor: 22, context: context),
                  color: Theme.of(context).primaryColor),
            ),
          )
        ],
      ),
    );
  }
}
