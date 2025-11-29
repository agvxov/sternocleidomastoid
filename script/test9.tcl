package require Tk

pack [text .t -width 60 -height 15] -fill both -expand 1

# Some dummy text before
.t insert end "Lorem ipsum dolor sit amet...\n\n"

# Create a label to embed
label .t.codeLbl -text "inline code block" -bg "#f0e6d2" -font "TkFixedFont" -borderwidth 1 -relief solid -padx 3 -pady 1

# Insert the window inline
.t window create end -window .t.codeLbl -padx 4 -pady 2

# Some dummy text after
.t insert end "\n\nMore text continues here after the embedded widget.\n"
