import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'var_rho_engine.dart';
import 'categories/student_lab.dart';
import 'categories/workshop_tool.dart';

void main() => runApp(MaterialApp(home: VarRhoHome(), debugShowCheckedModeBanner: false));

class VarRhoHome extends StatefulWidget { @override State<VarRhoHome> createState()=>_VarRhoHomeState(); }

class _VarRhoHomeState extends State<VarRhoHome> {
List<double> bufX=[], bufY=[];
double liveVar=0, liveRho=0;
String status="Clean — background";
Color statusColor=Colors.green;
List<Map<String,dynamic>> log=[];
int categoryIndex=0;

@override void initState(){
super.initState();
magnetometerEventStream(samplingPeriod: Duration(milliseconds: 20)).listen((e){
bufX.add(e.x); bufY.add(e.y);
if(bufX.length>=25){
final r = VarRhoEngine.analyze(bufX, bufY);
setState((){
liveVar = r['Var']; liveRho = r['Rho'];
if(r['pass']){
status = "EMI DETECTED: ${r['type']}";
statusColor = r['type'].toString().contains('global') ? Colors.red : Colors.orange;
log.insert(0, {'time': DateTime.now().toString().substring(11,19), ...r});
if(log.length>50) log.removeLast();
} else {
status = "Clean — Var ${liveVar.toStringAsFixed(0)}";
statusColor = Colors.green;
}
});
bufX.clear(); bufY.clear();
}
});
}

Widget getScreen(){
switch(categoryIndex){
case 0: return WorkshopToolScreen();
case 1: return WorkshopToolScreen();
case 2: return StudentLabScreen(liveLog: log);
case 3: return WorkshopToolScreen();
default: return WorkshopToolScreen();
}
}

@override Widget build(BuildContext ctx){
return Scaffold(
appBar: AppBar(title: Text("Var-Rho EMI Detector"), backgroundColor: Colors.black87),
body: Column(children: [
Container(color: statusColor, width: double.infinity, padding: EdgeInsets.all(10), child: Text(status, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
Container(height: 60, child: ListView(scrollDirection: Axis.horizontal, children: [
Padding(padding: EdgeInsets.all(6), child: ChoiceChip(label: Text("Home FREE"), selected: categoryIndex==0, onSelected: (_)=>setState(()=>categoryIndex=0))),
Padding(padding: EdgeInsets.all(6), child: ChoiceChip(label: Text("Workshop \$1.99"), selected: categoryIndex==1, onSelected: (_)=>setState(()=>categoryIndex=1))),
Padding(padding: EdgeInsets.all(6), child: ChoiceChip(label: Text("Student Lab"), selected: categoryIndex==2, onSelected: (_)=>setState(()=>categoryIndex=2))),
Padding(padding: EdgeInsets.all(6), child: ChoiceChip(label: Text("Hidden Device"), selected: categoryIndex==3, onSelected: (_)=>setState(()=>categoryIndex=3))),
 ])),
Expanded(child: getScreen()),
]),
);
}
}
