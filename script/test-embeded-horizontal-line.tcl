package require Tk

text .t -width 50 -height 10
pack .t -fill both -expand 1

frame .line \
    -height 3 \
    -width 150 \
    -background "#000000" \
    -borderwidth 0 \
    -highlightthickness 0

.t insert end "Above the line\n"
.t window create end -window .line
.t insert end "\nBelow the line\n"
