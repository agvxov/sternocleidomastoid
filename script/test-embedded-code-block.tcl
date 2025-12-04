package require Tk

text .txt -width 60 -height 20 -wrap none
pack .txt -fill both -expand 1

proc insert_code_block {content} {
    text .txt.child -width 50 -height [expr {[llength [split $content "\n"]]}] -wrap none \
        -bg #f0f0f0 -fg black -font {Courier 10} -bd 2 -relief sunken

    .txt window create end -window .txt.child

    .txt.child insert end $content

    .txt.child config -state disabled

    .txt tag configure codeblock -foreground white -background white
    .txt tag configure codeblock -elide 1
    .txt insert end $content codeblock
}

.txt insert end "Here is some normal text before the code block.\n\n"
insert_code_block {
    for {set i 0} {$i < 10} {incr i} {
        puts "Line $i"
    }
}
.txt insert end "\nAnd here is some text after the code block.\n"

bind .txt <Control-c> {
    set sel [.txt get sel.first sel.last]
    clipboard clear
    clipboard append $sel
}
