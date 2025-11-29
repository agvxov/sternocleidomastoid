# @BAKE tclsh $@
source "lui.tcl"
header 1 {An h1 header}
paragraph
paragraph
$::cursor insert end {2nd paragraph,
with inline formatting } {}
$::cursor insert end {2nd paragraph,
with inline formatting italic} {italic }
$::cursor insert end {2nd paragraph,
with inline formatting italic, } {}
$::cursor insert end {2nd paragraph,
with inline formatting italic, } {bold }
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold} {bolditalic }
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold} {italic }
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold, } {}
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold, } {bold }
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold, } {}
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold, both} {italic }
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold, both} {bolditalic }
$::cursor insert end {2nd paragraph,
with inline formatting italic, bold, both} {italic }
paragraph
list_item 1 {* this one}
list_item 1 {* that one}
list_item 1 {* the other one}
quote {Block quotes are written like so.
> They can span multiple paragraphs, if you like.}
paragraph
horizontal_line
header 2 {An h2 header}
paragraph
list_item 1 {1. first item}
list_item 1 {2. second item}
list_item 2 {1. with some nesting}
list_item 2 {2. etc}
list_item 1 {3. third item}
list_item 0 {0. Here's a code sample:}
code {As you probably guessed, indented 4 spaces.
By the way, instead of indenting the block, you can use fenced code blocks, if you like:}
