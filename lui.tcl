package require Tk

# --- ------- ---
# --- Globals ---
# --- ------- ---
set imageviewer $env(IMAGEVIEWER)
set videoplayer $env(VIDEOPLAYER)

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

proc embed_application {cmd arg} {
    set cursor [new_element_name embedding]

    frame $cursor -width 640 -height 480

    update idletasks
    update

    set xid [winfo id $cursor]

    # XXX
    exec sh -c "mpv --wid=$xid video.mp4 &"
}

proc md_image {name link} {
    #if {$imageviewer ne ""} {
    #    embed_application $imageviewer $link
    #}

    if {[catch {image create photo -file $link} img]} {
        placeholder $name
        return
    }

    .root.mid.t image create end -image $img
}

proc md_video {name link} {
    if {$videoplayer ne ""} {
        embed_application $videoplayer $link
    } else {
        placeholder $name
    }
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
