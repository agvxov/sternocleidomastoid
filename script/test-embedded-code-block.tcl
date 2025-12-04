package require Tk

# Run the Tk main loop
wm title . "Text with Embedded Code Block"

# Parent Text widget
text .txt -width 60 -height 20 -wrap none
pack .txt -fill both -expand 1

# Sample normal text before the code block
.txt insert end "Here is some normal text before the code block.\n\n"

# Function to insert an embedded code block
proc insert_code_block {content} {
    # Generate a unique tag name
    set tagname "codeblock_[clock clicks]"

    # Insert phony invisible text to occupy space in parent
    set placeholder [string repeat "\u{200B}" [string length $content]]
    .txt insert end $placeholder
    .txt tag add $tagname "insert - [string length $content] chars" "insert"
    .txt tag configure $tagname -foreground white -background white

    # Create child text widget
    text .txt.child -width 50 -height [expr {[llength [split $content "\n"]]}] -wrap none \
        -bg #f0f0f0 -fg black -font {Courier 10} -bd 2 -relief sunken

    .txt window create end -window .txt.child

    # Insert actual code into child
    .txt.child insert end $content

    # Optional: make child readonly
    .txt.child config -state disabled
}

# Insert a sample code block
insert_code_block {
    for {set i 0} {$i < 10} {incr i} {
        puts "Line $i"
    }
}

# More text after code block
.txt insert end "\nAnd here is some text after the code block.\n"

# Bind Ctrl+C to copy selection including child content
bind .txt <Control-c> {
    set sel [.txt get sel.first sel.last]
    clipboard clear
    clipboard append $sel
}
