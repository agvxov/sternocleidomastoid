package require Tk

# --- ------- ---
# --- Globals ---
# --- ------- ---

# NOTE:
#  Openers / default application management systems are in utter disrepair.
#  With xdg-open it is virtually impossible to catch the correct PID.
#  No proper alternatives exist as of 2025.
#  One suitable candidate would be `handlr`, but is a state of fork wars.
#  Therefor, since its not the responsibility of a MD renderer to handle all that,
#   we are cavemaning it until better days come (hopefully).
proc get_user_command {resource} {
    set video_extensions {mp4}
    set image_extensions {png jpg gif}

    set ext [string trimleft [file extension $resource] .]

    if {[info exists ::env(VIDEOPLAYER)]
    &&  [lsearch -exact $video_extensions $ext] != -1} {
        return "$::env(VIDEOPLAYER) $resource"
    }

    if {[info exists ::env(IMAGEVIEWER)]
    &&  [lsearch -exact $image_extensions $ext] != -1} {
        return "$::env(IMAGEVIEWER) $resource"
    }

    return ""
}

proc open_url {url} {
    [catch {exec xdg-open "$url" &}]
}

proc pid2xid {pid} {
    set r ""
    if {![catch {exec xdotool search --pid $pid} out]} {
        set r [lindex [split $out "\n"] 0]
    }
    return $r
}

set embedding_queue {}
proc queue_embedding {e cmd name link} {
    lappend ::embedding_queue "{$e {$cmd} $name $link}"
}


proc embed_application {e cmd name link} {
    proc fallback {name link} {
        try {
            set img [image create photo -file $link]
            .root.mid.t image create end -image $img
        } on error {err opts} {
            placeholder $name
        }
    }
    proc try_reparent {e pid container_xid attempt name link} {
        set max_attempts 20

        if {$attempt > $max_attempts} {
            fallback $name $link
            return
        }

        set xid [pid2xid $pid]

        if {$xid eq ""} {
            incr attempt
            after 100 [list try_reparent $e $pid $container_xid $attempt $name $link]
            return
        }

        reparent $xid $container_xid
    }

    set container_xid [winfo id $e]
    set pid [exec {*}$cmd &]

    try_reparent $e $pid $container_xid 1 $name $link
}


proc finalize_embeddings {} {
    update idletasks
    update

    foreach {i} $::embedding_queue {
        foreach {e cmd name link} {*}$i break
        embed_application $e $cmd $name $link
        puts $cmd
    }

    set ::embedding_queue {}
}

# produce unique widget names so Tk accepts them
array set element_counter {}
proc new_element_name {type} {
    if {![info exists ::element_counter($type)]} {
        set ::element_counter($type) 0
    }
    incr ::element_counter($type)
    return ".root.mid.t.${type}$::element_counter($type)"
}

# inline formatting
font create NormalFont     -family sans -size 12
font create BoldFont       -family sans -size 12 -weight bold
font create ItalicFont     -family sans -size 12 -slant italic
font create BoldItalicFont -family sans -size 12 -weight bold -slant italic
font create H1Font         -family sans -size 22 -weight bold
font create H2Font         -family sans -size 16 -weight bold
font create H3Font         -family sans -size 12 -weight bold
font create CodeFont       -family courier -size 11

proc setup_tags {text_element} {
    $text_element tag configure h1         -font H1Font
    $text_element tag configure h2         -font H2Font
    $text_element tag configure h3         -font H3Font

    $text_element tag configure bold       -font BoldFont
    $text_element tag configure italic     -font ItalicFont
    $text_element tag configure bolditalic -font BoldItalicFont
    $text_element tag configure strike     -overstrike 1

    $text_element tag configure code -font CodeFont -background "#f4e8c4"

    $text_element tag configure placeholder -font CodeFont -background red

    $text_element tag configure quote \
        -lmargin1 16  \
        -lmargin2 16  \
        -rmargin 10   \
        -spacing1 4   \
        -spacing3 4
    $text_element tag configure quote_stripe \
        -lmargin1 0 \
        -lmargin2 0
}

# formatting settings
set header_font_size 16

proc finalize_document {} {
    .root.mid.t configure -state disabled

    finalize_embeddings
}

# --- -------- ---
# --- Elements ---
# --- -------- ---
proc append_text {text tags} {
    .root.mid.t insert end $text $tags
}

proc header {level text} {
    append_text "$text\n" h$level
}

proc paragraph_end {} {
    append_text "\n\n" {}
}

proc quote {text} {
    set cursor [new_element_name quote]

    frame $cursor -width 4 -background "#ba0000" -height 1

    .root.mid.t window create end -window $cursor; # -padx {6 6} -pady 2 -align center

    append_text "$text\n" quote
}

proc link {text url} {
    set ::cursor [new_element_name link]

    label $::cursor -text $text -wraplength 600 -justify left -fg blue -underline 1
    pack  $::cursor -side top -anchor w -padx 4 -pady 2
    bind  $::cursor <Button-1> [list open_url $url]
}

proc code {text} {
    set cursor [new_element_name code]

    #set lines [llength [split $text "\n"]]
    #if {$lines < 1} { set lines 1 }
    #text $::cursor -wrap none -height $lines -borderwidth 1 -relief sunken -font TkFixedFont
    #pack $::cursor -side top -anchor w -padx 6 -pady 4
    #$::cursor insert end $text
    #$::cursor configure -state disabled

    set newline_count [expr {[llength [split $text "\n"]] - 1}]

    text $cursor -height $newline_count
    
    $cursor tag configure code -font CodeFont -background "#f4e8c4"
    $cursor insert end $text code
    $cursor configure -state disabled

    .root.mid.t window create end -window $cursor
}

proc list_item {level text} {
    set indent [expr $level * 4]

    append_text "[string repeat " " $indent]$text\n" {}
}

proc horizontal_line {} {
    set cursor [new_element_name horizontal_line]

    frame $cursor \
        -height 2 \
        -width 200 \
        -background "#000000" \
        -borderwidth 0 \
        -highlightthickness 0

    .root.mid.t window create end -window $cursor
    append_text "\n\n" {}
}

proc placeholder {target} {
    append_text $target "placeholder"
}

proc media {name link} {
    set command [get_user_command $link]

    if {$command eq ""} {
        placeholder $name
        return
    }

    set cursor [new_element_name embedding]

    frame $cursor -width 400 -height 400
    .root.mid.t window create end -window $cursor

    queue_embedding $cursor $command $name $link
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
#pack propagate .mod 0

text .root.mid.t \
    -background [. cget -background] \
    -borderwidth 0 \
    -highlightthickness 0 \
    -wrap word \
    -padx 7 \
    -pady 10

setup_tags .root.mid.t

pack .root.mid.t -expand 1 -fill both

bind . <Destroy> {exit}
