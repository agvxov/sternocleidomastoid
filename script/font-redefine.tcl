# @BAKE tclsh $@
package require Tk

font create NormalFont -family sans -size 12

text .t
pack .t
.t tag configure normal -font NormalFont

catch { font delete NonrealFont }
catch { font delete NormalFont  }
font create NormalFont -family sans -size 36

.t insert end "My text." normal
