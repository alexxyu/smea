/*
* Alex Yu
* November 28, 2018
*
* This module contains an assortment of useful utility functions regarding console output, string manipulation,
* and list manipulation. To use, simply batch in, and call the needed function(s).
*/

/*
* Prints out a given string on a single line in the command prompt/terminal.
* @param ?str  the strint to print
*/
(deffunction println (?str)

   (printout t ?str crlf)
   (return)

)

/*
* Returns the index of the first space in a given string. If the string contains no space, returns FALSE.
*
* @param ?string  the string from which to retrieve the index of the space
* @return         the index of the first space in the string; otherwise,
*                 FALSE
*/
(deffunction getSpaceIndex (?string)

   (return (str-index " " ?string))

)

/*
* Removes the given value in a list. If the given value does not exist, then the function
* just returns the original list.
* 
* @param ?list       the list from which to remove the value
* @param ?toRemove   the value to remove from the list
* @return            the modified list with the removed value; if value does not exist, then 
*                    the original list
*/
(deffunction removeValue$ (?list ?toRemove)

   (bind ?removeIndex (member$ ?toRemove ?list))
   (if (not ?removeIndex) then
      (bind ?newList ?list)
    else
      (bind ?newList (delete$ ?list ?removeIndex ?removeIndex))
   )
   (return ?newList)

)

/*
* Removes the elements in the given index range of a list and returns the newly modified list. The
* function skips over any indices less than 1 or greater than the list length, and it returns the original
* list if the end index is less than the begin index.
*
* @param ?list    the list from which to remove the value(s)
* @param ?begin   the index of the list from which to start removing elements
* @param ?end     the index of the list at which to stop removing elements
* @return         the modified list with the removed value(s), if any
*/
(deffunction removeIndices$ (?list ?begin ?end)

   (bind ?newList ?list)

   (if (<= ?begin ?end) then

      (for (bind ?i ?end) (>= ?i ?begin) (-- ?i)
      
         (if (and (>= ?i 1) (<= ?i (length$ ?newList)) ) then
            
            (bind ?newList (delete$ ?newList ?i ?i))

         )
      
      )

   ) ; (if (<= ?begin ?end) then

   (return ?newList)

) ; (deffunction removeIndices$ (?list ?begin ?end)