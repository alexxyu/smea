/*
* Alex Yu
* December 30, 2018
*
* The rules and function in this file are batched in if the user chooses the option "Have fun" as his/her goal
* for the meet. Together, they generate a list of random events that are deemed fun.
*/

(defglobal ?*FUN_EVENTS* = (create$ "50 Free" "100 Fly" "100 Free" "100 Back" "100 Breast"))

(defrule generateFunEvents
   (parameter (type numOfEvents) (val ?n))
   =>
   (assertRandomEvent ?*FUN_EVENTS* (integer ?n))
)

/*
* Asserts facts representing a number of random distinct events, given a list of events.
*
* @param ?eventList  the list of events to pick from
* @param ?n          the number of facts to assert
*/
(deffunction assertRandomEvent (?eventList ?n)

   (for (bind ?i 0) (< ?i ?n) (++ ?i)

      (bind ?randIndex (+ (mod (random) (length$ ?eventList)) 1))          ; generates random index within list bounds
      (bind ?event (nth$ ?randIndex ?eventList))
      (bind ?spaceIndex (getSpaceIndex ?event))

      (bind ?distance (integer (sub-string 1 (- ?spaceIndex 1) ?event)))
      (bind ?stroke (sub-string (+ ?spaceIndex 1) (str-length ?event) ?event))

      (assert (event (distance ?distance) (stroke ?stroke)))
      (bind ?eventList (delete$ ?eventList ?randIndex ?randIndex))

   ) ; (for (bind ?i 0) (< ?i ?n) (++ ?i)

   (return)

); (deffunction assertRandomEvent (?eventList ?n)