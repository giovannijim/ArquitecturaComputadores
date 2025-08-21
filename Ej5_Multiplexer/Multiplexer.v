// Arquitectura de computadores, Sección 10
// Giovanni Jimenez 22469

module Multiplexer (
    input [1:0] A,
    input [1:0] B,
    input [1:0] C,
    input [1:0] D,
    input [1:0] sel,
    output reg [1:0] out
);

    always @(*)
    begin
        case(sel[1:0]) 
        2'd0: out = A;
        2'd1: out = B;
        2'd2: out = C;
        2'd3: out = D;
        default: out = 4'H0;
        endcase
    end

endmodule


module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    // Señales para conectar al DUT (Design Under Test)
    reg [1:0] sel; // Entrada sel
    reg [1:0] A; // Entrada A
    reg [1:0] B; // Entrada B
    reg [1:0] C; // Entrada C
    reg [1:0] D; // Entrada D
    wire [1:0] out; // Salida del multiplexer (monitoreada por el testbench)
    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo MUX
    Multiplexer dut (
        .sel(sel),    // Conecta señal sel del testbench a sel del MUX
        .A(A),    // Conecta señal A del testbench a A del MUX
        .B(B),    // Conecta señal B del testbench a B del MUX
        .C(C),    // Conecta señal C del testbench a C del MUX
        .D(D),    // Conecta señal D del testbench a D del MUX 
        .out(out) // Conecta salida out del MUX a la señal out del testbench
    );

    // ================================================
    // 3. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    initial begin
        // Sistema de monitoreo: muestra señales en consola cuando cambian
        $monitor("Tiempo=%0t | sel=%b | A=%b | B=%b | C=%b | D=%b | out=%b", 
                 $time, sel, A, B, C, D, out);
        
        // --------------------------
        // Secuencia de pruebas:
        // --------------------------
        
        // Caso 1: Salida para sel = 2'b00, salida A
        sel = 2'b00;
        A = 2'b01;
        B = 2'b10;
        C = 2'b00;
        D = 2'b11;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)
        
        // Caso 2: Salida para sel = 2'b01, salida B
        sel = 2'b01;
        A = 2'b01;
        B = 2'b10;
        C = 2'b00;
        D = 2'b11;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)

        // Caso 2: Salida para sel = 2'b10, Salida C
        sel = 2'b10;
        A = 2'b00;
        B = 2'b01;
        C = 2'b11;
        D = 2'b10;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)

        // Caso 2: Salida para sel = 2'b11, salida D
        sel = 2'b11;
        A = 2'b00;
        B = 2'b11;
        C = 2'b10;
        D = 2'b01;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("multiplexer.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule

