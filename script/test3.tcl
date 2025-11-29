# @BAKE tclsh $@
package require Tk

# Create a text widget that looks like a label
text .t \
    -background [. cget -background] \
    -borderwidth 0 \
    -highlightthickness 0 \
    -wrap word \
    -padx 0 \
    -pady 0

# Disable editing
.t configure -state disabled

# Basic formatted tags
.t tag configure bold   -font "TkDefaultFont 9 bold"
.t tag configure italic -font "TkDefaultFont 9 italic"

# Insert some demonstration content
.t configure -state normal
.t insert end "This is " {}
.t insert end "bold" bold
.t insert end " and " {}
.t insert end "italic" italic
.t insert end " text inside a label-like text widget." {}
.t configure -state disabled

# Layout
pack .t -padx 10 -pady 10 -fill x
