* in this version:
*** Investment cost added to the model
*** purchased or sale power modelled
*** Income term added plus Ppur (purchased from network) and Psale(sold to network)
*** pv cells added to model. P(pv,t) is output parameter, SI(pv) is planning state of each pv
* obj func is cost minimization
* equality of ESS's energy level at times 0 and 24 is essential
* min on time and offtime have been commented out
* 1.1Pd used stead of spinning reserve requirement
Sets
i index of generating(NG) units /1*3/
t index of hour /1*24/
d inex of days /1*4/
y index of year /1*10/
e index of ESS systems /1*3/
*n number of segments of piecewise linear cost of units i /1/
pv set of solar pv panels /1*3/ ;
Alias(tt,t);
Parameters
*e(pv) efficiency of pv cell
YY(y) numerical value of each year
        / 1      1
          2      2
          3      3
          4      4
          5      5
          6      6
          7      7
          8      8
          9      9
          10     10 /
Cap(pv) capacity of pv candidates
        / 1      500
          2      1000
          3      2000 /
AnCost_pv(pv) Annual Cost of pv installation $perKw
        /1       1.065
         2       2.130
         3       4.260/
AnCost_ess(e) Annual cost of storage systems
         /1      1000
          2      2000
          3      3000/
Ps(y,d,t) output power of pv cell equal to efficiency times global irradiance at time t
Aninv(i) Annual investment cost of unit i
         /1     1000
          2     2000
          3     3000  /
MC(i) Min production cost of unit i
       / 1       .75
         2       .20
         3       .40 /
LMP(y,d,t) price of energy at each hour t
Pmin(i) min KW power of unit i
        / 1      1000
          2      1500
          3      2000 /
Pmax(i) max KW power of unit i
        / 1      10000
          2      30000
          3      60000 /
K(i) Sturtup cost of unit i
        / 1      7.35
          2      45
          3      95
         /
J(i) Shutdown cost of unit i
        / 1      1.5
          2      8.5
          3      15.3 /
RU(i) Ramp-Up limit (KWperHour)
        /1       250
         2       450
         3       600  /
RD(i) Ramp-Down
         /1      250
          2      450
          3      660  /

RC(e) Rate of Charge of storage e
         /1      200
          2      330
          3      500 /
RDC(e) Rate of Discharge e
         /1     200
          2     330
          3     500 /
*Ton(i) min on time of unit i
*Toff(i) min off time of unit i
SUR(i) Startup Ramp of unit i (KWperHour)
         /1      2500
          2      4500
          3      6000 /
SDR(i) Shutdown Ramp of unit i (KWperHour)
         /1      2500
          2      4500
          3      6000 /
Einit(e) init energy stored in ESS system e
         /1      800
          2      2400
          3      4000 /
Emin(e) min Energy stored in ESS system e at time t
         /1       0
          2       0
          3       0 /
Emax(e) max
         /1      2000
          2      6000
          3      10000 /

PR(e) power rating of ESS
         /1      500
          2      1000
          3      1500 /
Pd(y,d,t) Load demand at time t
*SRR(y,d,t) Spinning Reserve requirement of system at time t
 ;
$ call gdxxrw LMPs.xlsx par LMP rng=sheet3!A1:AA41 rdim=2 cdim=1
$ gdxin LMPs.gdx
$ load LMP
$ gdxin
$ call gdxxrw Solar.xlsx par Ps rng=Psolar!A1:AA41 rdim=2 cdim=1
$ gdxin Solar.gdx
$ load Ps
$ gdxin
$ call gdxxrw Demand.xlsx par Pd rng=Sheet1!A1:AA41 rdim=2 cdim=1
$ gdxin Demand.gdx
$ load Pd
$ gdxin

display LMP, Ps, Pd ;

parameter m(i) slope of segment n of cost func of unit i at t
       /
          1      0.125
          2      1.2
          3      1.1881 / ;

parameter Pnmax(i) max power for each segment
       /
          1      1000
          2      3000
          3      6000  / ;
Scalar
roi rate of interest /.1/
LCC Load Curtailment Cost /1000000/
Ce Charge Efficiency /0.95/
DCe Discharge Eff /0.95/
;

Variable

Aninvcost(y) Annual cost of investments yearly
Income(y) from selling power to Network yearly
OpCost(y) Operation cost yearly
NPV Net Present Value of total costs ;

Binary Variables
II(i,y,d,t) Commitment state of unit i at time t
S(i) planning state of each unit
SI(pv) planning state of each pv cell
EI(e) planing state of each ESS
U(e,y,d,t) 0 or 1 for charge or discharge of ESS ;

Positive Variables
SU(i,y,d,t) Startup cost of unit i at time t
SD(i,y,d,t) Shutdown cost of unit i at time t
PMG(i,y,d,t) Real Power scheduled for unit i at time t
Pn(i,y,d,t) power scheduled for unit i in segment n at time t
LC(y,d,t) Load Curtailment
En(e,y,d,t) Energy stored in ESS system e at time t
C(e,y,d,t) Charge power of ESS system e at time t
Dc(e,y,d,t) discharge power of ESS system e at time t
Ppur(y,d,t) P purchased from main Network at the price of LMP
Psale(y,d,t) P sold to Network at price of LMP ;

Equations
        obj_func   objective function
        prim_Aninvcost        annual cost
*        P_eq
        prim_state_commit
        gen_min
        gen_max
        SU_eq
        SD_eq
*       7min_ontime
*       8min_offtime
*        rampup_limit
*        rampdn_limit
        ESS_balance
        ESS_init
        ESS_min
        ESS_max
        discharge_limit
        charge_limit
        state_of_ESS
        discharge_rate_min
        discharge_rate_max
        charge_rate_min
        charge_rate_max
        power_balance
        Reserve
        Income_eq
        OpCost_eq ;

obj_func.. NPV =e= sum(y,(AnInvcost(y) + OpCost(y) - Income(y))/((1+roi)**YY(y))) ;
prim_Aninvcost(y).. Aninvcost(y) =e= sum(i, DG_param(i,'IC')*S(i)) + sum(pv, AnCost_pv(pv)*SI(pv)) + sum(e,EI(e)*ES_param('IC')) ;
*P_eq(i,y,d,t).. Pn(i,y,d,t) =l= Pnmax(i) ;
prim_state_commit(i,y,d,t).. II(i,y,d,t) =l= S(i) ;

gen_min(i,y,d,t).. P(i,y,d,t) =g= DG_param(i,'Pmin')*II(i,y,d,t) ;
gen_max(i,y,d,t).. P(i,y,d,t) =l= DG_param(i,'Pmax')*II(i,y,d,t) ;

SU_eq(i,y,d,t).. SU(i,y,d,t) =g= DG_param(i,'SUC')*(II(i,y,d,t) - II(i,y,d,t-1)) ;
SD_eq(i,y,d,t).. SD(i,y,d,t) =g= DG_param(i,'SDC')*(II(i,y,d,t-1) - II(i,y,d,t)) ;

*7min_ontime ;
* 8min_offtime ;

*rampup_limit(i,y,d,t).. P(i,y,d,t) - P(i,y,d,t-1) =l= RU(i)*II(i,y,d,t-1) + SUR(i)*(II(i,y,d,t-1) - II(i,y,d,t)) ;
*rampdn_limit(i,y,d,t).. P(i,y,d,t-1) - P(i,y,d,t) =l= RD(i)*II(i,y,d,t) + SDR(i)*(II(i,y,d,t-1) - II(i,y,d,t)) ;

ESS_balance(e,y,d,t).. En(e,y,d,t+1) =e= En(e,y,d,t) + Ce*C(e,y,d,t) - Dc(e,y,d,t)/DCe ;
ESS_init(e,y,d,t)$(ord(t) = 0).. En(e,y,d,t) =e= ES_param(e,'Einit') ;
ESS_min(e,y,d,t).. En(e,y,d,t) =g= ES_param(e,'Emin') ;
ESS_max(e,y,d,t).. En(e,y,d,t) =l= ES_param(e,'Emax') ;

discharge_limit(e,y,d,t).. Dc(e,y,d,t) =l= U(e,y,d,t)*ES_param(e,'PR') ;
charge_limit(e,y,d,t).. C(e,y,d,t) =l= (1 - U(e,y,d,t))*ES_param(e,'PR') ;
state_of_ESS(e,y,d,t).. C(e,y,d,t) + Dc(e,y,d,t) =l= EI(e) ;
discharge_rate_min(e,y,d,t).. Dc(e,y,d,t) - Dc(e,y,d,t-1) =l= ES_param(e,'RDC') ;
discharge_rate_max(e,y,d,t).. Dc(e,y,d,t) - Dc(e,y,d,t-1) =g= -ES_param(e,'RDC') ;
charge_rate_min(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =l= ES_param(e,'RC') ;
charge_rate_max(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =g= -ES_param(e,'RC') ;

power_balance(y,d,t).. sum(i,P(i,y,d,t))
         + sum(e,Dc(e,y,d,t) - C(e,y,d,t)) + LC(y,d,t) + Ppur(y,d,t)
         + sum(pv, Cap(pv)*Ps(y,d,t)*SI(pv)) =g= Pd(y,d,t) + Psale(y,d,t);
Reserve(y,d,t).. sum(i,DG_param(i,'Pmax')*II(i,y,d,t)) =g= 1.1*Pd(y,d,t) + (Psale(y,d,t) - Ppur(y,d,t));
Income_eq(y).. Income(y) =e= sum((d,t),LMP(y,d,t)*(Psale(y,d,t) - Ppur(y,d,t))) ;
OpCost_eq(y).. OpCost(y) =e= sum((d,t),sum(i,DG_param(i,'MC')*II(i,y,d,t) + SU(i,y,d,t) + SD(i,y,d,t)
         + DG_param(i,'m')*P(i,y,d,t) + LCC*LC(y,d,t))) ;

model MGPlanning /all/ ;
option optcr = 0.0 ;
solve MGPlanning minimizing NPV using mip;

