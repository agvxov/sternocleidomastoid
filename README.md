# Sternocleidomastoid
> The lightweight Markdown viewer

Sternocleidomastoid is a local Markdown renderer.

### Configuration
#### GUI
The GUI uses Tcl/Tk.
Since its all scripting, there is no limit to the available customization.

There is a default GUI script embedded into the application,
which can be printed with the `--dump-script option`.
Due to the nature of Tcl, any function can be arbitrarily overwritten,
given a user script which can be specified as detailed below.

#### Environment
Miscellaneous configuration options are all handled throught environment variables.
This is the ***correct*** way of handling a small number of configuration options,
in contrast to littering the user's home directory
and or pulling in a yaml dependency to store a single number on disk,
but I digress.

Available variables:
* `VIDEOPLAYER` is the preferred video player (+args) of the user
* `IMAGEVIEWER` is the preferred image viewer (+args) of the user
* `STERNOCLEIDOMASTOID_GRAPHICAL_USER_INTERFACE_SCRIPT` user Tcl script

### Notes
Parsing is handled by tree-sitter-markdown.
Tree-sitter-markdown -shortly put- is not great
and results in a number of limitations.
If there were a better TS grammar, I would use it.

Media, namely images and videos are rendered using embedded windows.
This divinely UNIX way of handling the question requires X11.

![regarding_the_name](documentation/name.png)
