`include "config.v"

module BRANCH_PREDICTOR (
    // general inputs
    input CLK,
    input RESET,
    input STALL,

    // IF inputs
    input IF_PC,
    input IF_Instr,

    // ID inputs
    input ID_PC,
    input is_Jump_Link,
    input is_Branch,
    input is_Taken,

    // outputs
    output reg take,
    output reg [31:0] alt_address
    );
