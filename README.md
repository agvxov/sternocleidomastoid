# Sternocleidomastoid
> The lightweight Markdown viewer

Sternocleidomastoid is a local Markdown renderer.

### Notes
Parsing is handled by tree-sitter-markdown.
Tree-sitter-markdown -shortly put- is not great
and results in a number of limitations.
If there were a better TS grammar, I would use it.

The GUI uses Tcl/Tk.
Since its all scripting, there is no limit to the available customization.

Media, namely images and videos are rendered using embedded windows.
This divinely UNIX way of handling the question requires X11.
