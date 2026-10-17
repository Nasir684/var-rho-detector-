import 'dart:math';

class VarRhoEngine {
static const double varThreshold = 1000.0;
static const double rhoThreshold = 0.8;

static double variance(List<double> x) {
if (x.isEmpty) return 0;
final m = x.reduce((a,b)=>a+b)/x.length;
return x.map((v) => pow(v-m,2).toDouble()).reduce((a,b)=>a+b)/x.length;
}

static double correlation(List<double> a, List<double> b) {
if (a.length != b.length || a.isEmpty) return 0;
final ma = a.reduce((x,y)=>x+y)/a.length;
final mb = b.reduce((x,y)=>x+y)/b.length;
double num = 0, denA = 0, denB = 0;
for(int i=0;i<a.length;i++){
num += (a[i]-ma)(b[i]-mb);
denA += pow(a[i]-ma,2);
denB += pow(b[i]-mb,2);
}
if(denA0 || denB0) return 0;
return num / sqrt(denAdenB);
}

static Map<String,dynamic> analyze(List<double> chA, List<double> chB){
final vA = variance(chA);
final vB = variance(chB);
final vMean = (vA+vB)/2;
final rho = correlation(chA, chB);
final pass = vMean > varThreshold && rho.abs() > rhoThreshold;
return {
'Var': vMean,
'VarA': vA,
'VarB': vB,
'Rho': rho,
'pass': pass,
'type': !pass ? 'background' : (rho.abs()>0.95 ? 'swarm-global EMI' : 'node-local')
};
}
}
