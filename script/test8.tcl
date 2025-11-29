package require Tk

text .t -width 60 -height 15 -wrap word
pack .t -fill both -expand 1

# Create fonts
font create CodeFont -family Courier -size 11

# Tag for interior (sand color + monospace)
.t tag configure code \
    -background "#f4e8c4" \
    -font CodeFont

# Outer tag to simulate 1-pixel border
# Use padding and a darker background color as a fake “border”
.t tag configure codeBorder \
    -background "#d2c6a3" \
    -offset 20

# Insert demo text
set start [.t index end]
.t insert end "Here is some code:\n"

set codeStart [.t index end]
.t insert end "   for (i = 0; i < 10; i++) {\n"
.t insert end "       printf(\"%d\\n\", i);\n"
.t insert end "   }\n"
set codeEnd [.t index end]

# Apply tags:
# outer border first, inner code next (so inner overrides inside area)
.t tag add codeBorder $codeStart $codeEnd
.t tag add code        $codeStart $codeEnd
