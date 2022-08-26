# default.copy.do - Redo mixin for copying the result to the clipboard

redo-ifchange "${2}"

xclip -sel clip -l 2 "${2}"
