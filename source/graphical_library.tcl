package require Tk

# --- ------- ---
# --- Globals ---
# --- ------- ---

# god text-element widget, everything within the document is a child of this.
set TE .root.mid.t

# NOTE:
#  Openers / default application management systems are in utter disrepair.
#  With xdg-open it is virtually impossible to catch the correct PID.
#  No proper alternatives exist as of 2025.
#  One suitable candidate would be `handlr`, but is a state of fork wars.
#  Therefor, since its not the responsibility of a MD renderer to handle all that,
#   we are cavemaning it until better days come (hopefully).
proc get_user_command {resource} {
    set video_extensions {mp4 mkv webm}
    set image_extensions {png jpg jpeg gif bmp webp}

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

# NOTE:
#  Similar problems as above.
proc open_url {url} {
    if {[file exists $url] && [string match *.md $url]} {
        catch {exec sternocleoidomastoid "$url" &}
    } else {
        catch {exec $::env(BROWSER) "$url" &}
    }
}

# NOTE:
#  Could be done from C, but Xlib terrifies me.
proc pid2xid {pid} {
    set r ""
    if {![catch {exec xdotool search --pid $pid} out]} {
        set r [lindex [split $out "\n"] 0]
    }
    return $r
}

# NOTE:
#  All embeddings are done at the end so that potential slow processes
#   may not hinder the documentum rendering speed.
#  The required information for this system is stored as followes.
set embedding_queue {}
proc queue_embedding {mark cmd name link} {
    lappend ::embedding_queue "{$mark {$cmd} $name $link}"
}

# NOTE:
#  The reason all embeddings are handled within the same loop,
#   -instead of using a cleaner, per process `after` system-
#   is how Tk handles GUI updates.
#  Namely it would result in ugly race condition bugs where
#   interupts and interupted, and windows don't render.
proc finalize_embeddings {} {
    proc try_embeds {pending_embeddings attempt} {
        proc fallback {mark name link} {
            try {
                set img [image create photo -file $link]
                $::TE image create $mark -image $img
            } on error {err opts} {
                $::TE insert $mark $name placeholder
            }
        }

        set max_attempts 20
        set ms_retry_interval 100

        if {$attempt > $max_attempts} {
            foreach {i} $pending_embeddings {
                foreach {mark pid name link} {*}$i break
                fallback $mark $name $link
            }
            return
        }

        set swap {}
        set ready {}
        foreach {i} $pending_embeddings {
            foreach {mark pid name link} {*}$i break

            if {![is_process_alive $pid]} {
                fallback $mark $name $link
                continue
            }

            set xid [pid2xid $pid]
            if {$xid eq ""} {
                lappend swap "{$mark $pid $name $link}"
            } else {
                lappend ready "{$mark $pid $xid}"
            }
        }
        set pending_embeddings $swap

        foreach {i} $ready {
            foreach {mark pid xid} {*}$i break
            set cursor [new_element_name embedding]

            # XXX magic numbers instead of proper sizing
            frame $cursor -width 400 -height 400
            $::TE window create $mark -window $cursor
            set container_xid [winfo id $cursor]

            update idletasks
            update

            reparent $xid $container_xid
        }

        if {$pending_embeddings eq ""} { return }
        incr attempt
        after $ms_retry_interval [list
            try_embeds $pending_embeddings $attempt
        ]
    }

    set pending_embeddings {}

    foreach {i} $::embedding_queue {
        foreach {mark cmd name link} {*}$i break
        #NOTE: for debugging, use this:
        #set pid [exec {*}$cmd &]
        set pid [exec {*}$cmd >& /dev/null &]
        lappend pending_embeddings "{$mark $pid $name $link}"
    }

    set ::embedding_queue {}

    try_embeds $pending_embeddings 1
}

# produce unique widget names so Tk accepts them
array set element_counter {}
proc new_element_name {type} {
    if {![info exists ::element_counter($type)]} {
        set ::element_counter($type) 0
    }
    incr ::element_counter($type)
    return "$::TE.${type}$::element_counter($type)"
}

# This proc is provided so that overriding the over all fontsize from a userscript is easier.
# One would have to just set $base_font and recall setup_fonts.
set base_font_size 12
proc setup_fonts {} {
    catch { font delete NormalFont     }
    catch { font delete BoldFont       }
    catch { font delete ItalicFont     }
    catch { font delete BoldItalicFont }
    catch { font delete H1Font         }
    catch { font delete H2Font         }
    catch { font delete H3Font         }
    catch { font delete CodeFont       }

    font create NormalFont     -family sans -size $::base_font_size
    font create BoldFont       -family sans -size $::base_font_size -weight bold
    font create ItalicFont     -family sans -size $::base_font_size -slant italic
    font create BoldItalicFont -family sans -size $::base_font_size -weight bold -slant italic
    font create H1Font         -family sans -size [expr $::base_font_size + 10] -weight bold
    font create H2Font         -family sans -size [expr $::base_font_size + 2]  -weight bold
    font create H3Font         -family sans -size $::base_font_size -weight bold
    # NOTE: monospace fonts are usually larger for the same size
    font create CodeFont       -family courier -size [expr $::base_font_size - 4]

    option add *Font NormalFont
}
setup_fonts

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

    $text_element tag configure shadow -elide 1

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

proc finalize_document {} {
    finalize_embeddings
    $::TE configure -state disabled
}

# --- -------- ---
# --- Elements ---
# --- -------- ---
proc append_text {text tags} {
    $::TE insert end $text $tags
}

proc header {level text} {
    append_text "$text\n" h$level
}

proc paragraph_end {} {
    append_text "\n\n" {}
}

proc link {text url} {
    set tag [new_element_name link]

    $::TE tag configure $tag -foreground blue -underline 1
    $::TE tag bind $tag <Button-1> [list open_url $url]
    $::TE insert end $text $tag
}

proc quote {text} {
    set cursor [new_element_name quote]

    set text [string trimright $text " \t\r\n"]
    set newline_count [expr {[llength [split $text "\n"]] - 1}]

    frame $cursor
    $::TE window create end -padx 6 -pady 2 -window $cursor

    canvas $cursor.ribbon \
        -background "#ba0000" \
        -width 10 \
        -highlightthickness 0
    pack $cursor.ribbon -side left -fill y
    
    set cursor $cursor.t
    text $cursor \
        -borderwidth 0 \
        -highlightthickness 0 \
        -height $newline_count
    $cursor insert end $text quote
    pack $cursor

    append_text $text shadow
    append_text "\n" {}
}

proc code {text} {
    set cursor [new_element_name code]

    set text [string trimright $text " \t\r\n"]
    set newline_count [expr {[llength [split $text "\n"]] - 1}]

    text $cursor \
        -wrap none \
        -bg #f0f0f0 \
        -bd 2 \
        -relief sunken \
        -width 80 \
        -height $newline_count
    
    $cursor insert end $text code
    $cursor configure -state disabled
    $::TE window create end -window $cursor

    append_text $text shadow
    append_text "\n" {}
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

    $::TE window create end -window $cursor
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

    set mark [new_element_name mark]
    $::TE mark set $mark insert
    $::TE mark gravity $mark left

    queue_embedding $mark $command $name $link
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

text $::TE \
    -background [. cget -background] \
    -borderwidth 0 \
    -highlightthickness 0 \
    -wrap word \
    -padx 7 \
    -pady 10

setup_tags $::TE

pack $::TE -expand 1 -fill both

bind . <Destroy> {exit}
