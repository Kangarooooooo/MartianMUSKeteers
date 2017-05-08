// Agent sample_agent in project jasonting

/* Initial beliefs and rules */

/* Initial goals */

!start.

/* Plans */

+!start : true <- .print("hello world.").

+step(X) : true <-
	.print("Received step percept.").
	
+actionID(X) : true <- 
	.print("Determining my action").
	
+charge(X):X>300 <- 
	!goToChargingStation.
	
+charge(X):X<300 <-
	!goToShop.
	
+!goToShop: true<-
	goto("shop0");
	.print("Going to shop");
	!goToShop;
	.print("Going to shop AGAIN").
	
+!goToChargingStation: true<-
	goto("chargingStation0");
	.print("Going to charge");
	!goToChargingStation.
/*
+!checkCharge: charge(cd)<500<-
	.print("going to charge");
	goto("chargingStation0");
	!checkCharge.
	
+!checkCharge: charge(cd)>=500<-
	.print("not going to charge");
	goto("shop0");
	!checkCharge. */
