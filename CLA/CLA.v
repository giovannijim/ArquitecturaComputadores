module RippleCarryAdder16 ();

wire [8:0] C;
wire [7:0] P;
wire [7:0] G;

or (C[1], G[0], P[0] & C[0]); 
or (C[2], G[1], P[1] & C[1]);
or (C[3], G[2], P[2] & C[2]);
or (C[4], G[3], P[3] & C[3]);
or (C[5], G[4], P[4] & C[4]);
or (C[6], G[5], P[5] & C[5]);
or (C[7], G[6], P[6] & C[6]);
or (C[8], G[7], P[7] & C[7]);

endmodule