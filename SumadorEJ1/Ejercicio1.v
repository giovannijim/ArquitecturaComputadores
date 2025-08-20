module sumador (
    input [3:0] A,
    input [3:0] B,
    output reg [3:0] sum,
    output reg cout
);
    reg [4:0] result;

    always @(*)
    begin
        result [4:0] = A + B;    // Se realiza una suma, de 5 bits.
        sum = result[3:0];       // Se asigna el resultado, 
        cout = result[4];        // El carry out, cuarto bit , se asigna
    end

endmodule

module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    // Señales para conectar al DUT (Design Under Test)
    reg [3:0] A, B; // Entradas A y B
    wire [3:0] sum; // Salida del sum (monitoreada por el testbench)
    wire cout;  // Salida cout (monitoreada por el testbench)
    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo sumador
    sumador dut (
        .A(A),    // Conecta señal A del testbench a A del sumador
        .B(B), // Conecta señal B del testbench a B del sumador
        .sum(sum), // Conecta salida sum del sumador a la señal sum del testbench
        .cout(cout) // Conecta la salida cout del sumador a la señal cout del testbench
    );

    // ================================================
    // 3. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    initial begin
        // Sistema de monitoreo: muestra señales en consola cuando cambian
        $monitor("Tiempo=%0t | A=%b | B=%b | sum=%b | cout=%b", 
                 $time, A, B, sum, cout);
        
        // --------------------------
        // Secuencia de pruebas:
        // --------------------------
        
        // Caso 1: Suma normal
        // Valores para una suma normal.
        A = 4'b0001;
        B = 4'b0001;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)
        
        // Caso 2: Overflow
        A = 4'b1111;    // Se asigna 4'HF, para poder probar la funcionalidad de overflow
        B = 4'b0001;    // Se assigna 4'H1, para que provoque el overflow
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("sumador.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule
