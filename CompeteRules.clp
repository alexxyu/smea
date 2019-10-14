/*
* Alex Yu
* December 30, 2018
*
* The rules in this file are batched in if the user chooses the option "Compete and win races" as his/her goal
* for the meet. These rules ask the user more questions, and the user's answers are used to determine the best events
* for this particular goal.
*/

(defglobal ?*REST_FOR_COMPETING* = 1)

(defrule askBestStroke
   =>
   (addQAndA "Which is your best stroke?" stroke ?*STROKES*)
)

(defrule setRestValue 
   (parameter (type numOfEvents) (val ?n &~ "1"))
   =>
   (bind ?*rest* ?*REST_FOR_COMPETING*)
)

(defrule askBestDistance
   (parameter (type stroke) (val ?s))
   =>
   (addQAndA "Are you a long distance, mid-distance, or sprint swimmer?" enduranceLevel ?*DISTANCES*)
)

(defrule askNextBestEvents
   (not (done))
   (parameter (type stroke) (val ?s))
   ?f <- (hasAdded)
   =>
   (retract ?f)
   (addQAndA "Choose your best event out of the following:" event ?*events*)
)

(defrule convertToEvent "Converts event parameter fact to proper event template fact"
   ?f <- (parameter (type event) (val ?e))
   =>
   (retract ?f)

   (bind ?spaceIndex (getSpaceIndex ?e))
   (bind ?distance (integer (sub-string 1 (- ?spaceIndex 1) ?e)))
   (bind ?stroke (sub-string (+ ?spaceIndex 1) (str-length ?e) ?e))

   (assert (event (distance ?distance) (stroke ?stroke)))
) ; (defrule convertToEvent "Converts event parameter fact to proper event template fact"