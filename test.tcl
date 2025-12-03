# @BAKE tclsh $@
package require Tk

proc pid2xid {pid} {
    set r ""
    if {![catch {exec xdotool search --pid $pid} out]} {
        set r [lindex [split $out "\n"] 0]
    }
    return $r
}

pack [frame .video_frame -width 640 -height 480]

update idletasks
update

set container_xid [winfo id .video_frame]
puts "Container XID: $container_xid"

#set pid [exec nomacs image.png &]
#set pid [exec mpv video.mp4 &]
set pid [exec obs &]
after 3000
set xid [pid2xid $pid]
puts "XID: $xid"

reparent $xid $container_xid

puts --
