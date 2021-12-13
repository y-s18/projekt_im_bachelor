// Agent agent in project agentPr

/* Initial beliefs and rules */

//direction("").
//moving(false).

directionIncrement(s, 0,  1).
directionIncrement(n, 0, -1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
myposition(37,30).
searching(true).
movingTowards(false).
lastDirection(nw). 
distcount(1). 
hasTask(false).
b0(0,0).
b1(0,0).

/* Initial goals */


//!start(.random(Number)).

//!start(Number).
//!goto(31,19).

/* Plans */
/* every move is a step (Test) 2 left 1 down */
//+step(0)<- !spiral.
//+step(3)<- !spiral.
//+step(6)<- !spiral.

/* start moving to a given position */
+step(X): searching(true) <- !spiral; .
+step(X): movingTowards(true) <- !goto(31,19).




//+!start <- if(lastAction(move) & lastActionResult(success)) {!spiral;}.

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
      move(DIRECTION);
      -+myposition(OX+DESIRABLEX, OY+DESIRABLEY);
      !goto(X,Y);
      .
/* first try for spiral movement */
//+!spiral: searching(true)<- 
//	-+searching(false);
//	?myposition(X,Y);
//	if(not thing(_,_,taskboard,_)){
//		!goto(X-1,Y-1);	
////		!spiral;
//	}
//	if(thing(_,_,taskboard,_)){
////		-+searching(false);
//		?thing(XT,YT,taskboard,_);
//		?myposition(XA,YA);
//		!goto(XA+XT,YA+YT);
//	}
//	-+searching(true);
////	!goto(X-2,Y+1);
////	-+searching(true);
////	!spiral;
//	.

+!spiral: searching(true) <- 
    -+searching(false);
    ?myposition(X,Y);
	if(not thing(_,_,taskboard,_)){
		?lastDirection(Dir);
		?distcount(Dist);
		if (Dir = nw){
    		!goto(X+3*Dist,Y-3*Dist);
    		-+lastDirection(ne);
		}
 		if (Dir = ne){
			-+distcount(Dist+1);
    		!goto(X+3*Dist,Y+3*Dist);
    		-+lastDirection(se);
		}
		if (Dir = se){
    		!goto(X-3*Dist,Y+3*Dist);
    		-+lastDirection(sw);
		}
		if (Dir = sw){
    		-+distcount(Dist+1);
    		!goto(X-3*Dist,Y-3*Dist);
    		-+lastDirection(nw);
 		}
//		!spiral;
	}
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
	
	if(thing(_,_,taskboard,_)){
//			-+searching(false);
		?thing(XT,YT,taskboard,_);
		?myposition(XA,YA);
		!goto(XA+XT,YA+YT);
		if(task(T,_,_,_) & hasTask(false) & myposition(XA+XT,YA+YT)){
			
			-+hasTask(true);
			accept(T);
			
			
		}
		
	}
    -+searching(true);
    .

//+step(0)<- move(w).
//+step(X): moving(false) <- !start.
//+step(5): true <- move(s).

/* first try to get the agent to stop when he percieves a taskboard */
//+actionID(X): true <- !start.

//+!start: moving(false) <- if(thing(_,_,taskboard,_)){accept(task0); if(lastAction(accept) & lastActionResult(success)){-+moving(true);}} move(n).
//
//+accepted(_): moving(true) <- move(s).
//?req(_,_,X); if(thing(_,_,dispenser,X)){
//	move(w);
//}.

//
///* random movement and the agent stops when he finds a taskboard. (still to be optimised) */

//+actionID(X): true <- .print("Determining my action", X); .random(Number); !start(Number).
//+!start(Y): moving(false) & Y <= 0.25 <- -+direction("n"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.
//
//+!start(Y): moving(false) & Y <= 0.50 & Y > 0.25  <- -+direction("s"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.
//
//+!start(Y): moving(false) & Y <= 0.75 & Y > 0.50 <- -+direction("w"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.
//
//+!start(Y): moving(false) & Y <= 1.00 & Y > 0.75 <- -+direction("e"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.




////+step(X) : true <-
////        .print("Received step percept.").
     













