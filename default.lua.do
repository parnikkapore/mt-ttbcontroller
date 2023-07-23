# default.lua.do - a script for compiling Fennel things for advtrains

ORIGINAL="${2}.fnl"

redo-ifchange "${ORIGINAL}"

fennel --no-compiler-sandbox --require-as-include --compile "${ORIGINAL}" |
    sed 's/_G.//g' |
    sed 's/require(/F.require(/g' |
    sed 's/package.preload/F._mods/g' |
    sed '1i\
F._mods = {};\
F._modc = {};\
function F.require(module)\
  if F._modc[module] == nil then\
    F._modc[module] = F._mods[module]()\
  end\
  return F._modc[module]\
end\n' \
    > $3
