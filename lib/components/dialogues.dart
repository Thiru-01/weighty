// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:weighty/utils/constants.dart';
import 'package:weighty/utils/utils.dart';

enum DialogueType { ERROR, WARNING, SUCCESS, LOADING }

class WeiDialogues extends StatelessWidget {
  final DialogueType dialogueType;
  final String message;
  const WeiDialogues(
      {super.key, required this.message, required this.dialogueType});

  @override
  Widget build(BuildContext context) {
    switch (dialogueType) {
      case DialogueType.ERROR:
        return buildForError(context);
      case DialogueType.WARNING:
        return buildForWarning(context);
      case DialogueType.SUCCESS:
        return buildForSuccess(context);
      case DialogueType.LOADING:
        return buildForLoading(context);
    }
  }

  Widget buildForError(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.circleXmark, color: Colors.red),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
          child: Text(
            message,
            style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w800,
                fontSize: calculateFontSize(factor: 16, context: context)),
          ),
        )
      ],
    );
  }

  Widget buildForWarning(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.circleExclamation, color: Colors.yellow),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
          child: Text(
            message,
            style: TextStyle(
                color: Colors.yellow,
                fontWeight: FontWeight.w800,
                fontSize: calculateFontSize(factor: 16, context: context)),
          ),
        )
      ],
    );
  }

  Widget buildForSuccess(BuildContext context) {
    return Row(
      children: [
        const Icon(FontAwesomeIcons.circleCheck, color: Colors.green),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
          child: Text(
            message,
            style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w800,
                fontSize: calculateFontSize(factor: 16, context: context)),
          ),
        )
      ],
    );
  }

  Widget buildForLoading(BuildContext context) {
    return SizedBox(
        height: calculateHeight(factor: 0.15, context: context),
        width: calculateWidth(factor: 0.35, context: context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            Padding(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConstrains.DEFAULT_PADDING * 2),
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            )
          ],
        ));
  }
}

class WeiNotifiers {
  final DialogueType type;
  late final String message;
  WeiNotifiers(this.type, this.message);

  void openDialogues(
      {required BuildContext context,
      DialogueType? dialogueType,
      String? dialogueMessage,
      Widget? content}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (context) =>
          content ??
          Dialog(
            child: WeiDialogues(
                message: dialogueMessage ?? message,
                dialogueType: dialogueType ?? type),
          ),
    );
  }

  void closeDialogue({required BuildContext context}) {
    Navigator.pop(context);
  }

  void openSnackBar(
      {required BuildContext context,
      DialogueType? snackType,
      String? snackMessage}) {
    printInfo(info: "Opening snack bar");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        dismissDirection: DismissDirection.vertical,
        content: WeiDialogues(
            message: snackMessage ?? message,
            dialogueType: snackType ?? type)));
  }
}

abstract class WeiNotifierDelegate {
  final WeiNotifiers notifiers =
      WeiNotifiers(DialogueType.SUCCESS, "Successfully added");
}
