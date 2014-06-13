set outfile [open sasa.dat w]
 set nf [molinfo top get numframes] 
# set all [atomselect top "resid 140 to 180 or resid 50 to 84"] 
# set all [atomselect top "all"] 
 set sel [atomselect top "all"] 
 for {set i 0} {$i < $nf} {incr i} { 
    $sel frame $i 
    set sasa [measure sasa 1.4 $sel] 
   puts $sasa 
   puts $outfile "$sasa"
            puts "Done"
 }
