import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// ignore: must_be_immutable
class Chart extends StatefulWidget {
  String datatest;
  Chart({Key? key, required this.datatest}) : super(key: key);
  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late List<Data> _chartData;
  //late ChartSeriesController _chartSeriesController;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
        enablePinching: true, zoomMode: ZoomMode.xy, enablePanning: true);
    _chartData = getChartData();
    Timer.periodic(const Duration(milliseconds: 250), updateDataSource);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      zoomPanBehavior: _zoomPanBehavior,
      primaryXAxis: const NumericAxis(
        maximum: 20,
        minimum: 0,
      ),
      primaryYAxis: const NumericAxis(
        maximum: 0.4,
        minimum: 0,
      ),
      series: <CartesianSeries>[
        SplineSeries<Data, double>(
          onRendererCreated: (ChartSeriesController controller) {
            //_chartSeriesController = controller;
          },
          dataSource: _chartData,
          xValueMapper: (Data voltage, _) => voltage.time,
          yValueMapper: (Data voltage, _) => voltage.voltage,
          //markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
    );
  }

  double time = 0;
  void updateDataSource(Timer timer) {
    _chartData.add(Data(time = time + 0.25, double.parse(widget.datatest)));
    //_chartData.removeAt(0);
    //_chartSeriesController.updateDataSource(addedDataIndex: _chartData.length - 1);
  }

  List<Data> getChartData() {
    final List<Data> chartData = [];
    return chartData;
  }
}

class Data {
  Data(this.time, this.voltage);
  final double time;
  final double voltage;
}
