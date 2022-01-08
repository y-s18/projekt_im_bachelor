/* Initial beliefs and rules */

moving(false).
searching(true).
distCount(1).
direction(s, 0,  1).
direction(n, 0, -1).
direction(w,-1,  0).
direction(e, 1,  0).
reqDir("").
nextDir(ne).
//changeDir(false).
spiStep(4).
desXY(0,0).
b0(-1,-1).
b1(-1,-1).
gl(-1,-1).
tb(-1,-1).
searchGL(false).
searchDisp(false).
moveGL(false).
moveDisp(false).
accepting(false).
newX(0).
newY(0).

/* Plans */

/*calculate & update the destination coordinates[desXY(x,y)]  */
+!calcDesXY(D) <- 
	?spiStep(S);
//	?position(X,Y);
	?distCount(Dist);
	if(Dist>8){-+distCount(0);}
	
	!calcXY(D,S);
//	?newX(NX); ?newY(NY);
	!correctX; !correctY;
	?newX(NX); ?newY(NY);
	-+desXY(NX,NY);
//	if(D=ne){
//		NewX = X+S*Dist;
//		NewY = Y-S*Dist;
//		-+distCount(Dist+1);
//	}elif(D=se){
//		NewX = X+S*Dist;
//		NewY = Y+S*Dist;
//	}elif(D=sw){
//		NewX = X-S*Dist;
//		NewY = Y+S*Dist;
//		-+distCount(Dist+1);
//	}elif(D=nw){
//		NewX = X-S*Dist;
//		NewY = Y-S*Dist;
//	}

//	if(NewX <= 49 & NewX >= 0 & NewY <= 49 & NewY >= 0){NewX1 = NewX;NewY1 = NewY;}
//	elif(NewX <= 49 & NewX >=0){NewX1 = NewX;}
//	elif(NewY <= 49 & NewY >=0){NewY1 = NewY;}
//	
//	if(NewX > 49){NewX1 = NewX-50;}
//  	elif(NewX < 0){NewX1 = NewX+50;}
//  	
//  	if(NewY > 49){NewY1 = NewY-50;}
//  	elif(NewY < 0){NewY1 = NewY+50;}
//	-+desXY(NewX1,NewY1);
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

/*trigger the spiral movement when not having a task to do*/
+step(X): moving(false) & searching(true) & not accepted(_)
	<- 
	?nextDir(D);
	!calcDesXY(D);
	-+moving(true); 
	skip;
  	.
//+step(X): moving(false) & searching(true) & accepting(false) & not accepted(_) <- ?nextDir(D); !calcDesXY(D); -+moving(true); .

/*spiral movement looking for a taskboard, if no task is accepted */
+step(X): moving(true) & not thing(_,_,taskboard,_) & not accepted(_) 
	<- 
	?desXY(DX,DY);
	if(thing(_,_,dispenser,b0)){!storeDispB0;}
	if(thing(_,_,dispenser,b1)){!storeDispB1;}
	if(goal(_,_)){!storeGoal;}
	!goto(DX,DY);
	skip;
	.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & accepting(false) & not accepted(_) <- 
//	if(thing(_,_,dispenser,b0)){!storeDispB0;}
//	if(thing(_,_,dispenser,b1)){!storeDispB1;}
//	if(goal(_,_)){!storeGoal;}
//	?desXY(DX,DY);
//	!goto(DX,DY);
//	.

//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & not b0(-1,-1) & not b0(-1,-1) & not gl(-1,-1) & accepting(false) <- ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & not thing(_,_,dispenser,_) & not goal(_,_) & accepting(false) <- ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & thing(_,_,dispenser,b0) & b0(-1,-1) & accepting(false) <- !storeDispB0; ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & thing(_,_,dispenser,b1) & b1(-1,-1) & accepting(false) <- !storeDispB1; ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & not thing(_,_,taskboard,_) & goal(_,_) & gl(-1,-1) & accepting(false) <- !storeGoal; ?desXY(DX,DY); !goto(DX,DY);.
//+step(X): moving(true) & searching(true) & thing(TX,TY,taskboard,_) & accepting(false) <- ?position(AX,AY); -+desXY(AX+TX,AY+TY); !goto(AX+TX,AY+TY); !storeTB;.



/*moving towards a TB, if the Agent does not have an accepted task & accept one*/
+step(X): moving(true) & thing(TX,TY,taskboard,_) & not accepted(_)
	<- 
	?position(AX,AY);
	!goto(AX+TX,AY+TY);
	!storeTB;
	!acceptTask;
	if(thing(_,_,dispenser,b0)){!storeDispB0;}
	if(thing(_,_,dispenser,b1)){!storeDispB1;}
	if(goal(_,_)){!storeGoal;}
	skip;
	.
//+step(X): moving(true) & searching(true) & thing(TX,TY,taskboard,_) & accepting(false) & not accepted(_) <- -+searching(false); -+accepting(true); ?position(AX,AY); -+desXY(AX+TX,AY+TY); !goto(AX+TX,AY+TY); .
//+step(X): desXY(DX,DY) & moving(true) & searching(false) & accepting(true) & not positon(DX,DY) & not accepted(_) <- ?desXY(TBX,TBY) !goto(TBX,TBY); .
//+step(X): desXY(DX,DY) & moving(false) & searching(false) & accepting(true) & positon(DX,DY) & not accepted(_) <- !storeTB; -+accepting(false); !acceptTask; .

/*start doing a task after accepting a Task */
+step(X): doingTask(false) & accepted(T) <-
	-+searching(false);
	!doTask;
	-+doingTask(true);
	skip;
	.
	
/*steps for finding Goal. */
+step(X): moveGL(false) & searchGL(true) <-
	?nextDir(D);
	!calcDesXY(D);
	-+moveGL(true);
	skip;
	.
/*search for a goal*/
//+step(X): moveGL(true) & searchGL(true) <-
//	?desXY(DX,DY);
//	!goto(DX,DY);
//	if(thing(_,_,dispenser,b0)){!storeDispB0;}
//	if(thing(_,_,dispenser,b1)){!storeDispB1;}
//	if(goal(_,_)){!storeGoal;}
//	//every step check if a goal is found
//	?gl(XG,YG);
//	if(XG >-1 & YG >-1){-+searchGL(false); -+moveGL(false); !doTask;}
//	.
+step(X): moveGL(true) & searchGL(true) & not goal(_,_) & not thing(_,_,dispenser,_) <- ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveGL(true) & searchGL(true) & not goal(_,_) & thing(_,_,dispenser,b0) <- !storeDispB0; ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveGL(true) & searchGL(true) & not goal(_,_) & thing(_,_,dispenser,b1) <- !storeDispB1; ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveGL(true) & searchGL(true) & goal(XG,YG) <- !storeGoal; -+searchGL(false); -+moveGL(false); !doTask; skip;.
//+step(X): moveGL(true) & searchGL(true) & (goal(XG,YG) | not goal(_,_)) & thing(_,_,dispenser,b0)<- !storeDispB0;.
/*steps for finding Dispensers. */
+step(X): moveDisp(false) & searchDisp(true) <-
	?nextDir(D);
	!calcDesXY(D);
	-+moveDisp(true);
	skip;
	.
/*search for a Dispenser*/
//+step(X): moveDisp(true) & searchDisp(true) <-
//	?desXY(DX,DY);
//	!goto(DX,DY);
//	/*PROBLEM: no applicable plan ==> rest of the code would not be executed(Bsp: tausche B0 & B1)*/
//	if(thing(_,_,dispenser,b0)){!storeDispB0;}
//	if(thing(_,_,dispenser,b1)){!storeDispB1;}
//	//every step check if a Disp is found
//	?searchFor(Disp);
//	if(Disp = b0){?b0(XB,YB); if(XB>-1 & YB>-1){-+searchDisp(false); -+moveDisp(false); !doTask;}}
//	elif(Disp = b1){?b1(XB,YB); if(XB>-1 & YB>-1){-+searchDisp(false); -+moveDisp(false); !doTask;}}
//	.
+step(X): moveDisp(true) & searchDisp(true) & not thing(_,_,dispenser,b0) & searchFor(b0) & b0(-1,-1) <- ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveDisp(true) & searchDisp(true) & not thing(_,_,dispenser,b1) & searchFor(b1) & b1(-1,-1) <- ?desXY(DX,DY); !goto(DX,DY); skip;.
+step(X): moveDisp(true) & searchDisp(true) & thing(_,_,dispenser,b0) & searchFor(b0) <- !storeDispB0; -+searchDisp(false); -+moveDisp(false); !doTask; skip;.
+step(X): moveDisp(true) & searchDisp(true) & thing(_,_,dispenser,b1) & searchFor(b1) <- !storeDispB1; -+searchDisp(false); -+moveDisp(false); !doTask; skip;.
/*plan for doing task scenarios */
//+!doTask: accepted(T) <- 
//	?task(T,_,_,[req(ASX,ASY,Disp)]);
//	?gl(XG,YG);
//	if(XG=-1&YG=-1){-+searchGL(true);}
//	/*PROBLEM: can trigger two steps at the same time if no goal & no disp is saved*/
//	/*PROBLEM: !goto(x,y) only moves one block. Possible Sol: +updateBel <- -+moving(false); -+searching(false); ...tbd.  to trigger the move step where goto is repeated.*/
//	if(Disp = b0){?b0(XB,YB) if(XB=-1& YB=-1){-+searchDisp(true); +searchFor(b0)}else{-+desXY(XB-ASX,YB-ASY); +requesting(true);   /*!goto(XB,YB-1);request(s);attach(s);!goto(XG,YG);submit(T);*/}}
//	elif(Disp = b1){?b1(XB,YB) if(XB=-1& YB=-1){-+searchDisp(true); +searchFor(b1)}else{-+desXY(XB-ASX,YB-ASY); +requesting(true); /*!goto(XB,YB-1);request(s);attach(s);!goto(XG,YG);submit(T);*/}}
//	.
+!doTask: accepted(T) & gl(-1,-1) <- -+searchGL(true); .
+!doTask: accepted(T) & b0(-1,-1) & searchGL(false) <- -+searchDisp(true); +searchFor(b0); .
+!doTask: accepted(T) & not b0(-1,-1) & task(T,_,_,[req(ASX,ASY,b0)]) <- ?b0(XB,YB); ?direction(DIR,ASX,ASY); -+reqDir(DIR); -+desXY(XB-ASX,YB-ASY); +requesting(true); .
+!doTask: accepted(T) & b1(-1,-1) & searchGL(false) <- -+searchDisp(true); +searchFor(b1); .
+!doTask: accepted(T) & not b1(-1,-1) & task(T,_,_,[req(ASX,ASY,b1)]) <- ?b1(XB,YB); ?direction(DIR,ASX,ASY); -+reqDir(DIR); -+desXY(XB-ASX,YB-ASY); +requesting(true); .

/*move towards a Dispenser & request  */
+step(X): desXY(DX,DY) & requesting(true) & not position(DX,DY) <- !goto(DX,DY); skip;.
+step(X): desXY(DX,DY) & requesting(true) & position(DX,DY)<- -+requesting(false); +attaching(true); ?reqDir(D); request(D); .
/*step for executing the attach action */
+step(X): attaching(true) <- -+attaching(false); +submitting(true); ?reqDir(D); attach(D);.
/*move towards the saved goal area & submit the already accepted task */
+step(X): gl(XG,YG) & submitting(true) & accepted(T) & not position(XG,YG) <- !goto(XG,YG); skip;.
+step(X): gl(XG,YG) & submitting(true) & accepted(T) & position(XG,YG) <- -+submitting(false); -+doingTask(false); submit(T); .

/*accepting task, if the Agent is on a TB */
+!acceptTask: thing(0,0,taskboard,_) <- ?task(T,_,_,_); +doingTask(false); accept(T); .

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
    
+!goto(X,Y): not position(X,Y)	
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
	    if(math.abs(X-OX)>24){
	    	DESIRABLEY = -(Y-OY)/DISTANCEY;
	    }
	    DESIRABLEY = (Y-OY)/DISTANCEY;
	}
	?direction(DIRECTION,DESIRABLEX,DESIRABLEY);
  	move(DIRECTION);
  	.
  
//[source(percept)]
/*plans for saving POI positions */
+!storeDispB0: thing(XB,YB,dispenser,b0) <- ?position(XAg, YAg); -+b0(XAg+XB, YAg+YB);.
+!storeDispB1: thing(XB,YB,dispenser,b1) <- ?position(XAg, YAg); -+b1(XAg+XB, YAg+YB);.
+!storeTB: thing(XT,YT,taskboard,_) <- ?position(XAg,YAg); -+tb(XAg+XT,YAg+YT);.
+!storeGoal: goal(XG,YG) <- ?position(XAg,YAg); -+gl(XAg+XG,YAg+YG);.


