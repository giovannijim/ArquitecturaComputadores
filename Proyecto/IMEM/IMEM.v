// ================================================
//  Universidad del Valle de Guatemala
//  Arquitectura de computadores, sección 10
//  Giovanni Jimenez 22469
//  Ever Yes 22510
//  INSTRUCTIONS MEMORY
// ================================================
`timescale 1ns/1ps
// ================================================
//  Módulo: IMEM (Instruction Memory)
// ================================================
module IMEM (
    input  wire [31:0] addr,         // dirección de instrucción (byte address o PC)
    output wire [31:0] instruction   // instrucción leída
);
    // Memoria de 16 palabras de 32 bits
    reg [31:0] memory [0:15];

    // Inicialización con 10 instrucciones de ejemplo
    // Formato R:  [31:26]=opcode(000000), [25:21]=rs, [20:16]=rt, [15:11]=rd, [10:6]=shamt, [5:0]=funct
    // Formato I:  [31:26]=opcode, [25:21]=rs, [20:16]=rt, [15:0]=imm
    initial begin
        // 0: ADD  $3, $1, $2   -> opcode=000000, rs=$1, rt=$2, rd=$3, shamt=0, funct=100000
        memory[0] = 32'b000000_00001_00010_00011_00000_100000;

        // 1: ADDI $9, $8, 10   -> opcode=001000, rs=$8, rt=$9, imm=10
        memory[1] = 32'b001000_01000_01001_0000000000001010;

        // 2: AND  $5, $3, $4   -> opcode=000000, rs=$3, rt=$4, rd=$5, shamt=0, funct=100100
        memory[2] = 32'b000000_00011_00100_00101_00000_100100;

        // 3: OR   $6, $3, $4   -> funct=100101
        memory[3] = 32'b000000_00011_00100_00110_00000_100101;

        // 4: SLT  $7, $1, $2   -> funct=101010
        memory[4] = 32'b000000_00001_00010_00111_00000_101010;

        // 5: LW   $10, 4($9)   -> opcode=100011, rs=$9, rt=$10, imm=4
        memory[5] = 32'b100011_01001_01010_0000000000000100;

        // 6: SW   $10, 8($9)   -> opcode=101011, rs=$9, rt=$10, imm=8
        memory[6] = 32'b101011_01001_01010_0000000000001000;

        // 7: BEQ  $1, $2, 3    -> opcode=000100, rs=$1, rt=$2, imm=3
        memory[7] = 32'b000100_00001_00010_0000000000000011;

        // 8: ADDI $8, $0, 255  -> cargar 255 en $8
        memory[8] = 32'b001000_00000_01000_0000000011111111;

        // 9: ORI  $11, $8, 0xAA -> opcode=001101 (ORI), rs=$8, rt=$11, imm=0x00AA
        memory[9] = 32'b001101_01000_01011_0000000010101010;

        // El resto sin usar
        memory[10] = 32'h00000000;
        memory[11] = 32'h00000000;
        memory[12] = 32'h00000000;
        memory[13] = 32'h00000000;
        memory[14] = 32'h00000000;
        memory[15] = 32'h00000000;
    end

    // Selección por bits menos significativos (mem de 16 => 4 bits)
    assign instruction = memory[addr[3:0]];
endmodule


// ================================================
//  Testbench: testbench
// ================================================
module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    reg  [31:0] addr;         // Dirección a leer
    wire [31:0] instruction;  // Instrucción leída

    // Campos decodificados
    reg  [5:0]  opcode;
    reg  [4:0]  rs, rt, rd;
    reg  [4:0]  shamt;
    reg  [5:0]  funct;
    reg  [15:0] imm;

    integer i; // contador para recorrer direcciones

    // ================================================
    // 2. INSTANCIACIÓN DEL DUT
    // ================================================
    IMEM dut (
        .addr(addr),
        .instruction(instruction)
    );

    // ================================================
    // 3. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    // Tarea para decodificar e imprimir bonito
    task decode_and_print(input [31:0] instr, input [31:0] a);
        begin
            opcode = instr[31:26];
            rs     = instr[25:21];
            rt     = instr[20:16];
            rd     = instr[15:11];
            shamt  = instr[10:6];
            funct  = instr[5:0];
            imm    = instr[15:0];

            $display("addr=%0d (idx=%0d) | instr=0x%08h | opcode=%06b",
                     a, a[3:0], instr, opcode);

            if (opcode == 6'b000000) begin
                // R-type
                $display("  R-type: rs=$%0d, rt=$%0d, rd=$%0d, shamt=%0d, funct=%06b",
                         rs, rt, rd, shamt, funct);
            end else begin
                // I-type (genérico)
                $display("  I-type: rs=$%0d, rt=$%0d, imm=0x%04h (%0d)",
                         rs, rt, imm, $signed(imm));
            end
        end
    endtask

    initial begin
        $display("===== IMEM Test =====");
        // Recorremos varias direcciones
        for (i = 0; i <= 15; i = i + 1) begin
            addr = i;           // usamos el valor 'i' directo; IMEM toma [3:0]
            #1;                 // pequeña espera para estabilizar
            decode_and_print(instruction, addr);
        end

        // Probar alias de direcciones por wrap (16 entradas):
        // p.ej., addr=16 debería mapearse a idx=0 (porque [3:0] = 0)
        // addr = 32'd16; #1; decode_and_print(instruction, addr);
        // addr = 32'd17; #1; decode_and_print(instruction, addr);

        $finish;
    end

    // Dump para ver en GTKWave
    initial begin
        $dumpfile("IMEM.vcd");
        $dumpvars(0, testbench);
    end
endmodule
