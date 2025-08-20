module FFD (
    input D,
    input clk,
    input reset,
    output reg Q
);

    always @(posedge clk)
    begin
        if(reset) Q = 0;
        else Q = D;
    end

endmodule

module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    // Señales para conectar al DUT (Design Under Test)
    reg clk;         // Reloj (señal periódica generada por el testbench)
    reg reset;       // Señal de reset (controlada por el testbench)
    reg D;          // Señal de entrada (controlada por el testbench)
    wire Q;         // Salida del FFD (monitoreada por el testbench)

    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo FFD
    FFD dut (
        .clk(clk),    // Conecta señal clk del testbench a clk del FFD
        .reset(reset), // Conecta señal reset del testbench a reset del FFD
        .D(D), // Conecta señal D del testbench a D del FFD
        .Q(Q)  // Conecta la salida Q del FFD a la señal del testbench
    );

    // ================================================
    // 3. GENERACIÓN DE RELOJ (CLOCK)
    // ================================================
    initial begin
        clk = 0;  // Inicializa el reloj en 0
        // Bucle infinito: conmuta el reloj cada 5 unidades de tiempo
        forever #5 clk = ~clk;  // Período = 10 unidades (5 alto + 5 bajo)
    end

    // ================================================
    // 4. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    initial begin
        // Sistema de monitoreo: muestra señales en consola cuando cambian
        $monitor("Tiempo=%0t | clk=%b | reset=%b | D=%d | Q=%d", 
                 $time, clk, reset, D, Q);
        
        // --------------------------
        // Secuencia de pruebas:
        // --------------------------
        
        // Paso 1: Reset inicial y establecer estado inicial
        reset = 1;  // Activa reset (pone a Q en cero)
        D = 0;      // Se establece un valor inicial de la entrada
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)
        
        // Paso 2: Se prueba la salida
        reset = 0;  // Desactiva reset (perrmite que se deje pasar la entrada D)
        D = 1;      // Se prende la salida para provocar una salida en Q
        #50;        // Espera 50 unidades (5 ciclos completos de reloj)
        
        // Paso 3: Reset durante operación
        reset = 1;  // Vuelve a activar reset (detiene conteo)
        #10;        // Espera 10 unidades (1 ciclo)
        
        // Paso 4: se prueba que al resetear y tener una entrada LOW, ya no haya una salida
        reset = 0;  // Desactiva reset nuevamente
        D = 0;
        #30;        // Espera 30 unidades (3 ciclos)

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("FFD.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule
