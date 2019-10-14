/*
* Alex Yu
* November 26, 2018
*
* This module handles the graphic user interface (GUI) part of the Swim Meet Event Picker. It
* will display questions for the user to answer and assert the appropriate facts for the rule
* engine. It also prints out the picked events at the end.
*/

(import javax.swing.*)
(import javax.swing.BoxLayout)
(import java.awt.event.*)
(import java.awt.event.WindowEvent)
(import java.awt.BorderLayout)

(batch smep/Toolbox.clp)

/*
* This template keeps track of the user's answers (the value) to specific questions (the type). Facts in this template
* are used to progress the question asking process and ultimately to determine the best event(s) to swim.
*/
(deftemplate parameter (slot type) (slot val))

(defglobal ?*SCREEN_WIDTH* = 600)
(defglobal ?*SCREEN_HEIGHT* = 450)

(defglobal ?*f* = (new JFrame "Swim Meet Event Picker (SMEP)"))
(defglobal ?*answerPanel* = (new JPanel))

/*
* Creates and readies the frame and its main panel. The main panel consists of an answer panel in the 
* upper section and a panel with exit and restart buttons in the lower right-hand section. 
*/
(deffunction instantiateGUI ()

   (call ?*f* setBounds 0 0 ?*SCREEN_WIDTH* ?*SCREEN_HEIGHT*)
   (call ?*f* setResizable FALSE)
   (call ?*f* addWindowListener (implement WindowListener using (lambda (?name ?event)
      (if (= (?event getID) (WindowEvent.WINDOW_CLOSING)) then
        (exit))))
   )

   (bind ?mainPanel (call ?*f* getContentPane))
   (call ?mainPanel setLayout (new BorderLayout))

   (call ?*answerPanel* setLayout (new BoxLayout ?*answerPanel* (BoxLayout.Y_AXIS)))
   (call ?mainPanel add ?*answerPanel* (BorderLayout.NORTH))

   (bind ?lowerPanel (new JPanel))
   (call ?lowerPanel setLayout (new BorderLayout))
   (call ?lowerPanel add (getUtilPanel) (BorderLayout.EAST))

   (call ?mainPanel add ?lowerPanel (BorderLayout.SOUTH))

   (return)

) ; (deffunction instantiateGUI ()

/*
* Creates and returns a panel that contains exit and restart buttons. The exit button stops the rule engine,
* closes the frame, and returns back to the Jess command line. The restart button resets the program, letting
* the user start from the initial page again.
*
* @return   a panel containing an exit button
*/
(deffunction getUtilPanel ()

   (bind ?utilPanel (new JPanel))
   (call ?utilPanel setLayout (new BoxLayout ?utilPanel (BoxLayout.Y_AXIS)))

   (bind ?restartButton (new JButton "Restart"))
   (call ?restartButton addActionListener (implement ActionListener using (lambda (?name ?evt)
      (dispose)
      (assert (restart))
   )))

   (bind ?exitButton (new JButton "Exit"))
   (call ?exitButton addActionListener (implement ActionListener using (lambda (?name ?evt)
      (dispose)
      (assert (stop))
   )))

   (call ?utilPanel add ?restartButton)
   (call ?utilPanel add ?exitButton)
   (return ?utilPanel)

) ; (deffunction getUtilPanel ()

/*
* Adds a question and a list of answers to the frame. The answers are added as buttons that
* the user can choose from. The button's action is to assert a fact associated with the type and 
* specific choice of the button. 
*
* For example, if (addQAndA "Choose:" Random (create$ Foo Bar)) is called, the GUI will display 
* the string "Choose" and two buttons, one labeled "Foo" and the other labeled "Bar". If the user clicks
* the Foo button, then the fact (parameter (type Random) (val Foo)) is asserted.
*
* @param ?question   the question to be asked and displayed
* @param ?type       the type of the fact to be asserted
* @param ?answers    the possible choices for the question asked
*/
(deffunction addQAndA (?question ?type ?answers)

   (clearJComponent ?*answerPanel*)

   (bind ?qText (new JLabel ?question))
   (call ?*answerPanel* add ?qText)

   (for (bind ?i 1) (<= ?i (length$ ?answers)) (++ ?i)
   
      (bind ?answer (nth$ ?i ?answers))
      (call ?*answerPanel* add (createButton ?answer))

   )

   (call ?*f* setVisible TRUE)
   (return)

) ; (deffunction addQAndA (?question ?type ?answers)

/*
* Creates and returns a JButton with a certain answer. When clicked, the button will assert a fact 
* associated with its type and specific choice. See the method (addQAndA) for more details.
*
* @param answer   the button's specific answer
* @return         the button with its action command set to assert the proper parameter fact
*/
(deffunction createButton (?answer)

   (bind ?b (new JButton ?answer))
   (call ?b setActionCommand (str-cat ?type " " ?answer))

   (call ?b addActionListener (implement ActionListener using (lambda (?name ?evt)
      (bind ?actionCmd (call ?evt getActionCommand))
      (bind ?spaceIndex (getSpaceIndex ?actionCmd))

      (bind ?type (sym-cat (sub-string 1 (- ?spaceIndex 1) ?actionCmd)))               ; gets the button's type
      (bind ?val (sub-string (+ ?spaceIndex 1) (str-length ?actionCmd) ?actionCmd))    ; gets the button's value

      (assert (parameter (type ?type) (val ?val)))
   )))

   (return ?b)

) ; (deffunction createButton (?answer)

/*
* Displays the events chosen by the program in a formatted label on the frame. 
* @param ?events  the list of events to display
*/
(deffunction displayEvents (?events)

   (clearJComponent ?*answerPanel*)

   (if (> (length$ ?events) 0) then 
   
      (bind ?eventText "<html>You should do the following event(s): <br/>")
      (foreach ?event ?events
         (bind ?eventText (str-cat ?eventText ?event "<br/>")) 
      )
      (bind ?eventText (str-cat ?eventText "</html>"))

    else
      (bind ?eventText "Oops, something went wrong. :(")

   ) ; (if (> (length$ ?events) 0) then 

   (bind ?label (new JLabel ?eventText))
   (call ?*answerPanel* add ?label)
   (call ?*f* setVisible TRUE)
   (return)

) ; (deffunction displayEvents (?events)

/*
* Clears a given JComponent of all its contents and repaints the JFrame.
* @param ?component  the JComponent to clear
*/
(deffunction clearJComponent (?component)

   (call ?component removeAll)
   (call ?*f* repaint)
   (return)

)

/*
* Disposes the JFrame.
*/
(deffunction dispose ()

   (call ?*f* dispose)
   (return)

)