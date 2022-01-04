

/* Initial beliefs and rules */

/* Initial goals */

myPos(0,0).
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
spiStep(1).

/* Plans */

+step(0)<- ?position(X,Y); -+myPos(X,Y);.

+!calcDesXY(D) <- ?spiStep(S);
	?myPos(Xne,Yne);
	?distCount(Distne);
	if(D=ne){
		NewXne = Xne+S*Distne;
		NewYne = Yne-S*Distne;
		-+distCount(Distne+1);
	}elif(D=se){
		NewXne = Xne+S*Distne;
		NewYne = Yne+S*Distne;
	}elif(D=sw){
		NewXne = Xne-S*Distne;
		NewYne = Yne+S*Distne;
		-+distCount(Distne+1);
	}elif(D=nw){
		NewXne = Xne-S*Distne;
		NewYne = Yne-S*Distne;
	}
	if(NewXne <= 49 & NewXne >= 0 & NewYne <= 49 & NewYne >= 0){NewXne1 = NewXne;NewYne1 = NewYne;}
	elif(NewXne <= 49 & NewXne >=0){NewXne1 = NewXne;}
	elif(NewYne <= 49 & NewYne >=0){NewYne1 = NewYne;}
	
	if(NewXne > 49){NewXne1 = NewXne-50;}
  	elif(NewXne < 0){NewXne1 = NewXne+50;}
  	
  	if(NewYne > 49){NewYne1 = NewYne-50;}
  	elif(NewYne < 0){NewYne1 = NewYne+50;}
	-+desXY(NewXne1,NewYne1);
	-+isMoving(true); 
	.

+step(X): isMoving(false) & isSearching(true)
	<- 
//	SpStep = 2;
	?nextDir(D);
	!calcDesXY(D);
//	?spiStep(S);
//	?myPos(Xne,Yne);
////	?lastDirection(Dir);
//	?distCount(Distne);
//	NewXne = Xne+S*Distne;
//	NewYne = Yne-S*Distne;
//	
//	if(NewXne <= 49 & NewXne >= 0 & NewYne <= 49 & NewYne >= 0){NewXne1 = NewXne;NewYne1 = NewYne;}
//	elif(NewXne <= 49 & NewXne >=0){NewXne1 = NewXne;}
//	elif(NewYne <= 49 & NewYne >=0){NewYne1 = NewYne;}
//	
//	if(NewXne > 49){NewXne1 = NewXne-50;}
//  	elif(NewXne < 0){NewXne1 = NewXne+50;}
//  	
//  	if(NewYne > 49){NewYne1 = NewYne-50;}
//  	elif(NewYne < 0){NewYne1 = NewYne+50;}
//
////  	!goto(NewXne1,NewYne1);
//	-+desXY(NewXne1,NewYne1);
////  	if(myPos(NewXne1, NewYne1)){-+changeDir(true)}
////  	!goto; 
//	-+distCount(Distne+1);
//  	-+isMoving(true); 
  	.
  	
//+step(X): isMoving(false) & nextDir(se) & isSearching(true)
//	<- 
////	SpStep = 2;
//	?spiStep(S);
//	?myPos(Xne,Yne);
////	?lastDirection(Dir);
//	?distCount(Distne);
//	NewXne = Xne+S*Distne;
//	NewYne = Yne+S*Distne;
//	
//	if(NewXne <= 49 & NewXne >= 0 & NewYne <= 49 & NewYne >= 0){NewXne1 = NewXne;NewYne1 = NewYne;}
//	elif(NewXne <= 49 & NewXne >=0){NewXne1 = NewXne;}
//	elif(NewYne <= 49 & NewYne >=0){NewYne1 = NewYne;}
//	
//	if(NewXne > 49){NewXne1 = NewXne-50;}
//  	elif(NewXne < 0){NewXne1 = NewXne+50;}
//  	
//  	if(NewYne > 49){NewYne1 = NewYne-50;}
//  	elif(NewYne < 0){NewYne1 = NewYne+50;}
//
////  	!goto(NewXne1,NewYne1);
//  	-+desXY(NewXne1,NewYne1);
////  	if(myPos(NewXne1, NewYne1)){-+changeDir(true)}
////  	!goto; 
//  	-+isMoving(true); 
//  	.
  	
//+step(X): isMoving(false) & nextDir(sw) & isSearching(true)
//	<- 
////	SpStep = 2;
//	?spiStep(S);
//	?myPos(Xne,Yne);
////	?lastDirection(Dir);
//	?distCount(Distne);
//	NewXne = Xne-S*Distne;
//	NewYne = Yne+S*Distne;
//	
//	if(NewXne <= 49 & NewXne >= 0 & NewYne <= 49 & NewYne >= 0){NewXne1 = NewXne;NewYne1 = NewYne;}
//	elif(NewXne <= 49 & NewXne >=0){NewXne1 = NewXne;}
//	elif(NewYne <= 49 & NewYne >=0){NewYne1 = NewYne;}
//	
//	if(NewXne > 49){NewXne1 = NewXne-50;}
//  	elif(NewXne < 0){NewXne1 = NewXne+50;}
//  	
//  	if(NewYne > 49){NewYne1 = NewYne-50;}
//  	elif(NewYne < 0){NewYne1 = NewYne+50;}
//
////  	!goto(NewXne1,NewYne1);
//	-+desXY(NewXne1,NewYne1);
////  	if(myPos(NewXne1, NewYne1)){-+changeDir(true)}
////  	!goto; 
//	-+distCount(Distne+1);
//  	-+isMoving(true); 
//  	.
  	
//+step(X): isMoving(false) & nextDir(nw) & isSearching(true)
//	<- 
////	SpStep = 2;
//	?spiStep(S);
//	?myPos(Xne,Yne);
////	?lastDirection(Dir);
//	?distCount(Distne);
//	NewXne = Xne-S*Distne;
//	NewYne = Yne-S*Distne;
//	
//	if(NewXne <= 49 & NewXne >= 0 & NewYne <= 49 & NewYne >= 0){NewXne1 = NewXne;NewYne1 = NewYne;}
//	elif(NewXne <= 49 & NewXne >=0){NewXne1 = NewXne;}
//	elif(NewYne <= 49 & NewYne >=0){NewYne1 = NewYne;}
//	
//	if(NewXne > 49){NewXne1 = NewXne-50;}
//  	elif(NewXne < 0){NewXne1 = NewXne+50;}
//  	
//  	if(NewYne > 49){NewYne1 = NewYne-50;}
//  	elif(NewYne < 0){NewYne1 = NewYne+50;}
//
////  	!goto(NewXne1,NewYne1);
//	-+desXY(NewXne1,NewYne1);
////	!changeDirection(NewXne1,NewYne1);
////  	if(myPos(NewXne1, NewYne1)){-+changeDir(true)}
////  	!goto; 
//  	-+isMoving(true); 
//  	.
  	
+step(X): isMoving(true) & thing(TX,TY,taskboard,_) 
	<- 
//	?desXY(DX,DY);
	?myPos(AX,AY);
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


+!goto(X,Y): myPos(X,Y) & changeDir(true)
    <- .print("-------> " ,arrived_at(X,Y));
    
    if(nextDir(ne)){-+nextDir(se);}
    elif(nextDir(se)){-+nextDir(sw);}
    elif(nextDir(sw)){-+nextDir(nw);}
    elif(nextDir(nw)){-+nextDir(ne);}
    -+isMoving(false);
    -+changeDir(false);
    .
    
+!goto(X,Y): not myPos(X,Y)	
	<- 
	?myPos(OX,OY);
	DISTANCEX=math.abs(X-OX);
	DISTANCEY=math.abs(Y-OY);

	if (DISTANCEX>=DISTANCEY) {
    	DESIRABLEX = (X-OX)/DISTANCEX;
    	DESIRABLEY = 0;
	}else {
	    DESIRABLEX = 0;
	    DESIRABLEY = (Y-OY)/DISTANCEY;
	}
	?directionIncrement(DIRECTION,DESIRABLEX,DESIRABLEY);
//      if(hasTask(false) & thing(_,_,taskboard,_) & foundTB(false)){!findTB;}

//      	if(not thing(0,0,taskboard,_) & hasTask(false)){
	
//	.wait(350);
//	!lastAction(move);
//      		.wait(350);
	move(DIRECTION);
  	if(lastAction(move) & lastActionResult(success)){	
	  	NewX = OX+DESIRABLEX;
	  	NewY = OY+DESIRABLEY;
	  	
	  	if(NewX <= 49 & NewX >= 0 & NewY <= 49 & NewY >= 0){NewX1 = NewX;NewY1 = NewY;}
		elif(NewX <= 49 & NewX >=0){NewX1 = NewX;}
		elif(NewY <= 49 & NewY >=0){NewY1 = NewY;}
		
		if(NewX > 49){NewX1 = NewX-50;}
	  	elif(NewX < 0){NewX1 = NewX+50;}
	  	
	  	if(NewY > 49){NewY1 = NewY-50;}
	  	elif(NewY < 0){NewY1 = NewY+50;}
	  	
	  	-+myPos(NewX1,NewY1);
	  	if(myPos(X,Y)){-+changeDir(true)}
	  	
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
  	}
  	.
//+!lastAction(A): lastAction(A) & lastActionResult(success)
//	<-
//	NewX = OX+DESIRABLEX;
//	NewY = OY+DESIRABLEY;
//	
//	if(NewX <= 49 & NewX >= 0 & NewY <= 49 & NewY >= 0){NewX1 = NewX;NewY1 = NewY;}
//	elif(NewX <= 49 & NewX >=0){NewX1 = NewX;}
//	elif(NewY <= 49 & NewY >=0){NewY1 = NewY;}
//	
//	if(NewX > 49){NewX1 = NewX-50;}
//	elif(NewX < 0){NewX1 = NewX+50;}
//	
//	if(NewY > 49){NewY1 = NewY-50;}
//	elif(NewY < 0){NewY1 = NewY+50;}
//	
//	-+myPos(NewX1,NewY1);
//  	.