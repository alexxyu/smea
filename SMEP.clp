/*
* Alex Yu
* November 5, 2018
*
* The Swim Meet Event Picker (SMEP) chooses what events the user should enter at a swim meet given a set of 
* constraints based on user input. To run, simply batch in this file. Once batched, you can re-run the program 
* with the command (pickEvents). You can also use the restart button on the graphic interface.
*/

(clear)
(reset)

(batch smep/GUI.clp)
(batch smep/Toolbox.clp)

/*
* This template keeps track of the user's answers (the value) to specific questions (the type). Facts in this template
* are used to progress the question asking process and ultimately to determine the best event(s) to swim.
*/
(deftemplate parameter (slot type) (slot val))

/*
* This template represents an event (characterized by its distance and stroke) chosen by the program. Once asserted, a 
* fact in this template is extracted of its information to display to the user.
*/
(deftemplate event (slot distance (type INTEGER)) (slot stroke))

(defglobal ?*PATH_TO_HS_EVENTS* = "smep/HSEvents.txt")
(defglobal ?*PATH_TO_COLLEGIATE_EVENTS* = "smep/CollegiateEvents.txt")

(defglobal ?*STROKES* = (create$ "Fly" "Back" "Breast" "Free" "IM"))
(defglobal ?*DISTANCES* = (create$ "Sprint" "Mid-Distance" "Long Distance"))

(defglobal ?*LONG_DISTANCES* = (create$ 1650 1000 500))
(defglobal ?*MID_DISTANCES* = (create$ 400 200))
(defglobal ?*SHORT_DISTANCES* = (create$ 100 50))

(defglobal ?*events* = (create$))                  ; list of available events for the user
(defglobal ?*pickedEvents* = (create$))            ; list of events that the user should enter
(defglobal ?*rest* = 0)                            ; number of events between races for rest (default is no rest between events)

/********************************
*
* Startup / Question Rules:
* Ask the user more general questions
*
*/

(defrule startup "Prints the startup message and prompts the user to click the start button to begin"
   =>
   (bind ?startupText "<html> Welcome to the <b> Swim Meet Event Picker </b> (SMEP for short). This program will (hopefully) <br/>")
   (bind ?startupText (str-cat ?startupText "help you decide which events you should enter in at a swim meet. However indecisive <br/>"))
   (bind ?startupText (str-cat ?startupText "you might be, you should still have some idea about yourself, such as your goals and <br/>"))
   (bind ?startupText (str-cat ?startupText "your best events. Click the button below when you are ready. <br/> <br/> <br/> <br/> </html>"))
   (addQAndA ?startupText startup (create$ "Start"))
)

(defrule askMeetType
   (parameter (type startup) (val "Start"))
   =>
   (addQAndA "What type of swim meet are you competing in?" meetType (create$ "High School" "Collegiate"))
)

(defrule askNumOfEvents
   (parameter (type meetType) (val ?v))
   =>
   (addQAndA "How many events would you like?" numOfEvents (create$ "1" "2" "3"))
)

(defrule askGoal 
   (parameter (type numOfEvents) (val ?v))
   =>
   (addQAndA "Which of the following choices best describes your goal for the meet?" goal 
      (create$ "Compete and win races" "Improve or train" "Have fun"))
)

/********************************
*
* Answer-specific Rules:
* Set proper events based on meet type and 
* batch in corresponding ruleset according
* to the user's goal for the meet
*
*/

(defrule setHighSchoolEvents
   (parameter (type meetType) (val "High School"))
   =>
   (setEventList ?*PATH_TO_HS_EVENTS*)
   (buildAllEvents)
)

(defrule setCollegiateEvents
   (parameter (type meetType) (val "Collegiate"))
   =>
   (setEventList ?*PATH_TO_COLLEGIATE_EVENTS*)
   (buildAllEvents)
)

(defrule batchFunRules
   (parameter (type goal) (val "Have fun"))
   =>
   (batch smep/FunRules.clp)
)

(defrule batchImproveRules
   (parameter (type goal) (val "Improve or train"))
   =>
   (batch smep/ImproveRules.clp)
)

(defrule batchCompeteRules
   (parameter (type goal) (val "Compete and win races"))
   =>
   (batch smep/CompeteRules.clp)
)

/********************************
*
* Miscellaneous Rules:
* Provide utility functionality for 
* the rule engine
*
*/

(defrule addEventToList
   (parameter (type numOfEvents) (val ?n))
   (test (< (length$ ?*pickedEvents*) (integer ?n)))
   ?f <- (event (distance ?d) (stroke ?s))
   =>
   (addEvent ?d ?s)
   (retract ?f)
   (assert (hasAdded))

   (if (>= (length$ ?*pickedEvents*) (integer ?n)) then
      (assert (done))
   )
) ; (defrule addEventToList

(defrule displayAllEvents
   (done)
   =>
   (displayEvents ?*pickedEvents*)
)

(defrule restartProgram
   (restart)
   =>
   (clear)
   (reset)
   (batch smep/smep.clp)
)

(defrule stopProgram "Halts the rule engine"
   (stop)
   =>
   (halt)
)

/********************************
*
* Conversion Rules:
* Convert different parameter facts into other
* types for program use
*
*/

(defrule convertMostToShortDistance "Converts sprint fact to numerical short distance facts for all strokes but IM"
   (parameter (type enduranceLevel) (val "Sprint"))
   (parameter (type stroke) (val ?s &~ "IM"))
   =>
   (foreach ?distance ?*SHORT_DISTANCES*
      (assert (parameter (type distance) (val ?distance)))
   )
)

(defrule convertIMToMidDistance "Converts sprint/distance facts to numerical mid distance facts for IM"
   (parameter (type enduranceLevel) (val ?e &~ "Mid-Distance"))
   (parameter (type stroke) (val "IM"))
   =>
   (foreach ?distance ?*MID_DISTANCES*
      (assert (parameter (type distance) (val ?distance)))
   )
)

(defrule convertHSStrokeToShortDistance "Converts mid/long distance fact to numerical short/mid distance facts if stroke at HS meet"
   (parameter (type meetType) (val "High School"))
   (parameter (type stroke) (val ?s &~ "Free"))
   (parameter (type enduranceLevel) (val ?e &~ "Sprint"))
   =>
   (foreach ?distance (union$ ?*SHORT_DISTANCES* ?*MID_DISTANCES*)
      (assert (parameter (type distance) (val ?distance)))
   )
)

(defrule convertCollegiateStrokeToMidDistance "Converts distance facts to numerical mid-distance facts if stroke at collegiate meet"
   (parameter (type meetType) (val "Collegiate"))
   (parameter (type stroke) (val ?s &~ "Free"))
   (parameter (type enduranceLevel) (val ?e &~ "Sprint"))
   =>
   (foreach ?distance ?*MID_DISTANCES*
      (assert (parameter (type distance) (val ?distance)))
   )
)

(defrule convertFreeToMidDistance "Converts mid-distance fact to numerical mid-distance facts if free"
   (parameter (type stroke) (val "Free"))
   (parameter (type enduranceLevel) (val "Mid-Distance"))
   =>
   (foreach ?distance ?*MID_DISTANCES*
      (assert (parameter (type distance) (val ?distance)))
   )
)

(defrule convertFreeToLongDistance "Converts long distance fact to numerical long distance facts if free"
   (parameter (type stroke) (val "Free"))
   (parameter (type enduranceLevel) (val "Long Distance"))
   =>
   (foreach ?distance ?*LONG_DISTANCES*
      (assert (parameter (type distance) (val ?distance)))
   )
)

/********************************
*
* Rule Engine Functions:
* Build rules for strokes, assert facts for strokes
*
*/

/*
* Builds a rule representing a given event (characterized by its distance and stroke).
* For example, if (buildEvent 100 "Free") is called, then the following rule is asserted 
* (formatted for readability):
*
* (defrule 100Free   
*    (parameter (type distance) (val 100)) 
*    (parameter (type stroke) (val "Free"))   
*    =>
*    (assert (event (distance 100) (stroke "Free")))
* )
*
* @param ?distance   the event's distance
* @param ?stroke     the event's stroke
*/
(deffunction buildEvent (?distance ?stroke)

   (bind ?rule (str-cat "(defrule " ?distance ?stroke))

   (bind ?lhs (str-cat "   
      (parameter (type distance) (val " ?distance ")) 
      (parameter (type stroke) (val \"" ?stroke "\"))")
   )

   (bind ?rhs (str-cat "(assert (event (distance " ?distance ") (stroke \"" ?stroke "\")))"))

   (bind ?rule (str-cat ?rule ?lhs "=>" ?rhs ")"))

   (build ?rule)
   (return)

) ; (deffunction buildEvent (?distance ?stroke ?enduranceLevel)

/*
* Dynamically builds all rules that represent the events at the given meet. Cycles through the event list
* to build the rules.
*/
(deffunction buildAllEvents ()

   (foreach ?event ?*events*

      (bind ?spaceIndex (getSpaceIndex ?event))

      (bind ?distance (integer (sub-string 1 (- ?spaceIndex 1) ?event)))
      (bind ?stroke (sub-string (+ ?spaceIndex 1) (str-length ?event) ?event))

      (buildEvent ?distance ?stroke ?distance)

   )

   (return)

) ; (deffunction buildAllEvents ()

/********************************
*
* Module-specific utility functions:
* Update global variables regarding events
*
*/

/*
* Adds a given event (characterized by the distance and stroke) to a list for all picked events. Then
* removes it, as well as any events around it for rest purposes, from the available events list.
* 
* @param ?distance   the event's distance
* @param ?stroke     the event's stroke
*/
(deffunction addEvent (?distance ?stroke)

   (bind ?event (str-cat ?distance " " ?stroke))
   (bind ?*pickedEvents* (insert$ ?*pickedEvents* (+ (length$ ?*pickedEvents*) 1) ?event))

   (bind ?eventIndex (member$ ?event ?*events*))

   (if (integerp ?eventIndex) then
      (bind ?*events* (removeIndices$ ?*events* (- ?eventIndex ?*rest*) (+ ?eventIndex ?*rest*)))
   )

   (return)

) ; (deffunction addEvent (?distance ?stroke)

/*
* Adds each of the meet's events from a text file to the events list as a string. 
* @param ?eventsPath    the path to the file containing the events, each on a new line
*/
(deffunction setEventList (?eventsPath) 

   (open ?eventsPath file "r")
   (bind ?event (readline file))                                                 ; get first event from file
   (while (stringp ?event)                                                       ; loop as there are more events

      (bind ?*events* (insert$ ?*events* (+ (length$ ?*events*) 1) ?event))      ; adds event to list
      (bind ?event (readline file))                                              ; gets next event

   )

   (return)

)

/*
* Starts the program by initializing key components (such as GUI) and then runs the rule engine.
*/
(deffunction pickEvents ()

   (reset)
   (instantiateGUI)
   (run-until-halt)
   (return)

)

(pickEvents)