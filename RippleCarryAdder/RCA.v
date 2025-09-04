// Arquitectura de computadores, Sección 10
// Giovanni Jimenez 22469
// -------------- RIPPLE CARRY ADDER -------------


module FullAdder(
    input A, B, Cin,
    output Sum, Cout
);
    assign Sum = A ^ B ^ Cin;
    assign Cout = (A & B) | (Cin & (A ^ B));
endmodule


module RippleCarryAdder16 (
    input  [15:0] A,
    input  [15:0] B,
    input        Cin,
    output [31:0] Sum   // Salida de 32 bits como lo piden
);
    wire [15:0] sum_internal;
    wire [15:0] carry;

    // Primer bit
    FullAdder FA0 (
        .A(A[0]), .B(B[0]), .Cin(Cin),
        .Sum(sum_internal[0]), .Cout(carry[0])
    );

    // Bits 1 a 15
    genvar i;
    generate
        for (i = 1; i < 16; i = i + 1) begin : ripple
            FullAdder FA (
                .A(A[i]), .B(B[i]), .Cin(carry[i-1]),
                .Sum(sum_internal[i]), .Cout(carry[i])
            );
        end
    endgenerate

    // Salida de 32 bits: bits [15:0] = sum, bit [16] = último carry, bits [31:17] = 0
    assign Sum = {15'b0, carry[15], sum_internal};

endmodule


/*
module FullAdder(
    input A, B, Cin,
    output Sum, Cout
);
    wire sum1, c1, c2;

    assign sum1 = A ^ B;
    assign Sum = sum1 ^ Cin;

    assign c1 = A & B;
    assign c2 = sum1 & Cin;
    assign Cout = c1 | c2;

    xor (sum1, A, B);
    xor (Sum, sum1, Cin);

    and (c1, A, B);
    and (c2, sum1, Cin);
    or  (Cout, c1, c2);
endmodule
*/

`timescale 1fs / 1fs

module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    // Señales para conectar al DUT (Design Under Test)
    reg [15:0] A;         // Señal de 16 bits (controlada desde el testbench)
    reg [15:0] B;         // Señal de 16 bits (controlada desde el testbench)
    reg Cin;              // Señal del carry in (controlada por el testbench)
    wire [31:0] Sum;      // Salida del sumador (monitoreada por el testbench)

    time start_time, end_time;  // Variables para medir el tiempo

    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo sumador
    RippleCarryAdder16 dut (
        .A(A),    // Conecta señal A del testbench a A del sumador
        .B(B),    // Conecta señal B del testbench a B del sumador
        .Cin(Cin),    // Conecta señal Cin del testbench a Cin del sumador
        .Sum(Sum)    // Conecta señal Sum del testbench a Sum del sumador

    );
    // ================================================
    // 3. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    initial begin
        // Sistema de monitoreo: muestra señales en consola cuando cambian
        //$monitor("Tiempo=%0t | A=%b | B=%b | Cin=%b | Sum=%b | Cout=%b", $time, A, B, Cin, Sum, Cout);
        
        // --------------------------
        // Secuencia de pruebas:
        // --------------------------
        
    $monitor("Tiempo=%0t | A=%b (%0d) | B=%b (%0d) | Cin=%b (%0d) |  SUMA=%b (%0d) | Cout=%b", 
        $time, A, A, B, B, Cin, Cin, Sum[31:0], Sum[31:0], Sum[16]);


        $display("===== RCA16 Test Cases =====");

        // CASO 1: Suma de ceros
        A = 0; B = 0; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 1: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 2: Uno más uno
        A = 1; B = 1; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 2: A=%b, B=%b Cin=%b -> Sum=%b,  delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 3: Overflow máximo
        A = 16'hFFFF; B = 1; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 3: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 4: Suma sin carry
        A = 10; B = 5; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 4: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 5: Carry propagado largo
        A = 32767; B = 1; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 5: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 6: Mitades altas
        A = 61440; B = 3855; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 6: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 7: Aleatorios pequeños
        A = 5; B = 3; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 7: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 8: Aleatorios grandes
        A = 43690; B = 21845; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 8: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 9: Cero en un operando
        A = 0; B = 21845; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 9: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 10: Overflow doble
        A = 16'hFFFF; B = 16'hFFFF; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 10: A=%b, B=%b Cin=%b -> Sum=%b, delta_t=%0t", A, B, Cin, Sum, end_time - start_time);

        // CASO 11: Entradas 0, y Carry In 1
        A = 32'h0000; B = 32'h0000; Cin = 1;
        start_time = $time; #1; end_time = $time;

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("RCA.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule

