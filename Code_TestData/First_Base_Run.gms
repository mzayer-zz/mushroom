Sets
i dispatchable units / 1*40 /
t hours of the day /1*24 / ;

parameters
C(i) Capacity of units 4th one being the PV
*a(t) /1 1,2 1,3 1,4 1,5 1,6 1,7 1,8 1,9 1,10 1,11 1,12 1,13 1,14 1,15 1,16 1,17 1,18 1,19 1,20 1,21 1,22 1,23 1,24 1 /
AIC(i) Annualized Investment Cost of units
CC(i) Cost Coefficient of units
D(t) Demand of each hour t
LMP(t) Price of energy $perMWh ;

$ call gdxxrw  TestData.xlsx par C rng=Sheet1!C1:AP2 rdim=0 cdim=1
$ gdxin TestData.gdx
$ load C
$gdxin

$ call gdxxrw  TestData.xlsx par AIC rng=Sheet2!C1:AP2 rdim=0 cdim=1
$ gdxin TestData.gdx
$ load AIC
$gdxin

$ call gdxxrw  TestData.xlsx par CC rng=Sheet3!C1:AP2 rdim=0 cdim=1
$ gdxin TestData.gdx
$ load CC
$gdxin

$ call gdxxrw  TestData.xlsx par D rng=Sheet4!C1:Z2 rdim=0 cdim=1
$ gdxin TestData.gdx
$ load D
$gdxin

$ call gdxxrw  TestData.xlsx par LMP rng=Sheet5!C1:Z2 rdim=0 cdim=1
$ gdxin TestData.gdx
$ load LMP
$gdxin
Variables z, P, Pinj, income, cost
Positive Variable P(i,t) Output power of each unit i at time t
Positive Variable Pinj(t) Injected power to main grid. positive means sale
Positive Variable income(t)
Positive Variable op_cost(t)
Positive Variable inv_cost
Binary Variable a(i) Decision Variable determining the state of each unit ;

equations
obj_func objective function which is Revenue to be maximized
Gen_limit(i,t) Gen limit for each i P<Capacity
Power_balance(t) sum of all generation plus injection equal to demand
Income_eq(t) income from power injection to main grid
Op_Cost_eq(t) of operation
Inv_Cost_eq   of investment ;

obj_func..  z =e= 20*8760*sum(t,income(t) - op_cost(t)) - inv_cost ;
Gen_limit(i,t).. P(i,t) =l= a(i)*C(i) ;
Power_balance(t).. sum(i,P(i,t)) =e= D(t) + Pinj(t) ;
Income_eq(t).. income(t) =e= LMP(t)*Pinj(t) ;
Op_Cost_eq(t).. op_cost(t) =e= sum(i, CC(i)*P(i,t)) ;
Inv_Cost_eq.. inv_cost =e= sum(i,a(i)*C(i)*AIC(i)*20) ;

option optca=0;
option optcr=0;

Model MG_Planning /all/ ;
Solve MG_Planning using MIP maximizing z ;
Display z.l,a.l, P.l,Pinj.l
