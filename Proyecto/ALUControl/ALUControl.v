// ===================================================
//  Módulo: ALUControl
//  Descripción: Decodifica ALUOp y funct para generar
//  la señal alu_control específica de la ALU.
// ===================================================
module ALUControl (
    input  wire [1:0] ALUOp,        // Señal desde la Unidad de Control
    input  wire [5:0] funct,        // Campo funct (instrucciones tipo R)
    output reg  [3:0] alu_control   // Señal de control para la ALU
);

    // Códigos de operación de la ALU (por claridad)
    localparam ALU_MOVI = 4'b0000;  // MOVI (I-type)
    localparam ALU_MOV  = 4'b0001;  // MOV  (R-type)
    localparam ALU_ADD  = 4'b0010;  // ADD
    localparam ALU_SUB  = 4'b0110;  // SUB
    localparam ALU_MULT = 4'b1000;  // MULT
    localparam ALU_DIV  = 4'b1001;  // DIV
    localparam ALU_INV  = 4'b1111;  // Valor por defecto/Inválido

    always @(*) begin
        case (ALUOp)
            2'b00: begin
                // Tipo I (MOVI) — funct no se usa
                alu_control = ALU_MOVI; // 0000
            end

            2'b10: begin
                // Tipo R — seleccionar por funct
                case (funct)
                    6'b100000: alu_control = ALU_ADD;   // ADD  -> 0010
                    6'b100100: alu_control = ALU_SUB;   // SUB  -> 0110
                    6'b100001: alu_control = ALU_MULT;  // MULT -> 1000
                    6'b100010: alu_control = ALU_DIV;   // DIV  -> 1001
                    6'b100011: alu_control = ALU_MOV;   // MOV  -> 0001
                    default:   alu_control = ALU_INV;   // No definido
                endcase
            end

            default: begin
                // Otros ALUOp no definidos en la tabla
                alu_control = ALU_INV;
            end
        endcase
    end

endmodule

`timescale 1ns/1ps

module tb_ALUControl;

  // Entradas al DUT
  reg  [1:0] ALUOp;
  reg  [5:0] funct;
  // Salida del DUT
  wire [3:0] alu_control;

  // Instancia del módulo bajo prueba
  ALUControl dut (
    .ALUOp(ALUOp),
    .funct(funct),
    .alu_control(alu_control)
  );

  // Códigos esperados (mapeo del ejercicio)
  localparam ALU_MOVI = 4'b0000; // I-type (ADDI/MOVI)
  localparam ALU_MOV  = 4'b0001; // MOV (R-type)
  localparam ALU_ADD  = 4'b0010; // ADD
  localparam ALU_SUB  = 4'b0110; // SUB
  localparam ALU_MULT = 4'b1000; // MULT
  localparam ALU_DIV  = 4'b1001; // DIV
  localparam ALU_INV  = 4'b1111; // Indefinido

  // Tarea para correr y verificar un caso
  task run_case(
    input [1:0] op,
    input [5:0] fn,
    input [3:0] exp,
    input [127:0] name
  );
  begin
    ALUOp = op;
    funct = fn;
    #1; // pequeño delay para que se propague la combinacional

    // Ejemplo de display (incluye exactamente la forma pedida)
    $display("ALUOp=%b, funct=%b -> alu_control=%b", ALUOp, funct, alu_control);

    // Mensaje con etiqueta y veredicto
    $display("%0t ns: %-12s | exp=%b | %s",
             $time, name, exp, (alu_control === exp) ? "PASS" : "FAIL");

    if (alu_control !== exp) begin
      $display("  Mismatch detectado. Test detenido.");
      $stop;
    end
  end
  endtask

  initial begin
    $display("\n=== Testbench ALUControl ===");

    ALUOp = 2'b00; funct = 6'b000000;
    #1;

    // I-type: ADDI/MOVI (ALUOp=00, funct es don't care)
    run_case(2'b00, 6'b000000, ALU_MOVI, "I-type (ADDI/MOVI)");

    // R-type: casos de la tabla provista
    run_case(2'b10, 6'b100000, ALU_ADD,  "ADD");
    run_case(2'b10, 6'b100100, ALU_SUB,  "SUB");
    run_case(2'b10, 6'b100001, ALU_MULT, "MULT");
    run_case(2'b10, 6'b100010, ALU_DIV,  "DIV");
    run_case(2'b10, 6'b100011, ALU_MOV,  "MOV");

    // Casos fuera de tabla (deberían ir a indefinido)
    run_case(2'b10, 6'b000000, ALU_INV,  "R undef funct");
    run_case(2'b01, 6'b000000, ALU_INV,  "ALUOp undef");

    $display("Todos los tests pasaron. ✔");
    $finish;
  end

endmodule
