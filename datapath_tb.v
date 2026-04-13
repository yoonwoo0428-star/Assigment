`timescale 1ns / 1ps

//------------------------------------------------------------------------------
// Datapath Testbench
//
// Test Program (memfile.dat):
//   20080007 - addi $t0, $zero, 7    -> $t0 = 7
//   20090003 - addi $t1, $zero, 3    -> $t1 = 3
//   01095022 - sub  $t2, $t0, $t1    -> $t2 = 7 - 3 = 4
//------------------------------------------------------------------------------

module datapath_tb;

    //--------------------------------------------------------------------------
    // Signal Declarations
    //--------------------------------------------------------------------------

    // Clock and Reset
    reg clk;
    reg rst_n;

    // Control Signals (manually provided in this testbench)
    reg reg_write_en;
    reg reg_dst;
    reg alu_src;
    reg [2:0] alu_ctrl;
    reg mem_write_en;
    reg mem_to_reg;

    // Output Signals
    wire [31:0] pc_out;
    wire [31:0] alu_result;

    //--------------------------------------------------------------------------
    // Device Under Test (DUT) Instantiation
    //--------------------------------------------------------------------------

    datapath uut (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_en(reg_write_en),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .mem_write_en(mem_write_en),
        .mem_to_reg(mem_to_reg),
        .pc_out(pc_out),
        .alu_result(alu_result)
    );

    //--------------------------------------------------------------------------
    // Clock Generation: 10ns period
    //--------------------------------------------------------------------------

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //--------------------------------------------------------------------------
    // Waveform Dump for GTKWave
    //--------------------------------------------------------------------------

    initial begin
        $dumpfile("datapath.vcd");
        $dumpvars(0, datapath_tb);
    end

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------

    initial begin
        // Initialize all signals
        rst_n        = 0;
        reg_write_en = 0;
        reg_dst      = 0;
        alu_src      = 0;
        alu_ctrl     = 3'b000;
        mem_write_en = 0;
        mem_to_reg   = 0;

        // Reset
        #10;
        rst_n = 1;
        $display("--- Start Simulation ---");

        //--------------------------------------------------------------------------
        // Instruction 1: addi $t0, $zero, 7
        // memfile: 20080007
        // Control:
        //   reg_write_en = 1
        //   alu_src      = 1   (immediate)
        //   alu_ctrl     = 010 (ADD)
        //   reg_dst      = 0   (rt)
        //--------------------------------------------------------------------------
        reg_write_en = 1;
        reg_dst      = 0;
        alu_src      = 1;
        alu_ctrl     = 3'b010;
        mem_write_en = 0;
        mem_to_reg   = 0;

        @(posedge clk);
        #1;
        $display("Instr1: addi $t0, $zero, 7  | PC = %h | ALU Result = %0d", pc_out, alu_result);

        //--------------------------------------------------------------------------
        // Instruction 2: addi $t1, $zero, 3
        // memfile: 20090003
        // Control:
        //   reg_write_en = 1
        //   alu_src      = 1   (immediate)
        //   alu_ctrl     = 010 (ADD)
        //   reg_dst      = 0   (rt)
        //--------------------------------------------------------------------------
        reg_write_en = 1;
        reg_dst      = 0;
        alu_src      = 1;
        alu_ctrl     = 3'b010;
        mem_write_en = 0;
        mem_to_reg   = 0;

        @(posedge clk);
        #1;
        $display("Instr2: addi $t1, $zero, 3  | PC = %h | ALU Result = %0d", pc_out, alu_result);

        //--------------------------------------------------------------------------
        // Instruction 3: sub $t2, $t0, $t1
        // memfile: 01095022
        // Control:
        //   reg_write_en = 1
        //   alu_src      = 0   (register)
        //   alu_ctrl     = 110 (SUB)
        //   reg_dst      = 1   (rd)
        //--------------------------------------------------------------------------
        reg_write_en = 1;
        reg_dst      = 1;
        alu_src      = 0;
        alu_ctrl     = 3'b110;
        mem_write_en = 0;
        mem_to_reg   = 0;

        @(posedge clk);
        #1;
        $display("Instr3: sub  $t2, $t0, $t1  | PC = %h | ALU Result = %0d", pc_out, alu_result);

        $display("--- Expected Final Result ---");
        $display("$t0 = 7");
        $display("$t1 = 3");
        $display("$t2 = 4");

        // Finish immediately after 3 instructions
        #5;
        $finish;
    end

endmodule