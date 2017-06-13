// Agent sample_agent in project jasonting

/* Initial beliefs and rules */

canDoJob(JobID):-job(JobID,_,_,_,_,RequiredList)& not (.member(required(Item,Qty),RequiredList)&item(Item,_,tools(ToolList),parts(Parts))& not( (.empty(ToolList)))).//|(.member(Tool,ToolList)&hasItem(Tool,_))
canBuildItem(Item):-item(Item,_,tools(ToolList1),parts(Parts))&not(.member(required(Item,Qty),RequiredList) & (not .empty(ToolList1)) & not canBuildItem(Item)).//(.member(X,ToolList1)&hasItem(X,_))| //Not used/finnished because we only build items that dont require tools, parts for these items can be bought not built.


needToCharge:-charge(Power)&role(Role,Speed,_,MaxBattery,_)&Power<(200+MaxBattery/20).

finnishedCharging:-role(Role,Speed,Load,MaxBattery,List)&charge(Power)&Power==MaxBattery.
atChargingStation(ChargingStationID):- chargingStation(ChargingStationID,CLAT,CLON,_) &  lat(LAT) & lon(LON) & CLAT == LAT & CLON == LON.

atStorage(StorageID):- storage(StorageID,SLAT,SLON,_,_,_) &  lat(LAT) & lon(LON) & SLAT == LAT & SLON == LON.
atShop(ShopID):- shop(ShopID,SLAT,SLON,_,_) &  lat(LAT) & lon(LON) & SLAT == LAT & SLON == LON.
atWorkShop(WorkshopID):- workshop(WorkshopID,SLAT,SLON) &  lat(LAT) & lon(LON) & SLAT == LAT & SLON == LON.


hasAllItems(JobID):-job(JobID,_,_,_,_,RequiredList)& not ( .member(required(Item,Qty),RequiredList) & not hasItem(Item,Qty) ).
readyToBuildItem(JobID,Item):-job(JobID,_,_,_,_,RequiredList) & .member(required(Item,Qty),RequiredList) & ((not hasItem(Item,_))|(hasItem(Item,Qty1)&Qty>Qty1)) & item(Item,_,_,parts(Parts))&not(.member([Part,Qty2],Parts)&(not(hasItem(Part,_))|hasItem(Part,Qty3)&Qty2>Qty3)).
readyToBuildSubItem(JobID,Part):- job(JobID,_,_,_,_,RequiredList) & .member(required(Item,Qty),RequiredList) & ((not hasItem(Item,_))|(hasItem(Item,Qty1)&Qty>Qty1)) & item(Item,_,_,parts(Parts))&.member([Part,Qty2],Parts)&(not(hasItem(Part,_))|hasItem(Part,Qty3)&Qty2>Qty3)&item(Part,_,_,parts(Parts2))&not(.empty(Parts2))&not(.member([Part2,Qty4],Parts2)&(not(hasItem(Part2,_))|hasItem(Part2,Qty5)&Qty4>Qty5)).

shopForItem(JobID,Part,ShopID,Qty2):-job(JobID,_,_,_,_,RequiredList) & .member(required(Item,Qty),RequiredList) & ((not hasItem(Item,_))|(hasItem(Item,Qty1)&Qty>Qty1)) & item(Item,_,_,parts(Parts))&(.member([Part,Qty2],Parts)&(not(hasItem(Part,_))|hasItem(Part,Qty3)&Qty2>Qty3))&shop(ShopID,_,_,_,Inventory)& .member(item(Part,_,_),Inventory).
shopForSubItem(JobID,Part2,ShopID,Qty4):-job(JobID,_,_,_,_,RequiredList) & .member(required(Item,Qty),RequiredList) & ((not hasItem(Item,_))|(hasItem(Item,Qty1)&Qty>Qty1)) & item(Item,_,_,parts(Parts))&(.member([Part,Qty2],Parts)&(not(hasItem(Part,_))|hasItem(Part,Qty3)&Qty2>Qty3)) & item(Part,_,_,parts(Parts2))&not(.empty(Parts2))&(.member([Part2,Qty4],Parts2)&(not(hasItem(Part2,_))|hasItem(Part2,Qty5)&Qty4>Qty5))&shop(ShopID,_,_,_,Inventory)& .member(item(Part2,_,_),Inventory).
/* Initial goals */
!init.

/* Plans */
+!init:true<-
	if(false&role(truck,Speed,Load,MaxBattery,ToolList)&.member(MissingTool,ToolList)& (not (hasItem(MissingTool,_)))& shop(ShopID, _, _, _, Inventory) & .member(item(MissingTool, _, _),Inventory)){
	.term2string(MissingTool,X);
	!!goBuy(ShopID,X,1,true);
	goto(ShopID);
	}
	else{
		if(role(car,Speed,Load,MaxBattery,ToolList)){
		!!choseJob;
		skip;
		}
		else{
			!!skip;
			skip;
		}
	}
	.
	/* +!choseChargingStation:lat(AgentLat)&lon(AgentLon)<-
		Dist = 8000;
		for(chargingStation(arg,arg,Lat,Lon)){
			if(actios.dist(AgentLat,AgentLon,Lat,Lon)<Dist){
				Dist = actios.dist(AgentLat,AgentLon,Lat,Lon);
			}
		}
		!!recharge(Lat,Lon);
		goto(Lat,Lon);
	.*/
+!skip:true<-
!!skip;
skip;
.

+!choseJob:true<-
	if(canDoJob(JobID)&job(JobID,Start,End,Rewawrd,Storage,RequiredList)){
		.print("JobID ",JobID," Start ",Start," End ",End," Rewawrd ",Rewawrd," Storage ",Storage," RequiredList ",RequiredList);
		+activeJob(JobID);
		!!decide;
		skip;
	}
	else{
		!!choseJob;
		skip
	}
	.
	
+!decide:activeJob(JobID)<-
	if(needToCharge){
		!!recharge;
		skip;
	}
	else{
		if(hasAllItems(JobID)){
			!!standAndDeliver(JobID);// add logic for delivering for JobID
			skip;
		}
		else{
			if(readyToBuildItem(JobID, Item)){//check if we can construct an item thats required
				!!goBuild(Item);
				skip;
			}else{
				if(readyToBuildSubItem(JobID,Item)){
					.print("Going to build ", Item)
					!!goBuild(Item);
					skip;
				}
				else{//go buy items so that we can construct item
					if(shopForSubItem(JobID,Part,Shop,Qty)){
							!!goBuy(Shop, Part, Qty, false);
							goto(Shop);
					}
					else{
						if(shopForItem(JobID,Part,Shop,Qty)){
							!!goBuy(Shop, Part, Qty, false);
							goto(Shop);
						}
						else{
							.print("Dont shop?");
							!!decide;
							skip;
						}
					}
				
				}
			}
				
				
			//!!goShop;//!!goBuild//;
			//!!decide;
			//goto(shop0);
		}
	}
	.
+!decide:not activeJob(JobID)<-
	!!choseJob;
	skip
	.

	
-job(JobID,_,_,_,_,_):activeJob(JobID)<-
	-activeJob(JobID)
	skip;
	.
+!recharge : needToCharge & not atChargingStation(chargingStation1) <-
    /*!!choseCharging(Chosen);
    skip;
    .print("Chose station ", Chosen)*/
    //!closest;
	!!recharge; 
	goto(chargingStation1).

+!recharge : not needToCharge & (not atChargingStation(chargingStation1) | finnishedCharging)<-
	!!decide.

+!recharge : atChargingStation(chargingStation1) & not finnishedCharging <-
	!!recharge;
	charge.
 
 
+!choseCharging(Chosen): chargingStation(ChargingStationID,CLAT,CLON,_) &  lat(LAT) & lon(LON)<-
	if(100>((CLAT-LAT) + (CLON-LON))){
		Chosen = ChargingStationID
	}
 skip.
 



+!goBuild(Item): not atWorkShop(workshop0)<-
	!!goBuild(Item);
	goto(workshop0)
.
+!goBuild(Item): atWorkShop(workshop0)<-
	!!decide;
	assemble(Item)
.


+!evalJob:true<-
for(job(JobID,StorageID,_,_,_,RequiredList)){
		for(.member(required(NameRequired,QtyRequired),RequiredList)){
			
		}
	}
skip.

+!standAndDeliver(JobID):true<-
	if(job(JobID,StorageID,_,_,_,RequiredList)){ // & .member(required(NameRequired,QtyRequired),RequiredList) & hasItem(Name, Qty)& Name==NameRequired){
		!!deliver(StorageID, JobID);
		goto(StorageID);
	}
	else{
		!!decide;
	}
	.

+!deliver(StorageID, JobID): not atStorage(StorageID)<-
	!!deliver(StorageID, JobID);
	goto(StorageID)
	.
+!deliver(StorageID, JobID): atStorage(StorageID)<-
	.print("Storing now");
	!!decide;
	deliver_job(JobID)
	.
	
+!goShop: true <-
	if(job(_,_,_,_,_,RequiredList)  & shop(ShopID, _, _, _, Inventory) & .member(required(NameRequired,QtyRequired),RequiredList) & .member(item(Name1, Price1, Qty1),Inventory) & Name1 == NameRequired){
		.print("We decided to buy something");
		if(QtyRequired > Qty1){
		!!goBuy(ShopID, NameRequired, Qty1,false);
		goto(ShopID);
		}
		else{
		!!goBuy(ShopID, NameRequired, QtyRequired,false);
		goto(ShopID);
		}
	}
	else{
		!!decide;
		skip;
	}
.

+!goBuy(ShopID, NameRequired, Qty1, Init): not facility(ShopID)<-
	!!goBuy(ShopID, NameRequired, Qty1, Init);
	goto(ShopID).	
/* 
+!goBuy(ShopID, NameRequired, Qty1): atShop(ShopID)<-
	!!decide;
	.term2string(Qty1,X);
	buy(NameRequired,X);
	if(lastActionResult(Result)&shop(ShopID,_,_,_,Inventory)){
		.print("Should have bought ", Qty1, " ", NameRequired, ". Resulted in: ", Result);
		.print("Inventory: ", Inventory)
	}
	.*/
	
+!goBuy(ShopID, NameRequired, Qty1, Init): facility(ShopID)<-
		.term2string(Qty1,X);
		buy(NameRequired,X);
		if(lastActionResult(Result)&Result == successful){
			if(Init){
				!!init;
				skip;
			}
			else
			{
				!!decide;
				skip;
			}
		}
		else{
			!!goBuy(ShopID, NameRequired, Qty1, Init);
			skip;
		}
	
	.
+!closest: true<-
	if(not(First == true)){
		FirstRun = true;
	}
	.
	
+!choseJob: true<-
	skip;
.
/*
+job(JobID,StorageID,_,_,_,RequiredList)<-
	CanBuild = true;
	for(.member(required(Item,Qty),RequiredList)){
		if(not canBuildItem(Item)){
			CanBuild = false;
		}
		if(item(Item,_,ToolList,parts(Parts)) & not .empty(Parts)){
			for(.member(required(Part,Qty),Parts)){
				if(not canBuildItem(Item)){
					CanBuild = false;
				}
			}
		}
	}
	if(CanBuild==true){
		.print("We can build it");
	}
.
*/
+!evaluate(JobID):job(JobID,_,_,_,_,RequiredList)<-
	CanDo=true;
	TotalWeight;
	for(.member(required(Item,Qty),RequiredList)){
		if(item(Item,Weight,tools(ToolList1),Parts)){
			
		}
		for(.member(item(Item,Weight,tools(ToolList2),Parts),Parts)){
			if( false==(.empty(ToolList2) |  hasItem(ToolList2))){
				CanDo=false;
			}
		}
	}
	.