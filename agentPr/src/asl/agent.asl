// Agent agent in project agentPr

/* Initial beliefs and rules */

directionIncrement(s, 0,  1).
directionIncrement(n, 0, -1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).
myposition(3,13).
searching(true).
movingTowards(false).
//lastDirection(nw). 
distcount(1). 
hasTask(false).
b0(0,0).
b1(0,0).
g(0,0).
foundTB(false).



/* Initial goals */


/* Plans */


/* start moving to a given position */
+step(X): searching(true) <- !spiral; .
//+step(X): movingTowards(true) <- !moveTo(dir, desX, desY);.

//+!moveTo(D,DX,DY)<- move(D);
//	if(lastAction(move) & lastActionResult(success)){
//      	
//      	NewX = OX+DX;
//      	NewY = OY+DY;
//      	
//			if(NewX > 49){NewX = NewX-50;}
//		  	elif(NewX < 0){NewX = NewX+50;}
//		  	if(NewY > 49){NewY = NewY-50;}
//		  	elif(NewY < 0){NewY = NewY+50;}
//		  	
//      	-+myposition(NewX,NewY); 	
//      }
//	-+movingTowards(false);
////      .wait(350);
//      .
+!findTB <- 
	if(thing(_,_,taskboard,_)){
//		-+searching(false);
		-+foundTB(true);
		?thing(XT,YT,taskboard,_);
		?myposition(XA,YA);
		!goto(XA+XT,YA+YT);
		
	}.
	
	
//		if(task(T,_,_,_) & hasTask(false) & myposition(XA+XT,YA+YT)){
//			
//			-+hasTask(true);
//			accept(T);
//		}
		
	
//	task(T,_,_,_)
//+!acceptTask <- if(task(T,_,_,_)){accept(T); -+hasTask(true); -+foundTB(false);}!acceptTask;.

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

      if (DISTANCEX>=DISTANCEY) {
        DESIRABLEX = (X-OX)/DISTANCEX;
        DESIRABLEY = 0;
      }
      else {
        DESIRABLEX = 0;
        DESIRABLEY = (Y-OY)/DISTANCEY;
      }
      ?directionIncrement(DIRECTION,DESIRABLEX,DESIRABLEY);
      if(hasTask(false) & thing(_,_,taskboard,_) & foundTB(false)){!findTB;}

      	if(not thing(0,0,taskboard,_) & hasTask(false)){move(DIRECTION);.wait(350);
		  	if(lastAction(move) & lastActionResult(success)){	
		  	NewX = OX+DESIRABLEX;
		  	NewY = OY+DESIRABLEY;
		  	
		  	if(NewX <= 49 & NewX >= 0 & NewY <= 49 & NewY >= 0){
		  		NewX1 = NewX;NewY1 = NewY;
		  	}
			elif(NewX <= 49 & NewX >=0){NewX1 = NewX;}
			elif(NewY <= 49 & NewY >=0){NewY1 = NewY;}
			
			if(NewX > 49){NewX1 = NewX-50;}
		  	elif(NewX < 0){NewX1 = NewX+50;}
		  	
		  	if(NewY > 49){NewY1 = NewY-50;}
		  	elif(NewY < 0){NewY1 = NewY+50;}
		  	

		  	-+myposition(NewX1,NewY1);
		  	
	  		if(thing(XB,YB,dispenser,b0)){
				?myposition(XAg, YAg);
				-+b0(XAg+XB, YAg+YB);
			}
			if(thing(XB1,YB1,dispenser,b1)){
				?myposition(XAg, YAg);
				-+b1(XAg+XB1, YAg+YB1);
			}
			if(goal(XG,YG)){
				?myposition(XAg,YAg);
				-+g(XAg+XG,YAg+YG);
			}
		  	!goto(X,Y);
      	}
      }
      elif(hasTask(true)){move(DIRECTION);.wait(350);
		  	if(lastAction(move) & lastActionResult(success)){	
		  	NewX = OX+DESIRABLEX;
		  	NewY = OY+DESIRABLEY;
		  	
		  	if(NewX <= 49 & NewX >= 0 & NewY <= 49 & NewY >= 0){
		  		NewX1 = NewX;NewY1 = NewY;
		  	}
			elif(NewX <= 49 & NewX >=0){NewX1 = NewX;}
			elif(NewY <= 49 & NewY >=0){NewY1 = NewY;}
			
			if(NewX > 49){NewX1 = NewX-50;}
		  	elif(NewX < 0){NewX1 = NewX+50;}
		  	
		  	if(NewY > 49){NewY1 = NewY-50;}
		  	elif(NewY < 0){NewY1 = NewY+50;}
		  	

		  	-+myposition(NewX1,NewY1);
		  	
//	  		if(thing(XB,YB,dispenser,b0)){
//				?myposition(XAg, YAg);
//				-+b0(XAg+XB, YAg+YB);
//			}
//			if(thing(XB1,YB1,dispenser,b1)){
//				?myposition(XAg, YAg);
//				-+b1(XAg+XB1, YAg+YB1);
//			}
//			if(goal(XG,YG)){
//				?myposition(XAg,YAg);
//				-+g(XAg+XG,YAg+YG);
//			}
		  	!goto(X,Y);
      	}
      	
      }
      
      
//      elif(thing(0,0,taskboard,_) & hasTask(false)){!acceptTask;}
      
      
//      !goto(X,Y);
//	if(movingTowards(false)){!goto(X,Y);}
      
      .
+!doTask <- ?accepted(T); ?task(T,_,_,[req(_,_,Disp)]);
	if(Disp = b0){?b0(XB,YB) if(XB =0& YB =0){!spiral;}else{!goto(XB,YB-1);request(s);attach(s);?g(XG,YG);!goto(XG,YG);submit(T);}}
	if(Disp = b1){?b1(XB,YB) if(XB =0& YB =0){!spiral;}else{!goto(XB,YB-1);request(s);attach(s);?g(XG,YG);!goto(XG,YG);submit(T);}}
.

+!spiral: searching(true) <- 
    -+searching(false);
    ?distcount(C);
    if(C>4){-+distcount(1)}
    
    SpStep = 2;
//    ?myposition(X,Y);
    if(not thing(0,0,taskboard,_) & hasTask(false)){
    	?myposition(Xne,Yne);
//		?lastDirection(Dir);
		?distcount(Distne);
		NewXne = Xne+SpStep*Distne;
		NewYne = Yne-SpStep*Distne;
		
		if(NewXne <= 49 & NewXne >= 0 & NewYne <= 49 & NewYne >= 0){
			NewXne1 = NewXne;NewYne1 = NewYne;
		}
		elif(NewXne <= 49 & NewXne >=0){NewXne1 = NewXne;}
		elif(NewYne <= 49 & NewYne >=0){NewYne1 = NewYne;}
		
		if(NewXne > 49){NewXne1 = NewXne-50;}
	  	elif(NewXne < 0){NewXne1 = NewXne+50;}
	  	
	  	if(NewYne > 49){NewYne1 = NewYne-50;}
	  	elif(NewYne < 0){NewYne1 = NewYne+50;}

	  	!goto(NewXne1,NewYne1);
//		-+lastDirection(ne);
		-+distcount(Distne+1);
	}elif(thing(0,0,taskboard,_) & hasTask(false)){?task(T,_,_,_);accept(T); -+hasTask(true); -+foundTB(false);}
	
	if(not thing(0,0,taskboard,_) & hasTask(false)){
		?myposition(Xse,Yse);
		?distcount(Distse);
		NewXse = Xse+SpStep*Distse;
		NewYse = Yse+SpStep*Distse;
		
		if(NewXse <= 49 & NewXse >= 0 & NewYse <= 49 & NewYse >= 0){
			NewXse1 = NewXse;NewYse1 = NewYse;
		}
		elif(NewXse <= 49 & NewXse >=0){NewXse1 = NewXse;}
		elif(NewYse <= 49 & NewYse >=0){NewYse1 = NewYse;}
		
		if(NewXse > 49){NewXse1 = NewXse-50;}
	  	elif(NewXse < 0){NewXse1 = NewXse+50;}
	  	
	  	if(NewYse > 49){NewYse1 = NewYse-50;}
	  	elif(NewYse < 0){NewYse1 = NewYse+50;}

	  	!goto(NewXse1,NewYse1);
//		-+lastDirection(se);
	}elif(thing(0,0,taskboard,_) & hasTask(false)){?task(T,_,_,_);accept(T); -+hasTask(true); -+foundTB(false);}
		
	if(not thing(0,0,taskboard,_) & hasTask(false)){
		?myposition(Xsw,Ysw);
		?distcount(Distsw);
		NewXsw = Xsw-SpStep*Distsw;
		NewYsw = Ysw+SpStep*Distsw;
		if(NewXsw <= 49 & NewXsw >= 0 & NewYsw <= 49 & NewYsw >= 0){
			NewXsw1 = NewXsw;NewYsw1 = NewYsw;
		}
		elif(NewXsw <= 49 & NewXsw >=0){NewXsw1 = NewXsw;}
		elif(NewYsw <= 49 & NewYsw >=0){NewYsw1 = NewYsw;}
		
		if(NewXsw > 49){NewXsw1 = NewXsw-50;}
	  	elif(NewXsw < 0){NewXsw1 = NewXsw+50;}
	  	
	  	if(NewYsw > 49){NewYsw1 = NewYsw-50;}
	  	elif(NewYsw < 0){NewYsw1 = NewYsw+50;}
		

	  	!goto(NewXsw1,NewYsw1);
//		-+lastDirection(sw);
		-+distcount(Distsw+1);
	}elif(thing(0,0,taskboard,_) & hasTask(false)){?task(T,_,_,_);accept(T); -+hasTask(true); -+foundTB(false);}
		
	if(not thing(0,0,taskboard,_) & hasTask(false)){
		?myposition(Xnw,Ynw);
		?distcount(Distnw);
		NewXnw = Xnw-SpStep*Distnw;
		NewYnw = Ynw-SpStep*Distnw;

		if(NewXnw <= 49 & NewXnw >= 0 & NewYnw <= 49 & NewYnw >= 0){
			NewXnw1 = NewXnw;NewYnw1 = NewYnw;
		}
		elif(NewXnw <= 49 & NewXnw >=0){NewXnw1 = NewXnw;}
		elif(NewYnw <= 49 & NewYnw >=0){NewYnw1 = NewYnw;}
		
		if(NewXnw > 49){NewXnw1 = NewXnw-50;}
	  	elif(NewXnw < 0){NewXnw1 = NewXnw+50;}
	  	
	  	if(NewYnw > 49){NewYnw1 = NewYnw-50;}
	  	elif(NewYnw < 0){NewYnw1 = NewYnw+50;}
	  	
	  	!goto(NewXnw1,NewYnw1);
//		-+lastDirection(nw);
	}elif(thing(0,0,taskboard,_) & hasTask(false)){?task(T,_,_,_);accept(T); -+hasTask(true); -+foundTB(false);}
	if(hasTask(true)){
		!doTask;
	}
	-+searching(true);

	
	
//    if(hasTask(false) & thing(0,0,taskboard) & task(_,_,_,_)){
//    	?task(T,_,_,_);
//    	accept(T); -+hasTask(true); -+foundTB(false);
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//	if(foundTB(false)){
//		?lastDirection(Dir);
//		?distcount(Dist);
//		if (Dir = nw){
//			NewX = X+SpStep*Dist;
//			NewY = Y-SpStep*Dist;
//			
//			if(NewX > 49){NewX = NewX-50;}
//		  	elif(NewX < 0){NewX = NewX+50;}
//		  	if(NewY > 49){NewY = NewY-50;}
//		  	elif(NewY < 0){NewY = NewY+50;}
//		  	
//		  	!goto(NewX,NewY);
//			
//
//    		-+lastDirection(ne);
//    		-+distcount(Dist+1);
//		}
//		.wait(250);
// 		if (Dir = ne){
// 			NewX = X+SpStep*Dist;
//			NewY = Y+SpStep*Dist;
//			
//			if(NewX > 49){NewX = NewX-50;}
//		  	elif(NewX < 0){NewX = NewX+50;}
//		  	if(NewY > 49){NewY = NewY-50;}
//		  	elif(NewY < 0){NewY = NewY+50;}
//		  	
//		  	!goto(NewX,NewY);
//    		-+lastDirection(se);
//		}
//		.wait(250);
//		if (Dir = se){
//			NewX = X-SpStep*Dist;
//			NewY = Y+SpStep*Dist;
//			
//			if(NewX > 49){NewX = NewX-50;}
//		  	elif(NewX < 0){NewX = NewX+50;}
//		  	if(NewY > 49){NewY = NewY-50;}
//		  	elif(NewY < 0){NewY = NewY+50;}
//		  	
//		  	!goto(NewX,NewY);
//    		-+lastDirection(sw);
//    		-+distcount(Dist+1);
//		}
//		.wait(250);
//		if (Dir = sw){
//			NewX = X-SpStep*Dist;
//			NewY = Y-SpStep*Dist;
//			
//			if(NewX > 49){NewX = NewX-50;}
//		  	elif(NewX < 0){NewX = NewX+50;}
//		  	if(NewY > 49){NewY = NewY-50;}
//		  	elif(NewY < 0){NewY = NewY+50;}
//		  	
//		  	!goto(NewX,NewY);
//    		-+lastDirection(nw);
// 		}
//	}
			//?thing(XB,YB,dispenser,b0);//?thing(XB,YB,dispenser,b0);
			
/*adds to belief where b0 and b1 are located */	

	
//	else{!acceptTask;}
//    -+searching(true);
    .


