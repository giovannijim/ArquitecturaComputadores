`timescale 1ns/1ps

// =====================
//  Módulo: PC
// =====================
module PC (
    input  wire        clk,         // reloj
    input  wire        reset,       // reinicia el PC
    input  wire [31:0] next_pc,     // dirección siguiente
    output reg  [31:0] current_pc   // dirección actual
);
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_pc <= 32'd0;      // Reinicio a 0
        else
            current_pc <= next_pc;    // Captura next_pc en flanco de clk
    end
endmodule


// =====================
//  Testbench: testbench
// =====================
module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    // Señales para conectar al DUT (Design Under Test)
    reg         clk;                  // reloj
    reg         reset;                // reset asíncrono
    reg  [31:0] next_pc;              // estímulo de dirección siguiente
    wire [31:0] current_pc;           // salida monitoreada

    time start_time, end_time;        // Variables para medir el tiempo

    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    PC dut (
        .clk      (clk),
        .reset    (reset),
        .next_pc  (next_pc),
        .current_pc(current_pc)
    );

    // ================================================
    // 3. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    // Reloj 100 MHz (T = 10 ns)
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // Monitor en vivo (binario y decimal)
    initial begin
        $monitor("Tiempo=%0t | reset=%b | next_pc=%h (%0d) | current_pc=%h (%0d)",
                 $time, reset, next_pc, next_pc, current_pc, current_pc);
    end

    // Casos de prueba estilo “bloque de pruebas”
    initial begin
        $display("===== PC Test Cases =====");

        // Estado inicial
        reset    = 1'b1;
        next_pc  = 32'd0;

        // CASO 1: Bajo reset, PC debe ser 0
        start_time = $time;
        @(posedge clk);  // 1 ciclo con reset activo
        end_time = $time;

        // Soltar reset
        reset = 1'b0;
        @(posedge clk);

        // CASO 2: Cargar 4
        start_time = $time;  next_pc = 32'd4;   @(posedge clk);  end_time = $time;

        // CASO 3: Cargar 8
        start_time = $time;  next_pc = 32'd8;   @(posedge clk);  end_time = $time;

        // CASO 4: Cargar 12
        start_time = $time;  next_pc = 32'd12;  @(posedge clk);  end_time = $time;

        // CASO 5: Cargar 16
        start_time = $time;  next_pc = 32'd16;  @(posedge clk);  end_time = $time;

        // CASO 6: Reset asíncrono en medio de la secuencia
        start_time = $time;  reset = 1'b1; #1;  @(posedge clk);  reset = 1'b0;  end_time = $time;

        // CASO 7: Continuar con 24
        start_time = $time;  next_pc = 32'd24;  @(posedge clk);  end_time = $time;

        // CASO 8: 28
        start_time = $time;  next_pc = 32'd28;  @(posedge clk);  end_time = $time;

        // CASO 9: 32
        start_time = $time;  next_pc = 32'd32;  @(posedge clk);  end_time = $time;

        // Finaliza la simulación
        @(posedge clk);
        $finish;
    end

    // Dump de señales (VCD)
    initial begin
        $dumpfile("ProgramCounter.vcd");  // 1. Nombre del archivo VCD
        $dumpvars(0, testbench);          // 2. Jerarquía a volcar
    end
endmodule
