# @BAKE tclsh $@
package require Tk

## Define fonts once
#font create MDNormal -family sans -size 12
#font create MDBold   -family sans -size 12 -weight bold
#font create MDIta    -family sans -size 12 -slant italic
#font create MDStrike -family sans -size 12 -overstrike 1
#
#proc insert_with_inline_formatting {w text} {
#    set i 0
#    set len [string length $text]
#
#    while {$i < $len} {
#        # Bold: **...**
#        if {[string range $text $i $i+1] eq "**"} {
#            set start [expr {$i + 2}]
#            set end   [string first "**" $text $start]
#            if {$end < 0} break
#            set content [string range $text $start [expr {$end - 1}]]
#            set pos [$w index end]
#            $w insert end $content bold
#            set i [expr {$end + 2}]
#            continue
#        }
#
#        # Italic: *...*
#        if {[string index $text $i] eq "*"} {
#            #[string index $text [expr {$i+1}]] ne "*"]} {
#
#            set start [expr {$i + 1}]
#            set end   [string first "*" $text $start]
#            if {$end < 0} break
#            set content [string range $text $start [expr {$end - 1}]]
#            $w insert end $content italic
#            set i [expr {$end + 1}]
#            continue
#        }
#
#        # Strikethrough: ~~...~~
#        if {[string range $text $i $i+1] eq "~~"} {
#            set start [expr {$i + 2}]
#            set end   [string first "~~" $text $start]
#            if {$end < 0} break
#            set content [string range $text $start [expr {$end - 1}]]
#            $w insert end $content strike
#            set i [expr {$end + 2}]
#            continue
#        }
#
#        # Otherwise: insert plain char
#        $w insert end [string index $text $i]
#        incr i
#    }
#}
#
#wm title . "Markdown-GUI"
#bind . <Destroy> {exit}
#
#text .t
#.t tag configure bold   -font MDBold
#.t tag configure italic -font MDIta
#.t tag configure strike -font MDStrike
#insert_with_inline_formatting .t "asd adas dsad sad *i* asdsad sadsa sa d"
#pack .t

set cursor {}

font create NormalFont -family sans -size 12
font create BoldFont   -family sans -size 12 -weight bold

text .t -font NormalFont -wrap word
pack .t

.t tag configure bold -font BoldFont
.t tag configure link -foreground blue -underline 1
.t tag bind link <Button-1> { puts "You clicked the link" }

.t insert end "word "
.t insert end "bold" bold
.t insert end " link" link
.t insert end " word"
