﻿@;=                                                        				=
@;=== candy1_conf.s: variables globales de configuración del juego    ===
@;=                                                       	        	=
@;=== Analista-programador: santiago.romani@urv.cat				  	  ===
@;=                                                       	        	=


@;-- .data. variables (globales) inicializadas ---
.data


@; límites de movimientos para cada nivel;
@;	los límites corresponderán a los niveles 0, 1, 2, ..., hasta MAXLEVEL-1
@;						(MAXLEVEL está definida en 'include/candy1_incl.h')
@;	cada límite debe ser un número entre 3 y 99.
		.global max_mov
	max_mov:	.byte 20, 27, 31, 45, 52, 32, 21, 90, 50 


@; objetivo de puntos para cada nivel;
@;	si el objetivo es cero, se supone que existe otro reto para superar el
@;	nivel, por ejemplo, romper todas las gelatinas.
@;	el objetivo de puntos debe ser un número menor que cero, que se irá
@;	incrementando a medida que se rompan elementos.
		.align 1
		.global pun_obj
	pun_obj:	.hword -1000, -830, -500, 0, -240, -500, -200, -900, 0



@; mapas de configuración de la matriz;
@;	cada mapa debe contener tantos números como posiciones tiene la matriz,
@;	con el siguiente significado para cada posicion:
@;		0:		posición vacía (a rellenar con valor aleatorio)
@;		1-6:	elemento concreto
@;		7:		bloque sólido (irrompible)
@;		8+:		gelatina simple (a sumarle código de elemento)
@;		16+:	gelatina doble (a sumarle código de elemento)
		.global mapas
	mapas:

	@; mapa 0: todo aleatorio
		.byte 3,3,3,4,4,4,6,6,6
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0

	@; mapa 1: paredes horizontales y verticales
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,0,0,0,0,0,0,0,0
		.byte 0,7,7,7,7,7,0,0,0
		.byte 0,7,0,0,0,0,0,0,0
		.byte 0,7,0,0,0,7,7,7,7
		.byte 0,7,0,0,0,0,0,0,7
		.byte 0,0,0,0,0,0,0,0,7
		.byte 0,0,7,7,7,7,0,0,7
		.byte 0,0,0,0,0,0,0,0,7

	@; mapa 2: huecos y bloques sólidos
		.byte 15,15,7,15,0,0,0,0,0
		.byte 0,15,15,7,15,0,0,0,15
		.byte 0,0,0,0,0,15,0,0,15
		.byte 0,0,0,0,0,0,7,7,7
		.byte 0,0,0,0,0,0,0,15,15
		.byte 15,0,15,15,0,0,0,0,15
		.byte 0,0,15,0,0,0,0,0,0
		.byte 0,0,0,0,0,15,0,0,0
		.byte 0,0,0,0,0,0,0,0,15
	
	@; mapa 3: gelatinas simples
		.byte 0,0,0,8,8,8,0,0,15
		.byte 0,0,0,0,8,0,0,0,15
		.byte 0,0,8,8,8,8,0,0,15
		.byte 0,0,8,0,8,0,0,0,15
		.byte 0,0,8,0,8,0,0,0,15
		.byte 0,0,8,0,8,0,0,0,15
		.byte 0,0,8,8,8,8,0,0,15
		.byte 0,0,0,0,0,0,0,0,15
		.byte 0,0,0,0,0,0,0,0,15

	@; mapa 4: gelatinas dobles (+ elementos prefijados)
		.byte 0,15,0,15,0,7,0,15,15
		.byte 0,0,7,0,0,7,0,0,15
		.byte 10,3,8,1,1,8,3,3,0
		.byte 10,1,9,0,0,20,3,4,7
		.byte 17,2,15,15,3,19,4,3,15
		.byte 3,2,10,0,0,20,0,15,0
		.byte 2,3,15,0,0,16,0,0,15
		.byte 0,0,8,0,0,8,0,0,0
		.byte 0,4,7,0,0,7,0,0,15

	@; mapa 5: secuencias en horizontal de 3, 4 y 5 elementos
		.byte 1,1,1,15,2,2,2,2,7
		.byte 3,3,3,3,3,15,7,7,15
		.byte 4,1,4,4,4,4,15,7,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 5,2,2,15,5,5,5,5,5
		.byte 6,5,5,2,5,6,6,6,15
		.byte 15,7,6,6,6,7,7,7,7
		.byte 7,7,7,15,7,7,7,15,15
		.byte 15,15,7,15,15,15,7,15,15

	@; mapa 6: secuencias en vertical de 3, 4 y 5 elementos
		.byte 1,3,4,1,5,6,2,15,15
		.byte 1,3,1,4,2,5,7,15,15
		.byte 1,3,4,4,2,5,15,7,15
		.byte 2,3,4,2,6,15,2,7,15
		.byte 2,3,4,15,6,6,5,7,15
		.byte 2,7,4,3,5,15,6,7,15
		.byte 2,7,15,6,6,5,6,7,7
		.byte 7,15,15,7,7,5,6,7,15
		.byte 15,15,7,15,15,5,7,15,15

	@; mapa 7: combinaciones cruzadas (hor/ver) de 5, 6 y 7 elementos
		.byte 15,15,7,15,15,7,15,15,15
		.byte 1,2,3,3,4,3,7,0,15
		.byte 1,2,7,5,3,7,7,0,15
		.byte 4,1,1,2,3,8,7,0,15
		.byte 1,4,4,2,6,3,7,0,15
		.byte 4,2,2,5,2,2,7,0,15
		.byte 4,5,5,2,5,5,7,0,15
		.byte 7,8,1,5,4,6,8,0,15
		.byte 8,8,8,8,8,8,8,0,15
		
	@; mapa 8: no hay combinaciones ni secuencias
		.byte 15,15,15,15,15,15,15,15,15
		.byte 15,15,15,15,15,15,15,15,15
		.byte 1,2,3,3,7,3,15,15,15
		.byte 1,2,7,5,3,7,15,15,15
		.byte 7,1,1,2,3,9,15,15,15
		.byte 1,4,20,10,9,6,15,15,15
		.byte 6,18,22,5,6,2,15,15,15
		.byte 12,5,4,3,11,5,15,15,15
		.byte 7,7,17,19,4,6,15,15,15


	@; Mapa 9: Combinaciones horizontales con gelatinas y bloques sólidos
    .byte 1, 1, 9, 7, 2, 2, 10, 7, 3
    .byte 0, 0, 0, 7, 0, 0, 0, 7, 0
    .byte 3, 11, 3, 19, 3, 7, 4, 8, 5
    .byte 0, 0, 0, 0, 16, 0, 0, 0, 7
    .byte 1, 2, 2, 7, 2, 2, 2, 7, 0
    .byte 0, 0, 0, 7, 0, 0, 0, 7, 0
    .byte 4, 4, 4, 7, 4, 4, 4, 7, 5
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 7, 7, 7, 7, 7, 7, 7, 7, 7

@; Mapa 10: Combinaciones verticales y horizontales, con gelatina doble
    .byte 2, 2, 2, 0, 0, 0, 0, 0, 0
    .byte 3, 3, 3, 7, 0, 0, 0, 0, 0
    .byte 1, 16, 1, 7, 1, 0, 1, 0, 1
    .byte 0, 0, 0, 7, 0, 0, 0, 0, 0
    .byte 4, 4, 4, 7, 4, 4, 4, 7, 0
    .byte 0, 0, 0, 7, 0, 0, 0, 7, 0
    .byte 5, 5, 5, 7, 5, 5, 5, 7, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 7, 7, 7, 7, 7, 7, 7, 7, 7

@; Mapa 11: Combinaciones interrumpidas
    .byte 3, 11, 3, 0, 0, 0, 0, 0, 7
    .byte 0, 0, 7, 2, 2, 2, 0, 0, 7
    .byte 1, 16, 1, 7, 0, 0, 1, 0, 1
    .byte 0, 0, 0, 7, 0, 0, 0, 0, 0
    .byte 4, 4, 4, 7, 4, 4, 4, 7, 0
    .byte 0, 0, 0, 7, 0, 0, 0, 7, 0
    .byte 5, 5, 5, 7, 5, 5, 5, 7, 0
    .byte 7, 7, 7, 7, 7, 7, 7, 7, 7
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0

@; Mapa 12: Gelatina doble con combinaciones horizontales y verticales
    .byte 16, 2, 2, 2, 10, 2, 7, 0, 0
    .byte 0, 0, 0, 7, 0, 0, 0, 0, 0
    .byte 4, 4, 4, 0, 0, 0, 0, 0, 7
    .byte 7, 0, 0, 0, 7, 0, 0, 0, 7
    .byte 5, 5, 5, 0, 0, 0, 0, 7, 7
    .byte 7, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 1, 1, 1, 0, 0, 0, 0, 0, 0
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0
    .byte 7, 7, 7, 7, 7, 7, 7, 7, 7

@; Mapa 13: Mezcla avanzada con gelatina, bloques y combinaciones
    .byte 5, 5, 5, 0, 16, 0, 0, 0, 7
    .byte 0, 0, 0, 0, 7, 0, 0, 0, 0
    .byte 3, 11, 3, 0, 0, 8, 0, 8, 3
    .byte 0, 0, 0, 0, 16, 0, 0, 0, 7
    .byte 4, 4, 4, 7, 0, 0, 0, 7, 0
    .byte 7, 0, 0, 0, 7, 0, 0, 0, 7
    .byte 6, 6, 6, 7, 6, 6, 6, 7, 0
    .byte 7, 7, 7, 7, 7, 7, 7, 7, 7
    .byte 0, 0, 0, 0, 0, 0, 0, 0, 0


@; Mapa 14: Paredes para bajar diagonal
    .byte 7, 0, 0, 0, 7, 0, 0, 4, 7    
	.byte 0, 7, 0, 0, 7, 0, 0, 7, 0
	.byte 0, 3, 7, 0, 7, 3, 7, 0, 0    
	.byte 0, 0, 4, 7, 7, 7, 0, 0, 0    
	.byte 0, 0, 0, 0, 7, 0, 0, 0, 0
	.byte 0, 2, 0, 0, 0, 0, 2, 0, 0    
	.byte 3, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 0, 0, 0, 0, 0, 0, 0, 0, 0
	.byte 7, 7, 7, 7, 7, 7, 7, 7, 7 


@; Mapa 15: Paredes para bajar diagonal y vertical un poco mas dificil
    .byte 7, 0, 7, 0, 7, 7, 7, 0, 7    
	.byte 7, 0, 0, 0, 15, 0, 0, 0, 7
	.byte 7, 0, 0, 0, 15, 3, 7, 0, 7    
	.byte 7, 0, 0, 0, 15, 0, 7, 0, 7    
	.byte 7, 0, 0, 0, 15, 0, 0, 0, 0
	.byte 7, 7, 0, 0, 15, 0, 0, 0, 0    
	.byte 7, 7, 7, 0, 0, 0, 15, 0, 15
	.byte 7, 7, 7, 7, 0, 0, 0, 0, 0
	.byte 15, 15, 15, 7, 7, 7, 7, 7, 7  



@; Mapa 16: Mezcla de todo, para el baja elementos
    .byte 7,  0,  15, 0,  7,  8,  15, 0,  7   
	.byte 0,  8,  0,  3,  15, 0,  0,  0,  7   
	.byte 8,  3,  0,  15, 8,  0,  7,  0,  15  
	.byte 7,  0,  0,  8,  15, 7,  15, 0,  7   
	.byte 0,  15, 8,  7,  0,  0,  0,  3,  8   
	.byte 7,  7,  0,  0,  15, 0,  0,  0,  0   
	.byte 0,  8,  7,  0,  0,  0,  15, 0,  15  
	.byte 15, 7,  0,  7,  8,  0,  0,  3,  0   
	.byte 15, 15, 15, 7,  7,  7,  7,  7,  15  
