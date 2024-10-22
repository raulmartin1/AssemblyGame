﻿@;=                                                               		=
@;=== candy1_comb.s: rutinas para detectar y sugerir combinaciones    ===
@;=                                                               		=
@;=== Programador tarea 1G: raul.martinm@estudiants.urv.cat				  ===
@;=== Programador tarea 1H: raul.martinm@estudiants.urv.cat				  ===
@;=                                                             	 	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1G;
@; hay_combinacion(*matriz): rutina para detectar si existe, por lo menos, una
@;	combinación entre dos elementos (diferentes) consecutivos que provoquen
@;	una secuencia válida, incluyendo elementos con gelatinas simples y dobles.
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 si hay una secuencia, 0 en otro caso
	.global hay_combinacion
hay_combinacion:
		push {r1-r12, lr}
		mov r4, r0 @; guardamos direccion base matriz en r4 (para que entre en detecta_orientacion)
		mov r1, #0 @; inicializar fila=0
		mov r2, #0 @; inizializar col=0
		mov r0, #6 @; inicializamos r0=6(sin secuencia)
	
		.Lrecorrer_filas: @; ==comprovar combinacion a la derecha==
			cmp r1, #ROWS
			bge .Lfin_filas	 @; si fila>=ROWS salta al final del bucle
			
			.Lrecorrer_columnas:
			cmp r2, #COLUMNS-1 @; si col>=COLUMNS-1 salta al final del bucle
			bge .Lfin_columnas
			
			mov r3, #COLUMNS @;Encontramos la posicion de la matriz 
			mul r5, r1, r3	 @; r5= fila*COLUMNS
			add r5, r2	     @; r5= (fila*COLUMNS)+columna
			ldrb r6, [r4, r5] @; matriu[i][j], gelatina actual
			
			mov r10, r6		  @; guardamos el valor de la gelatian en r10
			tst r6, #0x07		@; comprobamos 0(0000) 8(1000) 16(10000), comprueba si los 3 bits menos significativos son 0
			beq .Lsaltar_posicion
			and r6 ,#0x7		@; nos quedamos con los 3 bits menos signficativos de r6 en r6
			cmp r6, #7			@; comprobamos 7(0111) y 15(1111)
			beq .Lsaltar_posicion
			mov r6, r10
			
			add r5, #1		@; Sumamos una posicion a la derecha
			ldrb r7, [r4, r5] 	@; cargar la gelatina de la derecha en r7
			
			mov r10, r7		  @; guardamos el valor de la gelatian en r10
			tst r7, #0x07		@; comprobamos 0(0000) 8(1000) 16(10000), comprueba si los 3 bits menos significativos son 0)
			beq .Lsaltar_posicion
			and r7 ,#0x7		@; nos quedamos con los 3 bits menos signficativos de r7 en r7
			cmp r7, #7			@; comprobamos 7(0111) y 15(1111)
			beq .Lsaltar_posicion
			mov r7, r10
			
			and r8, r6, #0x07 @; r8= mascara de la gelatina actual per poder comparar bits baixos(r8=bits baixos)
			and r9, r7, #0x07 @; r9= mascara de la gelatina de la dreta
			cmp r8, r9	@; comaparem si son iguals no intercanvien posicio
			beq .LgelatinaIgualH @; si gelatina de la derecha igual salta
			strb r6, [r4, r5]	@; guardem la gelatina de la actual en la dreta
			sub r5, #1			@; obtenemos la posicion original de la que se ha movido
			strb r7, [r4, r5]	@; la gelatina de la derecha en la poscion que era de la actual
			
			.LgelatinaIgualH:	@;gelatinas iguales Horizontales
			bl detecta_orientacion
			cmp r0, #6				@; 6-> no hay secuencia
			bne .Lhay_combinacionH @; si troba combinacio salta al final
			add r2, #1
			bl detecta_orientacion @; mira si hay sequencia en la gelatina de la derecha
			sub r2, #1
			cmp r0, #6
			bne .Lhay_combinacionH
			cmp r8, r9
			beq .Lsaltar_posicion
			strb r6, [r4,r5]	@; tornem a colocar la gelatina actual en la seva posicio original
			add r5, #1
			strb r7, [r4, r5]	@; la gelatina de la dreta en la seva posicio original
			.Lsaltar_posicion:
			add r2, #1			@; col++
			b .Lrecorrer_columnas	@;seguent columna
			.Lfin_columnas:
			add r1, #1 @; fila++
			mov r2, #0	@; col=0
		b .Lrecorrer_filas	@; seguent fila
		.Lfin_filas:
		mov r1, #0	@; primera posicion de la tabla
		mov r2, #0
		.Lrecorrer_filas2: @; ==comprovacion combinacion hacia abajo==
			cmp r1, #ROWS-1
			bge .Lsaltar_final
			.Lrecorrer_columnas2:
			cmp r2, #COLUMNS
			bge .Lfin_columnas2
			mul r5, r1, r3  @; r5= fila*COLUMNS
			add r5, r2	     @; r5= (fila*COLUMNS)+columna
			ldrb r6, [r4, r5] @; matriu[i][j], gelatina actual 
			
			mov r10, r6		  @; guardamos el valor de la gelatian en r10
			tst r6, #0x07		@; comprobamos 0(0000) 8(1000) 16(10000), comprueba si los 3 bits menos significativos son 0)
			beq .Lsaltar_posicion2
			and r6 ,#0x7		@; nos quedamos con los 3 bits menos signficativos de r6 en r6
			cmp r6, #7			@; comprobamos 7(0111) y 15(1111)
			beq .Lsaltar_posicion2
			mov r6, r10
			
			add r5, r3		@; r5 = r5+COLUMNS, bajamos una posicion (siguiente fila)
			ldrb r7, [r4, r5] 	@; cargar la gelatina de debajo en r7
			
			mov r10, r7		  @; guardamos el valor de la gelatian en r10
			tst r7, #0x07		@; comprobamos 0(0000) 8(1000) 16(10000), comprueba si los 3 bits menos significativos son 0)
			beq .Lsaltar_posicion2
			and r7 ,#0x7		@; nos quedamos con los 3 bits menos signficativos de r6 en r6
			cmp r7, #7			@; comprobamos 7(0111) y 15(1111)
			beq .Lsaltar_posicion2
			mov r7, r10
			
			and r8, r6, #0x07 @; r8= mascara de la gelatina actual per poder comparar bits baixos(r8=bits baixos)
			and r9, r7, #0x07 @; r9= mascara de la gelatina de debajo
			cmp r8, r9		@; comaparem si son iguals no intercanvien posicio
			beq .LgelatinaIgualV
			strb r6, [r4, r5] @; gelatina actual al lloc de la de sota
			sub r5, r3		  @; restem una COLUMNS per pujar una fila
			strb r7, [r4, r5] @; gelatina de sota al lloc de la actual
			
			.LgelatinaIgualV:
			bl detecta_orientacion	@;comprova si hay combinacion en la posicion de la actual
			cmp r0, #6
			bne .Lhay_combinacionV @; si hi ha combinacio (r0 != 6) salta al final
			add r1, #1				@; fila++, posicio de sota
			bl detecta_orientacion @;comprova si hay combinacion en la de debajo 
			sub r1, #1
			cmp r0, #6
			bne .Lhay_combinacionV
			cmp r8, r9
			beq .Lsaltar_posicion2	@; si no eran iguals tornem a colocarlas al lloc original
			strb r6, [r4, r5]		@; gelatina actual al seu lloc	
			add r5, r3
			strb r7, [r4, r5]		@; gelatina de sota al seu lloc
			.Lsaltar_posicion2:
			add r2, #1				@; c++ seguent columna
			b .Lrecorrer_columnas2
			.Lfin_columnas2:
			add r1, #1				@; fila++
			mov r2, #0				@; col++, primera columna de la siguiente fila
		b .Lrecorrer_filas2
		
		.Lhay_combinacionH:	@;coloquem les gelatines al seu lloc original en cas de combinacio trobada horitzontal
		cmp r8, r9
		beq .Lsaltar_final 
		strb r6, [r4, r5]
		add r5, #1
		strb r7, [r4, r5]
		b .Lsaltar_final
		.Lhay_combinacionV: @; coloquem les gelatines al seu lloc origina en cas de combinacion trobada vertical
		cmp r8, r9
		beq .Lsaltar_final 
		strb r6, [r4, r5]
		add r5, r3
		strb r7, [r4, r5]
		
		.Lsaltar_final:
		cmp r0, #6
		bne .Lcomb_trobada
		mov r0, #0	@; si r0=6 -> r0=0 no hay combinacion
		b .Lfinal 
		
		.Lcomb_trobada:
		mov r0, #1		@; si r0!=6 -> r0=1 hay combinacion
		.Lfinal:
		pop {r1-r12, pc}


@;TAREA 1H;
@; sugiere_combinacion(*matriz, *psug): rutina para detectar una combinación
@;	entre dos elementos (diferentes) consecutivos que provoquen una secuencia
@;	válida, incluyendo elementos con gelatinas simples y dobles, y devolver
@;	las coordenadas de las tres posiciones de la combinación (por referencia).
@;	Restricciones:
@;		* se asume que existe por lo menos una combinación en la matriz
@;			 (se debe verificar antes con la rutina hay_combinacion())
@;		* la combinación sugerida tiene que ser escogida aleatoriamente de
@;			 entre todas las posibles, es decir, no tiene que ser siempre
@;			 la primera empezando por el principio de la matriz (o por el final)
@;		* para obtener posiciones aleatorias, se invocará la rutina mod_random()
@;			 (ver fichero 'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = dirección del vector de posiciones (unsigned char *), donde se
@;				guardarán las coordenadas (x1,y1,x2,y2,x3,y3), consecutivamente.
	.global sugiere_combinacion
sugiere_combinacion:
		push {r2-r12, lr}
		mov r4, r0	@; guaradamos direccion base de la matriz de juego
		mov r6, r1	@; guardamos direccion vector de posiciones
		
		mov r1, #0			@; inicializamos fila
		mov r2, #0			@; inicalizamos cols
		mov r3, #6			@; c.ori a 6 (sin secuencia)
		mov r5, #0			@; inicializamos c.p.i a 0
		
		mov r7, #0			@; inicializamos posicion de la gelatina
		mov r8, #COLUMNS
		
		mov r0, #ROWS		@; ROWS A r0 ya que es valor de entrada a mod_random
		bl mod_random		@; retorna una fila random
		mov r1, r0
		mov r0, #COLUMNS
		bl mod_random	@; retorna una columna random
		mov r2, r0
		b .Lrecorrer_sugerencia
		.Lpunt_inicial:			@; si no ha trobat una sugerencia, comença desde el principi
		mov r1, #0
		mov r2, #0
		.Lrecorrer_sugerencia:
			mul r7, r1, r8		@; r4= fila*COLUMNS
			add r7, r2	     	@; r4= (fila*COLUMNS)+columna
			ldrb r9, [r4, r7] 	@; r9= matriu[i][j], gelatina actual
			cmp r9, #0			@; comprobar si hay un bloque especial
			and r11, r9, #0x7	@; cogemos los 3 bits bajos de r9
								@; si hay bloque especial salta a mirar siguiente gelatina
			cmp r11, #0			@; miramos si es espacio vacio 0 8 16
			beq .Lsaltar_sugerencia
			cmp r9, #0x7		@; miramos si es bloque solido (7)
			beq .Lsaltar_sugerencia
			cmp r9, #0xF		@; miramos si es hueco (15)
			beq .Lsaltar_sugerencia 
								@; ==comprobar combinacion a la derecha==
			cmp r2, #COLUMNS-1	@; que no este en la ultima columna
			beq .Lintercambiar1 @; si estamos en la ultima col no intercambiar
			add r7, #1			@; siguiente posicion
			ldrb r10, [r4, r7]	@; r10= gelatina de la derecha
			sub r7, #1
			and r12, r10, #0x7	
			
			cmp r12, #0			@; bloque vacio (0, 8, 16)
			beq .Lintercambiar1			
			cmp r10, #0x7				
			beq .Lintercambiar1	@; bloque solido (7)
			cmp r10, #0xF				
			beq .Lintercambiar1	@; hueco (15)
			
			cmp r11, r12
			beq .Lsaltar_sugerencia @; si son iguales no intercambiar(no habra posible comb intercambiandolas) 
			strb r10, [r4, r7]		@; la gelatina de la derecha en la pos de la actual
			add r7, #1			
			strb r9, [r4, r7]		@; gelatina actual en la pos de la derecha
			sub r7, #1
			bl detecta_orientacion
			mov r5, #0					@; c.p.i=0 (gelatina que genera combinacion a la izquierda)
			cmp r0, #6					@; r0 = 6 -> no hay secuencia
			bne .LdeshacerIntercambio2	@; si hay secuencia se deshace
			
			add r2, #1				@; miramos si hay secuencia en la pos de la derecha
			bl detecta_orientacion
			mov r5, #1				@; c.p.i=1 (gelatina que genera combinacion a la derecha)
			cmp r0, #6
			bne .LdeshacerIntercambio2
			sub r2, #1				@; si no hay secuencia se vuelve a la posicion incial
			
			.LdeshacerIntercambio2:	@; hay sugerencia, deshacemos el intercambio
			strb r9, [r4, r7]		@; gelatina actual a su pos inicial
			add r7, #1
			strb r10, [r4, r7]		@; gelatina de la derecha a su pos inicial
			sub r7, #1
			cmp r0, #6
			bne .Lhay_sugerencia		
									@; ==comprobar combinacion abajo==
			.Lintercambiar1:		@; Esta en la ultima columna
			cmp r1, #ROWS-1			@; comprobamos que no estamos en la ultima fila
			beq .Lsaltar_sugerencia	@; si estamos en la ultiam fila salta
			add r7, #COLUMNS 		@; bajamos una fila
			ldrb r10, [r4, r7]		@; gelatina de debajo
			and r12, r10, #0x7
			
			cmp r12, #0				@; bloque vacio (0, 8, 16)
			beq .Lsaltar_sugerencia			
			cmp r10, #0x7				
			beq .Lsaltar_sugerencia	@; bloque solido (7)
			cmp r10, #0xF				
			beq .Lsaltar_sugerencia	@; hueco (15)
			
			cmp r11, r12			
			beq .Lsaltar_sugerencia		@; si son iguales no intercambiar
			strb r9, [r4, r7]			@; gelatina actual la ponemos abajo
			sub r7, #COLUMNS			
			strb r10, [r4, r7]			@; gelatina inferior la ponemos arriba
			bl detecta_orientacion
			mov r5, #2					@; c.p.i=2 (gelatina que genera comb arriba)
			cmp r0, #6
			bne .LdeshacerIntercambio1	@; si hay sug->deshacer
			
			add r1, #1					@;miramos si hay sugerencia en la de abajo
			bl detecta_orientacion			
			mov r5, #3					@; c.p.i=3 (gelatina que genera comb abajo)	
			cmp r0, #6
			bne .LdeshacerIntercambio1	@; si hay sug->deshacer
			sub r1, #1
			
			.LdeshacerIntercambio1:
			strb r9, [r4, r7]
			add r7, #COLUMNS
			strb r10, [r4, r7]
			sub r7, #COLUMNS
			cmp r0, #6
			bne .Lhay_sugerencia
			
			.Lsaltar_sugerencia:
			add r2, #1
			cmp r2, #COLUMNS
		bne .Lrecorrer_sugerencia	@;si col!=COLUMNS siguiente col
			add r1, #1					@; fila++
			mov r2, #0					@; col=0
			cmp r1, #ROWS				
		bne .Lrecorrer_sugerencia	@; si fila !=ROWS siguiente fila
			
		b .Lpunt_inicial			@; si no se ha encontrado aun, comenzar desde la posicion inicial
			
		.Lhay_sugerencia:
		mov r4, r5					@; r4= c.p.i para entrar a genera_posiciones
		mov r3, r0					@; r3= c.ori
		mov r0, r6					@; recuperamos direccion vector de posiciones
		bl genera_posiciones		@; si ha encontrado la sugerencia-> genera las posiciones de sugerencia
			
		pop {r2-r12, pc}
				
		

@;:::RUTINAS DE SOPORTE:::

@; genera_posiciones(vect_pos, f, c, ori, cpi): genera las posiciones de 
@;	sugerencia de combinación, a partir de la posición inicial (f,c), el código
@;	de orientación ori y el código de posición inicial cpi, dejando las
@;	coordenadas en el vector vect_pos[].
@;	Restricciones:
@;		* se asume que la posición y orientación pasadas por parámetro se
@;			corresponden con una disposición de posiciones dentro de los
@;			límites de la matriz de juego
@;	Parámetros:
@;		R0 = dirección del vector de posiciones vect_pos[]
@;		R1 = fila inicial f
@;		R2 = columna inicial c
@;		R3 = código de orientación ori:
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;		R4 = código de posición inicial cpi:
@;				0 -> izquierda, 1 -> derecha, 2 -> arriba, 3 -> abajo
@;	Resultado:
@;		vector de posiciones (x1,y1,x2,y2,x3,y3), devuelto por referencia
genera_posiciones:
		push {r1-r12, lr}
		cmp r4, #0	@; comparamos c.p.i=0 , c.ori pot ser 1,2,3 o 5
		bne .Lsaltar_cpi0
			mov r5, #0 @; inicializamos vector
			add r2, #1 @; sumamos una columna, posicion de la derecha
			strb r2, [r0, r5] @; guardamos de la derecha (x1=columna) 
			add r5, #1			@; siguiente posicion del vector
			strb r1, [r0, r5]   @; guardamos la fila inicial (y1=fila)
			sub r2, #1 
			cmp r3, #1			@; comprovamos c.ori=1
			bne .Lsaltar_cori1_0
				add r5, #1			@; siguiente posicion del vector
				strb r2, [r0, r5]	@; columna se queda igual 
				add r5, #1			@; siguiente posicion del vector
				add r1, #1				 
				strb r1, [r0, r5] 	@; posicion de debajo(siguiente fila)
				add r5, #1
				strb r2, [r0, r5] 	@; la columna no varia
				add r5, #1
				add r1, #1			
				strb r1, [r0, r5]	@; dos filas hacia abajo
				b .Lfi_generar		@; ya ha generado el vector de posiciones
		.Lsaltar_cori1_0:
		cmp r3, #2 	@; comparamos c.ori=2
		bne .Lsaltar_cori2_0 
				sub r2, #1
				add r5, #1
				strb r2, [r0, r5]	@;columna de la izquierda
				add r5, #1
				strb r1, [r0, r5] 	@; fila no varia
				add r5, #1
				sub r2, #1			
				strb r2, [r0, r5]	@; dos columnas a la izquierda
				add r5, #1
				strb r1, [r0, r5]  @; fila no varia
				b .Lfi_generar
		.Lsaltar_cori2_0:
		cmp r3, #3 		@; comprovamos c.ori=3
		bne .Lsaltar_cori3_0
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1
				strb r1, [r0, r5]	@; fila de arriba
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1			
				strb r1, [r0, r5]	@; fila dos arriba
				b .Lfi_generar
		.Lsaltar_cori3_0:
		cmp r3, #5				@; comprovamos c.ori=5
		bne .Lsaltar_cori5_0
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1
				strb r1, [r0, r5]	@; fila de arriba
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				add r1, #2
				strb r1, [r0, r5]	@; fila de debajo de la original
				b .Lfi_generar
		.Lsaltar_cori5_0:
		.Lsaltar_cpi0:
		cmp r4, #1					@; comparar c.p.i=1, c.ori pot ser 0, 1, 3 o 5
		bne .Lsaltar_cpi1
			mov r5, #0				@; inicializamos vector de posiciones
			sub r2, #1				
			strb r2, [r0, r5]		@; guardamos posicion izquierda
			add r5, #1
			strb r1, [r0, r5]		@; fila no varia
			add r2, #1				@; c++ para alinear los bloques
			cmp r3, #0	@; comprovamos si c.ori=0
			bne .Lsaltar_cori0_1
				add r5, #1
				add r2, #1
				strb r2, [r0, r5]	@; posicion de la derecha
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				add r5, #1
				add r2, #1
				strb r2, [r0, r5]	@; posicion de dos a la derecha
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				b .Lfi_generar
			.Lsaltar_cori0_1:
			cmp r3, #1			@; comprovamos c.ori=1
			bne .Lsaltar_cori1_1
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				add r1, #1
				strb r1, [r0, r5]	@; fila de debajo
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				add r1, #1
				strb r1, [r0, r5]	@; dos filas hacia abajo
				b .Lfi_generar
			.Lsaltar_cori1_1:
			cmp r3, #3				@; comprovamos c.ori=3
			bne .Lsaltar_cori3_1
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1
				strb r1, [r0, r5]	@; fila de arriba
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1
				strb r1, [r0, r5]	@; dos filas hacia arriba
				b .Lfi_generar
			.Lsaltar_cori3_1:
			cmp r3, #5				@; comprovamos si c.ori=5
			bne .Lsaltar_cori5_1
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1			
				strb r1, [r0, r5]	@; fila de arriba
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				add r1, #2
				strb r1, [r0, r5]	@; fila de debajo de la inicial
				b .Lfi_generar
		.Lsaltar_cori5_1:
		.Lsaltar_cpi1:
		cmp r4, #2				@; comparar c.p.i=2, c.ori pot ser 0, 2, 3 o 4			
		bne .Lsaltar_cpi2
			mov r5, #0			@; inicializamos vector de pos
			strb r2, [r0, r5]	@; col no varia (x1)
			add r5, #1
			add r1, #1
			strb r1, [r0, r5]	@; guardamos posicion de debajo (y1)
			sub r1, #1			@; dejamos la fila donde estaba para dejar los bloques alineados
			cmp r3, #0			@; comprovamos si c.ori=0
			bne .Lsaltar_cori0_2	
				add r5, #1
				add r2, #1
				strb r2, [r0, r5]	@; columna de la derecha
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				add r5 ,#1
				add r2, #1
				strb r2, [r0, r5]	@; columan de dos a la derecha
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				b .Lfi_generar
			.Lsaltar_cori0_2:
			cmp r3, #2				@; comprovamos si c.ori=2
			bne .Lsaltar_cori2_2
				add r5, #1
				sub r2, #1
				strb r2, [r0, r5]	@; columna de la izquierda
				add r5, #1
				strb r1, [r0, r5] 	@; fila no varia
				add r5, #1
				sub r2, #1
				strb r2, [r0, r5]	@; dos columnas a la izquierda
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				b .Lfi_generar
			.Lsaltar_cori2_2:
			cmp r3, #3				@; comprovamos si c.ori=3
			bne .Lsaltar_cori3_2
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1
				strb r1, [r0, r5]	@; fila de arriba
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				sub r1, #1
				strb r1, [r0, r5]	@; dos filas hacia arriba
				b .Lfi_generar
			.Lsaltar_cori3_2:
			cmp r3, #4				@; comprovamos c.ori=4
			bne .Lsaltar_cori4_2
				add r5, #1
				sub r2, #1
				strb r2, [r0, r5]	@; col de la izquierda
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				add r5, #1
				add r2, #2
				strb r2, [r0, r5]	@; col de la derecha a la inicial
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				b .Lfi_generar
		.Lsaltar_cori4_2:
		.Lsaltar_cpi2:
		cmp r4, #3 				@; comparar c.p.i=3, c.ori pot ser 0, 1, 2 o 4
		bne .Lsaltar_cpi3
			mov r5, #0				@; inicializamos vector de pos
			strb r2, [r0, r5]		@; col no varia
			add r5, #1
			sub r1, #1
			strb r1, [r0, r5]		@; guardamos la fila de arriba
			add r1, #1				@; volvemos a la fila para alinear los bloques
			cmp r3, #0				@; comprovamos si c.ori = 0
			bne .Lsaltar_cori0_3
				add r5, #1
				add r2, #1
				strb r2, [r0, r5]	@; col de la derecha
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				add r5, #1
				add r2, #1
				strb r2, [r0, r5]	@; dos columnas a la derecha
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				b .Lfi_generar
			.Lsaltar_cori0_3:
			cmp r3, #1				@; comprovamos si c.ori=1
			bne .Lsaltar_cori1_3
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				add r1, #1
				strb r1, [r0, r5]	@; fila de debajo
				add r5, #1
				strb r2, [r0, r5]	@; col no varia
				add r5, #1
				add r1, #1
				strb r1, [r0, r5]	@; dos filas hacia abajo
				b .Lfi_generar
			.Lsaltar_cori1_3:
			cmp r3, #2				@; comprovamos c.ori=2
			bne .Lsaltar_cori2_3
				add r5, #1
				sub r2, #1
				strb r2, [r0, r5]	@; columna de la izquierda
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				add r5, #1
				sub r2, #1
				strb r2, [r0, r5]	@; dos columnas a la izquierda
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				b .Lfi_generar
			.Lsaltar_cori2_3:
			cmp r3, #4			@; comprovamos c.ori=4
			bne .Lsaltar_cori4_3
				add r5, #1
				sub r2, #1
				strb r2, [r0, r5]	@; columna de la izquierda
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				add r5, #1
				add r2, #2
				strb r2, [r0, r5]	@; columna de la derecha de la inicial
				add r5, #1
				strb r1, [r0, r5]	@; fila no varia
				b .Lfi_generar
			.Lsaltar_cori4_3:
		.Lsaltar_cpi3:
		.Lfi_generar:
			
		pop {r1-r12, pc}
		

@; detecta_orientacion(f, c, mat): devuelve el código de la primera orientación
@;	en la que detecta una secuencia de 3 o más repeticiones del elemento de la
@;	matriz situado en la posición (f,c).
@;	Restricciones:
@;		* para proporcionar aleatoriedad a la detección de orientaciones en las
@;			que se detectan secuencias, se invocará la rutina mod_random()
@;			(ver fichero 'candy1_init.s')
@;		* para detectar secuencias se invocará la rutina cuenta_repeticiones()
@;			(ver fichero 'candy1_move.s')
@;		* solo se tendrán en cuenta los 3 bits de menor peso de los códigos
@;			almacenados en las posiciones de la matriz, de modo que se ignorarán
@;			las marcas de gelatina (+8, +16)
@;	Parámetros:
@;		R1 = fila f
@;		R2 = columna c
@;		R4 = dirección base de la matriz
@;	Resultado:
@;		R0 = código de orientación;
@;				inicio de secuencia: 0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte
@;				en medio de secuencia: 4 -> horizontal, 5 -> vertical
@;				sin secuencia: 6 
detecta_orientacion:
		push {r3, r5, lr}
		
		mov r5, #0				@;R5 = índice bucle de orientaciones
		mov r0, #4
		bl mod_random
		mov r3, r0				@;R3 = orientación aleatoria (0..3)
	.Ldetori_for:
		mov r0, r4
		bl cuenta_repeticiones
		cmp r0, #1
		beq .Ldetori_cont		@;no hay inicio de secuencia
		cmp r0, #3
		bhs .Ldetori_fin		@;hay inicio de secuencia
		add r3, #2
		and r3, #3				@;R3 = salta dos orientaciones (módulo 4)
		mov r0, r4
		bl cuenta_repeticiones
		add r3, #2
		and r3, #3				@;restituye orientación (módulo 4)
		cmp r0, #1
		beq .Ldetori_cont		@;no hay continuación de secuencia
		tst r3, #1
		moveq r3, #4			@;detección secuencia horizontal
		beq .Ldetori_fin
	.Ldetori_vert:
		mov r3, #5				@;detección secuencia vertical
		b .Ldetori_fin
	.Ldetori_cont:
		add r3, #1
		and r3, #3				@;R3 = siguiente orientación (módulo 4)
		add r5, #1
		cmp r5, #4
		blo .Ldetori_for		@;repetir 4 veces
		
		mov r3, #6				@;marca de no encontrada
		
	.Ldetori_fin:
		mov r0, r3				@;devuelve orientación o marca de no encontrada
		
		pop {r3, r5, pc}

.end
