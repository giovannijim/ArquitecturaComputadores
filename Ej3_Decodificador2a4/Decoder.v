module decoder (
    input [1:0] sel,
    output reg [3:0] out
);

    always @(*)
    begin
        case(sel[1:0]) 
        2'd0: out = 4'H1;
        2'd1: out = 4'H2;
        2'd2: out = 4'H4;
        2'd3: out = 4'H8;
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
    wire [3:0] out; // Salida del decoder (monitoreada por el testbench)
    // ================================================
    // 2. INSTANCIACIÓN DEL DISEÑO BAJO PRUEBA (DUT)
    // ================================================
    // Conectamos las señales del testbench al módulo DECODER
    decoder dut (
        .sel(sel),    // Conecta señal sel del testbench a sel del DECODER
        .out(out) // Conecta salida out del DECODER a la señal out del testbench
    );

    // ================================================
    // 3. GENERACIÓN DE ESTÍMULOS Y MONITOREO
    // ================================================
    initial begin
        // Sistema de monitoreo: muestra señales en consola cuando cambian
        $monitor("Tiempo=%0t | sel=%b | out=%b", 
                 $time, sel, out);
        
        // --------------------------
        // Secuencia de pruebas:
        // --------------------------
        
        // Caso 1: Salida para 0
        sel = 2'b00;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)
        
        // Caso 2: Salida para 1
        sel = 2'b01;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)

        // Caso 2: Salida para 2
        sel = 2'b10;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)

        // Caso 2: Salida para 3
        sel = 2'b11;
        #10;        // Espera 10 unidades de tiempo (1 ciclo completo de reloj)

        // Finaliza la simulación
        $finish;  
    end

    initial begin
        $dumpfile("decoder.vcd");  // 1. Especifica el nombre del archivo de salida
        $dumpvars(0, testbench);    // 2. Define qué señales guardar y en qué jerarquía
    end

endmodule
