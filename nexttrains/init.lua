local function get_trip(trip)
  local t_1_ = F.require("data")
  if (nil ~= t_1_) then
    t_1_ = (t_1_).trips
  else
  end
  if (nil ~= t_1_) then
    t_1_ = (t_1_)[trip]
  else
  end
  return t_1_
end
local function print_record(trip, time, dest)
  return string.format("%-10s%4ss\n%-15s\n", trip, time, dest)
end
local function doit(station)
  local ttb = F.require("data.ttb")
  local my_deps = (F.require("data")).deps[station]
  local trips_and_times
  do
    local tbl_15_auto = {}
    local i_16_auto = #tbl_15_auto
    for _, tripcode in pairs(my_deps) do
      local val_17_auto = {trip = tripcode, ["in"] = ttb["time-to-next"](station, tripcode)}
      if (nil ~= val_17_auto) then
        i_16_auto = (i_16_auto + 1)
        do end (tbl_15_auto)[i_16_auto] = val_17_auto
      else
      end
    end
    trips_and_times = tbl_15_auto
  end
  local function _5_(_241, _242)
    return (_241["in"] < _242["in"])
  end
  table.sort(trips_and_times, _5_)
  local function _6_()
    local output = ": Next trains :\n"
    for _, trip in ipairs(trips_and_times) do
      output = (output .. print_record(trip.trip, trip["in"], get_trip(trip.trip).destination))
    end
    return output
  end
  digiline_send("lcd_2",
        string.format("\n\n\n\n  Time:  %s",
                      rwt.to_string(rwt.now(), true)))
  digiline_send("lcd_1", _6_())
end
if (event.on and (event.pin.name == "B")) then
  return doit("Diesemerleve")
else
  return nil
end
