@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: david.quintana@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: david.quintana@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global mapas[][][]) y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
	.global inicializa_matriz
inicializa_matriz:

		push {r0-r8, lr}			
		
		mov r8, r0					@;pasamos a r8 la direccion base de la matriz de juego porque r0 la tendremos que usar en la funcion mod_random
		ldr r7, =mapas				
		mov r5, #ROWS*COLUMNS		
		mul r5, r1					
		add r7, r5					@;registro para acceder al mapa
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos r1 y la usamos como contador para inicializar las filas porque mas adelante la funcion cuenta_repeticiones exige que sea este registro
		
	.Lnumero_filas:
		mov r2, #0					@;inicializamos r2 y la usamos como contador para inicializar las columnas porque mas adelante la funcion cuenta_repeticiones exige que sea este registro
		
	.Lnumero_columna:
		ldrb r5, [r7, r6]	
									@;cmp r5, #0					
									@;beq	.Lbucle_random			@;si detectamos que la casilla esta vacia saltamos al bucle random para poner un elemento basico 
									@;cmp r5, #8					
									@;beq .Lbucle_random			@;si detectamos que hay una gelatina simple vacia saltamos al bucle random para poner un elemento de gelatina simple
									@;cmp r5, #16					
									@;beq .Lbucle_random			@;si detectamos que hay una gelatina doble vacia saltamos al bucle random para poner un elemento de gelatina doble
		tst r5, #0x07
		beq .Lbucle_random
		strb r5, [r8, r6]			@;si es un bloque solido o un hueco lo copiamos y passem a la siguiente casilla
		b .Lfinal					
		
	.Lbucle_random:					
		mov r4, #0					
		mov r0, #6					@;pasamos el rango del numero aleatorio
		bl mod_random				
		add r0, #1					@;le sumamos uno para que no salga 0(casilla vacia), esto no da problemas porque el rango que nos devuelve la funcion es 0..n-1
		add r4, r5, r0				@;guardamos el nuevo valor de la casilla
		mov r3, #2					@;pasamos la direccion oeste(horizontal) a r3 como pide la funcion cuenta_repeticiones
		mov r0, r8					
		strb r4, [r8, r6]			@;copio el nuevo valor de la casilla en la matriz de joc
		bl cuenta_repeticiones		
		cmp r0, #3					@;comprovamos que no haya una solucion de 3 o mas seguidas iguales
		bge .Lbucle_random			@;si es asi repetimos el bucle 
		mov r3, #3					@;pasamos la direccion norte(vertical) a r3 como pide la funcion cuenta_repeticiones
		mov r0, r8					
		bl cuenta_repeticiones	 
		cmp r0, #3					@;comprovamos que no haya una solucion de 3 o mas seguidas iguales
		bge .Lbucle_random			@;si es asi repetimos el bucle
		
	.Lfinal:						
		add r6, #1					@;avanzamos posicion
		add r2, #1					@;avanzamos columna
		cmp r2, #COLUMNS			
		blo .Lnumero_columna		@;si no esta al final de la fila vamos al siguiente elemento
		add r1, #1					@;avanzamos fila
		cmp r1, #ROWS				
		blo .Lnumero_filas			@;si quedan mas filas pasamos al primer elemento de la siguiente
		
		pop {r0-r8, pc}				



@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en mat_recomb1[][], para luego ir
@;	escogiendo elementos de forma aleatoria y colocándolos en mat_recomb2[][],
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina hay_combinacion() (ver fichero 'candy1_comb.s')
@;		* se puede asumir que siempre existirá una recombinación sin secuencias
@;			y con posibles combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:

		@;push {r0-r12, lr}
		
		mov r4, r0					@;pasamos a r4 la direccion base de la matriz de juego porque r0 la tendremos que usar mas adelante
		ldr r7, =mat_recomb1		
		ldr r8, =mat_recomb2		
	.LConstruirMatriu1:
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
		@;recorrer matriu de joc:
	.Lnumero_filas1:
		mov r2, #0					@;inicializamos columnas
	.Lnumero_columna1:
		mov r3, #COLUMNS			
		mul r12, r1, r3				
		add r6, r12, r2				@;preparamos el puntero
		ldrb r3, [r4, r6]			@;obtenemos el valor de la casilla indicada
		cmp r3, #0
		beq .Lguardar_0
		cmp r3, #7
		beq .Lguardar_0
		cmp r3, #15
		beq .Lguardar_0
		mov r5, r3, lsr#3
		and r5, #0x03
		cmp r5, #0
		beq .Lguardar_elemsimp1
		cmp r5, #1
		beq .Lguardar_gelsimp1
		cmp r5, #2
		beq .Lguardar_geldobl1
		
	.Lguardar_0:
		mov r3, #0
		strb r3, [r7, r6]
		b .Lfinal_construir1
	.Lguardar_elemsimp1:
		strb r3, [r7, r6]
		b .Lfinal_construir1
	.Lguardar_gelsimp1:
		sub r5, r3, #8
		strb r5, [r7, r6]
		b .Lfinal_construir1
	.Lguardar_geldobl1:
		sub r5, r3, #16
		strb r5, [r7,r6]
		b .Lfinal_construir1
		
	.Lfinal_construir1:
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			
		blo .Lnumero_columna1		@;si no esta en el final de la fila avanza al siguiente elemento
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				
		blo .Lnumero_filas1			@;si no esta en el final avanza al siguiente elemento
		
		
	.LConstruirMatriu2:
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
		@;recorrer matriu de joc:
	.Lnumero_filas2:
		mov r2, #0					@;inicializamos columnas
	.Lnumero_columna2:
		mov r3, #COLUMNS			
		mul r12, r1, r3				
		add r6, r12, r2				@;preparamos el puntero
		ldrb r3, [r4, r6]			@;obtenemos el valor de la casilla indicada
		cmp r3, #0
		beq .Lguardar_0_2
		cmp r3, #7
		beq .Lguardar_bls
		cmp r3, #15
		beq .Lguardar_huec
		mov r5, r3, lsr#3
		and r5, #0x03
		cmp r5, #0
		beq .Lguardar_0_2
		cmp r5, #1
		beq .Lguardar_8
		cmp r5, #2
		beq .Lguardar_16
		
	.Lguardar_0_2:
		mov r3, #0
		strb r3, [r8, r6]
		b .Lfinal_construir2
	.Lguardar_bls:
		strb r3, [r8, r6]
		b .Lfinal_construir2
	.Lguardar_huec:
		strb r3, [r8, r6]
		b .Lfinal_construir2
	.Lguardar_8:
		mov r3, #8
		strb r3, [r8,r6]
		b .Lfinal_construir2
	.Lguardar_16:
		mov r3, #16
		strb r3, [r8, r6]
		b .Lfinal_construir2
		
	.Lfinal_construir2:
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			
		blo .Lnumero_columna2		@;si no esta en el final de la fila avanza al siguiente elemento
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				
		blo .Lnumero_filas2			@;si no esta en el final avanza al siguiente elemento
		
		
	.Linici_recombinacio:
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.Lnumero_filas_recomb:
		mov r2, #0					@;inicializamos columnas
	.Lnumero_columna_recomb:
		mov r3, #COLUMNS			
		mul r12, r1, r3				
		add r6, r12, r2				@;preparamos el puntero
		ldrb r3, [r4, r6]
		and r3, #0x07
		cmp r3, #0
		beq .Lfinal_recombinacio
		ldrb r3, [r8, r6]			@;obtenemos valor
		and r3, #0x07
		cmp r3, #0					
		beq .Lescollir_random		@;buscamos un valor en la mtriz1    //PROBLEMAAAA!!
		b .Lfinal_recombinacio			
		mov r9, #0					@;control para evitar un bucle infinito con un contador 
	.Lescollir_random:
		mov r0, #COLUMNS			
		bl mod_random				@;obtenemos un numero de columna aleatorio
		mov r11, r0					
		mov r0, #ROWS				
		bl mod_random				@;obtenemos un numero de fila aleatorio
		mov r5, r0					
		mov r0, #COLUMNS			
		mul r10, r5, r0				
		add r10, r11				@;preparamos el puntero
		ldrb r0, [r7, r10]			@;obtenemos un valor de una casilla aleatoria de la matriz1
		add r9, #1					
		cmp r9, #2000				@;controlamos que no entre en un bucle infinito
		beq .Lmatriu_final				
		cmp r0, #0					@;miramos si la casilla ya esta usada, porque si es asi escogeremos otra
		beq .Lescollir_random		
		add r0, r3					
		strb r0, [r8, r6]			@;guardamos el valor de la casilla aleatoria en la matriz2
		mov r12, r11				@;guardamos la columna en r12
		mov r0, r8					
		mov r11, r3					
		mov r3, #2					@;pasamos la direccion oeste(horizontal) a r3 como pide la funcion cuenta_repeticiones
		bl cuenta_repeticiones		
		mov r3, r11					@;recuperemos el valor de r3
		cmp r0, #3					
		bhs .Lescollir_random		@;si hay secuencia volvemos a buscar otra casilla aleatoria
		mov r0, r8					
		mov r11, r3					
		mov r3, #3					@;pasamos la direccion norte(vertical) a r3 como pide la funcion cuenta_repeticiones
		bl cuenta_repeticiones		
		mov r3, r11					@;recuperem el valor de r3
		cmp r0, #3					
		bhs .Lescollir_random		@;si hay secuencia volvemos a buscar otra casilla aleatoria
		mov r3, #0					
		strb r3, [r7, r10]			@;guardamos un 0 en la matriz1 para no volver a escoger esa casilla
		@;Subtarea 2Ia
		mov r3, r2					@;r3=columna destino
		mov r0, r5					@;r0=fila origen
		mov r10, r2					@;guardamos valor columnas en r10
		mov r2, r1					@;r2=fila desti
		mov r11, r1					@;guardamos valor filas en r11
		mov r1, r12					@;r1=columna origen
		@;bl activa_elemento
		mov r2, r10					@;recuperem el valor de l'index de columnes
		mov r1, r11					@;recuperem el valor de l'index de files
	.Lfinal_recombinacio:
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			
		blo .Lnumero_columna_recomb		@;si no esta en el final de la fila avanza al siguiente elemento
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				
		blo .Lnumero_filas_recomb	@;si no esta en el final avanza al siguiente elemento
		
	.Lmatriu_final:
		mov r0, r8					
		bl hay_combinacion			@;coprobamos si hay alguna combinacion posible
		cmp r0, #0					@;en caso de que no haya ninguna sequencia possible volvemos a hacer la funcio
		beq .LConstruirMatriu1			
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.Lnumero_filas_mfinal:
		mov r2, #0					@;inicializamos columnas
	.Lnumero_columna_mfinal:
		mov r3, #COLUMNS			
		mul r12, r1, r3				
		add r6, r12, r2				@;preparamos puntero
		ldrb r3, [r8, r6]			
		strb r3, [r4, r6]			@;guardemos en la matriz de juego el valor de la matriz2 
	.Lacabar_mfinal:
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			
		blo .Lnumero_columna_mfinal		@;si no esta en el final de la fila avanza al siguiente elemento
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				
		blo .Lnumero_filas_mfinal		@;si no esta en el final avanza al siguiente elemento
		
		
		pop {r0-r12, pc}


@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina random()
@;	Restricciones:
@;		* el parámetro n tiene que ser un natural entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r2-r4, lr}
		
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		movlo r0, #2			@;si menor, fija el rango mínimo
		and r0, #0xFF			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4
		
		pop {r2-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global seed32 (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de seed32 no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en seed32)
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable seed32
	ldr r1, [r0]				@;R1 = valor actual de seed32
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en seed32
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
