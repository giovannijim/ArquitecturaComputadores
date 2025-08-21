module contadorE (
    input clk,
    input reset,
    input enable,
    output reg [2:0] count
);
    always @(posedge clk or posedge reset or posedge enable)
    begin
        if (reset)
            count <= 3'b000;
        else if (enable)
            count <= count + 1; 
    end
endmodule


module testbench;
    // ================================================
    // 1. DECLARACIÓN DE SEÑALES
    // ================================================
    // Señales para conectar al DUT (Design Under Test)
    reg clk;         // Reloj (señal periódica generada por el testbench)
    reg reset;       // Señal de reset (controlada por el testbench)
    reg enable;      // Señal del enable (controlada por el testbench)
    wire [3:0] count; // Salida del contador (monitoreada por el testbench)

    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo contador
    contadorE dut (
        .clk(clk),    // Conecta señal clk del testbench a clk del contador
        .reset(reset), // Conecta señal reset del testbench a reset del contador
        .enable(enable), // Conecta señal reset del testbench a reset del contador
        .count(count) // Conecta salida count del contador a señal del testbench
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
        $monitor("Tiempo=%0t | clk=%b | reset=%b | enable=%b | count=%d (%b)", 
                 $time, clk, reset, count, count);
        
        // --------------------------
        // Secuencia de pruebas:
        // --------------------------
        
        // Caso 1: Reset inicial
        reset = 1;  // Activa reset (pone contador en cero)
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)
        
        // Caso 2: Conteo normal
        reset = 0;  // Desactiva reset (contador empieza a contar)
        #50;        // Espera 50 unidades (5 ciclos completos de reloj)
        
        // Caso 3: Reset durante operación
        reset = 0;  // Conteo normal, reset desactivado
        enable = 0;  // desactiva el enable, bloquea el conteo
        #10;        // Espera 10 unidades (1 ciclo)
        
        // Caso 4: Reanudar conteo
        reset = 0;  // Desactiva reset nuevamente
        enable = 1;  // Activa el enable, permite el conteo
        #30;        // Espera 30 unidades (3 ciclos)

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("contadorE.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule
