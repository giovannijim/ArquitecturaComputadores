// Arquitectura de computadores, Sección 10
// Giovanni Jimenez 22469
// -------------- Carry-Lookahead ADDER -------------

`timescale 1ns / 1ps

module CLA8 (
    input  [7:0] A,     // Operando A
    input  [7:0] B,     // Operando B
    input        Cin,   // Carry in (C[0])
    output [15:0] SUM    // Salida de 9 bits (incluye carry out final)
);
    wire [7:0] P;       // Señales de propagación
    wire [7:0] G;       // Señales de generación
    wire [8:0] C;       // Acarreos

    assign C[0] = Cin;  // Carry in inicial

    // 1. Generar señales P y G
    assign P = A ^ B;   // P[i] = A[i] XOR B[i]
    assign G = A & B;   // G[i] = A[i] AND B[i]

    // 2. Generar acarreos usando lógica CLA
    assign C[1] = G[0] | (P[0] & C[0]);
    assign C[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & C[0]);
    assign C[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & C[0]);
    assign C[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0])
                       | (P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[5] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1])
                       | (P[4] & P[3] & P[2] & P[1] & G[0])
                       | (P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[6] = G[5] | (P[5] & G[4]) | (P[5] & P[4] & G[3]) | (P[5] & P[4] & P[3] & G[2])
                       | (P[5] & P[4] & P[3] & P[2] & G[1])
                       | (P[5] & P[4] & P[3] & P[2] & P[1] & G[0])
                       | (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[7] = G[6] | (P[6] & G[5]) | (P[6] & P[5] & G[4]) | (P[6] & P[5] & P[4] & G[3])
                       | (P[6] & P[5] & P[4] & P[3] & G[2])
                       | (P[6] & P[5] & P[4] & P[3] & P[2] & G[1])
                       | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0])
                       | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);
    assign C[8] = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) | (P[7] & P[6] & P[5] & G[4])
                       | (P[7] & P[6] & P[5] & P[4] & G[3])
                       | (P[7] & P[6] & P[5] & P[4] & P[3] & G[2])
                       | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1])
                       | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0])
                       | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & C[0]);

    // 3. Calcular la suma: Sum[i] = P[i] ^ C[i]
    wire [7:0] Sum;
    assign Sum = P ^ C[7:0];

    // 4. Salida final
    assign SUM = {7'b0,C[8], Sum};  // SUM[8] = carry out final, SUM[7:0] = suma

endmodule

module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    // Señales para conectar al DUT (Design Under Test)
    reg [7:0] A;         // Señal de 8 bits (controlada desde el testbench)
    reg [7:0] B;         // Señal de 8 bits (controlada desde el testbench)
    reg Cin;              // Señal del carry in (controlada por el testbench)
    wire [15:0] SUM;      // Salida de de 16 bits del sumador (monitoreada por el testbench)

    time start_time, end_time;  // Variables para medir el tiempo

    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo sumador
    CLA8 dut (
        .A(A),    // Conecta señal A del testbench a A del sumador
        .B(B),    // Conecta señal B del testbench a B del sumador
        .Cin(Cin),    // Conecta señal Cin del testbench a Cin del sumador
        .SUM(SUM)    // Conecta señal Sum del testbench a Sum del sumador

    );
    // ================================================
    // 3. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    initial begin
        
    $monitor("Tiempo=%0t | A=%b (%0d) | B=%b (%0d) | Cin=%b (%0d) |  SUMA=%b (%0d) | Cout=%b", 
        $time, A, A, B, B, Cin, Cin, SUM[15:0], SUM[15:0], SUM[8]);

        $display("===== CLA8 Test Cases =====");

        // CASO 1: Suma de ceros
        A = 0; B = 0; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 1: A=0, B=0 -> Sum=%b, Cout=%b, Time=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 2: Uno más uno
        A = 1; B = 1; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 2: A=1, B=1 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 3: Overflow máximo
        A = 8'hFF; B = 1; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 3: A=255, B=1 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 4: Suma sin carry
        A = 10; B = 5; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 4: A=10, B=5 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 5: Carry propagado largo
        A = 127; B = 1; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 5: A=127, B=1 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 6: Mitades altas
        A = 240; B = 15; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 6: A=240, B=15 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 7: Aleatorios pequeños
        A = 5; B = 3; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 7: A=5, B=3 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 8: Aleatorios grandes
        A = 170; B = 85; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 8: A=170, B=85 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 9: Cero en un operando
        A = 0; B = 85; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 9: A=0, B=85 -> Sum=%b, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 10: Overflow doble
        A = 8'hFF; B = 8'hFF; Cin = 0;
        start_time = $time; #1; end_time = $time;
        // $display("Caso 10: A=255, B=255 -> Sum=%bb, Cout=%b, Δt=%0t", SUM[7:0], SUM[8], end_time - start_time);

        // CASO 11: Entradas 0, y Carry In 1
        A = 8'h00; B = 8'h00; Cin = 1;
        start_time = $time; #1; end_time = $time;

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("CLA.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule

