* in this version:
*** Investment cost added to the model
*** purchased or sale power modelled
*** Income term added plus Ppur (purchased from network) and Psale(sold to network)
*** pv cells added to model. P(pv,t) is output parameter, SI(pv) is planning state of each pv
* obj func is cost minimization
* min on time and offtime have been commented out
Sets
i index of generating(NG) units / /
t index of hour /0*24/
d inex of days /1*4/
y index of year /1*10/
e index of ESS systems //
n number of segments of piecewise linear cost of units i //
pv set of solar pv panels // ;

Parameters
*e(pv) efficiency of pv cell
AnCost(pv) Annual Cost of pv installation
AnCost(e) Annual cost of storage systems
P(pv,y,d,t) output power of pv cell equal to efficiency times global irradiance at time t
Aninv(i) Annual investment cost of unit i
m(i,n) slope of segment n of cost func of unit i at t
MC(i) Min production cost of unit i
LMP(y,d,t) price of energy at each hour t
Pnmax(i,n) max power for each segment
Pmin(i) min power of unit i
Pmax(i) max power of unit i
K(i) Sturtup cost of unit i
J(i) Shutdown cost of unit i
RU(i) Ramp-Up limit (MWperMin)
RD(i) Ramp-Down
RC(e) Rate of Charge of storage e
RDC(e) Rate of Discharge e
Ton(i) min on time of unit i
Toff(i) min off time of unit i
SUR(i) Startup Ramp of unit i (MWpermin)
SDR(i) Shutdown Ramp of unit i (MWperMin)
Einit(e) init energy stored in ESS system e
Emin(e) min Energy stored in ESS system e at time t
Emax(e) max
PR(e) power rating of ESS
Pd(y,d,t) Load demand at time t
SRR(y,d,t) Spinning Reserve requirement of system at time t
Ce(e) Charge Efficiency of ESS
DCe(e) Discharge Efficiency of ESS  ;

Scalar
r rate of interest
LCC Load Curtailment Cost ;

Variable
total_cost generation cost
Aninvcost(y) Annual cost of investments
Income from selling power to Network ;

Binary Variables
I(i,y,d,t) Commitment state of unit i at time t
S(i) planning state of each unit
SI(pv) planning state of each pv cell
U(e,y,d,t) 0 or 1 for charge or discharge of ESS ;

Positive Variables
SU(i,y,d,t) Startup cost of unit i at time t
SD(i,y,d,t) Shutdown cost of unit i at time t
P(i,y,d,t) Real Power scheduled for unit i at time t
Pn(i,n,y,d,t) power scheduled for unit i in segment n at time t
LC(y,d,t) Load Curtailment
E(e,y,d,t) Energy stored in ESS system e at time t
C(e,y,d,t) Charge power of ESS system e at time t
D(e,y,d,t) discharge power of ESS system e at time t
Ppur(y,d,t) P purchased from main Network at the price of LMP
Psale(y,d,t) P sold to Network at price of LMP ;

Equations
        1obj_func
        1prim_Aninvcost
        2P_eq
        2prim_state_commit
        3gen_min
        4gen_max
        5SU_eq
        6SD_eq
*        * 7min_ontime
*        * 8min_offtime
        9rampup_limit
        10rampdn_limit
        11ESS_balance
        12ESS_init
        13ESS_min
        14ESS_max
        15discharge_limit
        16charge_limit
        17discharge_rate_min
        18discharge_rate_max
        19charge_rate_min
        20charge_rate_max
        21power_balance
        22Reserve
        23Income ;

*1obj_func.. total_cost =e=AnInvcost(y) + sum(t,sum(i,MC(i)*I(i,t) + SU(i,t) + SD(i,t) + sum(n, m(n)*P(i,t,n)))) - Income ;
1prim_Aninvcost(y).. Aninvcost(y) =e= sum(i, Aninv(i)*S(i)) + sum(pv, AnCost(pv)*SI(pv)) + sum(e,Ancost(e)*C(e)) ;
2P_eq(i,t,n).. Pn(i,n,y,d,t) =l= Pnmax(i,n) ;
2prim_state_commit(i).. I(i,y,d,t) =l= S(i)
3gen_min(i,t).. P(i,y,d,t) =g= Pmin(i)*I(i,y,d,t) ;
4gen_max(i,t).. P(i,y,d,t) =l= Pmax(i)*I(i,y,d,t) ;
5SU_eq(i,t).. SU(i,y,d,t) =g= K(i)*(I(i,y,d,t) - I(i,y,d,t-1)) ;
6SD_eq(i,t).. SD(i,y,d,t) =g= J(i)*(I(i,y,d,t-1) - I(i,y,d,t)) ;
* 7min_ontime ;
* 8min_offtime ;
9rampup_limit(i,y,d,t).. P(i,y,d,t) - P(i,y,d,t-1) =l= RU(i)*I(i,y,d,t-1) + SUR(i)*(i(i,y,d,t-1) - I(i,y,d,t)) ;
10rampdn_limit(i,y,d,t).. P(i,y,d,t-1) - P(i,y,d,t) =l= RD(i)*I(i,y,d,t) + SDR(i)*(I(i,y,d,t-1) - I(i,y,d,t)) ;
11ESS_balance(e,y,d,t).. E(e,y,d,t+1) = E(e,y,d,t) + Ce(e)*C(e,y,d,t) - D(e,y,d,t)/DCe(e) ;
12ESS_init(e,y,d,t)$(ord(t) = 0).. E(e,y,d,t) =e= Einit(e) ;
13ESS_min(e,y,d,t).. E(e,y,d,t) =g= Emin(e) ;
14ESS_max(e,y,d,t).. E(e,y,d,t) =l= Emax(e) ;
15discharge_limit(e,y,d,t).. D(e,y,d,t) =l= U(e,y,d,t)*PR(e) ;
16charge_limit(e,y,d,t).. D(e,y,d,t) =g= (1 - U(e,y,d,t))*PR(e) ;
17discharge_rate_min(e,y,d,t).. D(e,y,d,t) - D(e,y,d,t-1) =l= RDC(e) ;
18discharge_rate_max(e,y,d,t).. D(e,y,d,t) - D(e,y,d,t-1) =g= -RDC(e) ;
19charge_rate_min(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =l= RC(e) ;
20charge_rate_max(e,y,d,t).. C(e,y,d,t) - C(e,y,d,t-1) =g= -RC(e) ;
21power_balance(y,d,t).. sum(i,P(i,y,d,t)) + sum(e,D(e,y,d,t) - C(e,y,d,t)) + LC(y,d,t) + Ppur(y,d,t) =e= Pd(y,d,t) - sum(pv, P(pv,y,d,t)*SI(pv)) + Psale(y,d,t);
22Reserve(y,d,t).. sum(i,Pmax(i)*I(i,t)) =g= SRR(t) + Pd(t) + (Psale(t) - Ppur(t))
23Income.. Income = sum((y,d,t),LMP(y,d,t)*(Psale(y,d,t) - Ppur(y,d,t)))