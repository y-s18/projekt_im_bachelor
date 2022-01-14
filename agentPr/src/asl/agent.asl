/* Initial beliefs and rules */

direction(s, 0,  1). 
direction(n, 0, -1). 
direction(w,-1,  0). 
direction(e, 1,  0).
b0(-1,-1). 
b1(-1,-1). 
gl(-1,-1). 
tb(-1,-1).
listB0([]). 
listB1([]). 
listTB([]). 
listGL([]). 
listAG([]).
moving(false). 
searching(true).
moveGL(false). 
searchGL(false). 
moveDisp(false). 
searchDisp(false).
accepting(false). 
submitting(false). 
reqDir("").
extraMoveAction(false). 
extraMove("").
questionValue(""). 
nextDir(ne). 
currDir("").
distCount(1).
neededPOI("",0,0).
blocked(false).
newX(0). newY(0).
spiStep(4). 
desXY(0,0).


/* Plans */
/*Communication Steps */
+step(X): isAlreadyAccepted(T)[source(AGENT)] & not accepted(B)	& B \== T	<- .send(AGENT,tell,answerTask(no,T)); .abolish(isAlreadyAccepted(T)[source(AGENT)]); 
	.print("QUESTION FROM ", AGENT, " ANSWERED ------------------------------------> ANSWER ", no); skip; .
+step(X): isAlreadyAccepted(T)[source(AGENT)] & accepted(B)	& B \== T	<- .send(AGENT,tell,answerTask(no,T)); .abolish(isAlreadyAccepted(T)[source(AGENT)]); 
	.print("QUESTION FROM ", AGENT, " ANSWERED ------------------------------------> ANSWER ", no); skip; .
+step(X): isAlreadyAccepted(T)[source(AGENT)] & accepted(T)	<- .send(AGENT,tell,answerTask(yes,T)); .abolish(isAlreadyAccepted(T)[source(AGENT)]);
	.print("QUESTION FROM ", AGENT, " ANSWERED ------------------------------------> ANSWER ", yes); skip; .
+step(X): answerTask(_,T) & questionValue(Q) & Q=T & waitingAnswers(true)	<- 
	.count(answerTask(yes,T), NUM); /* ?listAG(L); .length(L, Len);*/ !makeDecision(NUM); .abolish(answerTask(_,T)); 
	-+waitingAnswers(false); skip; .
	/*if(NUM = .length(L)){-+decision(acceptAction);}else{-+decision(refuseAction);}*/ 
+!makeDecision(N): N = 0 	<- +decision(acceptAction);.
+!makeDecision(N): N > 0	<- +decision(refuseAction);.

/*Initial Steps */
+step(0): thing(0,0,entity,Team)[entity(NAME), source(percept)]		<- .broadcast(tell,myTeam(NAME,Team)); skip; .
+step(1) 															<- !listAgents(1, .count(myTeam(_,"A")) ); skip;.

/*trigger the spiral movement when not having a task to do*/
+step(X): moving(false) & searching(true) & not accepted(_)			<- ?nextDir(D); !calcDesXY(D); -+moving(true); skip; .

/*spiral movement looking for a taskboard, if no task is accepted */
+step(X): moving(true) & not thing(_,_,taskboard,_) & not accepted(_)	<- 
	?desXY(DX,DY);
	!storeDispB0; !storeDispB1; !storeGoal;
	
	!listBeliefs(1,.count(receivedTB(_,_)), recTB); 
	?listTB(L); 
	!comparePOIs(0, .length(L), recTB);
	
	?tb(XTB,YTB);
	if(XTB>-1 & YTB>-1){!goto(XTB,YTB);}
	else{!goto(DX,DY);}
	skip;
	.
	
/*moving towards a TB, if the Agent does not have an accepted task & accept one*/
+step(X): moving(true) & thing(TX,TY,taskboard,_) & not accepted(_)	& math.abs(TX)+math.abs(TY) > 0  & accepting(false)	<- 
	?position(AX,AY);
	!storeTB; !storeDispB0; !storeDispB1; !storeGoal;
	!goto(AX+TX,AY+TY);
	skip;
	.
@s1
+step(X): thing(0,0,taskboard,_) & not accepted(_) & accepting(false) <- -+accepting(true); skip; . 
	
/*start doing a task after accepting a Task */
+step(X): doingTask(false) & accepted(T)	<- -+searching(false); ?task(T,_,_,[req(XB,YB,D)]); -+neededPOI(D,XB,YB);  !doTask; -+doingTask(true); skip; .

/*move towards a Dispenser & request  */
+step(X): desXY(DX,DY) & requesting(true) & not position(DX,DY)	<- !checkBetterPOI; ?desXY(NewDX,NewDY) !goto(NewDX,NewDY); skip;.
+step(X): desXY(DX,DY) & requesting(true) & position(DX,DY)		<- -+requesting(false); +attaching(true); ?reqDir(D); request(D); .

/*step for executing the attach action */
+step(X): attaching(true) & gl(XG,YG) <- -+desXY(XG,YG); -+attaching(false); -+submitting(true); ?reqDir(D); attach(D);.

/*move towards the saved goal area & submit the already accepted task */
/*NEW CODE: gl(XG,YG) & -+desXY(XG,YG) added CL150 attaching step*/
+step(X): desXY(DX,DY) & submitting(true) & accepted(T) & not position(DX,DY) <- !checkBetterPOI; ?desXY(NewDX,NewDY) !goto(NewDX,NewDY); skip;.
+step(X): desXY(DX,DY) & submitting(true) & accepted(T) & position(DX,DY) <- -+submitting(false); -+accepting(true); submit(T); .
//+step(X): gl(XG,YG) & submitting(true) & accepted(T) & not position(XG,YG) <- !goto(XG,YG); skip;.
//+step(X): gl(XG,YG) & submitting(true) & accepted(T) & position(XG,YG) <- -+submitting(false); -+accepting(true); submit(T); .


/*reaccepting a task after submitting one*/
+step(X): accepting(true) & tb(TBX,TBY) & not position(TBX,TBY) <- !goto(TBX,TBY); skip;.
+step(X): accepting(true) & tb(TBX,TBY) & position(TBX,TBY) <- -+accepting(false); !acceptTask; skip;.

/*step for triggering goal finding*/
+step(X): moveGL(false) & searchGL(true)	<- ?nextDir(D); !calcDesXY(D); -+moveGL(true); skip; .
/*Scenarios when searching for a goal is triggered*/
+step(X): moveGL(true) & searchGL(true) & not goal(_,_) & not thing(_,_,dispenser,_)	<- ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveGL(true) & searchGL(true) & not goal(_,_) & thing(_,_,dispenser,b0)		<- !storeDispB0; ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveGL(true) & searchGL(true) & not goal(_,_) & thing(_,_,dispenser,b1)		<- !storeDispB1; ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveGL(true) & searchGL(true) & goal(XG,YG)									<- !storeGoal; -+searchGL(false); -+moveGL(false); !doTask; skip;.

/*step for triggering Disp's finding */
+step(X): moveDisp(false) & searchDisp(true)	<- ?nextDir(D); !calcDesXY(D); -+moveDisp(true); skip; .
/*Scenarios when searching for Disp's is triggered*/
+step(X): moveDisp(true) & searchDisp(true) & not thing(_,_,dispenser,b0) & searchFor(b0) & b0(-1,-1)	<- ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveDisp(true) & searchDisp(true) & not thing(_,_,dispenser,b1) & searchFor(b1) & b1(-1,-1) 	<- ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveDisp(true) & searchDisp(true) & thing(XB,YB,dispenser,b0) & searchFor(b0)		<- !storeDispB0; -+searchDisp(false); 
	-+moveDisp(false); !doTask; skip;.
+step(X): moveDisp(true) & searchDisp(true) & thing(XB,YB,dispenser,b1) & searchFor(b1) 	<- !storeDispB1; -+searchDisp(false); 
	-+moveDisp(false); !doTask; skip;.
	
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & not b0(-1,-1) & not b0(-1,-1) & not gl(-1,-1) & accepting(false) <- ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & not thing(_,_,dispenser,_) & not goal(_,_) & accepting(false) <- ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & thing(_,_,dispenser,b0) & b0(-1,-1) & accepting(false) <- !storeDispB0; ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & thing(_,_,dispenser,b1) & b1(-1,-1) & accepting(false) <- !storeDispB1; ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & goal(_,_) & gl(-1,-1) & accepting(false) <- !storeGoal; ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & thing(TX,TY,taskboard,_) & accepting(false) <- ?position(AX,AY); -+desXY(AX+TX,AY+TY); !goto(AX+TX,AY+TY); !storeTB;.

/*Scenarios when doing a task*/
+!doTask: accepted(T) & gl(-1,-1) <- -+searchGL(true); !listBeliefs(1,.count(receivedGL(_,_)), recGL); ?listGL(L); !comparePOIs(0, .length(L), recGL);.
+!doTask: accepted(T) & b0(-1,-1) & searchGL(false)	<- -+searchDisp(true); +searchFor(b0); !listBeliefs(1,.count(receivedB0(_,_)), recB0); 
	?listB0(L); !comparePOIs(0, .length(L), recB0);.
+!doTask: accepted(T) & not b0(-1,-1) & task(T,_,_,[req(ASX,ASY,b0)])	<- ?b0(XB,YB); ?direction(DIR,ASX,ASY); -+reqDir(DIR); -+desXY(XB-ASX,YB-ASY); 
	+requesting(true); -+neededPOI(b0,ASX,ASY); !listBeliefs(1,.count(receivedB0(_,_)), recB0); ?listB0(L); 
	!comparePOIs(0, .length(L),recB0); ?b0(NewXB, NewYB); -+desXY(NewXB-ASX,NewYB-ASY);.
+!doTask: accepted(T) & b1(-1,-1) & searchGL(false) <- -+searchDisp(true); +searchFor(b1); !listBeliefs(1,.count(receivedB1(_,_)), recB1); 
	?listB1(L); !comparePOIs(0,.length(L),recB1);.
+!doTask: accepted(T) & not b1(-1,-1) & task(T,_,_,[req(ASX,ASY,b1)])	<- ?b1(XB,YB); ?direction(DIR,ASX,ASY); -+reqDir(DIR); -+desXY(XB-ASX,YB-ASY); 
	+requesting(true); -+neededPOI(b1,ASX,ASY); !listBeliefs(1,.count(receivedB1(_,_)), recB1); ?listB1(L); 
	!comparePOIs(0, .length(L),recB1); ?b1(NewXB, NewYB); -+desXY(NewXB-ASX,NewYB-ASY); .

/*accepting task, if the Agent is on a TB */
+!acceptTask: thing(0,0,taskboard,_) /* & math.abs(XTB) < 2 & math.abs(YTB) < 2*/ <- ?task(T,_,_,_); /* +doingTask(false); */ 
	.remove_plan(s1);
	!broadcastTask(T); +waitingAnswers(true);
//	?decision(DECISION);
//	if(DECISION = acceptAction){ .print("Decision: ", DECISION, "-------------------------> ACCEPTED TASK", T); accept(T);}
//	else{  .print("Decision: ", DECISION, "-------------------------> REJECTED TASK", T); 
//	.print("--------------> Waiting for a new Task"); /*accept(T-1);!acceptTask; */
//	}  
	.
+!acceptTask: thing(XTB,YTB,taskboard,_) & math.abs(XTB) > 0 & math.abs(YTB) > 0 <- 
	.print("-----------------------------------> CAN'T ACCEPT");.

+step(X): waitingAnswers(false)	<- 
	?decision(DECISION); 
	if(DECISION = acceptAction){ 
		?questionValue(T);
		.print("Decision: ", DECISION, "-------------------------> ACCEPTED TASK", T); 
		accept(T); 
		+doingTask(false);
	}
	else{  
	.print("Decision: ", DECISION, "-------------------------> REJECTED TASK", T); 
	.print("--------------> Waiting for a new Task");
	-+accepting(true); /*accept(T-1);!acceptTask; */
	} 
	-decision(_);
	-waitingAnswers(_);
	.

//+!acceptTask: thing(XTB,YTB,taskboard,_) & math.abs(XTB) > 2 & math.abs(YTB) > 2 <- .print("not arrived yet");.


/*Checks if better POI -than the saved ones- available(closer to the agent)*/
/*No destination change when the available destinations are worse or =, Disp's scenarios*/
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b0,NBX,NBY) & thing(XB,YB,dispenser,b0) 
	& position(AX,AY) & math.abs(DX+NBX-AX)<=math.abs(XB) & math.abs(DY+NBY-AY)<=math.abs(YB) 		<- -+desXY(DX,DY); !changeDirection(DX,DY);.
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b1,NBX,NBY) & thing(XB,YB,dispenser,b1) 
	& position(AX,AY) & math.abs(DX+NBX-AX)<=math.abs(XB) & math.abs(DY+NBY-AY)<=math.abs(YB) 		<- -+desXY(DX,DY); !changeDirection(DX,DY);.
	
/*No destination change when no other destinations available */
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b0,_,_) & not thing(_,_,dispenser,b0) <- -+desXY(DX,DY); !changeDirection(DX,DY);.
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b1,_,_) & not thing(_,_,dispenser,b1) <- -+desXY(DX,DY); !changeDirection(DX,DY);.
	
/*Change Destination */
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b0,NBX,NBY) & thing(XB,YB,dispenser,b0) 
	& position(AX,AY) & math.abs(DX+NBX-AX)>math.abs(XB) & math.abs(DY+NBY-AY)>math.abs(YB) 		<- ?direction(DIR,NBX,NBY); -+reqDir(DIR); 
	-+newX(AX+XB-NBX);-+newY(AY+YB-NBY); !correctX; !correctY; ?newX(NX); ?newY(NY); -+desXY(NX,NY); /*AX+XB-NBX, AY+YB-NBY*/ !changeDirection(NX,NY);.
	
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b1,NBX,NBY) & thing(XB,YB,dispenser,b1) 
	& position(AX,AY) & math.abs(DX+NBX-AX)>math.abs(XB) & math.abs(DY+NBY-AY)>math.abs(YB) 		<- ?direction(DIR,NBX,NBY); -+reqDir(DIR); 
	-+newX(AX+XB-NBX);-+newY(AY+YB-NBY); !correctX; !correctY; ?newX(NX); ?newY(NY); -+desXY(NX,NY); /*AX+XB-NBX,AY+YB-NBY */ !changeDirection(NX,NY);.
	
/*better goal coordinates scenarios */
+!checkBetterPOI: submitting(true) & desXY(DX,DY) & not goal(_,_) 	<- -+desXY(DX,DY); !changeDirection(DX,DY);.
+!checkBetterPOI: submitting(true) & desXY(DX,DY) & goal(XG,YG) & position(AX,AY) 
	& math.abs(DX-AX)<=math.abs(XG) & math.abs(DY-AY)<=math.abs(YG) <- -+desXY(DX,DY); !changeDirection(DX,DY);.
+!checkBetterPOI: submitting(true) & desXY(DX,DY) & goal(XG,YG) & position(AX,AY) 
	& math.abs(DX-AX)>math.abs(XG) & math.abs(DY-AY)>math.abs(YG) 	<- -+newX(AX+XG);-+newY(AY+YG); !correctX; 
	!correctY; ?newX(NX); ?newY(NY); -+desXY(NX,NY); /*AX+XG,AY+YG */ !changeDirection(NX,NY);.
	
+!changeDirection(NX,NY): position(AX,AY) & AX>NX & AY>NY <- -+nextDir(nw);.
+!changeDirection(NX,NY): position(AX,AY) & AX<=NX & AY<=NY <- -+nextDir(se);.
+!changeDirection(NX,NY): position(AX,AY) & AX>NX & AY<=NY <- -+nextDir(sw);.
+!changeDirection(NX,NY): position(AX,AY) & AX<=NX & AY>NY <- -+nextDir(ne);.

/* -----------------------------------BROADCAST----------------------------------- 
*							Send all agents POI infos*/
+!broadcastPOI(b0)	<- ?b0(XB,YB); .broadcast(tell, receivedB0(XB,YB)); .
+!broadcastPOI(b1)	<- ?b1(XB,YB); .broadcast(tell, receivedB1(XB,YB)); .
+!broadcastPOI(gl)	<- ?gl(XG,YG); .broadcast(tell, receivedGL(XG,YG)); .
+!broadcastPOI(tb)	<- ?tb(XTB,YTB); .broadcast(tell, receivedTB(XTB,YTB)); .
+!broadcastTask(T)	<- -+questionValue(T); .broadcast(tell, isAlreadyAccepted(T)); 
	.print("QUESTION BROADCASTED ------------------------------------> QUESTION ABOUT ", T); .
/* -----------------------------------LISTS CREATION----------------------------------- 
*							Create list of the known Agents*/
+!listAgents(COUNTER, N): COUNTER <= N	<- ?thing(0,0,entity,TEAM); ?myTeam(NAME,TEAM); ?listAG(L);
	if(not .member(myTeam(NAME,TEAM),L)){
		.concat(L,[myTeam(NAME,TEAM)],NewL);
		-+listAG(NewL);
	}
	.abolish(myTeam(NAME,TEAM)); 
	!listAgents(COUNTER+1, N);
	.

+!listAgents(COUNTER, N): COUNTER > N <- ?listAG(L); -+listAG(L);.
	
+!listBeliefs(COUNTER,N,recB0): COUNTER<=N & receivedB0(_,_)	<- ?receivedB0(XB,YB); ?listB0(L); 
	if(not .member(receivedB0(XB,YB),L)){
		.concat(L,[receivedB0(XB,YB)],NewL);
		-+listB0(NewL);
	} 
//	-receivedB0(XB,YB)[source(agent2)]; 
	.abolish(receivedB0(XB,YB));
	!listBeliefs(COUNTER+1,N,recB0);
	. 
+!listBeliefs(COUNTER,N,recB1): COUNTER<=N & receivedB1(_,_)	<- ?receivedB1(XB,YB); ?listB1(L); 
	if(not .member(receivedB1(XB,YB),L)){
		.concat(L,[receivedB1(XB,YB)],NewL); 
		-+listB1(NewL); 
	}
//	-receivedB1(XB,YB)[source(agent2)]; 
	.abolish(receivedB1(XB,YB));
	!listBeliefs(COUNTER+1,N,recB1);
	.
+!listBeliefs(COUNTER,N,recTB): COUNTER<=N & receivedTB(_,_)	<- ?receivedTB(XTB,YTB); ?listTB(L); 
	if(not .member(receivedTB(XTB,YTB),L)){
		.concat(L,[receivedTB(XTB,YTB)],NewL);
		-+listTB(NewL);
	} 
//	-receivedTB(XTB,YTB)[source(agent2)]; 
	.abolish(receivedTB(XTB,YTB));
	!listBeliefs(COUNTER+1,N,recTB);
	. 
+!listBeliefs(COUNTER,N,recGL): COUNTER<=N & receivedGL(_,_)	<- ?receivedGL(XG,YG); ?listGL(L);
	if(not .member(receivedGL(XG,YG),L)){
		.concat(L,[receivedGL(XG,YG)],NewL);
		-+listGL(NewL);
	}
	.abolish(receivedGL(XGL,YGL));
	!listBeliefs(COUNTER+1,N,recGL);
	.

+!listBeliefs(COUNTER,N,recB0): COUNTER>N <- ?listB0(L); -+listB0(L);.
+!listBeliefs(COUNTER,N,recB1): COUNTER>N <- ?listB1(L); -+listB1(L);.
+!listBeliefs(COUNTER,N,recTB): COUNTER>N <- ?listTB(L); -+listTB(L);.
+!listBeliefs(COUNTER,N,recGL): COUNTER>N <- ?listGL(L); -+listGL(L);.

+!listBeliefs(COUNTER,N,recB0): not receivedB0(_,_) <- ?listB0(L); -+listB0(L);.
+!listBeliefs(COUNTER,N,recB1): not receivedB1(_,_) <- ?listB1(L); -+listB1(L);.
+!listBeliefs(COUNTER,N,recTB): not receivedTB(_,_) <- ?listTB(L); -+listTB(L);.
+!listBeliefs(COUNTER,N,recGL): not receivedGL(_,_) <- ?listGL(L); -+listGL(L);.

/* -----------------------------------COMPARE POIs-----------------------------------
 *							compare saved POIs with received POIs
 * ADD TEAM TEST XXX */
+!comparePOIs(COUNTER,N,recB0): COUNTER <= N-1 & not b0(-1,-1) <-	
	?listB0(L); ?position(AX,AY); ?b0(X,Y);
	.nth(COUNTER,L,receivedB0(XB,YB));
	.print("------------------------------------------------------------> ",visited(XB,YB));
	RecDIST = math.abs(XB-AX) + math.abs(YB-AY);
	SavedDIST = math.abs(X-AX) + math.abs(Y-AY);
	if(RecDIST > SavedDIST){
		-+b0(XB,YB);
		.print("------------------------------------------------------------> UPDATED B0 ", visited(XB,YB));
		-+searchDisp(false);
	}
	!comparePOIs(COUNTER+1,N,recB0);
	.
	
+!comparePOIs(COUNTER,N,recB1): COUNTER <= N-1 & not b1(-1,-1) <-	
	?listB1(L);
	?position(AX,AY);
	?b1(X,Y);
	.nth(COUNTER,L,receivedB1(XB,YB));
	.print("------------------------------------------------------------> ", visited(XB,YB));
	RecDIST = math.abs(XB-AX) + math.abs(YB-AY);
	SavedDIST = math.abs(X-AX) + math.abs(Y-AY);
	if(RecDIST < SavedDIST){
		-+b1(XB,YB);
		.print("------------------------------------------------------------> UPDATED B1 ", visited(XB,YB));
		-+searchDisp(false);
	}
	!comparePOIs(COUNTER+1,N,recB1);
	.
+!comparePOIs(COUNTER,N,recGL): COUNTER <= N-1 & not gl(-1,-1) <-
	?listGL(L);
	?position(AX,AY);
	?gl(X,Y);
	.nth(COUNTER,L,receivedGL(XG,YG));
	.print("------------------------------------------------------------> ", visited(XG,YG));
	RecDIST = math.abs(XG-AX) + math.abs(YG-AY);
	SavedDIST = math.abs(X-AX) + math.abs(Y-AY);
	if(RecDIST < SavedDIST){
		-+gl(XG,YG);
		.print("------------------------------------------------------------> UPDATED GL ", visited(XG,YG));
		-+searchGL(false);
	}
	!comparePOIs(COUNTER+1,N,recGL);
	.

+!comparePOIs(COUNTER,N,recTB): COUNTER <= N-1 & not tb(-1,-1) <-
	?listTB(L);
	?position(AX,AY);
	?tb(X,Y);
	.nth(COUNTER,L,receivedTB(XTB,YTB));
	.print("------------------------------------------------------------> ", visited(XTB,YTB));
	RecDIST = math.abs(XTB-AX) + math.abs(YTB-AY);
	SavedDIST = math.abs(X-AX) + math.abs(Y-AY);
	if(RecDIST < SavedDIST){
		-+tb(XTB,YTB);
		.print("------------------------------------------------------------> UPDATED TB ", visited(XTB,YTB));
//		-+search(false);
	}
	!comparePOIs(COUNTER+1,N,recTB);
	.

+!comparePOIs(COUNTER,N,recB0): COUNTER > N-1 & b0(XB,YB) <- -+b0(XB,YB);.
+!comparePOIs(COUNTER,N,recB1): COUNTER > N-1 & b1(XB,YB) <- -+b1(XB,YB);.
+!comparePOIs(COUNTER,N,recGL): COUNTER > N-1 & gl(XG,YG) <- -+gl(XG,YG);.
+!comparePOIs(COUNTER,N,recTB): COUNTER > N-1 & tb(XTB,YTB) <- -+tb(XTB,YTB);.

+!comparePOIs(0,N,recB0): N > 0 & b0(-1,-1) <- ?listB0(L); .nth(0,L,receivedB0(XB,YB)); -+b0(XB,YB); -+searchDisp(false);.
+!comparePOIs(0,N,recB1): N > 0 & b1(-1,-1) <- ?listB1(L); .nth(0,L,receivedB1(XB,YB)); -+b1(XB,YB); -+searchDisp(false);.
+!comparePOIs(0,N,recGL): N > 0 & gl(-1,-1) <- ?listGL(L); .nth(0,L,receivedGL(XG,YG)); -+gl(XG,YG); -+searchGL(false);.
+!comparePOIs(0,N,recTB): N > 0 & tb(-1,-1) <- ?listTB(L); .nth(0,L,receivedTB(XTB,YTB)); -+tb(XTB,YTB); .

+!comparePOIs(0,0,recB0): b0(-1,-1) | not b0(-1,-1)  <- ?b0(XB,YB); -+b0(XB,YB); .
+!comparePOIs(0,0,recB1): b1(-1,-1) | not b1(-1,-1) <- ?b1(XB,YB); -+b1(XB,YB); .
+!comparePOIs(0,0,recGL): gl(-1,-1) | not gl(-1,-1) <- ?gl(XG,YG); -+gl(XG,YG); .
+!comparePOIs(0,0,recTB): tb(-1,-1) | not tb(-1,-1) <- ?tb(XTB,YTB); -+tb(XTB,YTB); .
/* NEW */
/* -----------------------------------CALCULATION DESTINATION X,Y----------------------------------- 
 *						 calculate & update the destination coordinates[desXY(x,y)]  */
+!calcDesXY(D) <- 
	?spiStep(S);
	?distCount(Dist);
	if(Dist>6){-+distCount(1);}
	
	!calcXY(D,S);
	!correctX; !correctY;
	?newX(NX); ?newY(NY);
	-+desXY(NX,NY);
	.
+!calcXY(ne,S): position(X,Y) <- ?distCount(Dist); -+newX(X+S*Dist); -+newY(Y-S*Dist); -+distCount(Dist+1);.
+!calcXY(se,S): position(X,Y) <- ?distCount(Dist); -+newX(X+S*Dist); -+newY(Y+S*Dist);.
+!calcXY(sw,S): position(X,Y) <- ?distCount(Dist); -+newX(X-S*Dist); -+newY(Y+S*Dist); -+distCount(Dist+1);.
+!calcXY(nw,S): position(X,Y) <- ?distCount(Dist); -+newX(X-S*Dist); -+newY(Y-S*Dist);.

+!correctX: newX(X) & (X>=0 & X<=49) <- -+newX(X);.
+!correctX: newX(X) & X>49 <- -+newX(X-50);.
+!correctX: newX(X) & X<0 <- -+newX(X+50);.

+!correctY: newY(Y) & (Y>=0 & Y<=49) <- -+newY(Y);.
+!correctY: newY(Y) & Y>49 <- -+newY(Y-50);.
+!correctY: newY(Y) & Y<0 <- -+newY(Y+50);.
/* -----------------------------------GOTO----------------------------------- 
 * 					make one move action towards the destination */
+!goto(X,Y): position(X,Y) 
    <- .print("-------> " ,arrived_at(X,Y));
    if(nextDir(ne)){-+nextDir(se);}
    elif(nextDir(se)){-+nextDir(sw);}
    elif(nextDir(sw)){-+nextDir(nw);}
    elif(nextDir(nw)){-+nextDir(ne);}
    -+moving(false);
    -+moveGL(false);
    -+moveDisp(false);
    .
    
+!goto(X,Y): not position(X,Y)/*& blocked(false) */ 
	<- ?position(OX,OY);
	DISTANCEX=math.abs(X-OX);
	DISTANCEY=math.abs(Y-OY);

	if (DISTANCEX>=DISTANCEY) {
//		if((X<13 & OX>35) | (X>35 & OX<12)){
		if(math.abs(X-OX)>24){
			DESIRABLEX = -(X-OX)/DISTANCEX;
		}else{
			DESIRABLEX = (X-OX)/DISTANCEX;
		}
    	DESIRABLEY = 0;
	}else {
	    DESIRABLEX = 0;
//	    if((Y<13 & OY>35) | (Y>35 & OY<12)){
	    if(math.abs(Y-OY)>24){
	    	DESIRABLEY = -(Y-OY)/DISTANCEY;
	    }else{
	    	DESIRABLEY = (Y-OY)/DISTANCEY;
	    }
	}
	?direction(DIRECTION,DESIRABLEX,DESIRABLEY);
//	!checkLastAction(DIRECTION);

/*START */
//	?nextDir(NextD);
//	?currDir(NewD);
//	!checkLastAction(DIRECTION);
//	!checkObstacles(NextD,DIRECTION);
//	!checkAgent(DIRECTION);
//	?currDir(NewD);
//	move(NewD);
/*END */
	move(DIRECTION);
  	.
  	
/* -----------------------------------STORE POIs----------------------------------- 
 *							Plans for saving POI positions */
+!storeDispB0: thing(XB,YB,dispenser,b0)	<- ?position(XAg, YAg); -+newX(XAg+XB);-+newY(YAg+YB); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+b0(NX, NY); !broadcastPOI(b0);. 
+!storeDispB1: thing(XB,YB,dispenser,b1)	<- ?position(XAg, YAg); -+newX(XAg+XB);-+newY(YAg+YB); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+b1(NX, NY); !broadcastPOI(b1);.
+!storeTB: thing(XT,YT,taskboard,_)			<- ?position(XAg,YAg); -+newX(XAg+XT);-+newY(YAg+YT); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+tb(NX,NY); !broadcastPOI(tb);.
+!storeGoal: goal(XG,YG)					<- ?position(XAg,YAg); -+newX(XAg+XG);-+newY(YAg+YG); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+gl(NX,NY); !broadcastPOI(gl);.
+!storeDispB0: not thing(_,_,dispenser,b0)	<- .print("---> No B0 Block Here!");.
+!storeDispB1: not thing(_,_,dispenser,b1)	<- .print("---> No B1 Block Here!");.
+!storeTB: not thing(_,_,taskboard,_)		<- .print("---> No TB Here!");.
+!storeGoal: not goal(_,_)					<- .print("---> No Goal Here!");.

/* -----------------------------------BLOCKED SCENARIOS CHECK AGENT----------------------------------- */
+!checkAgent(e): not thing(1,0,entity,_) & not thing(1,0,block,B) & not thing(1,0,dispenser,B) <- -+currDir(e);.
+!checkAgent(e): not thing(1,0,entity,_) & not thing(1,0,block,B) & thing(1,0,dispenser,B) <- -+currDir(e);.
+!checkAgent(e): not thing(1,0,entity,_) & thing(1,0,block,B) & not thing(1,0,dispenser,B) <- -+currDir(e);.
+!checkAgent(s): not thing(0,1,entity,_) & not thing(0,1,block,B) & not thing(0,1,dispenser,B)<- -+currDir(s);.
+!checkAgent(s): not thing(0,1,entity,_) & not thing(0,1,block,B) & thing(0,1,dispenser,B)<- -+currDir(s);.
+!checkAgent(s): not thing(0,1,entity,_) & thing(0,1,block,B) & not thing(0,1,dispenser,B)<- -+currDir(s);.
+!checkAgent(e): thing(1,0,entity,_) | (thing(1,0,block,B) & thing(1,0,dispenser,B)) <- -+currDir(n);.
+!checkAgent(s): thing(0,1,entity,_) | (thing(0,1,block,B) & thing(0,1,dispenser,B)) <- -+currDir(e);.
+!checkAgent(n) <- -+currDir(n);.
+!checkAgent(w) <- -+currDir(w);.
/*START */
//1,-1 ne //-1,-1 nw //1,1 se //-1,1 sw
//ne & nw
+!checkObstacles(_,n): not obstacle(1,-1) & not obstacle(-1,-1) & extraMoveAction(false) <- -+currDir(n);  !chooseAction(mo,n);.//XXXX
+!checkObstacles(ne,n): not obstacle(1,-1) & obstacle(-1,-1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(n); !chooseAction(mo,e);.//ne when nw should e XXXX
+!checkObstacles(nw,n): not obstacle(1,-1) & obstacle(-1,-1) & extraMoveAction(false) <- -+currDir(s); -+extraMoveAction(true); -+extraMove(w); !chooseAction(mo,s);.
+!checkObstacles(ne,n): obstacle(1,-1) & not obstacle(-1,-1) & extraMoveAction(false) <- -+currDir(s); -+extraMoveAction(true); -+extraMove(e); !chooseAction(mo,s);.//ne when nw should w XXXX
+!checkObstacles(nw,n): obstacle(1,-1) & not obstacle(-1,-1) & extraMoveAction(false) <- -+currDir(w); -+extraMoveAction(true); -+extraMove(n);  !chooseAction(mo,w);.
+!checkObstacles(ne,n): obstacle(1,-1) & obstacle(-1,-1) & extraMoveAction(false) <- -+currDir(s); -+extraMoveAction(true); -+extraMove(e); !chooseAction(mo,s);.//ne when nw should w XXXX
+!checkObstacles(nw,n): obstacle(1,-1) & obstacle(-1,-1) & extraMoveAction(false) <- -+currDir(s); -+extraMoveAction(true); -+extraMove(w); !chooseAction(mo,s);.//ne when nw should w XXXX

+!checkObstacles(_,_): extraMoveAction(true) <- ?extraMove(D); /*-+currDir(D);*/ -+extraMoveAction(false);  !chooseAction(mo,D);.
////ne & se
+!checkObstacles(_,e): not obstacle(1,-1) & not obstacle(1,1) & extraMoveAction(false) <- -+currDir(e); !chooseAction(mo,e);.
+!checkObstacles(ne,e): not obstacle(1,-1) & obstacle(1,1) & extraMoveAction(false) <- -+currDir(n); -+extraMoveAction(true); -+extraMove(e); !chooseAction(mo,n);.//ne when se should s XXXX
+!checkObstacles(se,e): not obstacle(1,-1) & obstacle(1,1) & extraMoveAction(false) <- -+currDir(w); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,w);.
+!checkObstacles(ne,e): obstacle(1,-1) & not obstacle(1,1) & extraMoveAction(false) <- -+currDir(s); -+extraMoveAction(true); -+extraMove(e); !chooseAction(mo,s);.//ne when se should n XXXX
+!checkObstacles(se,e): obstacle(1,-1) & not obstacle(1,1) & extraMoveAction(false) <- -+currDir(s); -+extraMoveAction(true); -+extraMove(e); !chooseAction(mo,s);.
+!checkObstacles(ne,e): obstacle(1,-1) & obstacle(1,1) & extraMoveAction(false) <- -+currDir(w); -+extraMoveAction(true); -+extraMove(n); !chooseAction(mo,w);. //ne when se should s XXXX
+!checkObstacles(se,e): obstacle(1,-1) & obstacle(1,1) & extraMoveAction(false) <- -+currDir(w); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,w);.

////se & sw
+!checkObstacles(_,s): not obstacle(1,1) & not obstacle(-1,1) & not obstacle(0,1) & extraMoveAction(false) <- -+currDir(s); !chooseAction(mo,s);.
+!checkObstacles(se,s): not obstacle(1,1) & obstacle(-1,1) & not obstacle(0,1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,e);.//se when sw should w XXXX
+!checkObstacles(sw,s): not obstacle(1,1) & obstacle(-1,1) & not obstacle(0,1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,e);.
+!checkObstacles(se,s): obstacle(1,1) & not obstacle(-1,1) & not obstacle(0,1) & extraMoveAction(false) <- -+currDir(w); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,w);.//se when sw should e XXXX
+!checkObstacles(sw,s): obstacle(1,1) & not obstacle(-1,1) & not obstacle(0,1) & extraMoveAction(false) <- -+currDir(w); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,w);.//se when sw should e XXXX
+!checkObstacles(se,s): obstacle(1,1) & obstacle(-1,1) & not obstacle(0,1) & extraMoveAction(false) <- -+currDir(n); -+extraMoveAction(true); -+extraMove(e); !chooseAction(mo,n);.
+!checkObstacles(sw,s): obstacle(1,1) & obstacle(-1,1) & not obstacle(0,1) & extraMoveAction(false) <- -+currDir(n); -+extraMoveAction(true); -+extraMove(w); !chooseAction(mo,n);.//se when sw should w XXXX
+!checkObstacles(se,s): not obstacle(1,1) & not obstacle(-1,1) & obstacle(0,1) & extraMoveAction(false) <- -+currDir(w); !chooseAction(mo,w);.
+!checkObstacles(sw,s): not obstacle(1,1) & not obstacle(-1,1) & obstacle(0,1) & extraMoveAction(false) <- -+currDir(e); !chooseAction(mo,e);.
////nw & sw
+!checkObstacles(_,w): not obstacle(-1,-1) & not obstacle(-1,1) & extraMoveAction(false) <- -+currDir(w); !chooseAction(mo,w);.
+!checkObstacles(nw,w): not obstacle(-1,-1) & obstacle(-1,1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(n); !chooseAction(mo,e);.//nw when sw should s XXXX
+!checkObstacles(sw,w): not obstacle(-1,-1) & obstacle(-1,1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,e);.
+!checkObstacles(nw,w): obstacle(-1,-1) & not obstacle(-1,1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(n); !chooseAction(mo,e);.//nw when sw should s XXXX
+!checkObstacles(sw,w): obstacle(-1,-1) & not obstacle(-1,1) & extraMoveAction(false) <- -+currDir(s); -+extraMoveAction(true); -+extraMove(w); !chooseAction(mo,s);.
+!checkObstacles(nw,w): obstacle(-1,-1) & obstacle(-1,1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(w); !chooseAction(mo,e);.//nw when sw should s XXXX
+!checkObstacles(sw,w): obstacle(-1,-1) & obstacle(-1,1) & extraMoveAction(false) <- -+currDir(e); -+extraMoveAction(true); -+extraMove(s); !chooseAction(mo,e);.
/*END */
+!chooseAction(mo, D) <- move(D);.
+!chooseAction(cl, n) <- clear(0,-1);. 
+!chooseAction(cl, s) <- clear(0,1);.
+!chooseAction(cl, e) <- clear(1,0);.
+!chooseAction(cl, w) <- clear(-1,0);. 

/* oAo e.g try every direction(ne,se..) till one works, poss. problem: endless loop -> if ne is the solu. and e is blocked then try north first
 * ooo
  */
//+!checkLastAction(D): lastAction(move) & lastActionResult(failed_path) & lastActionParams([Dir]) <- !checkLastActionParams(Dir); .
+!checkLastAction(D): (lastAction(move) | lastAction(submit) | lastAction(attach) | lastAction(no_action) 
						| lastAction(skip)) & lastActionResult(success) <- -+currDir(D); .
+!checkLastAction(D): lastAction(move) & lastActionResult(failed_path) <- !chooseAction(cl,D);.

//+!checkLastAction(D): (lastAction(no_action) | lastAction(skip)) & lastActionResult(success) <- -+currDir(D);.
//+!checkLastAction(D): (lastAction(submit) | lastAction(attach)) & lastActionResult(success) <- -+currDir(D);.
//+!checkLastAction(D): lastAction(skip) & lastActionResult(success) <- -+currDir(D);.
/*thing(X,Y,entity,"A")[entity(agentA2), source(percept)] */


/*2 Blocks */
//+!checkLastActionParams(n): obstacle(0,-1) & not obstacle(0,1) & not obstacle(1,0) & not obstacle(-1,0) <- -+currDir(e);.
//+!checkLastActionParams(n): obstacle(0,-1) & obstacle(0,1) & not obstacle(1,0) & not obstacle(-1,0) <- -+currDir(e);.
//+!checkLastActionParams(n): obstacle(0,-1) & not obstacle(0,1) & obstacle(1,0) & not obstacle(-1,0) <- -+currDir(w);.
//+!checkLastActionParams(n): obstacle(0,-1) & not obstacle(0,1) & not obstacle(1,0) & obstacle(-1,0) <- -+currDir(e);.
/*3 Blocks */
//+!checkLastActionParams(n): obstacle(0,-1) & not obstacle(0,1) & obstacle(1,0) & obstacle(-1,0) <- -+currDir(s); /*-+lastDir(n,s);*/.
//+!checkLastActionParams(n): obstacle(0,-1) & obstacle(0,1) & obstacle(1,0) & not obstacle(-1,0) <- -+currDir(w);.
//+!checkLastActionParams(n): obstacle(0,-1) & obstacle(0,1) & not obstacle(1,0) & obstacle(-1,0) <- -+currDir(e);.
//
//+!checkLastActionParams(s): obstacle(0,1) <- -+currDir(w);.
//+!checkLastActionParams(e): obstacle(1,0) <- -+currDir(s);.
//+!checkLastActionParams(w): obstacle(-1,0) <- -+currDir(n);.
//[source(percept)]


//if(AX>DX & AY>DY){-+nextDir(nw);}elif(AX<=DX & AY<=DY){-+nextDir(se);}elif(AX>DX & AY<=DY){-+nextDir(sw);}elif(AX<=DX & AY>DY){-+nextDir(ne);} 	XXXX6 4disp 2gl
//	if(AX>NX & AY>NY){-+nextDir(nw);}elif(AX<=NX & AY<=NY){-+nextDir(se);}elif(AX>NX & AY<=NY){-+nextDir(sw);}elif(AX<=NX & AY>NY){-+nextDir(ne);}  XXXX3 2disp 1gl