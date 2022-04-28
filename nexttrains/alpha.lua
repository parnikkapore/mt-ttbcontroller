function printRecord(trip,time,dest)
    return string.format("%-10s%4ss\n%-15s\n", trip, time, dest)
end

if event.on and event.pin.name=="B" then
    digiline_send("lcd_2",
        string.format("\n\n\n\n  Time:  %s",
                      rwt.to_string(rwt.now(), true)))
    digiline_send("lcd_1",
                  ": Trains test :\n" ..
                  printRecord("L107", 12,"Ikceok") ..
                  printRecord("R103", 63,"Parisem") .. 
                  printRecord("L888",888,"Langcottonspringwoodcester"))
end
