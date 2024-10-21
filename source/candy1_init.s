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
		tst r5, #0x07				@;miramos si es un 0, 8 o 16 comparandolo a traves del tst con la mascara
		beq .Lbucle_random
		strb r5, [r8, r6]			@;si es un bloque solido o un hueco lo copiamos y pasamos a la siguiente casilla
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
		bhs .Lbucle_random			@;si es asi repetimos el bucle 
		mov r3, #3					@;pasamos la direccion norte(vertical) a r3 como pide la funcion cuenta_repeticiones
		mov r0, r8					
		bl cuenta_repeticiones	 
		cmp r0, #3					@;comprovamos que no haya una solucion de 3 o mas seguidas iguales
		bhs .Lbucle_random			@;si es asi repetimos el bucle
		
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

		push {r0-r10, lr}
		
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
		ldrb r3, [r4, r6]			@;obtenemos el valor de la casilla indicada
		mov r0, r3					@;movemos el valor a otro registro para que no se modifique el original
		and r0, #0x7				@;aplicamos una mascara para hacer que un 15 actue como un 7
		cmp r0, #7					
		beq .Lguardar_0				@;si es 7 entramos en el salto 
		tst r3, #0x07				@;miramos si es un 0, 8 o 16 comparandolo a traves del tst con la mascara
		beq .Lguardar_0
		mov r5, r3, lsr#3			@;desplazamos los bits 3 veces a la derecha para quedarnos solo con los 3 y 4 que indican que clase de elemento es
		cmp r5, #0					@;si es elemento simple entramos en el salto 
		beq .Lguardar_elemsimp1
		cmp r5, #1
		beq .Lguardar_gelsimp1		@;si es gelatina simple entramos en el salto 
		cmp r5, #2
		beq .Lguardar_geldobl1		@;si es gelatina doble entramos en el salto
	.Lguardar_0:
		mov r3, #0					
		strb r3, [r7, r6]			@;guardamos un 0 en la matriz1
		b .Lfinal_construir1
	.Lguardar_elemsimp1:
		strb r3, [r7, r6]			@;guardamos el elemento en la matriz1
		b .Lfinal_construir1
	.Lguardar_gelsimp1:
		sub r5, r3, #8
		strb r5, [r7, r6]			@;guardamos el elemento en la matriz1
		b .Lfinal_construir1
	.Lguardar_geldobl1:
		sub r5, r3, #16
		strb r5, [r7,r6]			@;guardamos el elemento en la matriz1
		b .Lfinal_construir1
	.Lfinal_construir1:
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			
		blo .Lnumero_columna1		@;si no esta en el final de la fila avanza al siguiente elemento
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				
		blo .Lnumero_filas1			@;si no esta en el final avanza al siguiente elemento
		
		
	.LCopiarEnMatriu2:
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.Lnumero_filas2:
		mov r2, #0					@;inicializamos columnas
	.Lnumero_columna2:
		ldrb r3, [r4, r6]			@;obtenemos valor de la matriz de juego
		tst r3, #0x07				@;miramos si el valor es un 0, 8  o 16
		beq .Lguardar_valor2		@;si es asi guardamos el valor
		mov r0, r3					@;copiamos el valor para no modificar el actual
		and r0, #0b111				@;aplicamos una mascara para hacer que un 15 actue como un 7
		cmp r0, #7
		beq .Lguardar_valor2		@;si es un 7 o un 15 guardamos el valor
		and r3, #0b11000			@;aplicamos una mascara para solo obtener los codigos de gelatina de la casilla
	.Lguardar_valor2:	
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
		
		
	.LConstruirMatriuJ:
		mov r6, #0					@;inicializamos puntero
		mov r1, #0					@;inicializamos filas
	.Lnumero_filasJ:
		mov r2, #0					@;inicializamos columnas
	.Lnumero_columnaJ:
		ldrb r3, [r4, r6]
		tst r3, #0x07				@;si hay un 0, 8 o 16 pasamos al siguiente elemento
		beq .Lfinal_construirJ
		mov r0, r3			
		and r0, #0x7				@;aplicamos una mascara para hacer que un 15 actue como un 7
		cmp r0, #7					@;si es un 7 o un 15 pasamos al siguiente elemento
		beq .Lfinal_construirJ
	.Lpos_aleatori:
		mov r0, #ROWS*COLUMNS
		bl mod_random				@;obtenemos una casilla aleatoria de la matriz
		mov r9, r0					
		ldrb r0, [r7, r9]			@;miramos esa casilla en la matriz1
		cmp r0, #0
		beq .Lpos_aleatori			@;si es un 0 buscamos otra sino seguimos
		ldrb r5, [r8, r6]			@;leemos el valor en la posicion actual de la matriz2
		add r10, r5, r0				@;le sumamos el codigo de elemento que hemos obtenido de la matriz1
		strb r10, [r8, r6]			@;y lo volvemos a guradar en la matriz2
		mov r0, r8					@;pasamos a r0 la direccion de matriz que queremos comprovar
		mov r3, #2					@;pasamos la direccion oeste(horizontal) a r3 como pide la funcion cuenta_repeticiones
		bl cuenta_repeticiones
		cmp r0, #3					@;miramos si ha havido alguna repeticion de 3 o mas
		bhs .Lrecuperar_valor_m2	@;si es asi guardamos en la casilla el valor que havia anteriormente para no modificar algo erroneo
		mov r0, r8					@;pasamos a r0 la direccion de matriz que queremos comprovar
		mov r3, #3					@;pasamos la direccion norte(vertical) a r3 como pide la funcion cuenta_repeticiones
		bl cuenta_repeticiones		
		cmp r0, #3					@;miramos si ha havido alguna repeticion de 3 o mas
		bhs .Lrecuperar_valor_m2	@;si es asi guardamos en la casilla el valor que havia anteriormente para no modificar algo erroneo
		mov r0, #0
		strb r0, [r7, r9]			@;la casilla usada en la matriz1 la ponemos a 0 para no volver a usarla
		b .Lcopiar_m2_J
	.Lrecuperar_valor_m2:
		strb r5, [r8, r6]			@;guardamos en la casilla el valor que havia anteriormente para no modificar algo erroneo
		b .Lpos_aleatori
	.Lcopiar_m2_J:
		strb r10, [r4, r6]			@;copiamos el contenido de la matriz2 en la matriz de juego
	.Lfinal_construirJ:
		add r6, #1					@;avanza posicion
		add r2, #1					@;avanza columna
		cmp r2, #COLUMNS			
		blo .Lnumero_columnaJ		@;si no esta en el final de la fila avanza al siguiente elemento
		add r1, #1					@;avanza fila
		cmp r1, #ROWS				
		blo .Lnumero_filasJ			@;si no esta en el final avanza al siguiente elemento
		
		pop {r0-r10, pc}


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
