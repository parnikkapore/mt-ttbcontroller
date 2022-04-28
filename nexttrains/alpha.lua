function printRecord(trip,time,dest,invalid)
    local destChopped
    if string.len(dest) <= 16 or invalid then
        destChopped = dest
    else
        local destChopTick = ticks % (string.len(dest) - 15 + 4) + 1
        destChopped = string.sub("  " .. dest, destChopTick)
    end
    local time = invalid and "-" or time

    return string.format("%3.3s %-5.5s %-.16s\n", time, trip, destChopped)
end

if event.int and event.msg.type=="update" and event.msg.count<=7 then
    ticks = (ticks or -1) + 1
    local i = event.msg.count > 6
    digiline_send("allnext_long",
                  string.format("From this station %8.8s\n",
                   i and "" or rwt.to_string(rwt.now(), true)) ..
                  printRecord("L107","12s","Ikceok",i) ..
                  printRecord("R103","58s","Omenutleikque",i) .. 
                  printRecord("L888a","8m","Langcottonspringwoodcester",i))
    if i then ticks = -1 end
    clear_interrupts()
    interrupt(0.5, {type="update", count=event.msg.count + 1})
elseif (event.on or event.off) and event.pin.name=="D" then
    clear_interrupts()
    interrupt(0, {type="update", count=1})
end
