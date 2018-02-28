Note: If you stumble across this repo, the processing.js application on the website does not work (didn't port over correctly from Processing). But the Processing code works if dug out!

The dataset (students.csv) is a randomly generated set of students. Features of interest for a student are overall grade (float), number of late days (int), current age (int), miles away from school (float), and height in inches (float).

For hovering, I decided to only include data for the dimension closest to the current mouse position. I did not think that including the entire row of data for a student would scale well, particularly if this program was used to represent higher dimensional data ( the more dimensions, the less readable displaying all feature values would be).

Though this was not in the writeup, I also implemented a tooltip "deadzone" in between dimensions. For example, if the mouse hovers directly in between two coordinates, no tooltip will be displayed. If the mouse is relatively close to a dimension, the tooltip is displayed. I thought doing this added a lot of clarity as to what feature the displayed information is describing - allowing tooltips in the middle of the 'abyss' left it pretty ambiguous to the user as to what type of information they were looking at.

Multiple tooltips are displayed in a cross-like formation.



