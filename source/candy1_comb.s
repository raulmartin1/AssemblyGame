@;=                                                               		=
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
		push {r1-r9, lr}
		mov r3, r0 @; guardamos direccion base matriz en r3
		mov r1, #0 @; inicializar fila=0
		mov r2, #0 @; inizializar col=0
		mov r0, #0 @; si "hay combinacion" se inicializa a 0
	
		.Lrecorrer_filas: @; comprovar combinacion a la derecha
		cmp r1, #R0WS
		bge .Lfin_filas	 @; si fila>=ROWS salta al final del bucle
		
		.Lrecorrer_columnas:
		cmp r2, #COLUMNS-1 @; si col>=COLUMNS-1 salta al final del bucle
		bge .Lfin_columnas
		
		mov r4, #COLUMNS @;Encontramos la posicion de la matriz 
		mul r5, r1, r4	 @; r3= fila*COLUMNS
		add r5, r2	     @; r3= (fila*COLUMNS)+columna
		ldrb r6, [r3, r5] @; matriu[i][j], gelatina actual
		
		cmp r6, #0 		  @; Comprobar si no es un espacio vacio (0, 8, 16), un bloque solido (7) o un hueco (15)
		beq .Lsaltar_posicion
		cmp r6, #8						
		beq .Lsaltar_posicion				
		cmp r6, #16					
		beq .Lsaltar_posicion				
		cmp r6, #7						
		beq .Lsaltar_posicion
		cmp r6, #15						
		beq .Lsaltar_posicion
		add r5, #1		@; Sumamos una posicion a la derecha
		ldrb r7, [r3, r5] 	@; cargar la gelatina de la derecha en r7
		cmp r7, #0 		  @; Comprobar si no es un espacio vacio (0, 8, 16), un bloque solido (7) o un hueco (15)
		beq .Lsaltar_posicion
		cmp r7, #8						
		beq .Lsaltar_posicion				
		cmp r7, #16					
		beq .Lsaltar_posicion				
		cmp r7, #7						
		beq .Lsaltar_posicion
		cmp r7, #15						
		beq .Lsaltar_posicion
		and r8, r6, #0x07 @; r8= mascara de la gelatina actual per poder comparar bits baixos(r8=bits baixos)
		and r9, r7, #0x07 @; r9= mascara de la gelatina de la dreta
		cmp r8, r9	@; comaparem si son iguals no intercanvien posicio
		beq .LgelatinaIgualH @; si gelatina de la derecha igual salta
		strb r6, [r3, r5]	@; guardem la gelatina de la actual en la dreta
		sub r5, #1			@; obtenemos la posicion original de la que se ha movido
		strb r7, [r3, r5]	@; la gelatina de la derecha en la poscion que era de la actual
		
		.LgelatinasIgualesH:	@;gelatinas iguales Horizontales
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
		strb r6, [r3,r5]	@; tornem a colocar la gelatina actual en la seva posicio original
		add r5, #1
		strb r7, [r3, r5]	@; la gelatina de la dreta en la seva posicio original
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
		.Lrecorrer_filas2: @; comprovacion combinacion hacia abajo
		cmp r1, #ROWS-1
		bge .Lsaltar_final
		.Lrecorrer_columnas2:
		cmp r2, #COLUMNS
		bge .Lfin_columnas2
		mul r5, r1, r4  @; r3= fila*COLUMNS
		add r5, r2	     @; r3= (fila*COLUMNS)+columna
		ldrb r6, [r3, r5] @; matriu[i][j], gelatina actual 
		cmp r6, #0
		beq .Lsaltar_posicion2
		cmp r6, #8						
		beq .Lsaltar_posicion2				
		cmp r6, #16					
		beq .Lsaltar_posicion2				
		cmp r6, #7						
		beq .Lsaltar_posicion2
		cmp r6, #15						
		beq .Lsaltar_posicion2
		add r5, r4		@; r5 = r5+COLUMNS, bajamos una posicion (siguiente fila)
		ldrb r7, [r3, r5] 	@; cargar la gelatina de debajo en r7
		cmp r7, #0 		  @; Comprobar si no es un espacio vacio (0, 8, 16), un bloque solido (7) o un hueco (15)
		beq .Lsaltar_posicion2
		cmp r7, #8						
		beq .Lsaltar_posicion2				
		cmp r7, #16					
		beq .Lsaltar_posicion2				
		cmp r7, #7						
		beq .Lsaltar_posicion2
		cmp r7, #15						
		beq .Lsaltar_posicion2
		and r8, r6, #0x07 @; r8= mascara de la gelatina actual per poder comparar bits baixos(r8=bits baixos)
		and r9, r7, #0x07 @; r9= mascara de la gelatina de debajo
		cmp r8, r9		@; comaparem si son iguals no intercanvien posicio
		beq .LgelatinaIgualV
		strb r6, [r3, r5] @; gelatina actual al lloc de la de sota
		sub r5, r4		  @; restem una COLUMNS per pujar una fila
		strb r7, [r3, r5] @; gelatina de sota al lloc de la actual
		
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
		strb r6, [r3, r5]		@; gelatina actual al seu lloc	
		add r5, r4
		strb r7, [r3, r5]		@; gelatina de sota al seu lloc
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
		strb r6, [r3, r5]
		add r5, #1
		strb r7, [r3, r5]
		b .Lsaltar_final
		.Lhay_combinacionV: @; coloquem les gelatines al seu lloc origina en cas de combinacion trobada vertical
		cmp r8, r9
		beq .Lsaltar_final 
		strb r6, [r3, r5]
		add r5, r4
		strb r7, [r3, r5]
		
		.Lsaltar_final:
		cmp r0, #6
		bne .Lcomb_trobada
		mov r0, #0	@; si r0=6 -> r0=0 no hay combinacion
		b .Lfinal 
		
		.Lcomb_trobada:
		mov r0, #1		@; si r0!=6 -> r0=1 hay combinacion
		.Lfinal:
		pop {r1-r9, pc}


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
		push {lr}
		
		
		pop {pc}




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
		push {lr}
		
		
		pop {pc}



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
