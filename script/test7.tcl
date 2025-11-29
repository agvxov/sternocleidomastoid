package require Tk

# create text widget
text .t -width 30 -height 5
pack .t

# insert normal text
.t insert end "Before the label...\n"

# create a label to embed
label .lbl -text "I am an embedded label" -bg yellow

# embed the label at index 2.0
.t window create 2.0 -window .lbl

# insert more text
.t insert end "\nAfter the label."
