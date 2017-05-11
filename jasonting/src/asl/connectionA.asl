// Agent sample_agent in project jasonting

/* Initial goals */

!start.

/* Plans */

+!start : needToCharge <-
	!!start; 
	goto(chargingStation0).


+!start : not needToCharge <-
	!!start;
	goto(shop0).
	

needToCharge:-charge(Power)&Power<300.