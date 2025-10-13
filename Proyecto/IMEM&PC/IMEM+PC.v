// ================================================
//  Universidad del Valle de Guatemala
//  Arquitectura de computadores, sección 10
//  Giovanni Jimenez 22469
//  Ever Yes 22510
//  IMEM + PROGRAM COUNTER
// ================================================


`timescale 1ns/1ps
// ===================================================
//  Módulo: PC (Program Counter)
// ===================================================
module PC (
    input  wire        clk,
    input  wire        reset,          // reset asíncrono
    input  wire [31:0] next_pc,
    output reg  [31:0] current_pc
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_pc <= 32'd0;
        else
            current_pc <= next_pc;
    end
endmodule

// ===================================================
//  Módulo: IMEM de 16 WORDS
//  Dirección en bytes → índice de palabra = addr[5:2]
// ===================================================
module IMEM (
    input  wire [31:0] addr,
    output wire [31:0] instruction
);
    reg [31:0] memory [0:15];

    // Instrucciones de ejemplo
    initial begin
        // 0: ADD  $3, $1, $2
        memory[0] = 32'b000000_00001_00010_00011_00000_100000;
        // 1: ADDI $9, $8, 10
        memory[1] = 32'b001000_01000_01001_0000000000001010;
        // 2: AND  $5, $3, $4
        memory[2] = 32'b000000_00011_00100_00101_00000_100100;
        // 3: OR   $6, $3, $4
        memory[3] = 32'b000000_00011_00100_00110_00000_100101;
        // 4: SLT  $7, $1, $2
        memory[4] = 32'b000000_00001_00010_00111_00000_101010;
        // 5: LW   $10, 4($9)
        memory[5] = 32'b100011_01001_01010_0000000000000100;
        // 6: SW   $10, 8($9)
        memory[6] = 32'b101011_01001_01010_0000000000001000;
        // 7: BEQ  $1, $2, 3
        memory[7] = 32'b000100_00001_00010_0000000000000011;
        // 8: ADDI $8, $0, 255
        memory[8] = 32'b001000_00000_01000_0000000011111111;
        // 9: ORI  $11, $8, 0x00AA
        memory[9] = 32'b001101_01000_01011_0000000010101010;

        memory[10] = 32'h00000000;
        memory[11] = 32'h00000000;
        memory[12] = 32'h00000000;
        memory[13] = 32'h00000000;
        memory[14] = 32'h00000000;
        memory[15] = 32'h00000000;
    end

    assign instruction = memory[addr[5:2]];
endmodule


// ===================================================
//  Testbench: Integración PC + IMEM
// ===================================================
module testbench;
    // ================================================
    // 1) DECLARACIÓN DE SEÑALES
    // ================================================
    reg         clk;
    reg         reset;
    reg  [31:0] next_pc;
    wire [31:0] current_pc;
    wire [31:0] instruction;

    // Campos para decodificación
    reg  [5:0]  opcode;
    reg  [4:0]  rs, rt, rd, shamt;
    reg  [5:0]  funct;
    reg  [15:0] imm;

    integer ciclo;

    // Parámetro: paso del PC (4 bytes por instrucción)
    localparam STEP = 32'd4;

    // ================================================
    // 2) INSTANCIACIÓN DE DUTs (PC + IMEM)
    // ================================================
    PC   u_pc   (.clk(clk), .reset(reset), .next_pc(next_pc), .current_pc(current_pc));
    IMEM u_imem (.addr(current_pc), .instruction(instruction));

    // ================================================
    // 3) ESTÍMULOS, RELOJ Y MONITOREO
    // ================================================
    // Reloj 100 MHz
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Contador de ciclos
    initial ciclo = 0;
    always @(posedge clk) ciclo <= ciclo + 1;

    // Avance automático del PC: cambiar next_pc lejos del posedge
    always @(negedge clk) begin
        if (reset)
            next_pc <= 32'd0;
        else
            next_pc <= current_pc + STEP;
    end

    // Decodificación + impresión cada ciclo (después del posedge)
    always @(posedge clk) begin
        // Extraer campos
        opcode = instruction[31:26];
        rs     = instruction[25:21];
        rt     = instruction[20:16];
        rd     = instruction[15:11];
        shamt  = instruction[10:6];
        funct  = instruction[5:0];
        imm    = instruction[15:0];

        // Línea 1: PC e instrucción partida con guiones bajos
        $write("PC=%0d, Instr=", current_pc);
        $write("%06b_", instruction[31:26]); // opcode
        $write("%05b_", instruction[25:21]); // rs
        $write("%05b_", instruction[20:16]); // rt
        $write("%05b_", instruction[15:11]); // rd
        $write("%05b_", instruction[10:6]);  // shamt
        $write("%06b\n", instruction[5:0]);  // funct / parte baja

        // Línea 2: campos ya interpretados
        if (opcode == 6'b000000) begin
            $display("opcode=%06b rs=%05b rt=%05b rd=%05b shamt=%05b funct=%06b",
                     opcode, rs, rt, rd, shamt, funct);
        end else begin
            $display("opcode=%06b rs=%05b rt=%05b immediate=%016b (signed=%0d)",
                     opcode, rs, rt, imm, $signed(imm));
        end
        $display("---");
    end

    // Secuencia de reset y fin
    initial begin
        // VCD
        $dumpfile("PC_IMEM.vcd");
        $dumpvars(0, testbench);

        // Reset
        reset   = 1'b1;
        next_pc = 32'd0;
        repeat (2) @(posedge clk);
        reset = 1'b0;

        // Correr ~12 ciclos (suficiente para ver las 10 instrucciones)
        repeat (12) @(posedge clk);

        $finish;
    end
endmodule
