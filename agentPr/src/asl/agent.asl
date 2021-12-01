// Agent agent in project agentPr
/* Initial beliefs and rules */

mypostion(0,0).
directions([n,s,w,e]).

directionIncrement(n, 0, -1).
directionIncrement(s, 0,  1).
directionIncrement(w,-1,  0).
directionIncrement(e, 1,  0).

/* Initial goals */

!startMoving.

/* Plans */

+!startMoving <- !chooseDirection.

+!chooseDirection : true <-	.random(Number)
						if(Number <=0.25){
							-+direction(n);
							X =  0;
							Y = -1;
						}
						if(Number > 0.25 & Number <= 0.50){
							-+direction(s);
							X =  0;
							Y =  1;
						}
						if(Number > 0.50 & Number <= 0.75){
							-+direction(w);
							X = -1;
							Y =  0;
						}
						if(Number > 0.75 & Number <= 1.00){
							-+direction(e);
							X = 1;
							Y = 0;
						}
						?direction(Direction);
						!moveTowards(Direction, X,Y).

+!moveTowards(Direction,X,Y) <- move(Direction, X, Y).
