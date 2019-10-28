`include "config.v"

module BRANCH_PREDICTOR (
    // general inputs
    input CLK,
    input RESET,
    input STALL,

    // IF inputs
    input [31:0] IF_PC,
    input [31:0] IF_Instr,

    // ID inputs
    input [31:0] ID_PC,
    input Is_Jump_Link,
    input Is_Branch,
    input Is_Taken,

    // outputs
    output reg flush,
    output reg take,
    output reg [31:0] alt_address
    );
