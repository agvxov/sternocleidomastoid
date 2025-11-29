package require Tk
# text widget
text .t -wrap word
pack .t

.t insert end "Ashdalkshdlksahldd sahlksa hdlkhsad aadl sahldha lksldhsa hdsalkd h"
update idletasks   ;# force rendering

# get number of rendered screen lines
set nlines [.t count -displaylines 1.0 end]

# get pixel height of a single rendered line
set bbox [.t bbox "1.0"]
set lineheight [lindex $bbox 3]

# compute total rendered height in pixels
set total_height [expr {$nlines * $lineheight}]

# compute rendered width: longest display line
set maxwidth 0
for {set i 1} {$i <= $nlines} {incr i} {
    set bbox [.t bbox "$i.0"]
    if {$bbox ne ""} {
        set w [lindex $bbox 2]
        if {$w > $maxwidth} {set maxwidth $w}
    }
}

# apply padding (needed to avoid clipping borders)
set pad 6
set final_w [expr {$maxwidth + $pad}]
set final_h [expr {$total_height + $pad}]

# resize widget or its container
.t configure -width 0 -height 0   ;# remove char-based sizing
.t configure -width $final_w -height $final_h
