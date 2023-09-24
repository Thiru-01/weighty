import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:weighty/components/buttons.dart';
import 'package:weighty/models/wei_model.dart';
import 'package:weighty/services/firestore_service.dart';
import 'package:weighty/utils/constants.dart';
import 'package:weighty/utils/utils.dart';

class AddTracker extends StatefulWidget {
  const AddTracker({super.key});

  @override
  State<AddTracker> createState() => _AddTrackerState();
}

class _AddTrackerState extends State<AddTracker> {
  TextEditingController dateController = TextEditingController();
  Map<String, dynamic> rawData = {};
  Rx<Uint8List> imageData = Uint8List(0).obs;
  Rx<String?> fileName = null.obs;
  GlobalKey<FormState> formKey = GlobalKey();
  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Details"),
      ),
      body: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConstrains.DEFAULT_PADDING),
                  child: TextFormField(
                    controller: dateController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return "Please provide the date";
                      }

                      if (DateFormat("dd-MMM-yyyy")
                          .parse(value)
                          .isAfter(DateTime.now())) {
                        return "Date can't be future date";
                      }
                      return null;
                    },
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    readOnly: true,
                    onTap: () async {
                      DateTime? selectedTime = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2001),
                          lastDate: DateTime(DateTime.now().year + 1000));
                      dateController.text = DateFormat("dd-MMM-yyyy")
                          .format(selectedTime ?? DateTime.now());
                      rawData[WeiDataKeys.DATA] = DateFormat("dd/MM/yyyy")
                          .format(selectedTime ?? DateTime.now());
                    },
                    decoration: InputDecoration(
                        icon: Icon(
                          Icons.calendar_month,
                          color: Theme.of(context).disabledColor,
                        ),
                        border: const OutlineInputBorder(),
                        hintStyle:
                            const TextStyle(fontWeight: FontWeight.normal),
                        hintText: "DD/MM/YYYY"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConstrains.DEFAULT_PADDING),
                  child: TextFormField(
                    onChanged: (value) => rawData[WeiDataKeys.WEIGHT] = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please provide the weight";
                      }
                      return null;
                    },
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintStyle:
                            const TextStyle(fontWeight: FontWeight.normal),
                        icon: Icon(
                          FontAwesomeIcons.weightScale,
                          color: Theme.of(context).disabledColor,
                        ),
                        hintText: "Enter your weight"),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConstrains.DEFAULT_PADDING),
                  child: TextFormField(
                    onChanged: (value) =>
                        rawData[WeiDataKeys.DESCRIPTION] = value,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                    decoration: InputDecoration(
                        hintText: "Enter some description",
                        hintStyle:
                            const TextStyle(fontWeight: FontWeight.normal),
                        border: const OutlineInputBorder(),
                        icon: Icon(
                          FontAwesomeIcons.solidComment,
                          color: Theme.of(context).disabledColor,
                        )),
                  ),
                ),
                Obx(() => buildImageProvider(context)),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConstrains.DEFAULT_PADDING),
                  child: WeiButton(
                    title: "Add Record",
                    width: double.maxFinite,
                    onTap: () async {
                      if (formKey.currentState != null &&
                          formKey.currentState!.validate()) {
                        WeiData data = WeiData.fromJson(rawData);
                        //Starting the details adding prorcess
                        FirestoreCURDService service =
                            FirestoreCURDService(context);
                        await service.uploadDetails(
                            data, imageData.value, fileName.split(".")?.last);
                        //After uploading just back to the previous page
                        Get.back();
                        //After poping have to perform rendering of the future builder
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding buildImageProvider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConstrains.DEFAULT_PADDING),
      child: imageData.value.isEmpty
          ? Container(
              height: calculateHeight(factor: 0.05, context: context),
              width: calculateWidth(factor: 0.05, context: context),
              decoration: BoxDecoration(
                  color: Theme.of(context).hoverColor, shape: BoxShape.circle),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                    SizeConstrains.DEFAULT_BORDER_RADIUS * 5),
                onTap: () async {
                  ImagePicker picker = ImagePicker();
                  XFile? pickedFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    imageData.value = (await pickedFile.readAsBytes());
                    fileName.value = pickedFile.name;
                    imageData.refresh();
                  }
                },
                child: Icon(
                  FontAwesomeIcons.plus,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: () async {
                      imageData.value = Uint8List(0);
                      imageData.refresh();
                    },
                    child: Icon(
                      FontAwesomeIcons.xmark,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ),
                Expanded(
                  flex: 95,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: SizeConstrains.DEFAULT_PADDING * 1.5),
                    child: InkWell(
                      onTap: () async {
                        await picker();
                      },
                      borderRadius: BorderRadius.circular(
                          SizeConstrains.DEFAULT_BORDER_RADIUS),
                      child: Container(
                        width: double.infinity,
                        height: calculateHeight(factor: 0.15, context: context),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                SizeConstrains.DEFAULT_BORDER_RADIUS),
                            image: DecorationImage(
                                image: Image.memory(imageData.value).image,
                                fit: BoxFit.fitWidth)),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).disabledColor,
                              borderRadius: BorderRadius.circular(
                                  SizeConstrains.DEFAULT_BORDER_RADIUS)),
                          child: Center(
                            child: Icon(
                              FontAwesomeIcons.arrowsRotate,
                              color: Theme.of(context).indicatorColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Future<void> picker() async {
    ImagePicker picker = ImagePicker();
    XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageData.value = (await pickedFile.readAsBytes());
      fileName.value = pickedFile.name;
      imageData.refresh();
      return;
    }
    imageData.value = Uint8List(0);
    fileName.value = null;
    imageData.refresh();
  }
}
