/*
* Alex Yu
* December 30, 2018
*
* The rules in this file are batched in if the user chooses the option "Improve or train" as his/her goal
* for the meet. These rules ask the user more questions, and the user's answers are used to determine the best events
* for this particular goal.
*/

(defrule askAreaToImprove
   =>
   (addQAndA "Which area would you like to focus on improving?" improveArea (create$ "Distance" "Stroke"))
)

(defrule askDistanceToImprove
   (parameter (type improveArea) (val "Distance"))
   =>
   (addQAndA "Which distance would you like to focus on training or improving?" enduranceLevel ?*DISTANCES*)
)

(defrule askBestStroke
   (parameter (type improveArea) (val "Distance"))
   (parameter (type enduranceLevel) (val ?e))
   =>
   (addQAndA "Which stroke is your best?" stroke ?*STROKES*)
)

(defrule askStrokeToImprove
   (parameter (type improveArea) (val "Stroke"))
   =>
   (addQAndA "Which stroke would you like to focus on training or improving?" stroke ?*STROKES*)
)

(defrule askBestDistance
   (parameter (type improveArea) (val "Stroke"))
   (parameter (type stroke) (val ?s))
   (not (parameter (type enduranceLevel) (val ?e)))
   =>
   (addQAndA "Are you a long distance, mid-distance, or sprint swimmer?" enduranceLevel ?*DISTANCES*)
)

(defrule askBestRemainingStroke
   (not (done))
   (not (parameter (type improveArea) (val "Stroke")))
   (parameter (type stroke) (val ?s))
   ?f <- (hasAdded)
   =>
   (retract ?f)
   (addQAndA "Which stroke among the following is your best? " stroke (removeValue$ ?*STROKES* ?s))
)

(defrule askBestRemainingDistance
   (not (done))
   (not (parameter (type improveArea) (val "Distance")))
   (parameter (type enduranceLevel) (val ?e))
   ?f <- (hasAdded)
   =>
   (retract ?f)
   (addQAndA "Which distance among the following is your best? " enduranceLevel (removeValue$ ?*DISTANCES* ?e))
)

(defrule generateRemainingEventsToImproveIM "Tries to fill out last event(s) with IM if needed as a last resort"
   (declare (salience -100))
   (not (done))
   (parameter (type stroke) (val ?s &~ "IM"))
   (or (and (parameter (type enduranceLevel) (val ?e1)) (parameter (type enduranceLevel) (val ?e2 &~ ?e1)))
       (and (parameter (type stroke) (val ?s1))         (parameter (type stroke) (val ?s2 &~ ?s1)))
   )
   =>
   (assert (parameter (type stroke) (val "IM")))
)

(defrule generateRemainingEventsToImproveFree "Tries to fill out last event(s) with freestyle if needed as a last resort"
   (declare (salience -100))
   (not (done))
   (parameter (type stroke) (val ?s &~ "Free"))
   (parameter (type stroke) (val "IM"))
   (or (and (parameter (type enduranceLevel) (val ?e1)) (parameter (type enduranceLevel) (val ?e2 &~ ?e1)))
       (and (parameter (type stroke) (val ?s1))         (parameter (type stroke) (val ?s2 &~ ?s1)))
   )
   =>
   (assert (parameter (type stroke) (val "Free")))
)