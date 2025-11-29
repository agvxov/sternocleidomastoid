# @BAKE tclsh $@
package require Tk

pack [frame .video_frame -width 640 -height 480]

update idletasks
update

set xid [winfo id .video_frame]
puts "Container XID: $xid"

exec sh -c "mpv --wid=$xid video.mp4 &"
