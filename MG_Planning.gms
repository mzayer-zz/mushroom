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
z table /1*8/
t index of hour /1*24/
d inex of days /1*4/
y index of year /1*10/
e index of ESS systems /1/
pv set of solar pv panels /1*3/ ;
alias (t,j);
Alias(tt,t);
table DG_param(i,z)
$include "C:\Users\Mansour\Desktop\mushroom\DG_param.txt";

Parameters
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
        / 1      200
          2      200
          3      200 /
AnCost_pv(pv) Annual Cost of pv installation $perKw
        /1       2255000
         2       2255000
         3       2255000 /
AnCost_ess(e) Annual cost of storage systems
         /1      10170000 /
Ps(y,d,t) output power of pv cell equal to efficiency times global irradiance at time t
Aninv(i) Annual investment cost of unit i
        /1     100000
         2     100000
         3     250000
         4     250000
         5     500000
         6     500000
         7     750000
         8     750000  /

LMP(y,d,t) price of energy at each hour t

RC(e) Rate of Charge of storage e
         /1      200 /
RDC(e) Rate of Discharge e
         /1     200 /
*Ton(i) min on time of unit i
*Toff(i) min off time of unit i

Einit(e) init energy stored in ESS system e
         /1      800 /
Emin(e) min Energy stored in ESS system e at time t
         /1       0 /
Emax(e) max
         /1      1000 /
PR(e) power rating of ESS
         /1      200 /
Pd(y,d,t) Load demand at time t
*SRR(y,d,t) Spinning Reserve requirement of system at time t
Ce(e) Charge Efficiency of ESS
       / 1        0.95 /
DCe(e) Discharge Efficiency of ESS
       / 1       0.95 / ;
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

Scalar
r rate of interest /.2/
LCC Load Curtailment Cost /10000/
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
*        Reserve
        Income_eq
        OpCost_eq  ;
*         MIN_UP_Con
*        MIN_DN_Con
*         Min_UP_Con_1
*         Min_DN_Con_1 ;

obj_func.. NPV =e= sum(y,(AnInvcost(y) + OpCost(y) - Income(y))/((1+r)**YY(y))) ;
prim_Aninvcost(y).. Aninvcost(y) =e= sum(i, Aninv(i)*S(i)) + sum(pv, AnCost_pv(pv)*SI(pv)) + sum(e,Ancost_ess(e)) ;

prim_state_commit(i,y,d,t).. II(i,y,d,t) =l= S(i) ;

gen_min(i,y,d,t).. P(i,y,d,t) =g= DG_param(i,'1')*II(i,y,d,t) ;
gen_max(i,y,d,t).. P(i,y,d,t) =l= DG_param(i,'2')*II(i,y,d,t) ;

SU_eq(i,y,d,t).. SU(i,y,d,t) =g= DG_param(i,'7')*(II(i,y,d,t) - II(i,y,d,t-1)) ;
SD_eq(i,y,d,t).. SD(i,y,d,t) =g= DG_param(i,'8')*(II(i,y,d,t-1) - II(i,y,d,t)) ;

* 7min_ontime ;
* 8min_offtime ;

rampup_limit(i,y,d,t).. P(i,y,d,t) - P(i,y,d,t-1) =l= DG_param(i,'3') ;
rampdn_limit(i,y,d,t).. P(i,y,d,t-1) - P(i,y,d,t) =l= DG_param(i,'3') ;

*MIN_UP_Con(i,y,d,t)$((ord(t)>=UF+1) and (ord(t)<24-DG_param(i,'4')+1))..sum(j$((ord(j)>=ord(t)) and (ord(j)<=ord(t)+DG_param(i,'4')-1)),II(i,y,d,j))=g=DG_param(i,'4')*II(i,y,d,t);
*MIN_DN_Con(i,y,d,t)$((ord(t)>=DF+1) and (ord(t)<24-DG_param(i,'4')+1))..sum(j$((ord(j)>=ord(t)) and (ord(j)<=ord(t)+DG_param(i,'4')-1)),(1-II(i,y,d,j)))=g=DG_param(i,'4')*II(i,y,d,t);

*Min_UP_Con_1(i,y,d,t)$((ord(t)>=25-DG_param(i,'4')))..sum(j$(ord(j)>=ord(t)),II(i,y,d,j)-II(i,y,d,t))=g=0;
*Min_DN_Con_1(i,y,d,t)$((ord(t)>=25-DG_param(i,'4')))..sum(j$(ord(j)>=ord(t)),(1-II(i,y,d,j)-II(i,y,d,t)))=g=0;

ESS_init(e,y,d,t)$(ord(t) = 1).. En(e,y,d,t) =e= Einit(e) ;
ESS_balance(e,y,d,t).. En(e,y,d,t+1) =e= En(e,y,d,t) + Ce(e)*C(e,y,d,t) - Dc(e,y,d,t)/DCe(e) ;
ESS_min(e,y,d,t).. En(e,y,d,t) =g= Emin(e) ;
ESS_max(e,y,d,t).. En(e,y,d,t) =l= Emax(e) ;

discharge_limit(e,y,d,t).. Dc(e,y,d,t) =l= U(e,y,d,t)*PR(e) ;
charge_limit(e,y,d,t).. C(e,y,d,t) =l= (1 - U(e,y,d,t))*PR(e) ;

discharge_rate_min(e,y,d,t).. Dc(e,y,d,t) - Dc(e,y,d,t-1) =l= RDC(e) ;
discharge_rate_max(e,y,d,t).. Dc(e,y,d,t) - Dc(e,y,d,t-1) =g= -RDC(e) ;
charge_rate_min(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =l= RC(e) ;
charge_rate_max(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =g= -RC(e) ;

power_balance(y,d,t).. sum(i,P(i,y,d,t)) + sum(e,Dc(e,y,d,t) - C(e,y,d,t)) + LC(y,d,t) +
 sum(pv, Cap(pv)*Ps(y,d,t)*SI(pv))+ Ppur(y,d,t) =g= Pd(y,d,t) + Psale(y,d,t);

*Reserve(y,d,t).. sum(i,DG_param(i,'2')*II(i,y,d,t)) =g= 1.1*Pd(y,d,t) + (Psale(y,d,t) - Ppur(y,d,t));
Income_eq(y).. Income(y) =e= 91.25*sum((d,t),LMP(y,d,t)*Psale(y,d,t)) ;
OpCost_eq(y).. OpCost(y) =e= 91.25*(sum((d,t), sum(i,DG_param(i,'6')*II(i,y,d,t)
 + LMP(y,d,t)*Ppur(y,d,t) + SU(i,y,d,t) + SD(i,y,d,t) + DG_param(i,'5')*P(i,y,d,t) + LCC*LC(y,d,t)))) ;

model MGPlanning /all/ ;
option optcr = 0.0 ;
solve MGPlanning minimizing NPV using mip;

