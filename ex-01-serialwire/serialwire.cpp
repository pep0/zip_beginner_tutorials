#include <stdio.h>
#include <stdlib.h>
#include "Vserialwire.h"
#include "verilated.h"

int main(int argc, char **argv) {
	// Call commandArgs first!
	Verilated::commandArgs(argc, argv);

	// Instantiate our design
	Vserialwire *tb = new Vserialwire;

	tb->i_rx = 0;
	for(int k=0; k<20; k++) {
		// We'll set the switch input
		// to the LSB of our counter
		tb->i_rx = k&1;

		tb->eval();

		// Now let's print our results
		printf("k = %2d, ", k);
		printf("rx = %d, ", tb->i_rx);
		printf("tx = %d\n", tb->o_tx);
	}
}
