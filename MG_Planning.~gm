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
i index of generating(NG) units /1*8/
t index of hour /1*24/
d inex of days /1*4/
y index of year /1*10/
e index of ESS systems /1*3/
pv set of solar pv panels /1*3/
DG_par /Pmin,Pmax,IC,MC,SUC,SDC,RU,RD,m /
ES_par /PR,IC,RC,RDC,Einit,Emin,Emax /
PV_par /cap,IC/ ;
alias (t,j);
Alias(tt,t);


Parameters
DG_param(i,DG_par)
ES_param(e,ES_par)
PV_param(pv,PV_par)
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
        /1       2255000
         2       4255000
         3       8255000 /
AnCost_ess(e) Annual cost of storage systems
         /1      10170000
          2      10170000
          3      10170000 /
Ps(y,d,t) output power of pv cell equal to efficiency times global irradiance at time t
Aninv(i) Annual investment cost of unit i
        /1     100000
         2     100000
         3     250000
         4     2500000000000000
         5     5000000000000000
         6     5000000000000000
         7     7500000000000000
         8     7500000000000000  /

LMP(y,d,t) price of energy at each hour t

RC(e) Rate of Charge of storage e
         /1      200
          2      500
          3      1000 /
RDC(e) Rate of Discharge e
         /1     200
          2     500
          3     1000  /
*Ton(i) min on time of unit i
*Toff(i) min off time of unit i

Einit(e) init energy stored in ESS system e
         /1      500
          3       800
          2      1000 /
Emin(e) min Energy stored in ESS system e at time t
         /1       0
          2
          3       /
Emax(e) max
         /1      1000
          2      2000
          3      4000 /
PR(e) power rating of ESS
         /1      200
          2      400
          3      80/
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
$ call gdxxrw DG_param.xlsx par DG_param rng=sheet1!A1:J7 rdim=1 cdim=1
$ gdxin DG_param.gdx
$ load DG_param
$ gdxin
$ call gdxxrw ES_param.xlsx par ES_param rng=sheet1!A1:H7 rdim=1 cdim=1
$ gdxin ES_param.gdx
$ load ES_param
$ gdxin
$ call gdxxrw PV_param.xlsx par PV_param rng=sheet1!A1:C7 rdim=1 cdim=1
$ gdxin PV_param.gdx
$ load PV_param
$ gdxin

display LMP, Ps, Pd ;

Scalar
r rate of interest /.1/
LCC Load Curtailment Cost /10000/
Ce Charge effiency / 0.95 /
DCe Discharge effiency / 0.95 /
UF /0/
DF /0/;

Variable
Aninvcost(y) Annual cost of investments yearly
Income(y) from selling power to Network yearly
OpCost(y) Operation cost yearly
NPV Net Present Value of total costs ;

Binary Variables
II(i,y,d,t) Commitment state of unit i at time t
S(i) planning state of each unit
SI(pv) planning state of each pv cell
SII(pv,y,d,t) commit of pv
ES(e) planning state of ESS
U(e,y,d,t) 0 or 1 for charge or discharge of ESS ;

Positive Variables
SU(i,y,d,t) Startup cost of unit i at time t
SD(i,y,d,t) Shutdown cost of unit i at time t
P(i,y,d,t) Real Power scheduled for unit i at time t
LC(y,d,t) Load Curtailment
En(e,y,d,t) Energy stored in ESS system e at time t
C(e,y,d,t) Charge power of ESS system e at time t
Dc(e,y,d,t) discharge power of ESS system e at time t
Ppur(y,d,t) P purchased from main Network at the price of LMP
Psale(y,d,t) P sold to Network at price of LMP ;

Equations
        obj_func   objective function
        prim_Aninvcost        annual cost
        prim_state_commit
        gen_min
        gen_max
        SU_eq
        SD_eq
*       7min_ontime
*       8min_offtime
        rampup_limit
        rampdn_limit
        eq_pvcommit
        ESS_balance
        ESS_init
        ESS_min
        ESS_max
        discharge_limit
        charge_limit
        discharge_rate_min
        discharge_rate_max
        charge_rate_min
        charge_rate_max
        power_balance
        eq_Psale
        eq_Ppur
*        Reserve
        Income_eq
        OpCost_eq  ;
*         MIN_UP_Con
*        MIN_DN_Con
*         Min_UP_Con_1
*         Min_DN_Con_1 ;

obj_func.. NPV =e= sum(y,(AnInvcost(y) + OpCost(y) - Income(y))/((1+r)**YY(y))) ;
prim_Aninvcost(y).. Aninvcost(y) =e= sum(i, DG_param(i,'IC')*S(i)) + sum(pv, PV_param(pv,'IC')*SI(pv)) + sum(e,ES_param(e,'IC')) ;

prim_state_commit(i,y,d,t).. II(i,y,d,t) =l= S(i) ;

gen_min(i,y,d,t).. P(i,y,d,t) =g= DG_param(i,'Pmin')*II(i,y,d,t) ;
gen_max(i,y,d,t).. P(i,y,d,t) =l= DG_param(i,'Pmax')*II(i,y,d,t) ;

SU_eq(i,y,d,t).. SU(i,y,d,t) =g= DG_param(i,'SUC')*(II(i,y,d,t) - II(i,y,d,t-1)) ;
SD_eq(i,y,d,t).. SD(i,y,d,t) =g= DG_param(i,'SDC')*(II(i,y,d,t-1) - II(i,y,d,t)) ;

* 7min_ontime ;
* 8min_offtime ;
eq_pvcommit(pv,y,d,t).. SII(pv,y,d,t) =l= SI(pv) ;
rampup_limit(i,y,d,t).. P(i,y,d,t) - P(i,y,d,t-1) =l= DG_param(i,'RU') ;
rampdn_limit(i,y,d,t).. P(i,y,d,t-1) - P(i,y,d,t) =l= DG_param(i,'RD') ;

*MIN_UP_Con(i,y,d,t)$((ord(t)>=UF+1) and (ord(t)<24-DG_param(i,'4')+1))..sum(j$((ord(j)>=ord(t)) and (ord(j)<=ord(t)+DG_param(i,'4')-1)),II(i,y,d,j))=g=DG_param(i,'4')*II(i,y,d,t);
*MIN_DN_Con(i,y,d,t)$((ord(t)>=DF+1) and (ord(t)<24-DG_param(i,'4')+1))..sum(j$((ord(j)>=ord(t)) and (ord(j)<=ord(t)+DG_param(i,'4')-1)),(1-II(i,y,d,j)))=g=DG_param(i,'4')*II(i,y,d,t);

*Min_UP_Con_1(i,y,d,t)$((ord(t)>=25-DG_param(i,'4')))..sum(j$(ord(j)>=ord(t)),II(i,y,d,j)-II(i,y,d,t))=g=0;
*Min_DN_Con_1(i,y,d,t)$((ord(t)>=25-DG_param(i,'4')))..sum(j$(ord(j)>=ord(t)),(1-II(i,y,d,j)-II(i,y,d,t)))=g=0;

ESS_init(e,y,d,t)$(ord(t) = 1).. En(e,y,d,t) =e= ES_param(e,'Einit') ;
ESS_balance(e,y,d,t).. En(e,y,d,t+1) =e= En(e,y,d,t) + Ce*C(e,y,d,t) - Dc(e,y,d,t)/DCe ;
ESS_min(e,y,d,t).. En(e,y,d,t) =g= ES_param(e,'Emin')*ES(e) ;
ESS_max(e,y,d,t).. En(e,y,d,t) =l= ES_param(e,'Emax')*ES(e) ;

discharge_limit(e,y,d,t).. Dc(e,y,d,t) =l= U(e,y,d,t)*ES_param(e,'PR') ;
charge_limit(e,y,d,t).. C(e,y,d,t) =l= (1 - U(e,y,d,t))*ES_param(e,'PR') ;

discharge_rate_min(e,y,d,t).. Dc(e,y,d,t) - Dc(e,y,d,t-1) =l= ES_param(e,'RDC') ;
discharge_rate_max(e,y,d,t).. Dc(e,y,d,t) - Dc(e,y,d,t-1) =g= -ES_param(e,'RDC') ;
charge_rate_min(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =l= ES_param(e,'RC') ;
charge_rate_max(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =g= -ES_param(e,'RC') ;

eq_Psale(y,d,t).. Psale(y,d,t) =l= 20;
eq_Ppur(y,d,t).. Ppur(y,d,t) =l= 20;
power_balance(y,d,t).. sum(i,P(i,y,d,t)) + sum(e,Dc(e,y,d,t) - C(e,y,d,t)) + LC(y,d,t) +
 sum(pv, Cap(pv)*Ps(y,d,t)*SII(pv,y,d,t))+ Ppur(y,d,t) =e= Pd(y,d,t) + Psale(y,d,t);

*Reserve(y,d,t).. sum(i,DG_param(i,'2')*II(i,y,d,t)) =g= 1.1*Pd(y,d,t) + (Psale(y,d,t) - Ppur(y,d,t));
Income_eq(y).. Income(y) =e= 91.25*sum((d,t),LMP(y,d,t)*Psale(y,d,t)) ;
OpCost_eq(y).. OpCost(y) =e= 91.25*(sum((d,t), sum(i,DG_param(i,'MC')*II(i,y,d,t)
 + LMP(y,d,t)*Ppur(y,d,t) + SU(i,y,d,t) + SD(i,y,d,t) + DG_param(i,'m')*P(i,y,d,t) + LCC*LC(y,d,t)))) ;

model MGPlanning /all/ ;
option optcr = 0.01 ;
solve MGPlanning minimizing NPV using mip;

