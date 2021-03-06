# Written by Lazemare.
# Used to calculate the distribution alone the simulation trajectory of
# the distance between two structures (for example, two residues), and 
# give out the distribution percentage. The parameter tau is the number
# of data points between the largest length and the shortest length. The
# bigger this value is, the higher resolution you will have.
# If the curve generated from this script is too rugged, it means that 
# maybe you have chosen a too large tau, or have too little frames.
# Then you could try to change the value of tau to generate a series of 
# more smooth data, with lower resolution.  
#--------------------------------------------------- 
# Here are the paras:
set outfile [open distance_distribution.dat w]
set select1 "protein and resid 1"
set select2 "protein and resid 10"
set tau 100
#---------------------------------------------------
set nf [molinfo top get numframes]
set sel1 [atomselect top "$select1"]
set sel2 [atomselect top "$select2"]
set maxdis 0.0
set mindis 1E100
for { set i 1 } { $i <= $nf } { incr i } {  
	$sel1 frame $i
	set V1 [measure center "$sel1"]
	$sel2 frame $i
	set V2 [measure center "$sel2"]
	set VA [vecsub $V1 $V2]
	set DISTA [veclength $VA]
    if {$DISTA > $maxdis} {
        set maxdis $DISTA
    }
    if {$DISTA < $mindis} {
        set mindis $DISTA
    }
}
set npoints [expr int(floor([expr $maxdis * $tau] - [expr $mindis * $tau])) + 1]
for { set i 0 } { $i < $npoints } { incr i } {    
	set density($i) 0.0
}
for { set i 1 } { $i <= $nf } { incr i } {  
	$sel1 frame $i
	set V1 [measure center "$sel1"]
	$sel2 frame $i
	set V2 [measure center "$sel2"]
	set VA [vecsub $V1 $V2]
	set DISTA [veclength $VA]
	set index [expr int(floor([expr ($DISTA - $mindis) * $tau]))]
	set density($index) [expr $density($index) + 1.0]
}
for { set i 0 } { $i < $npoints } { incr i } {    
	set density($i) [expr $density($i) / $nf * 100]
	puts -nonewline $outfile "[expr $mindis + $i / ($tau * 1.0)]"
	puts -nonewline $outfile " "
	puts $outfile "[expr $density($i)]"
}
close $outfile
puts "All Done!"
