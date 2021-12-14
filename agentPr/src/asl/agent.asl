// Agent agent in project agentPr

/* Initial beliefs and rules */

directionIncrement(s, 0,  1).
directionIncrement(n, 0, -1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
myposition(3,13).
searching(true).
//movingTowards(false).
lastDirection(nw). 
distcount(1). 
hasTask(false).
b0(0,0).
b1(0,0).
foundTB(false).


/* Initial goals */


/* Plans */


/* start moving to a given position */
+step(X): searching(true) <- !spiral; .
//+step(X): movingTowards(true) <- !goto(31,19).


+!findTB <- 
	if(thing(_,_,taskboard,_)){
//			-+searching(false);
		-+foundTB(true);
		?thing(XT,YT,taskboard,_);
		?myposition(XA,YA);
		!goto(XA+XT,YA+YT);
//		if(task(T,_,_,_) & hasTask(false) & myposition(XA+XT,YA+YT)){
//			
//			-+hasTask(true);
//			accept(T);
//		}
		
	}.
	
+!acceptTask: hasTask(false) &  task(T,_,_,_) <- -+hasTask(true); accept(T).

/* checks if arrived */
+!goto(X,Y):
    myposition(X,Y)
    <- .print("-------> " ,arrived_at(X,Y)).
    
/* agent moves to a given position and stops */
+!goto(X,Y):
    not myposition(X,Y)
    <- 
      ?myposition(OX,OY);
      DISTANCEX=math.abs(X-OX);
      DISTANCEY=math.abs(Y-OY);

      if (DISTANCEX>DISTANCEY) {
        DESIRABLEX = (X-OX)/DISTANCEX;
        DESIRABLEY = 0;
      }
      else {
        DESIRABLEX = 0;
        DESIRABLEY = (Y-OY)/DISTANCEY;
      }
      ?directionIncrement(DIRECTION,DESIRABLEX,DESIRABLEY);
      if(hasTask(false) & thing(_,_,taskboard,_) & foundTB(false)){!findTB; drop_event(goto(X,Y)); -+searching(true);}
      move(DIRECTION);
      if(lastAction(move) & lastActionResult(success)){
      	
      	NewX = OX+DESIRABLEX;
      	NewY = OY+DESIRABLEY;
      	
			if(NewX > 49){NewX = NewX-50;}
		  	elif(NewX < 0){NewX = NewX+50;}
		  	if(NewY > 49){NewY = NewY-50;}
		  	elif(NewY < 0){NewY = NewY+50;}
		  	
      	-+myposition(NewX,NewY);
      	    	
      }
      !goto(X,Y);
      .

+!spiral: searching(true) <- 
    -+searching(false);
    ?myposition(X,Y);
    SpStep = 1;
	if(foundTB(false)){
		?lastDirection(Dir);
		?distcount(Dist);
		if (Dir = nw){
			NewX = X+SpStep*Dist;
			NewY = Y-SpStep*Dist;
			
			if(NewX > 49){NewX = NewX-50;}
		  	elif(NewX < 0){NewX = NewX+50;}
		  	if(NewY > 49){NewY = NewY-50;}
		  	elif(NewY < 0){NewY = NewY+50;}
		  	
		  	!goto(NewX,NewY);
			

    		-+lastDirection(ne);
    		-+distcount(Dist+1);
		}
 		if (Dir = ne){
 			NewX = X+SpStep*Dist;
			NewY = Y+SpStep*Dist;
			
			if(NewX > 49){NewX = NewX-50;}
		  	elif(NewX < 0){NewX = NewX+50;}
		  	if(NewY > 49){NewY = NewY-50;}
		  	elif(NewY < 0){NewY = NewY+50;}
		  	
		  	!goto(NewX,NewY);
    		-+lastDirection(se);
		}
		if (Dir = se){
			NewX = X-SpStep*Dist;
			NewY = Y+SpStep*Dist;
			
			if(NewX > 49){NewX = NewX-50;}
		  	elif(NewX < 0){NewX = NewX+50;}
		  	if(NewY > 49){NewY = NewY-50;}
		  	elif(NewY < 0){NewY = NewY+50;}
		  	
		  	!goto(NewX,NewY);
    		-+lastDirection(sw);
    		-+distcount(Dist+1);
		}
		if (Dir = sw){
			NewX = X-SpStep*Dist;
			NewY = Y-SpStep*Dist;
			
			if(NewX > 49){NewX = NewX-50;}
		  	elif(NewX < 0){NewX = NewX+50;}
		  	if(NewY > 49){NewY = NewY-50;}
		  	elif(NewY < 0){NewY = NewY+50;}
		  	
		  	!goto(NewX,NewY);
    		-+lastDirection(nw);
 		}

	}
	
/*adds to belief where b0 and b1 are located */	
//	if(thing(XB,YB,dispenser,b0)){
//		//?thing(XB,YB,dispenser,b0);
//		?myposition(XAg, YAg);
//		-+b0(XAg+XB, YAg+YB);
//	}
//	
//	if(thing(XB1,YB1,dispenser,b1)){
//		//?thing(XB,YB,dispenser,b0);
//		?myposition(XAg, YAg);
//		-+b1(XAg+XB1, YAg+YB1);
//	}
	
	else{!acceptTask;}
    -+searching(true);
    .




     













