import 'package:flutter/material.dart';
import 'package:weighty/utils/constants.dart';
import 'package:weighty/utils/utils.dart';

class DateField extends StatefulWidget {
  const DateField({super.key});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  TextEditingController dayController = TextEditingController();
  TextEditingController monthController = TextEditingController();
  TextEditingController yearController = TextEditingController();

  @override
  void dispose() {
    dayController.dispose();
    monthController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: calculateHeight(factor: 0.06, context: context),
      decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(SizeConstrains.DEFAULT_BORDER_RADIUS),
          border: Border.all(width: 2, color: Theme.of(context).primaryColor)),
      child: Row(
        children: [
          buildCustomDateField(context),
          Expanded(
              flex: 15,
              child: GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.date_range,
                    color: Colors.grey,
                  )))
        ],
      ),
    );
  }

  Expanded buildCustomDateField(BuildContext context) {
    return Expanded(
      flex: 85,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
        child: Row(
          children: [
            SizedBox(
              height: calculateHeight(factor: 0.06, context: context),
              width: calculateWidth(factor: 0.02, context: context),
              child: TextFormField(
                maxLength: 2, //For date
                textAlign: TextAlign.center,
                onChanged: (value) {
                  if (value.length == 2) {
                    FocusScope.of(context).nextFocus();
                  }
                },
                decoration: const InputDecoration(
                    hintText: "dd",
                    border: InputBorder.none,
                    counter: SizedBox.shrink()),
              ),
            ),
            buildDelimeter(context),
            SizedBox(
              height: calculateHeight(factor: 0.06, context: context),
              width: calculateWidth(factor: 0.03, context: context),
              child: TextFormField(
                textAlign: TextAlign.center,
                maxLength: 2, //For month
                onChanged: (value) {
                  if (value.length == 2) {
                    FocusScope.of(context).nextFocus();
                  }

                  if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }
                },
                decoration: const InputDecoration(
                    hintText: "mm",
                    border: InputBorder.none,
                    counter: SizedBox.shrink()),
              ),
            ),
            buildDelimeter(context),
            SizedBox(
              height: calculateHeight(factor: 0.06, context: context),
              width: calculateWidth(factor: 0.04, context: context),
              child: TextFormField(
                maxLength: 4, //For year
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: calculateFontSize(factor: 20, context: context)),
                onChanged: (value) {
                  if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }
                },
                decoration: const InputDecoration(
                    hintText: "yyyy",
                    border: InputBorder.none,
                    counter: SizedBox.shrink()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Text buildDelimeter(BuildContext context) => Text(
        "/",
        style: TextStyle(
            fontWeight: FontWeight.w100,
            fontSize: calculateFontSize(factor: 25, context: context),
            color: Colors.grey),
      );
}
