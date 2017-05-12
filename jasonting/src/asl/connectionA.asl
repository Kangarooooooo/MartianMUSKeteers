// Agent sample_agent in project jasonting

/* Initial beliefs and rules */

/* Initial goals */
!start.
/* Plans */
	
+!start : needToCharge & not atChargingStation & closest_facility(chargingStationList, Facility) <-
	!!start;
	+chargingStationList([]); 
	goto(charginStation0).

+!start : not needToCharge & (not atChargingStation | finishedCharging)<-
	!!start;
	goto(shop3).

+!start : atChargingStation & not finishedCharging <-
	!!start;
	charge.
 
needToCharge:-charge(Power)&role(Role,Speed,_,MaxBattery,_)&Power<(100+MaxBattery/20).

atChargingStation:-chargingStation(chargingStation0,CLAT,CLON,_) &  lat(LAT) & lon(LON) & CLAT == LAT & CLON == LON.

finishedCharging:-role(Role,Speed,Load,MaxBattery,List)&charge(Power)&Power==MaxBattery.
doJob(JobID, StorageID):-job(JobID,StorageID,_,_,_,RequiredList)&RequiredList=[T|L].//[required(item16,2),required(item12,2)]).
//job(JobID,storage0,6255,18,151,[required(item16,2),required(item12,2)]).
//item(item0,78)[entity(connectionA6),source(percept)]. 

closest_facility(List, Facility) :- role(Role, _, _, _, _) & java.actions.closestFinder(Role, List, Facility, lat(LAT), lon(LON)).

@chargingStationList[atomic]
+chargingStation(ChargingStationID,LAT,LON,_) 
: chargingStationList(List) & not .member(ChargingStationID,List)
<- -+chargingStationList([[ChargingStationID,LAT,LON]|List]).