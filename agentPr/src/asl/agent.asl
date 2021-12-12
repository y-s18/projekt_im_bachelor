// Agent agent in project agentPr

/* Initial beliefs and rules */

//direction("").
//moving(false).

directionIncrement(s, 0,  1).
directionIncrement(n, 0, -1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
myposition(37,30).

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
+step(X): true <- !goto(31,19).

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
+!spiral<- 
	?myposition(X,Y);
	!goto(X-2,Y+1);
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
     













