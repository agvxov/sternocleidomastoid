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
    if {![info exists ::element_counter($type)]} {
        set ::element_counter($type) 0
    }
    incr ::element_counter($type)
    return ".root.mid.${type}$::element_counter($type)"
}

# inline formatting
font create NormalFont     -family sans -size 12
font create BoldFont       -family sans -size 12 -weight bold
font create ItalicFont     -family sans -size 12 -slant italic
font create BoldItalicFont -family sans -size 12 -weight bold -slant italic

# the latest widget; used for appending
set cursor {}

# formatting settings
set header_font_size 16

# --- -------- ---
# --- Elements ---
# --- -------- ---
proc header {level text} {
    set ::cursor [new_element_name header]

    set font_size [expr {$::header_font_size - $level*2}]
    if {$font_size < 8} { set font_size 8 }

    label $::cursor -text $text -font "TkDefaultFont $font_size bold"
    pack $::cursor -side top -anchor w -padx 4 -pady 4
}

#proc paragraph {text} {
proc paragraph {} {
    set ::cursor [new_element_name paragraph]

    text $::cursor \
        -background [. cget -background] \
        -borderwidth 0 \
        -highlightthickness 0 \
        -wrap word \
        -padx 0 \
        -pady 0 \
        -height 3
    # XXX height is fucked; it takes up exacty as much space as specified
    #      instead of what is required, meaning text is either cropped or the
    #      widget is too big. not specifying it apparently uses some large default

    # XXX disables algorithmic editting too
    #$::cursor configure -state disabled

    $::cursor tag configure bold       -font BoldFont
    $::cursor tag configure italic     -font ItalicFont
    $::cursor tag configure bolditalic -font BoldItalicFont
    $::cursor tag configure strike     -overstrike 1

    pack $::cursor -side top -anchor w -padx 4 -pady 2
}

proc quote {text} {
    set ::cursor [new_element_name quote]

    frame $::cursor -relief flat -padx 6 -pady 2
    pack  $::cursor -side top -anchor w -padx 6 -pady 2
    frame $::cursor.stripe -width 4 -height 1 -background #ba0000
    pack  $::cursor.stripe -in $::cursor -side left -padx {0 6} -pady 2 -fill y
    label $::cursor.lbl -text $text -wraplength 560 -justify left
    pack  $::cursor.lbl -in $::cursor -side left -fill x -expand 1 -padx 4

    # XXX set ::cursor accuretly
}

proc link {text url} {
    set ::cursor [new_element_name link]

    label $::cursor -text $text -wraplength 600 -justify left -fg blue -underline 1
    pack  $::cursor -side top -anchor w -padx 4 -pady 2
    bind  $::cursor <Button-1> [list open_url $url]
}

proc code {text} {
    set ::cursor [new_element_name code]

    set lines [llength [split $text "\n"]]
    if {$lines < 1} { set lines 1 }
    text $::cursor -wrap none -height $lines -borderwidth 1 -relief sunken -font TkFixedFont
    pack $::cursor -side top -anchor w -padx 6 -pady 4
    $::cursor insert end $text
    $::cursor configure -state disabled
}

proc list_item {level text} {
    set ::cursor [new_element_name list]

    if {![string is integer -strict $level]} { set level 0 }
    set indent [expr {($level + 1) * 20}]

    frame $::cursor -relief flat -padx $indent
    pack  $::cursor -side top -anchor w -padx 4 -pady 1
    label $::cursor.lbl -text $text -wraplength [expr {600 - $indent}] -justify left
    pack  $::cursor.lbl -in $::cursor -side left -expand 1 -padx 4

    # XXX set ::cursor accuretly
}

proc horizontal_line {} {
    set ::cursor [new_element_name horizontal_line]

    frame $::cursor \
        -height 2 \
        -background "#808080" \
        -borderwidth 0 \
        -highlightthickness 0

    pack $::cursor -side top -fill x -padx 20 -pady 6
}

# --- ---- ---
# --- Exec ---
# --- ---- ---
wm title . "Markdown-GUI"
. configure -background #ffffff

pack [frame .root -padx 0 -pady 0] -fill both -expand 1

label .root.left
label .root.right
frame .root.mid
.root.mid configure -background #ffffff

grid .root.left .root.mid .root.right -sticky news

grid columnconfigure .root 0 -weight 1
grid columnconfigure .root 1 -weight 8
grid columnconfigure .root 2 -weight 1

grid rowconfigure .root 0 -weight 1

bind . <Destroy> {exit}
