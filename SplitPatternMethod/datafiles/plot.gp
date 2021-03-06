set term postscript color
set out "Barrier.ps"
set title "Step Potential"
set xlabel "x grid"
set ylabel "potential"

do for [i=1:50] {
	if (i > 9) {
		filename = sprintf("psi%d.",10*i)
	} else {
		filename = sprintf("psi %d.",10*i)
	}
	SlideTitle = sprintf("Timestep : %d",10*i)
	plot [-2:2] [-4:4] filename u 1:2 title SlideTitle w l,"potential.txt" u 1:2 title "barrier" w l
}



