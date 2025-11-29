# @BAKE tclsh $@
package require Tk

pack [frame .root -padx 0 -pady 0] -fill both -expand 1

# Create child widgets for each column
label .root.left  -text "Left"
label .root.mid   -text "Middle" -background "#ccccff"
label .root.right -text "Right"

# Use grid
grid .root.left  .root.mid  .root.right -sticky news

# Set column weight ratios 1:8:1
grid columnconfigure .root 0 -weight 1
grid columnconfigure .root 1 -weight 8
grid columnconfigure .root 2 -weight 1

# Allow row expansion if desired
grid rowconfigure .root 0 -weight 1
