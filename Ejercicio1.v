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
    reg [3:0] A, B;
    wire [3:0] sum; // Salida del contador (monitoreada por el testbench)
    wire cout;
    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo contador
    sumador dut (
        .A(A),    // Conecta señal clk del testbench a clk del contador
        .B(B), // Conecta señal reset del testbench a reset del contador
        .sum(sum), // Conecta salida count del contador a señal del testbench
        .cout(cout)
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
        
        // Caso 1: Reset inicial
        A = 4'b0001;
        B = 4'b0001;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)
        
        // Caso 2: Conteo normal
        A = 4'b1111;
        B = 4'b0001;
        #10;        // Espera 50 unidades (5 ciclos completos de reloj)

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("sumador.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule
