#! /usr/bin/make
# Build script for the advtrains timetable system (Make version)

FENNEL := fennel
BUILD_DIR := ./build
SRC_DIR := .

ATLATC_GLOBALS := \
string,math,table,os,$\
assert,error,ipairs,pairs,next,select,tonumber,tostring,type,unpack,$\
POS,getstate,setstate,is_passive,$\
interrupt,interrupt_safe,interrupt_pos,clear_interrupts,$\
atc_send_to_train,$\
rwt,schedule,schedule_in,$\
digiline_send,$\
can_set_route,set_route,cancel_route,get_aspect,$\
atc_send,atc_reset,$\
atc_set_text_outside,atc_set_text_inside,$\
atc_get_text_outside,atc_get_text_inside,$\
get_line,set_line,get_rc,set_rc,train_length,set_shunt,$\
atc_set_ars_disable,atc_set_lzb_tsr,set_autocouple,unset_autocouple,$\
atc_id,atc_speed,atc_arrow

# Rules which aren't named after files
.PHONY: default all clean

# This name isn't special - what makes it the default is the fact that it's the
# first rule in the file
default: main.lua

all: $(BUILD_DIR)/init.lua $(BUILD_DIR)/require-test.lua

# Template for building Fennel scripts
$(BUILD_DIR)/%.lua: $(SRC_DIR)/%.fnl
	@# create containing directory
	mkdir -p $(dir $@)
	@# Compile the script, embedding includes
	@# then use sed to add require shim and remove use of _G
	@echo "Compiling $<..."
	@$(FENNEL) --no-compiler-sandbox --require-as-include --compile $< \
	| sed 's/_G.//g' \
	| sed 's/require(/F.require(/g' \
	| sed 's/package.preload/F._mods/g' \
	| sed '1i\
F._mods = F._mods or {};\
F._modc = F._modc or {};\
function F.require(module)\
  if F._modc[module] == nil then\
    F._modc[module] = F._mods[module]()\
  end\
  return F._modc[module]\
end\n' \
	> $@

# Convenience
# Also copies the compiled script to the clipboard for a quick paste into the atlatc dialog
%.lua: $(BUILD_DIR)/%.lua
	xclip -sel clip $<

clean:
	rm -rv $(BUILD_DIR)
