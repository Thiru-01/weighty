import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:weighty/components/buttons.dart';
import 'package:weighty/utils/utils.dart';

class AgeReport extends StatelessWidget {
  final List<String> filterNames;
  final RxList<ReportDate> sourceContet;
  final int? currentlySelected;
  final Function(String selectedValue) onSelected;
  const AgeReport(
      {super.key,
      required this.filterNames,
      required this.onSelected,
      required this.sourceContet,
      this.currentlySelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReportFilterButtons(
          count: 4,
          title: filterNames,
          selectedIndex: currentlySelected ?? 0,
          onSelect: (selectedValue) => onSelected(selectedValue),
        ),
        Obx(() => SfCartesianChart(
              key: UniqueKey(),
              plotAreaBorderWidth: 0,
              annotations: sourceContet.isEmpty
                  ? [
                      CartesianChartAnnotation(
                        widget: Text(
                          "No data for selected range",
                          style: TextStyle(
                              fontSize: calculateFontSize(
                                  factor: 18, context: context),
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w800),
                        ),
                        x: '50%',
                        y: '40%',
                        coordinateUnit: CoordinateUnit.percentage,
                      )
                    ]
                  : [],
              tooltipBehavior: TooltipBehavior(
                enable: true,
                canShowMarker: true,
                activationMode: ActivationMode.singleTap,
              ),
              primaryXAxis: CategoryAxis(
                  title: AxisTitle(
                      text: "Week",
                      textStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize:
                              calculateFontSize(factor: 14, context: context),
                          fontWeight: FontWeight.w900)),
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  labelPlacement: LabelPlacement.onTicks,
                  interval:
                      sourceContet.isEmpty ? null : sourceContet.length / 4,
                  majorGridLines: const MajorGridLines(width: 0),
                  majorTickLines: const MajorTickLines(width: 0)),
              primaryYAxis: NumericAxis(
                  // For only showing the MajorGridLine
                  axisLine: const AxisLine(width: 0),
                  axisLabelFormatter: (axisLabelRenderArgs) =>
                      ChartAxisLabel("", const TextStyle()),
                  majorGridLines: MajorGridLines(
                      width: 0,
                      color: Theme.of(context).primaryColor.withOpacity(0.8)),
                  majorTickLines: const MajorTickLines(width: 0)),
              series: [
                SplineAreaSeries<ReportDate, String>(
                    dataSource: sourceContet,
                    emptyPointSettings: EmptyPointSettings(),
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                    ),
                    enableTooltip: true,
                    gradient: LinearGradient(colors: [
                      Theme.of(context).primaryColor.withOpacity(0.0002),
                      Theme.of(context).primaryColor.withOpacity(0.1),
                    ], stops: const [
                      0.0,
                      1.0
                    ], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                    color: Theme.of(context).primaryColor,
                    borderColor: Theme.of(context).primaryColor,
                    borderWidth: 4,
                    xValueMapper: (datum, index) => datum.legend,
                    yValueMapper: (datum, index) => datum.weight)
              ],
            )),
      ],
    );
  }

  List<ReportDate> _getReportData() {
    Random random = Random();
    List<ReportDate> result = [];
    DateTime currentDateTime = DateTime.now();
    DateTime thisMonthStart =
        DateTime(currentDateTime.year, currentDateTime.month, 1);
    DateTime firstMonday = thisMonthStart.add(
        Duration(days: (7 - (currentDateTime.weekday - DateTime.monday)) % 7));
    while (firstMonday.month == currentDateTime.month) {
      int randomNumber = random.nextInt(16) + 65;
      result.add(ReportDate(BasicUtils.calculateWeekOfYear(firstMonday),
          randomNumber.toDouble()));
      firstMonday = firstMonday.add(const Duration(days: 7));
    }
    return result;
  }

  List<Color> generateGradint(Color primaryColor) {
    List<Color> gradiantList = [];
    for (int i = 1; i <= 9; i = i + 9) {
      gradiantList.add(primaryColor.withOpacity(i * 0.1));
    }
    return gradiantList;
  }

  String dateFomater(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}

class ReportDate {
  final String legend;
  final double? weight;
  ReportDate(this.legend, this.weight);
}
