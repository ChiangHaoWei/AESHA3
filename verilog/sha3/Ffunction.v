module Ffunction (
    in,out,round
);
    input [1599:0] in;
    input [4:0] round;
    output [1599:0] out;
    wire [1599:0] theta_out,rho_out,pi_out,chi_out;
    Theta t0(.in(in),.out(theta_out));
    Rho rho0(.in(theta_out),.out(rho_out));
    Pi pi(.in(rho_out),.out(pi_out));
    Chi c0(.in(pi_out),.out(chi_out));
    Iota i0(.in(chi_out),.out(out),.round(round));

endmodule