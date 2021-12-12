// Agent agent in project agentPr

/* Initial beliefs and rules */

direction("").
moving(false).


/* Initial goals */

//!start(.random(Number)).

//!start(Number).


/* Plans */
//+step(0)<- move(w).
+step(X): moving(false) <- !start.
//+step(5): true <- move(s).

/* first try to get the agent to stop when he percieves a taskboard */
//+actionID(X): true <- !start.

+!start: moving(false) <- if(thing(_,_,taskboard,_)){accept(task0); if(lastAction(accept) & lastActionResult(success)){-+moving(true);}} move(n).

+accepted(_): moving(true) <- move(s).
//?req(_,_,X); if(thing(_,_,dispenser,X)){
//	move(w);
//}.

//
///* random movement and the agent stops when he finds a taskboard. (still to be optimised) */
//+actionID(X): true <- .print("Determining my action", X); .random(Number); !start(Number).
//
//+!start(Y): moving(false) & Y <= 0.25 <- -+direction("n"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.
//
//+!start(Y): moving(false) & Y <= 0.50 & Y > 0.25  <- -+direction("s"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.
//
//+!start(Y): moving(false) & Y <= 0.75 & Y > 0.50 <- -+direction("w"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.
//
//+!start(Y): moving(false) & Y <= 1.00 & Y > 0.75 <- -+direction("e"); ?direction(D); move(D); if(thing(_, _, taskboard, _)){-+moving(true);}.




////+step(X) : true <-
////        .print("Received step percept.").
     













