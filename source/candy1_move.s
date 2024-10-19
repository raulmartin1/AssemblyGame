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
		push {r4, lr}
		mov r4, r0
		bl baja_verticales
		cmp r0, #1
		beq .Lbe_final
		bl baja_laterales
		.Lbe_final:
		pop {r4, pc}



@;:::RUTINAS DE SOPORTE:::



@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada  

baja_verticales:
		push {r1-r3, r5-r11, lr}
		mov r2, #COLUMNS
		mov r3, #ROWS
		mov r10, #0
		mla r1, r2, r3, r4		@;Es va al final de la matriu
		
		.Lbv_for:
		sub r1, #1				@;i--
		cmp r2, #0				@;Es comprova si estem en la primera columna per a poder assignar el pròxim element

		beq .Lbv_restar_fila
		sub r2, #1
		
		b .Lbv_continuacio
		
		.Lbv_restar_fila:
		mov r2, #COLUMNS-1
		sub r3, #1
		cmp r3, #0				@;Es comprova que estiguem dins la matriu
		beq .Lbv_fi_for

		
		.Lbv_continuacio:
		mov r9, r3	
		mov r6, r1				
		ldrb r5, [r1]
		
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		cmp r5, #0				@;Es comprova si l'element és buit
		beq .Lbv_espai_disp

		b .Lbv_for				@;Si l'element actual no està buit es passa al següent
		
		.Lbv_espai_disp:
		mov r8, #0
		cmp r3, #1
		beq .Lbv_primera_fila
		cmp r9, #1
		beq .Lbv_primera_fila
		sub r9, #1				@;R9 és la fila de l'element superior
		cmp r9, #0				@;Es mira si seguim en la matriu al buscar un element per a baixar (no estem fora de rang)
		beq .Lbv_for

		sub r6, #COLUMNS		@;R6 és l'element superior sense filtrar
		@;
		ldrb r7, [r6]			@;S'emmagatzema el valor filtrat (r7) i el valor amb gelatina (r8)
		@;
		and r7, #7				
		@;
		ldrb r8, [r6]
		@;
		and r8, #0x1F
		cmp r8, #15				@;Es mira si hi ha un forat
		beq .Lbv_espai_disp		@;Es segueix buscant l'element superior fins que no sigui un forat
		cmp r7, #0				@;Es mira si hi ha gelatina buida
		beq .Lbv_for
		cmp r7, #7				@;Es mira si hi ha un bloc sòlid
		beq .Lbv_for
		
		@;Baixar l'element superior
		mov r11, r7				@;S'utilitza r11 com a registre auxiliar al baixar l'element trobat (emmagatzema valor superior filtrat)
		sub r8, r7				@;S'obté la quantitat de gelatina que hi ha en l'element superior
		strb r8, [r6]
		ldrb r5, [r1]
		and r5, #0x1F
		add r11, r5
		strb r11, [r1]

		mov r10, #1
		b .Lbv_for
		
		.Lbv_primera_fila:
		ldrb r8, [r1]
		and r8, #0x1F
		mov r0, #6
		bl mod_random
		add r0, #1
		add r0, r8
		strb r0, [r1]
		mov r10, #1
		b .Lbv_for
		
		.Lbv_fi_for:
		mov r0, r10
		pop {r1-r3, r5-r11, pc}



@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada. 
baja_laterales:
		push {r1-r3, r5-r12, lr}
		mov r2, #COLUMNS
		mov r3, #ROWS
		mov r10, #0
		mla r1, r2, r3, r4		@;Es va al final de la matriu

		
		.Lbl_for:
		sub r1, #1				@;i--
		cmp r2, #0				@;Es comprova si estem en la primera columna per a poder assignar el pròxim element

		beq .Lbl_restar_fila

		sub r2, #1
		
		b .Lbl_continuacio
		
		.Lbl_restar_fila:

		mov r2, #COLUMNS-1
		sub r3, #1
		cmp r3, #1				@;Es comprova que estiguem dins el rang de la funció
		beq .Lbl_fi_for
		
		.Lbl_continuacio:
		mov r9, r3
		mov r12, r2
		mov r6, r1				
		ldrb r5, [r1]
		and r5, #7				@;R5 es el valor filtrado (sin marcas de gel.)
		cmp r5, #0				@;Es comprova si l'element és buit
		beq .Lbl_espai_disp

		b .Lbl_for				@;Si l'element actual no està buit es passa al següent
		
		.Lbl_espai_disp:

		sub r9, #1				@;R9 és la fila de l'element superior
		sub r6, #COLUMNS		@;R6 és l'element superior sense filtrar			
		cmp r12, #0				@;Es comprova si estem en els límits de la fila o no
		beq .Lbl_nomes_dreta
		cmp r12, #COLUMNS-1
		bhs .Lbl_nomes_esquerra
		
		@;En el cas que les dues posicions estiguin disponibles
		mov r11, #0
		mov r12, #0
		
		sub r6, #1
		ldrb r7, [r6]			@;S'emmagatzema el valor filtrat (r7) i el valor amb gelatina (r8)
		add r6, #1
		and r7, #7				
		cmp r7, #0				@;Es mira si hi ha gelatina buida
		moveq r11, #1
		cmp r7, #7				@;Es mira si hi ha un bloc sòlid
		moveq r11, #1
		
		add r6, #1
		ldrb r7, [r6]	
		sub r6, #1
		and r7, #7			
		cmp r7, #0				
		moveq r12, #1
		cmp r7, #7				
		moveq r12, #1
		
		cmp r11, #0
		beq .Lbl_esq_disp
		cmp r12, #0
		beq .Lbl_nomes_dreta
		b .Lbl_for
		
		.Lbl_esq_disp:
		cmp r12, #0
		beq .Lbl_dos_costats
		b .Lbl_nomes_esquerra
		
		.Lbl_dos_costats:
		mov r0, #2
		bl mod_random			@;Es selecciona un dels dos costats aleatòriament
		cmp r0, #0
		beq .Lbl_nomes_dreta
		
		.Lbl_nomes_esquerra:
		sub r6, #1
		b .Lbl_element_valid
		
		.Lbl_nomes_dreta:
		add r6, #1
		
		.Lbl_element_valid:
		ldrb r7, [r6]			@;S'emmagatzema el valor filtrat (r7) i el valor amb gelatina (r8)
		and r7, #7				
		ldrb r8, [r6]


		and r8, #0x1F
		cmp r7, #0				@;Es mira si hi ha gelatina buida
		beq .Lbl_for
		cmp r7, #7				@;Es mira si hi ha un bloc sòlid
		beq .Lbl_for
		
		@;Baixar l'element superior
		mov r11, r7				@;S'utilitza r11 com a registre auxiliar al baixar l'element trobat (emmagatzema valor superior filtrat)
		sub r8, r7				@;S'obté la quantitat de gelatina que hi ha en l'element superior
		strb r8, [r6]
		ldrb r5, [r1]
		and r5, #0x1F
		add r11, r5
		strb r11, [r1]
		mov r10, #1
		b .Lbl_for
		
		.Lbl_fi_for:
		mov r0, r10
		pop {r1-r3, r5-r12, pc}


.end

