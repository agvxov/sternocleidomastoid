# @BAKE tclsh $@
package require Tk

pack [text .t -width 100 -height 100]
frame .t.video_frame -width 640 -height 480
.t window create end -window .t.video_frame

update idletasks
update

set xid [winfo id .t.video_frame]
puts "Container XID: $xid"

exec sh -c "mpv --wid=$xid video.mp4 &"
