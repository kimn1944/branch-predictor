//Added during project 1
`define HAS_FORWARDING
`define INCLUDE_IF_CONTENT
`define HAS_WRITEBACK
`define INCLUDE_MEM_CONTENT

`ifdef HAS_FORWARDING
//Add files after project 1:
//  RegValue1.v
//  RegValue2.v
//  RegValue3.v
`endif

//Added during project 2 (usually removed for project 3; may be re-added for project 4)
//`define SUPERSCALAR

//Added during project 3
`define USE_ICACHE
`define USE_DCACHE

//Added before project 4 starts
//`define OUT_OF_ORDER

// printing defines
// `define FSM_PRINT
// `define GBP_PRINT
// `define LBP_PRINT
// `define BTB_PRINT
// `define RAS_PRINT
// `define STACK_PRINT
// `define META_PRINT
// `define BP_PRINT
// `define BP_STAT
