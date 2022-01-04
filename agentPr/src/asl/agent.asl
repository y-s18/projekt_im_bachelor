

/* Initial beliefs and rules */

/* Initial goals */

//myPos(0,0).
isMoving(false).
isSearching(true).
distCount(1).
directionIncrement(s, 0,  1).
directionIncrement(n, 0, -1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
nextDir(ne).
changeDir(false).
desXY(0,0).
spiStep(3).

/* Plans */

+!calcDesXY(D) <- ?spiStep(S);
	?position(X,Y);
	?distCount(Dist);
	if(D=ne){
		NewX = X+S*Dist;
		NewY = Y-S*Dist;
		-+distCount(Dist+1);
	}elif(D=se){
		NewX = X+S*Dist;
		NewY = Y+S*Dist;
	}elif(D=sw){
		NewX = X-S*Dist;
		NewY = Y+S*Dist;
		-+distCount(Dist+1);
	}elif(D=nw){
		NewX = X-S*Dist;
		NewY = Y-S*Dist;
	}
	if(NewX <= 49 & NewX >= 0 & NewY <= 49 & NewY >= 0){NewX1 = NewX;NewY1 = NewY;}
	elif(NewX <= 49 & NewX >=0){NewX1 = NewX;}
	elif(NewY <= 49 & NewY >=0){NewY1 = NewY;}
	
	if(NewX > 49){NewX1 = NewX-50;}
  	elif(NewX < 0){NewX1 = NewX+50;}
  	
  	if(NewY > 49){NewY1 = NewY-50;}
  	elif(NewY < 0){NewY1 = NewY+50;}
	-+desXY(NewX1,NewY1);
	-+isMoving(true); 
	.

+step(X): isMoving(false) & isSearching(true)
	<- 
	?nextDir(D);
	!calcDesXY(D);
  	.
  	
  	
+step(X): isMoving(true) & thing(TX,TY,taskboard,_) 
	<- 
//	?desXY(DX,DY);
	?position(AX,AY);
	!goto(AX+TX,AY+TY);
	!acceptTask;
	.

	
+step(X): isMoving(true) & not thing(_,_,taskboard,_) 
	<- 
	?desXY(DX,DY);
	!goto(DX,DY);
	.


+!acceptTask: thing(0,0,taskboard,_) <- ?task(T,_,_,_); accept(T); .

//+!changeDirection(X,Y): myPos(X,Y) <- -+changeDir(true).


+!goto(X,Y): position(X,Y) & changeDir(true)
    <- .print("-------> " ,arrived_at(X,Y));
    
    if(nextDir(ne)){-+nextDir(se);}
    elif(nextDir(se)){-+nextDir(sw);}
    elif(nextDir(sw)){-+nextDir(nw);}
    elif(nextDir(nw)){-+nextDir(ne);}
    -+isMoving(false);
    -+changeDir(false);
    .
    
+!goto(X,Y): not position(X,Y)	
	<- 
	?position(OX,OY);
	DISTANCEX=math.abs(X-OX);
	DISTANCEY=math.abs(Y-OY);

	if (DISTANCEX>=DISTANCEY) {
		if((X<13 & OX>35) | (X>35 & OX<12)){
			DESIRABLEX = -(X-OX)/DISTANCEX;
		}else{
			DESIRABLEX = (X-OX)/DISTANCEX;
		}
    	DESIRABLEY = 0;
	}else {
	    DESIRABLEX = 0;
	    if((Y<13 & OY>35) | (Y>35 & OY<12)){
	    	DESIRABLEY = -(Y-OY)/DISTANCEY;
	    }
	    DESIRABLEY = (Y-OY)/DISTANCEY;
	}
	?directionIncrement(DIRECTION,DESIRABLEX,DESIRABLEY);
	
  	move(DIRECTION);
  	.wait(500);
	if(position(X,Y)){-+changeDir(true);}
//  		move(DIRECTION);
//	if(lastAction(move) & lastActionResult(success)){	
//	  	}
	  	
//	  		if(thing(XB,YB,dispenser,b0)){
//				?myPos(XAg, YAg);
//				-+b0(XAg+XB, YAg+YB);
//			}
//			if(thing(XB1,YB1,dispenser,b1)){
//				?myPos(XAg, YAg);
//				-+b1(XAg+XB1, YAg+YB1);
//			}
//			if(goal(XG,YG)){
//				?myPos(XAg,YAg);
//				-+g(XAg+XG,YAg+YG);
//			}
//		!goto(X,Y);
//      	}
  	
  	.