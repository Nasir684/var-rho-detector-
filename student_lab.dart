import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class StudentLabScreen extends StatefulWidget {
final List<Map<String,dynamic>> liveLog;
StudentLabScreen({required this.liveLog});
@override State<StudentLabScreen> createState() => _StudentLabState();
}

class StudentLabState extends State<StudentLabScreen> {
double varThreshold = 1000;
double rhoThreshold = 0.8;
@override Widget build(BuildContext ctx) {
List<ScatterSpot> spots = widget.liveLog.map((e){
double v = (e['Var'] as double).clamp(0, 3000);
double r = (e['Rho'] as double).abs().clamp(0, 1);
Color c = Colors.grey;
if(e['pass']==true){ c = e['type'].toString().contains('global') ? Colors.red : Colors.blue; }
return ScatterSpot(v, r*1000, color: c, radius: 5);
}).toList();
return Scaffold(
appBar: AppBar(title: Text("Student Lab — Fig2"), backgroundColor: Colors.indigo),
body: Column(children: [
Padding(padding: EdgeInsets.all(8), child: Text("DOI 10.5281/zenodo.23434145 Var>{varThreshold.toStringAsFixed(0)} Rho&gt;rhoThreshold", style: TextStyle(fontSize: 11))),
Row(children: [Expanded(child: Slider(value: varThreshold, min: 250, max: 2000, divisions: 7, label: varThreshold.toStringAsFixed(0), onChanged: (v)=>setState(()=>varThreshold=v))), Text("Var")]),
Row(children: [Expanded(child: Slider(value: rhoThreshold, min: 0.5, max: 0.95, divisions: 9, label: rhoThreshold.toStringAsFixed(2), onChanged: (v)=>setState(()=>rhoThreshold=v))), Text("Rho")]),
Expanded(child: Padding(padding: EdgeInsets.all(12), child: ScatterChart(ScatterChartData(
scatterSpots: spots, minX: 0, maxX: 3000, minY: 0, maxY: 1000,
borderData: FlBorderData(show: true), gridData: FlGridData(show: true),
titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v,)=>Text(v.toInt().toString(), style: TextStyle(fontSize: 10)))), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v,_)=>Text((v/1000).toStringAsFixed(1), style: TextStyle(fontSize: 10)))), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
extraLinesData: ExtraLinesData(verticalLines: [VerticalLine(x: varThreshold, color: Colors.red, dashArray: [5,5])], horizontalLines: [HorizontalLine(y: rhoThreshold*1000, color: Colors.red, dashArray: [5,5])])
)))),
Padding(padding: EdgeInsets.all(8), child: ElevatedButton.icon(icon: Icon(Icons.download), label: Text("Export results.json"), onPressed: () async {
final data = {"doi_reference": "10.5281/zenodo.23434145", "seed": 684, "Var_threshold": varThreshold, "Rho_threshold": rhoThreshold, "total_events": widget.liveLog.length, "events": widget.liveLog};
final dir = await getTemporaryDirectory(); final file = File("${dir.path}/results.json");
await file.writeAsString(JsonEncoder.withIndent(' ').convert(data));
await Share.shareXFiles([XFile(file.path)]);
}))
]),
);
}
}
