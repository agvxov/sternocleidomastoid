package require Tk

# --- ------- ---
# --- Globals ---
# --- ------- ---
# XXX modify to use environment variable
proc open_url {url} {
    # try common commands; ignore failures
    if {[catch {exec xdg-open -- "$url" &}]} {
        if {[catch {exec open "$url" &}]} {
            # windows: use cmd /c start "" "url"
            catch {exec cmd /C start \"\" \"$url\"}
        }
    }
}

# produce unique widget names so Tk accepts them
array set element_counter {}
proc new_element_name {type} {
    variable ::element_counter
    if {![info exists element_counter($type)]} {
        set element_counter($type) 0
    }
    incr element_counter($type)
    return "${type}$element_counter($type)"
}

# for inline formatting
font create NormalFont -family sans -size 12
font create BoldFont   -family sans -size 12 -weight bold
set cursor {}

# --- -------- ---
# --- Elements ---
# --- -------- ---
proc header {level text} {
    set name [new_element_name header]

    set base_size 16
    set font_size [expr {$base_size - $level*2}]
    if {$font_size < 8} { set font_size 8 }

    label .$name -text $text -font "TkDefaultFont $font_size bold"

    pack .$name -side top -anchor w -padx 4 -pady 4
}

# XXX probably prepend the dot directly into the name
proc paragraph {text} {
    set name [new_element_name paragraph]
    #label .$name -text $text -wraplength 600 -justify left
    text .$name -wrap word
    .$name tag configure bold -font BoldFont
    pack .$name -side top -anchor w -padx 4 -pady 2
    set cursor .$name
}

proc quote {text} {
    set name [new_element_name quote]
    frame .$name -relief flat -padx 6 -pady 2
    pack .$name -side top -anchor w -padx 6 -pady 2
    label .$name.lbl -text $text -wraplength 560 -justify left
    pack .$name.lbl -in .$name -side left -fill x -expand 1 -padx 4
    frame .$name.stripe -width 4 -height 1 -background #ba0000
    pack .$name.stripe -in .$name -side left -padx {0 6} -pady 2 -fill y
}

proc link {text url} {
    set name [new_element_name link]
    label .$name -text $text -wraplength 600 -justify left -fg blue -underline 1
    pack .$name -side top -anchor w -padx 4 -pady 2
    bind .$name <Button-1> [list open_url $url]
}

proc code {text} {
    set name [new_element_name code]
    set lines [llength [split $text "\n"]]
    if {$lines < 1} { set lines 1 }
    text .$name -wrap none -height $lines -borderwidth 1 -relief sunken -font TkFixedFont
    pack .$name -side top -anchor w -padx 6 -pady 4
    .$name insert end $text
    .$name configure -state disabled
}

proc list_item {level text} {
    set name [new_element_name list]
    # normalize level (min 1)
    if {![string is integer -strict $level]} { set level 0 }
    set indent [expr {($level + 1) * 20}]
    frame .$name -relief flat -padx $indent
    pack .$name -side top -anchor w -padx 4 -pady 1
    # show the raw input text (marker embedded in text as requested)
    label .$name.lbl -text $text -wraplength [expr {600 - $indent}] -justify left
    pack .$name.lbl -in .$name -side left -expand 1 -padx 4
}

proc horizontal_line {} {
    set name [new_element_name horizontal_line]
    ttk::separator .$name -orient horizontal
    pack .$name -side top -fill x -pady 6
}

# --- ---- ---
# --- Exec ---
# --- ---- ---
wm title . "Markdown-GUI"

bind . <Destroy> {exit}
