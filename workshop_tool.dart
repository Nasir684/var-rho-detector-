import 'package:flutter/material.dart';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import '../var_rho_engine.dart';

class WorkshopToolScreen extends StatefulWidget { @override State<WorkshopToolScreen> createState()=>_WorkshopState(); }

class WorkshopState extends State<WorkshopToolScreen> {
List<double> magBuf=[], vibBuf=[];
double magVar=0, vibVar=0, crossRho=0;
String diagnosis="Analyzing..."; Color diagColor=Colors.grey;
List<Map<String,dynamic>> events=[];
@override void initState(){
super.initState();
List<double> magX=[], accMag=[];
magnetometerEventStream(samplingPeriod: Duration(milliseconds: 20)).listen((e){ magX.add(sqrt(e.xe.x + e.ye.y + e.ze.z)); });
accelerometerEventStream(samplingPeriod: Duration(milliseconds: 20)).listen((e){
accMag.add(sqrt(e.xe.x + e.ye.y + e.ze.z));
if(magX.length>=30 && accMag.length>=30){
var r = VarRhoEngine.analyze(magX, accMag);
setState((){
magVar = VarRhoEngine.variance(magX); vibVar = VarRhoEngine.variance(accMag); crossRho = r['Rho'];
if(magVar>1000 && vibVar>1000 && crossRho.abs()>0.8){ diagnosis="SWARM-GLOBAL EMI\nShared power supply / ground loop"; diagColor=Colors.red; }
else if(magVar>1000){ diagnosis="MAGNETIC EMI ONLY\nCharger / magnet / speaker"; diagColor=Colors.orange; }
else if(vibVar>1000){ diagnosis="VIBRATION EMI ONLY\nMotor imbalance / bearing"; diagColor=Colors.orange; }
else if(magVar>500 || vibVar>500){ diagnosis="LOW-LEVEL EMI\nMove closer"; diagColor=Colors.yellow.shade700; }
else { diagnosis="CLEAN\nNo EMI"; diagColor=Colors.green; }
if(r['pass']){ events.insert(0, {'time': DateTime.now().toString().substring(11,19), 'magVar': magVar, 'vibVar': vibVar, 'rho': crossRho, 'diag': diagnosis}); if(events.length>30) events.removeLast(); }
});
magX.clear(); accMag.clear();
}
});
}
@override Widget build(BuildContext ctx){
return Scaffold(appBar: AppBar(title: Text("Workshop Tool"), backgroundColor: Colors.black87),
body: Column(children: [
Container(width: double.infinity, color: diagColor, padding: EdgeInsets.all(14), child: Text(diagnosis, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
Padding(padding: EdgeInsets.all(8), child: Row(children: [Expanded(child: _meter("Mag Var", magVar, 1000)), SizedBox(width: 8), Expanded(child: _meter("Vib Var", vibVar, 1000)), SizedBox(width: 8), Expanded(child: _meter("Rho", crossRho.abs(), 0.8))])),
Expanded(child: ListView.builder(itemCount: events.length, itemBuilder: (,i){ final e=events[i]; return ListTile(dense:true, title: Text("{e['magVar'].toStringAsFixed(0)} Vib {e['rho'].toStringAsFixed(2)}", style: TextStyle(fontSize: 10))); }))
]));
}
Widget _meter(String label, double val, double thr){ bool alert = val>thr; return Card(child: Padding(padding: EdgeInsets.all(8), child: Column(children: [Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), Text(val.toStringAsFixed(val<1?2:0), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: alert?Colors.red:Colors.black)), LinearProgressIndicator(value: (val/thr).clamp(0,1).toDouble(), color: alert?Colors.red:Colors.green)]))); }
}

class HiddenDeviceScreen extends StatelessWidget {
@override Widget build(BuildContext ctx){ return Scaffold(appBar: AppBar(title: Text("Hidden Device Finder"), backgroundColor: Colors.purple), body: Center(child: Padding(padding: EdgeInsets.all(20), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search, size: 80, color: Colors.purple), SizedBox(height: 20), Text("Walk slowly near walls. Var>1000 = magnet/electronics found.", textAlign: TextAlign.center), SizedBox(height: 20), ElevatedButton(onPressed: ()=> Navigator.push(ctx, MaterialPageRoute(builder: (_)=>WorkshopToolScreen())), child: Text("Start Scanning"))])))); }
}
