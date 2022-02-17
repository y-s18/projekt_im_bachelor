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
listAnswers([]).
listHelpAnswers([]).
listTasksAsked([]).
//listOBS([]).
//obsDIRs([]).
moving(false). 
searching(true).
moveGL(false). 
searchGL(false). 
moveDisp(false). 
searchDisp(false).
accepting(false). 
submitting(false). 
reqDir("").
extraAction(false). 
//extraActionParams("").
questionValue(""). 
nextDir(ne). 
currDir("").
distCount(1).
neededPOI("",0,0).
//blocked(false).
newX(0). newY(0).
spiStep(4). 
desXY(0,0).
//rtCWCounter(0).
//rtCorrDir("").
//clearAction(false).
//extraClear(false).
clearActionParams(s,0,0).
//obsDir("").
avoidAction(false).
numAttBlocks(0).
avoidActionDir("").
multiBlockTask(false).
busy(false).
answersWaitingID(0).
helpQuestTimer(0).
connecting(false).
taskInfos("",-1,[]).
connActionCOUNTER(0).
sentCOUNTER(0).
initialStep(0).

/* Plans */
/*########ACHTUNG########TO BE CHANGED IF THE AGENTS USERNAMES CHANGED########ACHTUNG########*/
+!getAGNum(AG): AG="ag-JNY1" <- +myAgentNum(1);.
+!getAGNum(AG): AG="ag-JNY2" <- +myAgentNum(2);.
+!getAGNum(AG): AG="ag-JNY3" <- +myAgentNum(3);.
+!getAGNum(AG): AG="ag-JNY4" <- +myAgentNum(4);.
+!getAGNum(AG): AG="ag-JNY5" <- +myAgentNum(5);.
+!getAGNum(AG): AG="ag-JNY6" <- +myAgentNum(6);.
+!getAGNum(AG): AG="ag-JNY7" <- +myAgentNum(7);.
+!getAGNum(AG): AG="ag-JNY8" <- +myAgentNum(8);.
+!getAGNum(AG): AG="ag-JNY9" <- +myAgentNum(9);.
+!getAGNum(AG): AG="ag-JNY10" <- +myAgentNum(10);.
+!getAGNum(AG): AG="ag-JNY11" <- +myAgentNum(11);.
+!getAGNum(AG): AG="ag-JNY12" <- +myAgentNum(12);.
+!getAGNum(AG): AG="ag-JNY13" <- +myAgentNum(13);.
+!getAGNum(AG): AG="ag-JNY14" <- +myAgentNum(14);.
+!getAGNum(AG): AG="ag-JNY15" <- +myAgentNum(15);.

/*Initial Steps */
+step(X): initialStep(IS) & team(TEAM) & name(NAME)	
	<- 
	if(IS=0){-+initialStep(IS+1); .concat("",NAME,AGENT_NAME); !getAGNum(AGENT_NAME); ?myAgentNum(NUM); .broadcast(tell,myName(NAME,TEAM,NUM));}
	elif(IS=1){.findall(agent(UN, SERVER_NAME, TEAM, AG_NUM),myName(UN, TEAM, AG_NUM)[source(SERVER_NAME)],LIST); -+listAG(LIST); .abolish(myName(_,_,_)); -initialStep(1);} 
	skip; .
//+step(X): initialStep(IS) & IS=1 & team(TEAM)				<- -+initialStep(IS+1); skip;.
//+step(X): initialStep(IS) & IS=2 & team(TEAM)				<- .findall(agent(UN, SERVER_NAME, TEAM, AG_NUM),myName(UN, TEAM, AG_NUM)[source(SERVER_NAME)],LIST); -+listAG(LIST); .abolish(myName(_,_,_)); -initialStep(_); skip;.
+step(X): disabled(true) <- skip;.

/*Checks lastAction & result for SINGLE BLOCK TASK */

+step(X): lastAction(request) & lastActionResult(success) & multiBlockTask(false) <- -+requesting(false); +attaching(true); skip;.
+step(X): lastAction(request) & lastActionResult(failed_blocked) & multiBlockTask(false) <- ?reqDir(D); ?direction(D,XRD,YRD); 
	if(thing(XRD,YRD,block)){
		+singleExtraClear(true); -+clearCOUNTER(1); 
//		?attDIR(DIR);
		if(D = s){-+clearActionParams(s,0,2); !chooseAction(cl,s,0,2);}
		elif(D = n){-+clearActionParams(n,0,-2); !chooseAction(cl,n,0,-2);}
		elif(D = e){-+clearActionParams(e,2,0); !chooseAction(cl,e,2,0);}
		elif(D = w){-+clearActionParams(w,-2,0); !chooseAction(cl,w,-2,0);}
	}else{
		  request(D);
	}
	.
+step(X): lastAction(submit) & lastActionResult(success) & multiBlockTask(false) <- -+busy(false); -+numAttBlocks(0); -+accepting(true); ?tb(XTB,YTB); -+desXY(XTB,YTB); skip;.
/*If submit failed for SINGLE BLOCK TASKS */
+step(X): lastAction(submit) & (lastActionResult(failed) | lastActionResult(failed_target)) & multiBlockTask(false) <- ?attDIR(DET_DIR); !chooseAction(dtt, DET_DIR); .
+step(X): lastAction(detach) & lastActionResutl(success) & multiBlockTask(false) <- -+numAttBlocks(0); +singleExtraClear(true); -+clearCOUNTER(1); 
	+h___________________________________("DETACHED STEP: ",X,"MY NAME: ", name(NAME));
	?attDIR(DIR);
	if(DIR = s){-+clearActionParams(s,0,2); !chooseAction(cl,s,0,2);}
	elif(DIR = n){-+clearActionParams(n,0,-2); !chooseAction(cl,n,0,-2);}
	elif(DIR = e){-+clearActionParams(e,2,0); !chooseAction(cl,e,2,0);}
	elif(DIR = w){-+clearActionParams(w,-2,0); !chooseAction(cl,w,-2,0);}
	skip;
	.
+step(X): lastAction(detach) & (lastActionResult(failed_parameter) | lastActionResult(failed_target) | lastActionResult(failed)) & multiBlockTask(false)
	<- -+numAttBlocks(0); -+busy(false); -+accepting(true); ?tb(XTB,YTB); -+desXY(XTB,YTB); !chooseAction(mo, D);.

/*Checks lastAction & result for MULTI BLOCK TASK */
+step(X): lastAction(request) & lastActionResult(success) & multiBlockTask(true) <- -+requesting(false); +attaching(true); skip;.
+step(X): lastAction(request) & lastActionResult(failed_blocked) & multiBlockTask(true) <- ?reqDir(D);   request(D);.
+step(X): accepterMULTI(true,AG) & lastAction(attach) & lastActionResult(success) <- 
	-+numAttBlocks(1); -+connecting(true); +startConnecting(false); 
	?position(AX,AY);
	.send(AG, tell, firstPoint(AX,AY));
	+h___________________________("FIRSTPOINT SENT IM ACCEPTER: ", AX,AY, "TO: ", AG);
	skip;.
	
+step(X): helperMULTI(true,AG) & lastAction(attach) & lastActionResult(success) 
	<- -+numAttBlocks(1); 
	?position(AX,AY);
	if(firstPoint(XFP1,YFP1)){
		NEWX = AX+XFP1;
		NEWY = AY+YFP1;
		if(NEWX mod 2 = 1){	MOD_NEWX = NEWX-1;	}else{	MOD_NEWX = NEWX;	}
		if(NEWY mod 2 = 1){	MOD_NEWY = NEWY-1;	}else{	MOD_NEWY = NEWY;	}
		MPX = MOD_NEWX/2;
		MPY = MOD_NEWY/2;
		-+desXY(MPX,MPY);
		?reqDir(DIR); ?direction(DIR,XBO,YBO);
		-+newX(MPX+XBO); -+newY(MPY+YBO); !correctX; !correctY;
		?newX(NXBO); ?newY(NYBO);
		.send(AG, tell, meetingPosition_BlockOn(MPX,MPY, NXBO,NYBO));
		+h________________________________("IM HELPER SENDING MEETING POSITION: ",MPX,MPY, "& BLOCKON: ",NXBO,NYBO, "TO: ",AG);
		-+connecting(true); 
		.abolish(firstPoint(XFP1,YFP1));
	}else{
		+moveUntilFP(true); ?nextDir(D); !calcDesXY(D);
	}
	skip;.
	
	
+step(X): lastAction(submit) & lastActionResult(success) & multiBlockTask(true) <- -+busy(false); -+multiBlockTask(false); -accepterMULTI(true,_); -+accepting(true); ?tb(XTB,YTB); -+desXY(XTB,YTB); skip;.
+step(X): lastAction(submit) & (lastActionResult(failed) | lastActionResult(failed_target)) & multiBlockTask(true) 
	<- ?taskInfos(_,_,[req(XB1,YB1,DISP1),req(XB2,YB2,DISP2)]); ?neededPOI(_,XB,YB);
	if(XB=XB1 & YB=YB1){?direction(DIR,XB1,YB1);}
	elif(XB=XB2 & YB=YB2){?direction(DIR,XB2,YB2);}
	-+attDIR(DIR);
	+accepterExtraMove(true);
	!chooseAction(dtt, DIR); 
	.


/*Steps for performing the connect action in the same step */
+step(X): doActionConnect(true) & accepterMULTI(true, AG) & connActionCOUNTER(CAC) <- 
	-+connActionCOUNTER(CAC+1); ?neededPOI(_,XB,YB); -doActionConnect(_); 
	?listAG(AGENTS_LIST); .member(agent(USERNAME, AG,_,_), AGENTS_LIST);
	-+connecting(false);
	+h_________________________________("USERNAME OF AGENT: ", AG, "IS", USERNAME);
	+h_________________________________("CONNECT PARAMS ACCEPTER CONNECT", USERNAME, XB,YB); 
	  connect(USERNAME,XB,YB);.
+step(X): doActionConnect(true)[source(AGENT)] & helperMULTI(true, AG) & connActionCOUNTER(CAC) <- 
	-+connActionCOUNTER(CAC+1); ?neededPOI(_,XB,YB); .abolish(doActionConnect(_)[source(AGENT)]); 
	?listAG(AGENTS_LIST); .member(agent(USERNAME, AG,_,_), AGENTS_LIST);
	-+connecting(false); 
	-+sentCOUNTER(0);
	+h_________________________________("USERNAME OF AGENT: ", AG, "IS", USERNAME);
	+h_________________________________("CONNECT PARAMS HELPER CONNECT", USERNAME, XB,YB); 
	  connect(USERNAME,XB,YB);.

+step(X): helperMULTI(true,_) & lastAction(connect) & lastActionResult(success) & multiBlockTask(true) <- ?neededPOI(_,XB,YB); ?direction(D,XB,YB); 
	-+connActionCOUNTER(0); !chooseAction(dtt, D);.
+step(X): helperMULTI(true,_) & lastAction(detach) & lastActionResult(success) & multiBlockTask(true) <- -+multiBlockTask(false); -+busy(false); 
	-helperMULTI(true,_); -connectInfos(_,_,_,_); -+numAttBlocks(0); if(accepted(_)){-+accepting(true); ?tb(TBX,TBY); -+desXY(TBX,TBY);}   skip; .

+step(X): accepterMULTI(true,AG) & lastAction(connect) & lastActionResult(success) & gl(XG,YG) & multiBlockTask(true) <- 
	-+numAttBlocks(2); -+connActionCOUNTER(0); -+desXY(XG,YG); -+submitting(true);   skip;.
+step(X): accepterMULTI(true,AG) & lastAction(connect) & lastActionResult(failed_partner) & gl(XG,YG) & taskInfos(_,_,[req(XB1,YB1,DISP1),req(XB2,YB2,DISP2)]) <- 
	 ?neededPOI(DISP,XB,YB); ?listAG(AGENTS_LIST); .member(agent(USERNAME, AG,_,_), AGENTS_LIST);
	 if(XB=XB1 & YB=YB1 & DISP=DISP1){
	 	if(thing(XB2,YB2,block,DISP2) & connActionCOUNTER(CAC) & CAC<2){
	 		.send(AG, tell, doActionConnect(true)); +doActionConnect(true);
	 		 
	 		skip;
	 	}else{	?direction(DIR,XB,YB); -accepterMULTI(true,_); !chooseAction(dtt,DIR);	}
	 }elif(XB=XB2 & YB=YB2 & DISP=DISP2){
	 	if(thing(XB1,YB1,block,DISP1) & connActionCOUNTER(CAC) & CAC<2){
	 		.send(AG, tell, doActionConnect(true)); +doActionConnect(true);
	 		 
			skip;
	 	}else{	?direction(DIR,XB,YB); -accepterMULTI(true,_); !chooseAction(dtt,DIR);	}
	 }
	 .
+step(X): helperMULTI(true,AG) & lastAction(connect) & lastActionResult(failed_partner) & connActionCOUNTER(CAC) <- if(CAC<2){  skip;}
	else{	?neededPOI(DISP,XB,YB); ?direction(DIR,XB,YB); -helperMULTI(true,_); !chooseAction(dtt,DIR); }.

+step(X): accepterMULTI(true,AG) & lastAction(connect) & (lastActionResult(failed_parameter) | lastActionResult(failed_target) | lastActionResult(failed)) & multiBlockTask(true) <-
	?neededPOI(DISP,XB,YB); ?direction(DIR,XB,YB); -accepterMULTI(true,_); !chooseAction(dtt,DIR);.
+step(X): helperMULTI(true,AG) & lastAction(connect) & (lastActionResult(failed_parameter) | lastActionResult(failed_target) | lastActionResult(failed)) & multiBlockTask(true) <-
	?neededPOI(DISP,XB,YB); ?direction(DIR,XB,YB); -helperMULTI(true,_); !chooseAction(dtt,DIR);.
+step(X): lastAction(detach) & lastActionResult(success) & not accepterMULTI(_,_) & not helperMULTI(_,_) & multiBlockTask(true) <- 
	-+numAttBlocks(0); +accepterExtraMove(true); +h___________________________________("DETACHED STEP: ",X,"MY NAME: ", name(NAME));   skip; .
+step(X): lastAction(detach) & (lastActionResult(failed_parameter) | lastActionResult(failed_target) | lastActionResult(failed)) & multiBlockTask(true) 
	<-	-+numAttBlocks(0); -+busy(false); -+multiBlockTask(false); -+accepting(true); ?tb(XTB,YTB); -+desXY(XTB,YTB); !chooseAction(mo, D);. 

/*Communication Steps */
+step(X): isAlreadyAccepted(T,A_NUM)[source(AGENT)] & not accepted(B)	& B \== T	<- 
	?listTasksAsked(LTAsked);
	if(not .member(T, LTAsked)){
		.concat(LTAsked,[T], NewLTAsked);
		-+listTasksAsked(NewLTAsked);
	}
	?questionValue(Q);
	?myAgentNum(MY_NUM);
	if(Q=T){
		
		if(MY_NUM>A_NUM){.send(AGENT,tell,answerTask(yes,T));
//			+h________________________________________("IM AGENT", MY_NUM, "VS", A_NUM,"ON TASK ",Q, "MY ANSWER IS YES --> STEP ", X);
		}
		else{.send(AGENT,tell,answerTask(no,T)); 
//			+h________________________________________("IM AGENT", MY_NUM, "VS", A_NUM, "ON TASK ",Q, "MY ANSWER IS NO --> STEP ", X);
		}
	}
	else{.send(AGENT,tell,answerTask(no,T));
//		+h________________________________________("IM AGENT", MY_NUM,"WITHOUT COMPETION ON TASK ",T," MY ANSWER TO",A_NUM ," IS NO --> STEP ", X);
	}
	
	/* .send(AGENT,tell,answerTask(no,T)); */ .abolish(isAlreadyAccepted(T,_)[source(AGENT)]); 
	.print("QUESTION FROM ", AGENT, " ABOUT ", T, " ANSWERED ------------------------------------> ANSWER ", no); 
	 
	skip; 
	.
	
+step(X): isAlreadyAccepted(T,A_NUM)[source(AGENT)] & accepted(B)	& B \== T	<- 
	?listTasksAsked(LTAsked);
	if(not .member(T, LTAsked)){
		.concat(LTAsked,[T], NewLTAsked);
		-+listTasksAsked(NewLTAsked);
	}
	?questionValue(Q);
	?myAgentNum(MY_NUM);
	if(Q=T){
		if(MY_NUM>A_NUM){.send(AGENT,tell,answerTask(yes,T));
//			+h________________________________________("IM AGENT", MY_NUM, "VS", A_NUM, "ON TASK ",Q, "MY ANSWER IS YES --> STEP ", X);
		}
		else{.send(AGENT,tell,answerTask(no,T)); 
//			+h________________________________________("IM AGENT", MY_NUM, "VS", A_NUM, "ON TASK ",Q, "MY ANSWER IS NO --> STEP ", X);
		}
	}
	else{.send(AGENT,tell,answerTask(no,T)); 
//		+h________________________________________("IM AGENT", MY_NUM,"WITHOUT COMPETION ON TASK ",T," MY ANSWER TO",A_NUM ," IS NO --> STEP ", X);
	}
	
	/*.send(AGENT,tell,answerTask(no,T)); */ .abolish(isAlreadyAccepted(T,_)[source(AGENT)]); 
	.print("QUESTION FROM ", AGENT, " ABOUT ", T, " ANSWERED ------------------------------------> ANSWER ", no); 
	 
	skip; .
	
+step(X): isAlreadyAccepted(T,_)[source(AGENT)] & accepted(T)	<- 
	?listTasksAsked(LTAsked);
	if(not .member(T, LTAsked)){
		.concat(LTAsked,[T], NewLTAsked);
		-+listTasksAsked(NewLTAsked);
	}
	.send(AGENT,tell,answerTask(yes,T)); .abolish(isAlreadyAccepted(T,_)[source(AGENT)]);
	.print("QUESTION FROM ", AGENT, " ABOUT ", T, " ANSWERED ------------------------------------> ANSWER ", yes);   skip; .
	
+step(X): answerTask(_,T) & questionValue(Q) & Q=T & waitingAnswers(true) & teamSize(TS) & TS>1	<- .findall(an(A,T,AGENT), answerTask(A,T)[source(AGENT)], LIST);
	-+listAnswers(LIST); .length(LIST, ListLen); !checkReplyNumber(ListLen);   skip; .
+step(X): teamSize(1) & questionValue(Q) & Q=T & waitingAnswers(true)	<- .findall(an(A,T,AGENT), answerTask(A,T)[source(AGENT)], LIST);
	-+listAnswers(LIST); .length(LIST, ListLen); !checkReplyNumber(ListLen);   skip; .
/*update decision belief wether to do an accept action or to try again */
+!makeDecision(N): N = 0 	<- +decision(acceptAction);.
+!makeDecision(N): N > 0	<- +decision(refuseAction);.
/*checks if the agent have received answers from all teammates */
+!checkReplyNumber(AnsNum): teamSize(TS) & AnsNum = TS-1	<- .count(answerTask(yes,T), NUM); !makeDecision(NUM); .abolish(answerTask(_,T)); 
	-+waitingAnswers(false);.
+!checkReplyNumber(AnsNum): teamSize(TS) & AnsNum \== TS-1	<- .print("--------------------------------------> WAITING FOR ANSWERS REPLY NUMBER");.

+!checkHelpReplyNumber(AnsNum, T): teamSize(TS) & AnsNum = TS-1	<- .abolish(answerHelp(no, T)[source(_)]); 
	.findall(ansH(ANS,AGENT, T), answerHelp(ANS, T)[source(AGENT)], ANS_LIST); .abolish(answerHelp(_, T)[source(_)]); -+listHelpAnswers(ANS_LIST); 
	-+waitingHelpAnswers(false);
//	?step(X); +h_______________________________________("ALL ANSWERS ARRIVED STEP:", X,"ANSNUM: ",AnsNum);
	.
+!checkHelpReplyNumber(AnsNum,_): teamSize(TS) & AnsNum \== TS-1<- .print("--------------------------------------> WAITING FOR ANSWERS HELP REPLY NUMBER");.

/*serve the bigger number implementation same step question problem Curr Sol: stepX waitingToBeChosen above*/
+step(X): wannaHelp(_,_,T)[source(AGENT)] & busy(false) <- .send(AGENT,tell, answerHelp(yes, T)); .abolish(wannaHelp(_,_,T)[source(AGENT)]); 
	?answersWaitingID(ID); -+answersWaitingID(ID+1); -+busy(true); +waitToBeChosen(true, ID+1); +wTBC(true,ID+1,AGENT); 
//	+h__________________________________________("STARTED WAITING TO BE CHOSEN FROM AGENT: ", AGENT, " STEP: ",X, "BUSY: true"); 
	 
	skip;.
+step(X): wannaHelp(_,_,T)[source(AGENT)] & busy(true) 	<- .send(AGENT,tell, answerHelp(no, T)); .abolish(wannaHelp(_,_,T)[source(AGENT)]);   skip;.
/*break after the first free agent, to be implemented*/ 
+step(X): answerHelp(_, T) & waitingHelpAnswers(true)	<- .findall(ansH(ANS,AGENT, T), answerHelp(ANS, T)[source(AGENT)], ANS_LIST); 
	-+listHelpAnswers(ANS_LIST); .length(ANS_LIST, LEN); !checkHelpReplyNumber(LEN, T);	
	 
	skip;.

+step(X): waitToBeChosen(true, ID) <- 
	if(chosenOne(true, XB, YB, DISP, DIR)[source(AGENT1)]){
		-+multiBlockTask(true);
		-+neededPOI(DISP, XB,YB);
		-waitToBeChosen(_,ID); /*DO NOT REMOVE */
		+connectInfos(XB,YB,DISP, DIR);
		+helperMULTI(true, AGENT1);
		.abolish(chosenOne(true, XB, YB, DISP, DIR)[source(AGENT1)]);
		if(chosenOne(false)){
			.abolish(chosenOne(false)[source(_)]);
		}
//		+h_______________________________________("FINISHED WAITING TO BE CHOSEN: waitToBeChosen(true", ID,") STEP:", X,"ChosenOne(true) FROM ",AGENT1," INFOS:", XB,YB,DISP);
		!doTask;
		 
		skip;
	}elif(chosenOne(false)[source(AGENT2)]){
		-+busy(false);
		-waitToBeChosen(_,ID); /*DO NOT REMOVE */
		.abolish(chosenOne(false)[source(AGENT2)]);
		 
		skip;
//		+h_______________________________________("FINISHED WAITING TO BE CHOSEN: waitToBeChosen(true", ID,") STEP:", X,"chosenOne(false) FROM ",AGENT2);
	}
	/*-waitToBeChosen(_); IF HERE THE STEP WONT REPEAT ITSELF*/
	/*FIXED: with the ID, think it can be deleted here! */
	.
	
+step(X): waitingHelpAnswers(false) <- 
	?listHelpAnswers(ANS_LIST); /*check if list length is bigger than 0 so it means someone is free */
	.length(ANS_LIST, LEN_ANS_LIST);
	if(LEN_ANS_LIST\==0){
		.nth(0, ANS_LIST, ansH(ANS,AGENT, TASK)); 
		 ?task(TASK,STEPLIMIT,_,[req(XB1,YB1,DISP1),req(XB2,YB2,DISP2)]);
		 -+taskInfos(TASK,STEPLIMIT,[req(XB1,YB1,DISP1),req(XB2,YB2,DISP2)]);
		 +accepterMULTI(true, AGENT);
		 if(math.abs(XB1)+math.abs(YB1)=2){
		 	-+neededPOI(DISP2,XB2,YB2); ?direction(DIR,XB2,YB2);
		 	.send(AGENT, tell, chosenOne(true, XB1, YB1, DISP1, DIR));
		 }elif(math.abs(XB1)+math.abs(YB1)=1){
		 	-+neededPOI(DISP1,XB1,YB1); ?direction(DIR,XB1,YB1);
		 	.send(AGENT, tell, chosenOne(true, XB2, YB2, DISP2, DIR));
		 }
		.delete(0, ANS_LIST, NEW_ANS_LIST);
		.length(NEW_ANS_LIST, LEN_NEW_ANS_LIST);
		if(len>0){
			for( .member(ansH(_,AG_NAME,TASK), NEW_ANS_LIST) ){	.send(AG_NAME, tell, chosenOne(false));	}
		}
		!doTask;
		-waitingHelpAnswers(_);
		 
		skip;
	}elif(LEN_ANS_LIST=0){
		?helpQuestTimer(HQT); -+helpQuestTimer(HQT+1);
		if(HQT=10){
			-+helpQuestTimer(0); -+waitingHelpAnswers(true); !broadcastHelp;
			+h_____________________________________("HQT: ", HQT, "BROADCASTED AGAIN, STEP: ",X," & HQT: 0 & WAITINGHELPANSWERS: true");
		}
		 
		skip;
	}
	 .


/*trigger the spiral movement when not having a task to do*/
+step(X): moving(false) & searching(true) & not accepted(_)	& busy(false)	<- ?nextDir(D); !calcDesXY(D); -+moving(true);   skip; .

/*spiral movement looking for a taskboard, if no task is accepted */
+step(X): moving(true) & not thing(_,_,taskboard,_) & not accepted(_) & busy(false) <- 
	?desXY(DX,DY);
	!storeDispB0; !storeDispB1; !storeGoal;
	
	!listBeliefs(recTB); 
	?listTB(L); 
	!comparePOIs(0, .length(L), recTB);
	
	?tb(XTB,YTB);
	if(XTB>-1 & YTB>-1){!goto(XTB,YTB);}
	else{!goto(DX,DY);}
	skip;
	.
	
/*moving towards a TB, if the Agent does not have an accepted task & accept one*/
/* math.abs(TX)+math.abs(TY) > 2 could cause problems coz !goto() cant reach the destination --> not updating moving with false */
+step(X): moving(true) & thing(TX,TY,taskboard,_) & not accepted(_)	& (math.abs(TX)+math.abs(TY))>0  & accepting(false)	& busy(false) <- 
	?position(AX,AY);
	!storeTB; !storeDispB0; !storeDispB1; !storeGoal;
	?tb(TBX,TBY);
	-+desXY(TBX,TBY);
	if( (math.abs(TX)+math.abs(TY))<=2 ){
		-+moving(false); -+searching(false);
		 
		skip;
	}elif( (math.abs(TX)+math.abs(TY))>2 ){
		!goto(AX+TX,AY+TY);	
		skip;
	}
	.
@s1
+step(X): thing(TX,TY,taskboard,_) & not accepted(_) & accepting(false) & (math.abs(TX)+math.abs(TY)<=2) & busy(false)
	<- -+accepting(true);   skip; . 

/*reaccepting a task after submitting one*/
+step(X): accepting(true) & desXY(DX,DY) /*& tb(TBX,TBY)*/ & position(AX,AY) & (math.abs(AX-DX)+math.abs(AY-DY))>2
	<- !checkBetterPOI; ?desXY(NX,NY); !changeDirection(NX,NY); !goto(NX,NY); skip;.
+step(X): accepting(true) & desXY(DX,DY) /*& tb(TBX,TBY)*/ & position(AX,AY) & (math.abs(AX-DX)+math.abs(AY-DY))<=2
	<- -+accepting(false); !acceptTask; skip;.


/*start doing a task after accepting a Task */
+step(X): doingTask(false) & accepted(T)	<- -+searching(false); /* ?task(T,_,_,[req(XB,YB,DISP)]);*/ 
	?task(T,_,_,REQs); .length(REQs,LEN_REQs); 
	if(LEN_REQs = 1){
		?task(T,_,_,[req(XB,YB,DISP)]);
		-+neededPOI(DISP,XB,YB); 
		-+multiBlockTask(false); /* add multiBlockTask in doTask context */
		-+doingTask(true); 
		!doTask; 
		 
		skip;
	}elif(LEN_REQs = 2){
		-+multiBlockTask(true);
		/* NEW: !doTask to be implemented with multiBlockTask*/
		!broadcastHelp;
		+waitingHelpAnswers(true);
		-+doingTask(true);
		 
		skip;
	}
	.

/*move towards a Dispenser & request for SINGLE BLOCK TASKS */
+step(X): desXY(DX,DY) & requesting(true) & not position(DX,DY)	& busy(true) & multiBlockTask(false)<- !checkBetterPOI; ?desXY(NewDX,NewDY); 
	!changeDirection(NewDX,NewDY); !goto(NewDX,NewDY); skip;.
+step(X): desXY(DX,DY) & requesting(true) & position(DX,DY)	& busy(true) & multiBlockTask(false)	<- ?reqDir(D);   request(D); .

/*move towards a Dispenser & request for MULTI BLOCK TASKS ---ACCEPTER & HELPER---*/
+step(X): desXY(DX,DY) & requesting(true) & not position(DX,DY)	& busy(true) & multiBlockTask(true) & accepterMULTI(true, AGENT) 
	<- !checkBetterPOI; ?desXY(NewDX,NewDY); !changeDirection(NewDX,NewDY); !goto(NewDX,NewDY); skip;.
+step(X): desXY(DX,DY) & requesting(true) & position(DX,DY)	& busy(true) & multiBlockTask(true) & accepterMULTI(true, AGENT) 
	<- ?reqDir(D);   request(D); .

+step(X): desXY(DX,DY) & requesting(true) & not position(DX,DY)	& busy(true) & multiBlockTask(true) & helperMULTI(true, AGENT) 
	<- !checkBetterPOI; ?desXY(NewDX,NewDY); !changeDirection(NewDX,NewDY); !goto(NewDX,NewDY); skip;.
+step(X): desXY(DX,DY) & requesting(true) & position(DX,DY)	& busy(true) & multiBlockTask(true) & helperMULTI(true, AGENT) 
	<- ?reqDir(D);   request(D);.

/*step for executing the attach action for SINGLE BLOCK TASKS*/
+step(X): attaching(true) & gl(XG,YG) & multiBlockTask(false) <- 
	?reqDir(D); -+desXY(XG,YG); -+attaching(false); -+submitting(true); -+attDIR(D);   attach(D); .

/*step for executing the attach action for MULTI BLOCK TASKS ---ACCEPTER & HELPER---*/
+step(X): attaching(true) & multiBlockTask(true) & accepterMULTI(true,AG)
	<- ?reqDir(D); -+attaching(false); -+attDIR(D);   attach(D); .
	
+step(X): attaching(true) & multiBlockTask(true) & helperMULTI(true,AG)
	<- ?reqDir(D); -+attaching(false); -+attDIR(D);   attach(D); .
	
/*Steps to start the connection process for MULTI BLOCK TASKS ---HELPER & ACCEPTER--- */
+step(X): connecting(false) & multiBlockTask(true) & helperMULTI(true,AG) & moveUntilFP(true) <- 
	?desXY(XD,YD);
	if(firstPoint(XFP1,YFP1)){
		?position(AX,AY); NEWX = AX+XFP1; NEWY = AY+YFP1;
		if(NEWX mod 2 = 1){	MOD_NEWX = NEWX-1;	}else{	MOD_NEWX = NEWX;	}
		if(NEWY mod 2 = 1){	MOD_NEWY = NEWY-1;	}else{	MOD_NEWY = NEWY;	}
		MPX = MOD_NEWX/2; MPY = MOD_NEWY/2;
		-+desXY(MPX,MPY);
		?reqDir(DIR); ?direction(DIR,XBO,YBO);
		-+newX(MPX+XBO); -+newY(MPY+YBO); !correctX; !correctY;
		?newX(NXBO); ?newY(NYBO);
		.send(AG, tell, meetingPosition_BlockOn(MPX,MPY, NXBO,NYBO));
		-+connecting(true); -moveUntilFP(true);
		.abolish(firstPoint(XFP1,YFP1));
		 
		skip;
	}else{
		if(position(XD,YD)){	?nextDir(D); !calcDesXY(D);   skip;	}
		else{	!goto(XD,YD);	}
	}.
+step(X): connecting(true) & multiBlockTask(true) & helperMULTI(true,AG) & desXY(XD,YD) & not position(XD,YD) <- !goto(XD,YD);.
+step(X): connecting(true) & multiBlockTask(true) & helperMULTI(true,AG) & desXY(XD,YD) & position(XD,YD) <- 	
	if(sentCOUNTER(0)){	
		.send(AG, tell, helperArrived(arr));
		+h_______________________________("IM HELPER & I ARRIVED TO THE MP WITH: ", AG);
		-+sentCOUNTER(1);	}
		 
	skip;
	.

/*ACCEPTER */
+step(X): connecting(true) & startConnecting(false) & multiBlockTask(true) & accepterMULTI(true, AG) 
	<- ?desXY(XD,YD);
		if(meetingPosition_BlockOn(XGT,YGT, XBO,YBO)){
			?name(NAME);
			+h_____________________________________("IM ACCEPTER: ",NAME," RECIEVED FROM: ",AG,"HELP POS: ", XGT,YGT, "BLOCK POS: ",XBO,YBO);
			?accepted(TASK); ?taskInfos(TASK,_,[req(XB1,YB1,DISP1),req(XB2,YB2,DISP2)]);
			/*test if task is still relevant */
			 ?neededPOI(_,XB,YB);
			/* subtract the helper block from how it should be submitted not mine*/
			if(XB=XB1 & YB=YB1){	-+desXY(XBO-XB2, YBO-YB2);
				+h________________________________("desXY AG Position IM ACCEPTER: ",NAME, XBO-XB2, YBO-YB2, "XB2",XB2,"YB2",YB2);
			}elif(XB=XB2 & YB=YB2){	-+desXY(XBO-XB1, YBO-YB1);
				+h________________________________("desXY AG Position IM ACCEPTER: ",NAME, XBO-XB1, YBO-YB1, "XB1",XB1,"YB1",YB1);
			}
			.abolish(meetingPosition_BlockOn(XGT,YGT, XBO,YBO)[source(_)]);
			-+startConnecting(true);
			skip;
		}else{
			if(position(XD,YD)){	?nextDir(D); !calcDesXY(D);	skip;	}
			else{	!goto(XD,YD);	}
		}
		.
/*Second step updates the belief base of both the accepter & helper with same belief so they can execute the connect action at the same step */
+step(X): connecting(true) & startConnecting(true) & multiBlockTask(true) & accepterMULTI(true, AG) & desXY(DX,DY) & not position(DX,DY) 
	& accepterMULTI(true,AG) <- !goto(DX,DY);.
+step(X): connecting(true) & startConnecting(true) & multiBlockTask(true) & accepterMULTI(true, AG) & desXY(DX,DY) & position(DX,DY) 
	& accepterMULTI(true,AG) <- 
		if(helperArrived(_)){
			.abolish(helperArrived(_));
			.send(AG, tell, doActionConnect(true)); -startConnecting(_); +doActionConnect(true);
		}		
		 skip;.

/*move towards the saved goal area & submit the already accepted task for SINGLE BLOCK TASKS*/
/*NEW CODE: gl(XG,YG) & -+desXY(XG,YG) added CL150 attaching step*/
+step(X): submitting(true) & desXY(DX,DY) & accepted(T) & not position(DX,DY) & multiBlockTask(false) <- !checkBetterPOI; ?desXY(NewDX,NewDY) !goto(NewDX,NewDY); skip;.
+step(X): submitting(true) & desXY(DX,DY) & accepted(T) & position(DX,DY) & multiBlockTask(false) <- -+submitting(false);   submit(T); .

+step(X): singleExtraClear(true) & clearCOUNTER(CC) <- 
	?clearActionParams(D,X,Y);
	if(CC <= 2 & lastAction(clear) & lastActionResult(success)){
		-+clearCOUNTER(CC+1);
		!chooseAction(cl, D, X, Y);
	}elif(CC >2){
		-singleExtraClear(_); -+clearCOUNTER(1);
		-+busy(false); -+accepting(true);
		?tb(XTB,YTB); -+desXY(XTB,YTB);
		!chooseAction(mo, D);
	}elif(lastAction(ACTION) & ACTION\==clear){
		-+clearCOUNTER(CC+1);
		!chooseAction(cl, D, X, Y);
	}
	skip;
	.

/*move towards the saved goal area & submit the already accepted task for MULTI BLOCK TASKS ---ACCEPTER---*/
+step(X): submitting(true) & desXY(DX,DY) & accepted(T) & not position(DX,DY) & multiBlockTask(true) & accepterMULTI(true, AGENT) <- !checkBetterPOI; ?desXY(NewDX,NewDY) !goto(NewDX,NewDY); skip;.
+step(X): submitting(true) & desXY(DX,DY) & accepted(T) & position(DX,DY) & multiBlockTask(true) & accepterMULTI(true, AGENT)  <- -+submitting(false);   submit(T); .

+step(X): accepterExtraMove(true) <- 
	?attDIR(DIR); -accepterExtraMove(_); +accepterClearAfterDetach(true);
	if(DIR=s){!chooseAction(mo,n);}
	elif(DIR=n){!chooseAction(mo,s);}
	elif(DIR=e){!chooseAction(mo,w);}
	elif(DIR=w){!chooseAction(mo,e);}
	skip;
	.
+step(X): accepterClearAfterDetach(true) <- 
	?attDIR(DIR); -accepterClearAfterDetach(_); +accepterExtraClear(true); -+clearCOUNTER(1);
	if(DIR = s){-+clearActionParams(s,0,2); !chooseAction(cl,s,0,2);}
	elif(DIR = n){-+clearActionParams(n,0,-2); !chooseAction(cl,n,0,-2);}
	elif(DIR = e){-+clearActionParams(e,2,0); !chooseAction(cl,e,2,0);}
	elif(DIR = w){-+clearActionParams(w,-2,0); !chooseAction(cl,w,-2,0);}
	skip;
	.
+step(X): accepterExtraClear(true) & clearCOUNTER(CC) <- 
	?clearActionParams(D,CX,CY);
	if(CC <= 2 & lastAction(clear) & lastActionResult(success)){
		-+clearCOUNTER(CC+1);
		!chooseAction(cl, D, CX, CY);
	}elif(CC >2){
		-accepterExtraClear(_); -+clearCOUNTER(1);
		-+busy(false); -+multiBlockTask(false); -accepterMULTI(true,_); -+accepting(true);
		?tb(XTB,YTB); -+desXY(XTB,YTB);
		!chooseAction(mo, D);
	}elif(lastAction(ACTION) & ACTION\==clear){
		-+clearCOUNTER(CC+1);
		!chooseAction(cl, D, CX, CY);
	}
	skip;
	.

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
	

/*Scenarios when doing a task*/
+!doTask: accepted(T) & gl(-1,-1) <- -+searchGL(true); !listBeliefs(recGL); ?listGL(L); .length(L, LEN_L); !comparePOIs(0, LEN_L, recGL);.
/*NEVER IMPLEMENT doTask for not gl(-1,-1) */
+!doTask: accepted(T) & b0(-1,-1) & searchGL(false)	<- -+searchDisp(true); +searchFor(b0); !listBeliefs(recB0); 
	?listB0(L); !comparePOIs(0, .length(L), recB0);.
+!doTask: accepted(T) & not b0(-1,-1) & task(T,_,_,[req(ASX,ASY,b0)])	<- ?b0(XB,YB); ?direction(DIR,ASX,ASY); -+reqDir(DIR); -+desXY(XB-ASX,YB-ASY); 
	+requesting(true); -+neededPOI(b0,ASX,ASY); !listBeliefs(recB0); ?listB0(L); 
	.length(L, LEN_L); !comparePOIs(0, LEN_L, recB0); ?b0(NewXB, NewYB); -+desXY(NewXB-ASX,NewYB-ASY); !changeDirection(NewXB-ASX,NewYB-ASY); .
+!doTask: accepted(T) & b1(-1,-1) & searchGL(false) <- -+searchDisp(true); +searchFor(b1); !listBeliefs(recB1); 
	?listB1(L); .length(L, LEN_L); !comparePOIs(0, LEN_L, recB1);.
+!doTask: accepted(T) & not b1(-1,-1) & task(T,_,_,[req(ASX,ASY,b1)])	<- ?b1(XB,YB); ?direction(DIR,ASX,ASY); -+reqDir(DIR); -+desXY(XB-ASX,YB-ASY); 
	+requesting(true); -+neededPOI(b1,ASX,ASY); !listBeliefs(recB1); ?listB1(L); 
	.length(L, LEN_L); !comparePOIs(0, LEN_L, recB1); ?b1(NewXB, NewYB); -+desXY(NewXB-ASX,NewYB-ASY); !changeDirection(NewXB-ASX,NewYB-ASY); .

/*!doTask for MULTI BLOCK TASKS -----ACCEPTER & HELPER----- */
+!doTask: multiBlockTask(true) & gl(-1,-1) <- -+searchGL(true); !listBeliefs(recGL); ?listGL(L); .length(L, LEN_L); !comparePOIs(0, LEN_L, recGL);.
+!doTask: multiBlockTask(true) & b0(-1,-1) & neededPOI(b0,_,_) & searchGL(false) <- -+searchDisp(true); +searchFor(b0); !listBeliefs(recB0); ?listB0(L); 
	!comparePOIs(0, .length(L), recB0);.
+!doTask: multiBlockTask(true) & not b0(-1,-1) & neededPOI(b0, XDISP, YDISP) <- 
	?b0(XB,YB); 
	if((math.abs(XDISP)+math.abs(YDISP))=1){
		?direction(DIR, XDISP, YDISP);
		-+reqDir(DIR); -+desXY(XB-XDISP,YB-YDISP); +requesting(true); -+neededPOI(b0,XDISP,YDISP); !listBeliefs(recB0); ?listB0(L); .length(L, LEN_L); 
		!comparePOIs(0, LEN_L, recB0); ?b0(NewXB, NewYB); -+desXY(NewXB-XDISP,NewYB-YDISP); !changeDirection(NewXB-XDISP,NewYB-YDISP);
	}elif((math.abs(XDISP)+math.abs(YDISP))=2){
		if(XDISP=0){	if(YDISP>0){-+reqDir(n); ?direction(n,DIRX,DIRY);}elif(YDISP<0){-+reqDir(s); ?direction(s,DIRX,DIRY);}	}
		elif(YDISP=0){	if(XDISP>0){-+reqDir(w); ?direction(w,DIRX,DIRY);}elif(XDISP<0){-+reqDir(e); ?direction(e,DIRX,DIRY);}	}
		else{	?connectInfos(_,_,_,DIR); if(DIR=s | DIR=n){-+reqDir(s); DIRX=0; DIRY=1;}elif(DIR=e | DIR=w){-+reqDir(e); DIRX=1; DIRY=0;}	}
		/*-+reqDir(s);*/ -+desXY(XB-DIRX,YB-DIRY); +requesting(true); -+neededPOI(b0,DIRX,DIRY); !listBeliefs(recB0); ?listB0(L); .length(L, LEN_L); 
		!comparePOIs(0, LEN_L, recB0); ?b0(NewXB, NewYB); -+desXY(NewXB-DIRX, NewYB-DIRY); !changeDirection(NewXB-DIRX, NewYB-DIRY);
	}.
+!doTask: multiBlockTask(true) & b1(-1,-1) & neededPOI(b1,_,_) & searchGL(false) <- -+searchDisp(true); +searchFor(b1); !listBeliefs(recB1); ?listB1(L); 
	!comparePOIs(0, .length(L), recB1);.
+!doTask: multiBlockTask(true) & not b1(-1,-1) & neededPOI(b1, XDISP, YDISP) <- 
	?b1(XB,YB); 
	if((math.abs(XDISP)+math.abs(YDISP))=1){
		?direction(DIR, XDISP, YDISP);
		-+reqDir(DIR); -+desXY(XB-XDISP,YB-YDISP); +requesting(true); -+neededPOI(b1,XDISP,YDISP); !listBeliefs(recB1); ?listB1(L); .length(L, LEN_L); 
		!comparePOIs(0, LEN_L, recB1); ?b1(NewXB, NewYB); -+desXY(NewXB-XDISP,NewYB-YDISP); !changeDirection(NewXB-XDISP,NewYB-YDISP);
	}elif((math.abs(XDISP)+math.abs(YDISP))=2){
		if(XDISP=0){	if(YDISP>0){-+reqDir(n); ?direction(n,DIRX,DIRY);}elif(YDISP<0){-+reqDir(s); ?direction(s,DIRX,DIRY);}	}
		elif(YDISP=0){	if(XDISP>0){-+reqDir(w); ?direction(w,DIRX,DIRY);}elif(XDISP<0){-+reqDir(e); ?direction(e,DIRX,DIRY);}	}
		else{	?connectInfos(_,_,_,DIR); if(DIR=s | DIR=n){-+reqDir(s); DIRX=0; DIRY=1;}elif(DIR=e | DIR=w){-+reqDir(e); DIRX=1; DIRY=0;}	}
		/*-+reqDir(s);*/ -+desXY(XB-DIRX,YB-DIRY); +requesting(true); -+neededPOI(b1,DIRX,DIRY); !listBeliefs(recB1); ?listB1(L); .length(L, LEN_L); 
		!comparePOIs(0, LEN_L, recB1); ?b1(NewXB, NewYB); -+desXY(NewXB-DIRX, NewYB-DIRY); !changeDirection(NewXB-DIRX, NewYB-DIRY);
	}.

/*accepting task, if the Agent is on a TB */
+!acceptTask: thing(XTB,YTB,taskboard,_) & (math.abs(XTB)+math.abs(YTB))<=2 & task(T,_,_,_) & busy(false) <- /*?task(T,_,_,_);  +doingTask(false); */ 
	.remove_plan(s1);
	!broadcastTask(T); 
	if(brCastResult(success)){	+waitingAnswers(true); -brCastResult(_); -+busy(true);	}
	else{	-brCastResult(_); -+accepting(true); -+busy(false);	}
	.
+!acceptTask: thing(XTB,YTB,taskboard,_) & (math.abs(XTB)+math.abs(YTB))<=2 & not task(_,_,_,_) <- skip;.

+!acceptTask: thing(XTB,YTB,taskboard,_) & (math.abs(XTB)+math.abs(YTB))>2 <- 
	.print("-----------------------------------> CAN'T ACCEPT");.

+step(X): waitingAnswers(false)	<- 
	?decision(DECISION); 
	if(DECISION = acceptAction){ 
		?questionValue(T);
		.print("Decision: ", DECISION, "-------------------------> ACCEPTED TASK", T); 
		-decision(_); -waitingAnswers(_); +doingTask(false);
		accept(T); 
	}else{  
		.print("Decision: ", DECISION, "-------------------------> REJECTED TASK", T); 
		.print("--------------> Waiting for a new Task");
		-+busy(false); -+accepting(true); -decision(_); -waitingAnswers(_);
		skip;
	} 
	.

/*Checks if better POI -than the saved ones- available(closer to the agent)*/
/*No destination change when the available destinations are worse or =, Disp's scenarios*/
	// math.abs(DX+NBX-AX) + math.abs(DY+NBY-AY) <= math.abs(XB) + math.abs(YB)
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b0,NBX,NBY) & thing(XB,YB,dispenser,b0) 
	& position(AX,AY) & /*math.abs(DX+NBX-AX)<=math.abs(XB) & math.abs(DY+NBY-AY)<=math.abs(YB)*/
						math.abs(DX+NBX-AX) + math.abs(DY+NBY-AY) <= math.abs(XB) + math.abs(YB) 		<- !changeDirection(DX,DY);.
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b1,NBX,NBY) & thing(XB,YB,dispenser,b1) 
	& position(AX,AY) & /*math.abs(DX+NBX-AX)<=math.abs(XB) & math.abs(DY+NBY-AY)<=math.abs(YB)*/
						math.abs(DX+NBX-AX) + math.abs(DY+NBY-AY) <= math.abs(XB) + math.abs(YB) 		<- !changeDirection(DX,DY);.
	
/*No destination change when no other destinations available */
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b0,_,_) & not thing(_,_,dispenser,b0) <- !changeDirection(DX,DY);.
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b1,_,_) & not thing(_,_,dispenser,b1) <- !changeDirection(DX,DY);.
	
/*Change Destination */
//		math.abs(DX+NBX-AX) + math.abs(DY+NBY-AY) > math.abs(XB) + math.abs(YB)
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b0,NBX,NBY) & thing(XB,YB,dispenser,b0) 
	& position(AX,AY) & /*math.abs(DX+NBX-AX)>math.abs(XB) & math.abs(DY+NBY-AY)>math.abs(YB)*/
						math.abs(DX+NBX-AX) + math.abs(DY+NBY-AY) > math.abs(XB) + math.abs(YB) 		<- ?direction(DIR,NBX,NBY); -+reqDir(DIR); 
	-+newX(AX+XB-NBX);-+newY(AY+YB-NBY); !correctX; !correctY; ?newX(NX); ?newY(NY); -+desXY(NX,NY); /*AX+XB-NBX, AY+YB-NBY*/ !changeDirection(NX,NY);.
	
+!checkBetterPOI: requesting(true) & desXY(DX,DY) & neededPOI(b1,NBX,NBY) & thing(XB,YB,dispenser,b1) 
	& position(AX,AY) & /*math.abs(DX+NBX-AX)>math.abs(XB) & math.abs(DY+NBY-AY)>math.abs(YB)*/
						math.abs(DX+NBX-AX) + math.abs(DY+NBY-AY) > math.abs(XB) + math.abs(YB) 		<- ?direction(DIR,NBX,NBY); -+reqDir(DIR); 
	-+newX(AX+XB-NBX);-+newY(AY+YB-NBY); !correctX; !correctY; ?newX(NX); ?newY(NY); -+desXY(NX,NY); /*AX+XB-NBX,AY+YB-NBY */ !changeDirection(NX,NY);.
	
/*better goal coordinates scenarios */
+!checkBetterPOI: submitting(true) & desXY(DX,DY) & not goal(_,_) 			<- !changeDirection(DX,DY);.
+!checkBetterPOI: submitting(true) & desXY(DX,DY) & goal(_,_) 	
	<- !changeDirection(DX,DY);
	+minDist(999);
	?position(AX,AY);
	.findall(g(XG,YG), goal(XG,YG), LIST);
	for(	.member(g(NXG,NYG), LIST)	){
		?minDist(MD);
		if(math.abs(NXG)+math.abs(NYG)<MD){
			-+minDist(math.abs(NXG)+math.abs(NYG));
			-+gl(AX+NXG, AY+NYG);
		}
	}
	-minDist(_);
	?gl(OXG,OYG); -+newX(OXG); -+newY(OYG); !correctX; !correctY;
	?newX(NXG); ?newY(NYG);
	-+gl(NXG,NYG); -+desXY(NXG,NYG);	
	.

+!checkBetterPOI: accepting(true) & desXY(DX,DY) & not thing(XTB,YTB,taskboard,_)			<- !changeDirection(DX,DY); . 
+!checkBetterPOI: accepting(true) & desXY(DX,DY) & thing(XTB,YTB,taskboard,_)
	& position(AX,AY) & math.abs(DX-AX) + math.abs(DY-AY) <= math.abs(XTB) + math.abs(YTB)	<- !changeDirection(DX,DY); . 
+!checkBetterPOI: accepting(true) & desXY(DX,DY) & thing(XTB,YTB,taskboard,_) 
	& position(AX,AY) & math.abs(DX-AX) + math.abs(DY-AY) > math.abs(XTB) + math.abs(YTB)	<- -+newX(AX+XTB); -+newY(AY+YTB); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+desXY(NX,NY); !changeDirection(NX,NY); . 
/* ----------------------------------CHANGE DIRECTION-----------------------------------
 * 	 	updates the general direction of the agent based on the current destination	*/
+!changeDirection(NX,NY): position(AX,AY) & ((AX>NX & AY>NY) | (AX>=NX & AY>NY) | (AX>NX & AY>=NY))	<- -+nextDir(nw); .
+!changeDirection(NX,NY): position(AX,AY) & ((AX<NX & AY<NY) | (AX<=NX & AY<NY) | (AX<NX & AY<=NY))	<- -+nextDir(se); .
+!changeDirection(NX,NY): position(AX,AY) & ((AX>NX & AY<NY) | (AX>=NX & AY<NY) | (AX>NX & AY<=NY))	<- -+nextDir(sw); .
+!changeDirection(NX,NY): position(AX,AY) & ((AX<NX & AY>NY) | (AX<=NX & AY>NY) | (AX<NX & AY>=NY))	<- -+nextDir(ne); .
+!changeDirection(NX,NY): position(AX,AY) & AX=NX & AY=NY	<- ?nextDir(NextDir); -+nextDir(NextDir);.

/* -----------------------------------BROADCAST----------------------------------- 
*							Send all agents POI infos*/
+!broadcastPOI(b0)	<- ?b0(XB,YB); .broadcast(tell, receivedB0(XB,YB)); .
+!broadcastPOI(b1)	<- ?b1(XB,YB); .broadcast(tell, receivedB1(XB,YB)); .
+!broadcastPOI(gl)	<- ?gl(XG,YG); .broadcast(tell, receivedGL(XG,YG)); .
+!broadcastPOI(tb)	<- ?tb(XTB,YTB); .broadcast(tell, receivedTB(XTB,YTB)); .
+!broadcastTask(T): questionValue(Q) & Q \== T & teamSize(TS) & TS>1 & listTasksAsked(LTAsked) & not .member(T, LTAsked) 
	<- +brCastResult(success); -+questionValue(T); ?myAgentNum(AG_NUM); ?step(STEP); +h_____________________________________("MY QUESTION ABOUT TASK ", T, "STEP: ",STEP); 
		.broadcast(tell, isAlreadyAccepted(T, AG_NUM));
		.print("QUESTION BROADCASTED ------------------------------------> QUESTION FROM ",name(NAME)," ABOUT ", T); . 
+!broadcastTask(T): ( (questionValue(Q) & Q = T) | (listTasksAsked(LTAsked) & .member(T, LTAsked)) )  & teamSize(TS) & TS>1	 
	<- +brCastResult(failed_repeated); .print("---------------------------------------------------------> ALREADY ASKED ABOUT ", T); .
+!broadcastTask(T): teamSize(1) <- 
	+brCastResult(success); -+questionValue(T); .print("-----> SINGLE AGENT NO NEED TO BROADCAST!"); .
+!broadcastHelp 	<- ?name(NAME); ?accepted(T); .broadcast(tell, wannaHelp(NAME, "Are you free?", T)); .

//.findall(an(A,T,AGENT), answerTask(A,T)[source(AGENT)], LIST);
+!listBeliefs(recB0) <- .findall(b0(XB,YB),receivedB0(XB,YB),L); .abolish(receivedB0(_,_)); !updateList(0, .length(L), L, b0);.
+!listBeliefs(recB1) <- .findall(b1(XB,YB),receivedB1(XB,YB),L); .abolish(receivedB1(_,_)); !updateList(0, .length(L), L, b1);.
+!listBeliefs(recGL) <- .findall(gl(XG,YG),receivedGL(XG,YG),L); .abolish(receivedGL(_,_)); !updateList(0, .length(L), L, gl);.
+!listBeliefs(recTB) <- .findall(tb(XTB,YTB),receivedTB(XTB,YTB),L); .abolish(receivedTB(_,_)); !updateList(0, .length(L), L, tb);.

+!updateList(COUNTER,N,LIST,POI): COUNTER < N <- 
	if(POI=b0){?listB0(OldL);}elif(POI=b1){?listB1(OldL);}elif(POI=gl){?listGL(OldL);}elif(POI=tb){?listTB(OldL);}
	.nth(COUNTER,LIST,ELEMENT);
	if(not .member(ELEMENT, OldL)){
		.concat(OldL,[ELEMENT], NewL);
		if(POI=b0){-+listB0(NewL);}elif(POI=b1){-+listB1(NewL);}elif(POI=gl){-+listGL(NewL);}elif(POI=tb){-+listTB(NewL);}
	}
	!updateList(COUNTER+1, N, LIST, POI);
	.
	
+!updateList(COUNTER,N,_,_): COUNTER >=N <- .print("FINISHED UPDATING"); .

/* -----------------------------------COMPARE POIs-----------------------------------
 *							compare saved POIs with received POIs
 * ADD TEAM TEST XXX */
+!comparePOIs(COUNTER,N,recB0): COUNTER <= N-1 & not b0(-1,-1) <-	
	?listB0(L); ?position(AX,AY); ?b0(X,Y);
	.nth(COUNTER,L,b0(XB,YB));
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
	.nth(COUNTER,L,b1(XB,YB));
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
	.nth(COUNTER,L,gl(XG,YG));
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
	.nth(COUNTER,L,tb(XTB,YTB));
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

+!comparePOIs(0,N,recB0): N > 0 & b0(-1,-1) <- ?listB0(L); .nth(0,L,b0(XB,YB)); -+b0(XB,YB); -+searchDisp(false); !doTask; .
+!comparePOIs(0,N,recB1): N > 0 & b1(-1,-1) <- ?listB1(L); .nth(0,L,b1(XB,YB)); -+b1(XB,YB); -+searchDisp(false); !doTask; .
+!comparePOIs(0,N,recGL): N > 0 & gl(-1,-1) <- ?listGL(L); .nth(0,L,gl(XG,YG)); -+gl(XG,YG); -+searchGL(false); !doTask; .
+!comparePOIs(0,N,recTB): N > 0 & tb(-1,-1) <- ?listTB(L); .nth(0,L,tb(XTB,YTB)); -+tb(XTB,YTB); .

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
		if(math.abs(X-OX)>24){	DESIRABLEX = -(X-OX)/DISTANCEX;	}
		else{	DESIRABLEX = (X-OX)/DISTANCEX;	}
    	DESIRABLEY = 0;
	}else {
	    DESIRABLEX = 0;
	    if(math.abs(Y-OY)>24){	DESIRABLEY = -(Y-OY)/DISTANCEY;	}
	    else{	DESIRABLEY = (Y-OY)/DISTANCEY;	}
	}
	?direction(DIRECTION,DESIRABLEX,DESIRABLEY);
	!clearObs(DIRECTION);
  	.

/* -----------------------------------BLOCKED SCENARIOS CHECK OBSTACLE----------------------------------- */
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(0,-1) & numAttBlocks(_) & extraAction(false)	<- -+clearActionParams(n,0,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,0,-2);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(0,1) & numAttBlocks(_) & extraAction(false)	<- -+clearActionParams(s,0,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,0,2);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,0) & numAttBlocks(_) & extraAction(false)	<- -+clearActionParams(e,2,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,2,0);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,0) & numAttBlocks(_) & extraAction(false)	<- -+clearActionParams(w,-2,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-2,0);.

+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(1,1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(s,1,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,1,2);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(s,-1,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,-1,2);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(0,2) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(s,0,3); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,0,3);.

+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(1,-1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(n,1,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,1,-2);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,-1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(n,-1,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,-1,-2);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(0,-2) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(n,0,-3); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,0,-3);.

+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,-1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(e,1,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,1,-2);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(e,1,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,1,2);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(2,0) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(e,3,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,3,0);.

+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,-1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(w,-1,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-1,-2);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,1) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(w,-1,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-1,2);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-2,0) & numAttBlocks(1) & extraAction(false) <- -+clearActionParams(w,-3,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-3,0);.
/*MY BLOCKS ON: (0,1)&(1,1) OR  (0,1)&(-1,1) OR (1,0)&(1,1) OR (-1,0)&(-1,1) OR (0,-1)&(-1,-1) OR (0,-1)&(1,-1)	*/
/*				A				 		A			A#				#A		 		 ##					##		*/
/*				##			    	   ##			 #				#		 		  A					A		*/
/*OBSTs:		(0,2)&(1,2)	    (-1,2)&(0,2)	   (1,2)		  (-1,2)	 		 (-1,0)				(1,0)	*/
/*CLEARS: 		(0,3)&(1,3)		(-1,3)&(0,3)	   (1,3)		  (-1,3)			 (-2,0)				(2,0)	*/
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(1,2) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,1,3); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,1,3);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,2) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,-1,3); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,-1,3);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(0,2) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,0,3); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,0,3);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(0,3) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,0,4); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,0,4);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,0) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,-1,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,-1,1);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(1,0) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,1,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,1,1);.
/*MY BLOCKS ON: (1,0)&(2,0) OR  (-1,0)&(-2,0)	*/
/*				A##						##A		*/
/*OBSTs:		(1,1)&(2,1)		(-2,1)&(-1,1)	*/
/*CLEARS:		(1,2)&(2,2)		(-2,2)&(-1,2)	*/
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(2,1) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,2,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,2,2);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(-2,1) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,-2,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,-2,2);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(1,1) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,1,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,1,2);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,1) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,-1,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,-1,2);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & obstacle(0,1) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(s,0,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,s,0,2);.
/*MY BLOCKS ON: (0,-1)&(1,-1) OR  (0,-1)&(-1,-1) OR (1,0)&(1,-1) OR (-1,0)&(-1,-1) OR (0,1)&(-1,1) OR (0,1)&(1,1)	*/
/*				##			    	 		##			 #				  #		 		  A					A		*/
/*				A				 	  		 A			A#				  #A			 ##					##		*/
/*OBSTs:		(0,-2)&(1,-2)	 (-1,-2)&(0,-2)	   	   (1,-2)		    (-1,-2)	 		 (-1,0)				(1,0)	*/
/*CLEARS:		(0,-3)&(1,-3)	 (-1,-3)&(0,-3)		   (1,-3)			(-1,-3)	 		 (-2,0)				(2,0)	*/
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(1,-2) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,1,-3); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,1,-3);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,-2) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,0,-4); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,0,-4);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(0,-2) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,0,-3); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,0,-3);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(0,-3) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,0,-4); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,0,-4);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,0) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(n,-1,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,-1,-1);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(1,0) & numAttBlocks(2) & extraAction(false) <- -+clearActionParams(n,1,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,1,-1);.
/*MY BLOCKS ON: (1,0)&(2,0) OR  (-1,0)&(-2,0)		*/
/*				A##						##A			*/
/*OBSTs:		(1,-1)&(2,-1)		(-2,-1)&(-1,-1)	*/
/*CLEARS:		(1,-2)&(2,-2)		(-2,-2)&(-1,-2)	*/
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(1,-1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,1,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,1,-2);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,-1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,-1,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,-1,-2);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(2,-1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,2,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,2,-2);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(-2,-1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,-2,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,-2,-2);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & obstacle(0,-1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(n,0,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,n,0,-2);.

/*MY BLOCKS ON: (0,-1)&(1,-1) OR  (0,1)&(1,1) OR (1,0)&(1,-1) OR (-1,0)&(-1,1) OR (-1,0)&(-1,-1) OR (1,0)&(1,1)*/
/*				##			      A			 		   #			   #A				#				A#		*/
/*				A				  ## 				  A#			   #	 			#A				 #		*/
/*OBSTs:		(2,-1)	 		(2,1)	  		  (2,0)&(2,-1)		 (0,1)			  (0,-1)	 	(2,0)&(2,1)	*/
/*CLEARS:		(3,-1)	 		(3,1)	  		  (3,0)&(3,-1)		 (1,1)	 			(1,-1)		(3,0)&(3,1)	*/
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(2,-1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(e,3,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,3,-1);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(2,1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(e,3,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,3,1);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(2,0) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(e,3,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,3,0);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(3,0) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(e,4,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,4,0);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(0,1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(e,1,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,1,1);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(0,-1) & numAttBlocks(2) & extraAction(false)  <- -+clearActionParams(e,1,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,1,-1);.
/*MY BLOCKS ON: (0,1)&(0,2) OR (0,-1)&(0,-2)	*/
/*					A				#			*/
/*					#				#			*/
/*					#				A			*/
/*OBSTs:	(1,1)&(1,2)		  (1,-1)&(1,-2)		*/
/*CLEARS:	(2,1)&(2,2)		  (2,-1)&(2,-2)		*/
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,-1) & numAttBlocks(2) & extraAction(false)  
	<- -+clearActionParams(e,2,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,2,-1);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,-2) & numAttBlocks(2) & extraAction(false)  
	<- -+clearActionParams(e,2,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,2,-2);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,1) & numAttBlocks(2) & extraAction(false)  
	<- -+clearActionParams(e,2,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,2,1);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,2) & numAttBlocks(2) & extraAction(false)  
	<- -+clearActionParams(e,2,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,2,2);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & obstacle(1,0) & numAttBlocks(2) & extraAction(false)  
	<- -+clearActionParams(e,2,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,e,2,0);.
/*MY BLOCKS ON:		(-1,0)&(-1,-1) OR 	(-1,0)&(-1,1) OR 	(0,-1)&(-1,-1) OR (0,1)&(-1,1) OR (1,0)&(1,-1) OR (1,0)&(1,1)	*/
/* 						#					#A					##					A				#			   A#		*/
/* 						#A					#					 A				   ##			   A#				#		*/
/*OBSTs: 			(-2,0)&(-2,-1)		(-2,0)&(-2,1)		  (-2,-1)			(-2,1)			(0,-1)			  (0,1)		*/
/*CLEARS: 			(-3,0)&(-3,-1)		(-3,0)&(-3,1)		  (-3,-1)			(-3,1)			(-1,-1)			  (-1,1)	*/
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-2,-1) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-3,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-3,-1);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-2,1) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-3,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-3,1);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-2,0) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-3,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-3,0);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-3,0) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-4,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-4,0);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(0,-1) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-1,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-1,-1);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(0,1) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-1,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-1,1);.
/*MY BLOCKS ON: (0,1)&(0,2) OR (0,-1)&(0,-2)		*/
/*					A				#				*/
/*					#				#				*/
/*					#				A				*/
/*OBSTs:	(-1,1)&(-1,2)		(-1,-1)&(-1,-2)		*/
/*CLEARS:	(-2,1)&(-2,2)		(-2,-1)&(-2,-2)		*/
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,-1) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-2,-1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-2,-1);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,-2) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-2,-2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-2,-2);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,1) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-2,1); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-2,1);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,2) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-2,2); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-2,2);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & obstacle(-1,0) & numAttBlocks(2) & extraAction(false) 
	<- -+clearActionParams(w,-2,0); -+extraAction(true); -+clearCOUNTER(1); !chooseAction(cl,w,-2,0);.

+!clearObs(D): lastAction(move) & lastActionResult(success) & extraAction(false) & avoidAction(false) <- !chooseAction(mo, D);.

+!clearObs(D): lastAction(move) & lastActionResult(failed_path) & extraAction(false) & avoidAction(true) & moveCOUNTER(1) <- -+moveCOUNTER(2); -+avoidActionDir(D); !chooseAction(mo, D);.
+!clearObs(_): lastAction(move) & lastActionResult(failed_path) & extraAction(false) & avoidAction(true) & moveCOUNTER(2) 
	<- ?avoidActionDir(D); if(D=n){-+avoidActionDir(s); !chooseAction(mo, s);}elif(D=s){-+avoidActionDir(n); !chooseAction(mo, n);}
					elif(D=e){-+avoidActionDir(w); !chooseAction(mo, w);}elif(D=w){-+avoidActionDir(e); !chooseAction(mo, e);}.

+!clearObs(_): lastAction(move) & lastActionResult(success) & extraAction(false) & avoidAction(true) & moveCOUNTER(2) & exActionParams(D) 
	<- -+avoidAction(false); -moveCOUNTER(_); -exActionParams(_); !chooseAction(mo,D);.

+!clearObs(D): lastAction(clear) & lastActionResult(success) & extraAction(false) <- !chooseAction(mo, D);.
+!clearObs(D): lastAction(accept) & lastActionResult(success) & extraAction(false) <- !chooseAction(mo, D);.
+!clearObs(D): lastAction(attach) & lastActionResult(success) & extraAction(false) <- !chooseAction(mo, D);.
+!clearObs(D): lastAction(submit) & lastActionResult(success) & extraAction(false) <- !chooseAction(mo, D);.
+!clearObs(D): lastAction(submit) & (lastActionResult(failed) | lastActionResult(failed_target)) & extraAction(false) <- ?attDIR(DET_DIR); +clearAfterDetach(true); !chooseAction(dtt, DET_DIR); .

+!clearObs(D): clearAfterDetach(true) & lastAction(detach) & lastActionResult(success) & attDIR(DIR) <-	-clearAfterDetach(_); -+extraAction(true); -+clearCOUNTER(1);
	if(DIR = s){-+clearActionParams(s,0,2); !chooseAction(cl,s,0,2);}
	elif(DIR = n){-+clearActionParams(n,0,-2); !chooseAction(cl,n,0,-2);}
	elif(DIR = e){-+clearActionParams(e,2,0); !chooseAction(cl,e,2,0);}
	elif(DIR = w){-+clearActionParams(w,-2,0); !chooseAction(cl,w,-2,0);} .
	
+!clearObs(D): lastAction(no_action) & (lastActionResult(success) | lastActionResult(failed_status)) & extraAction(false) <- !chooseAction(mo, D);.
+!clearObs(D): lastAction(skip) & (lastActionResult(success) | lastActionResult(failed_status)) & extraAction(false) <- !chooseAction(mo, D);.

+!clearObs(_): extraAction(true) & (lastAction(clear) | lastAction(skip)) & (lastActionResult(success) | lastActionResult(failed_resources)) & clearCOUNTER(CC) <- 
	?clearActionParams(D,X,Y);
	if(CC <= 2 & lastActionResult(success)){
		-+clearCOUNTER(CC+1);
		!chooseAction(cl, D, X, Y);
	}elif(CC >2){
		-+extraAction(false); -+clearCOUNTER(1);
		if(avoidAction(true)){
			-+moveCOUNTER(2); -+avoidActionDir(D);
		}
		!chooseAction(mo, D);
	}
	.
	
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & not thing(0,-1,entity,_) & not thing(0,-1,block,_) & extraAction(false) & numAttBlocks(0) <- !chooseAction(mo,n);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & not thing(0,1,entity,_) & not thing(0,1,block,_) & extraAction(false) & numAttBlocks(0) <- !chooseAction(mo,s);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & not thing(1,0,entity,_) & not thing(1,0,block,_) & extraAction(false) & numAttBlocks(0) <- !chooseAction(mo,e);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & not thing(-1,0,entity,_) & not thing(-1,0,block,_) & extraAction(false) & numAttBlocks(0) <- !chooseAction(mo,w);.

+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & not thing(0,-2,entity,_) & not thing(0,-2,block,_) 
	& not thing(1,-1,entity,_) & not thing(1,-1,block,_) & not thing(-1,-1,entity,_) & not thing(-1,-1,block,_)
	& extraAction(false) & numAttBlocks(1) <- !chooseAction(mo,n);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & not thing(0,2,entity,_) & not thing(0,2,block,_) 
	& not thing(1,1,entity,_) & not thing(1,1,block,_) & not thing(-1,1,entity,_) & not thing(-1,1,block,_) 
	& extraAction(false) & numAttBlocks(1) <- !chooseAction(mo,s);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & not thing(2,0,entity,_) & not thing(2,0,block,_) 
	& not thing(1,1,entity,_) & not thing(1,1,block,_) & not thing(1,-1,entity,_) & not thing(1,-1,block,_)
	& extraAction(false) & numAttBlocks(1) <- !chooseAction(mo,e);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & not thing(-2,0,entity,_) & not thing(-2,0,block,_) 
	& not thing(-1,1,entity,_) & not thing(-1,1,block,_) & not thing(-1,-1,entity,_) & not thing(-1,-1,block,_)
	& extraAction(false) & numAttBlocks(1) <- !chooseAction(mo,w);.

+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & not thing(1,0,entity,_) & not thing(1,0,block,_) & not thing(-1,0,entity,_)
	& not thing(-1,0,block,_) & not thing(0,-1,entity,_) & not thing(0,-1,block,_) & extraAction(false) & numAttBlocks(2) <- !chooseAction(mo,n);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & not thing(0,3,entity,_) & not thing(0,3,block,_) & not thing(-1,2,entity,_)
	& not thing(-1,2,block,_) & not thing(0,2,entity,_) & not thing(0,2,block,_) & not thing(1,2,entity,_) & not thing(1,2,block,_) 
	& extraAction(false) & numAttBlocks(2) <- !chooseAction(mo,n);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & not thing(1,0,entity,_) & not thing(1,0,block,_) & not thing(1,1,entity,_)
	& not thing(1,1,block,_) & not thing(1,2,entity,_) & not thing(1,2,block,_) & not thing(2,1,entity,_) & not thing(2,1,block,_) 
	& extraAction(false) & numAttBlocks(2) <- !chooseAction(mo,n);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & not thing(-1,0,entity,_) & not thing(-1,0,block,_) & not thing(-1,1,entity,_)
	& not thing(-1,1,block,_) & not thing(-1,2,entity,_) & not thing(-1,2,block,_) & not thing(-2,1,entity,_) & not thing(-2,1,block,_) 
	& extraAction(false) & numAttBlocks(2) <- !chooseAction(mo,n);.
	
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & (thing(0,-1,entity,_) | thing(0,-1,block,_)) & extraAction(false) & numAttBlocks(_)	
	<- -+avoidAction(true); +exActionParams(n); +moveCOUNTER(1); !clearObs(e);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & (thing(0,1,entity,_) | thing(0,1,block,_)) & extraAction(false) & numAttBlocks(_)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(w);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & (thing(1,0,entity,_) | thing(1,0,block,_)) & extraAction(false) & numAttBlocks(_)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(n);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & (thing(-1,0,entity,_) | thing(-1,0,block,_)) & extraAction(false) & numAttBlocks(_)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(s);.
/*NORTH 1 BLOCK */
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & (thing(0,-2,entity,_) | thing(0,-2,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(n); +moveCOUNTER(1); !clearObs(e);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & (thing(1,-1,entity,_) | thing(1,-1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(n); +moveCOUNTER(1); !clearObs(w);.
+!clearObs(n): lastAction(move) & lastActionResult(failed_path) & (thing(-1,-1,entity,_) | thing(-1,-1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(n); +moveCOUNTER(1); !clearObs(e);.
/*SOUTH 1 BLOCK */
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & (thing(0,2,entity,_) | thing(0,2,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(w);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & (thing(1,1,entity,_) | thing(1,1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(w);.
+!clearObs(s): lastAction(move) & lastActionResult(failed_path) & (thing(-1,1,entity,_) | thing(-1,1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(e);.
/*EAST 1 BLOCK */
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & (thing(2,0,entity,_) | thing(2,0,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(n);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & (thing(1,1,entity,_) | thing(1,1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(n);.
+!clearObs(e): lastAction(move) & lastActionResult(failed_path) & (thing(1,-1,entity,_) | thing(1,-1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(s);.
/*WEST 1 BLOCK */
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & (thing(-2,0,entity,_) | thing(-2,0,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(s);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & (thing(-1,-1,entity,_) | thing(-1,-1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(s);.
+!clearObs(w): lastAction(move) & lastActionResult(failed_path) & (thing(-1,1,entity,_) | thing(-1,1,block,_)) & extraAction(false) & numAttBlocks(1)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(n);.

/*SOUTH 2 BLOCKS */

+!clearObs(s): lastAction(move) & lastActionResutl(failed_path) & (thing(0,2,entity,_) | thing(0,2,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(w);.
+!clearObs(s): lastAction(move) & lastActionResutl(failed_path) & (thing(1,2,entity,_) | thing(1,2,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(w);.
+!clearObs(s): lastAction(move) & lastActionResutl(failed_path) & (thing(-1,2,entity,_) | thing(-1,2,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(w);.
+!clearObs(s): lastAction(move) & lastActionResutl(failed_path) & (thing(0,3,entity,_) | thing(0,3,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(s); +moveCOUNTER(1); !clearObs(w);.
/*NORTH 2 BLOCKS */
+!clearObs(n): lastAction(move) & lastActionResutl(failed_path) & (thing(0,-1,entity,_) | thing(0,-1,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(n); +moveCOUNTER(1); !clearObs(e);.
+!clearObs(n): lastAction(move) & lastActionResutl(failed_path) & (thing(1,0,entity,_) | thing(1,0,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(n); +moveCOUNTER(1); !clearObs(e);.
+!clearObs(n): lastAction(move) & lastActionResutl(failed_path) & (thing(-1,0,entity,_) | thing(-1,0,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(n); +moveCOUNTER(1); !clearObs(e);.
/*EAST 2 BLOCKS */
+!clearObs(e): lastAction(move) & lastActionResutl(failed_path) & (thing(1,0,entity,_) | thing(1,0,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(n);.
+!clearObs(e): lastAction(move) & lastActionResutl(failed_path) & (thing(1,1,entity,_) | thing(1,1,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(n);.
+!clearObs(e): lastAction(move) & lastActionResutl(failed_path) & (thing(1,2,entity,_) | thing(1,2,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(n);.
+!clearObs(e): lastAction(move) & lastActionResutl(failed_path) & (thing(2,1,entity,_) | thing(2,1,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(e); +moveCOUNTER(1); !clearObs(n);.
/*WEST 2 BLOCKS */
+!clearObs(w): lastAction(move) & lastActionResutl(failed_path) & (thing(-1,0,entity,_) | thing(-1,0,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(s);.
+!clearObs(w): lastAction(move) & lastActionResutl(failed_path) & (thing(-1,1,entity,_) | thing(-1,1,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(s);.
+!clearObs(w): lastAction(move) & lastActionResutl(failed_path) & (thing(-1,2,entity,_) | thing(-1,2,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(s);.
+!clearObs(w): lastAction(move) & lastActionResutl(failed_path) & (thing(-2,1,entity,_) | thing(-2,1,block,_)) & extraAction(false) & numAttBlocks(2)
	<- -+avoidAction(true); +exActionParams(w); +moveCOUNTER(1); !clearObs(s);.
	
+!chooseAction(mo, D)	<- /*!correctDirection(D); ?rtCorrDir(CD) move(CD);*/ move(D);.
+!chooseAction(dtt, D) 	<-   detach(D);.
+!chooseAction(cl, D, CX, CY)	<- clear(CX,CY);.

/* -----------------------------------STORE POIs----------------------------------- 
 *							Plans for saving POI positions */
+!storeDispB0: thing(XB,YB,dispenser,b0)	<- ?position(XAg, YAg); -+newX(XAg+XB); -+newY(YAg+YB); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+b0(NX, NY); !broadcastPOI(b0);. 
+!storeDispB1: thing(XB,YB,dispenser,b1)	<- ?position(XAg, YAg); -+newX(XAg+XB); -+newY(YAg+YB); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+b1(NX, NY); !broadcastPOI(b1);.
+!storeTB: thing(XT,YT,taskboard,_)			<- ?position(XAg,YAg); -+newX(XAg+XT); -+newY(YAg+YT); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+tb(NX,NY); !broadcastPOI(tb);.
+!storeGoal: goal(XG,YG)					<- ?position(XAg,YAg); -+newX(XAg+XG); -+newY(YAg+YG); !correctX; !correctY; 
	?newX(NX); ?newY(NY); -+gl(NX,NY); !broadcastPOI(gl);.
+!storeDispB0: not thing(_,_,dispenser,b0)	<- .print("---> No B0 Block Here!");.
+!storeDispB1: not thing(_,_,dispenser,b1)	<- .print("---> No B1 Block Here!");.
+!storeTB: not thing(_,_,taskboard,_)		<- .print("---> No TB Here!");.
+!storeGoal: not goal(_,_)					<- .print("---> No Goal Here!");.


