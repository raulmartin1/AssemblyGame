@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: nicolas.canton@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: nicolas.canton@estudiants.urv.cat				  ===
@;=                                                         	      	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz, f, c, ori): rutina para contar el número de
@; repeticiones del elemento situado en la posición (f,c) de la matriz, 
@; visitando las siguientes posiciones según indique el parámetro de
@; orientación 'ori'.
@; Restricciones:
@;    * Solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;      almacenados en las posiciones de la matriz, de modo que se ignorarán
@;      las marcas de gelatina (+8, +16).
@;    * La primera posición también se tiene en cuenta, de modo que el número
@;      mínimo de repeticiones será 1, es decir, el propio elemento de la
@;      posición inicial.
@; Parámetros:
@;    R0 = dirección base de la matriz.
@;    R1 = fila 'f'.
@;    R2 = columna 'c'.
@;    R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte).
@; Resultado:
@;    R0 = número de repeticiones detectadas (mínimo 1).
    
    .global cuenta_repeticiones  
cuenta_repeticiones:
    push {r1-r2, r4-r9, lr}      

    mov r5, #COLUMNS             @; Carga el número de columnas de la matriz en r5.
    mla r6, r1, r5, r2           @; Calcula el índice de la posición (f, c): r6 = f * columnas + c.
    add r4, r0, r6               @; R4 apunta al elemento (f, c) en la matriz.
    ldrb r5, [r4]                @; Carga el valor del elemento de la matriz en r5 (byte de menor peso).
    and r5, #7                   @; Filtra los 3 bits de menor peso de r5, ignorando las marcas de gelatina.
    mov r0, #1                   @; Inicializa r0 con 1, ya que al menos la primera posición se cuenta.
    mov r6, r0                   @; Copia el número de repeticiones (1) en r6.

    cmp r3, #0                   @; Compara 'ori' con 0 (Este).
    beq .Lconrep_este             @; Si 'ori' es 0, salta a la rutina de Este.
    cmp r3, #1                   @; Compara 'ori' con 1 (Sur).
    beq .Lconrep_sur              @; Si 'ori' es 1, salta a la rutina de Sur.
    cmp r3, #2                   @; Compara 'ori' con 2 (Oeste).
    beq .Lconrep_oeste            @; Si 'ori' es 2, salta a la rutina de Oeste.
    cmp r3, #3                   @; Compara 'ori' con 3 (Norte).
    beq .Lconrep_norte            @; Si 'ori' es 3, salta a la rutina de Norte.
    b .Lconrep_fin                @; Si 'ori' no es ninguno de los anteriores, salta al final.

.Lconrep_este:
    mov r8, r2                   @; Copia la columna actual en r8.
.Lwhile1:
    cmp r8, #COLUMNS-1           @; Compara la columna con el límite derecho de la matriz.
    beq .Lconrep_fin              @; Si ya está en la última columna, salta al final.
    add r4, #1                   @; Avanza una posición en la matriz (siguiente columna).
    ldrb r9, [r4]                @; Carga el valor del siguiente elemento en r9.
    and r9, #7                   @; Filtra los 3 bits de menor peso en r9.
    cmp r5, r9                   @; Compara el valor inicial con el valor actual.
    bne .Lconrep_fin              @; Si no coinciden, salta al final.
    add r6, #1                   @; Si coinciden, incrementa el contador de repeticiones.
    add r8, #1                   @; Avanza a la siguiente columna.
    b .Lwhile1                   @; Repite el ciclo.

.Lconrep_sur:
    mov r8, r1                   @; Copia la fila actual en r8.
.Lwhile2:
    cmp r8, #ROWS-1              @; Compara la fila con el límite inferior de la matriz.
    beq .Lconrep_fin              @; Si está en la última fila, salta al final.
    add r4, #COLUMNS             @; Avanza una posición hacia abajo en la matriz.
    ldrb r9, [r4]                @; Carga el valor del siguiente elemento.
    and r9, #7                   @; Filtra los 3 bits de menor peso.
    cmp r5, r9                   @; Compara el valor inicial con el valor actual.
    bne .Lconrep_fin              @; Si no coinciden, salta al final.
    add r6, #1                   @; Incrementa el contador de repeticiones.
    add r8, #1                   @; Avanza a la siguiente fila.
    b .Lwhile2                   @; Repite el ciclo.

.Lconrep_oeste:
    mov r8, r2                   @; Copia la columna actual en r8.
.Lwhile3:
    cmp r8, #0                   @; Compara la columna con el límite izquierdo de la matriz.
    beq .Lconrep_fin              @; Si está en la primera columna, salta al final.
    sub r4, #1                   @; Retrocede una posición en la matriz (columna anterior).
    ldrb r9, [r4]                @; Carga el valor del siguiente elemento.
    and r9, #7                   @; Filtra los 3 bits de menor peso.
    cmp r5, r9                   @; Compara el valor inicial con el valor actual.
    bne .Lconrep_fin              @; Si no coinciden, salta al final.
    add r6, #1                   @; Incrementa el contador de repeticiones.
    sub r8, #1                   @; Retrocede a la columna anterior.
    b .Lwhile3                   @; Repite el ciclo.

.Lconrep_norte:
    mov r8, r1                   @; Copia la fila actual en r8.
.Lwhile4:
    cmp r8, #0                   @; Compara la fila con el límite superior de la matriz.
    beq .Lconrep_fin              @; Si está en la primera fila, salta al final.
    sub r4, #COLUMNS             @; Retrocede una posición hacia arriba en la matriz.
    ldrb r9, [r4]                @; Carga el valor del siguiente elemento.
    and r9, #7                   @; Filtra los 3 bits de menor peso.
    cmp r5, r9                   @; Compara el valor inicial con el valor actual.
    bne .Lconrep_fin              @; Si no coinciden, salta al final.
    add r6, #1                   @; Incrementa el contador de repeticiones.
    sub r8, #1                   @; Retrocede a la fila anterior.
    b .Lwhile4                   @; Repite el ciclo.

.Lconrep_fin:
    mov r0, r6                   @; Copia el número de repeticiones encontradas en r0.

    pop {r1-r2, r4-r9, pc}       




@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en diagonal; cada llamada a la función
@;	baja múltiples elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si no se ha movido ningún elemento.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina mod_random() (ver fichero
@;			'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que pueden
@;				quedar movimientos pendientes; 0 si no ha movido nada 
	.global baja_elementos
baja_elementos:
		push {lr}
		
		
		pop {pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada  
baja_verticales:
		push {lr}
		
		
		pop {pc}


@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada. 
baja_laterales:
		push {lr}
		
		
		pop {pc}


.end
