/*------------------------------------------------------------------------------

	$ candy1_main.c $

	Programa principal para la prÃ¡ctica de Computadores: candy-crash para NDS
	(2Âº curso de Grado de IngenierÃ­a InformÃ¡tica - ETSE - URV)
	
	Analista-programador: santiago.romani@urv.cat
	Programador 1: david.quintana@estudiants.urv.cat
	Programador 2: yyy.yyy@estudiants.urv.cat
	Programador 3: nicolas.canton@estudiants.urv.cat
	Programador 4: raul.martinm@estudiants.urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include <time.h>
#include "candy1_incl.h"


/* ATENCIÃ“N: cuando el programa se considere terminado, hay que comentar la
			 lÃ­nea '#define TRUCOS' y volver a compilar, con el fin de generar
			 un fichero ejecutable libre del cÃ³digo de trucos.
*/
#define TRUCOS		// si se define este sÃ­mbolo se generarÃ¡ un ejectuable con
					// los trucos que permiten controlar el juego para testear
					// su funcionamiento, pulsando los siguientes botones:
					//	'B' 	 ->	pasa al siguiente nivel
					//	'START'	 ->	reinicia el nivel actual
					//	'<' 	 ->	pasa a modo backup, donde se puede ver
					//				el contenido del tablero y la informaciÃ³n
					//				de juego (puntos, movimientos restantes,
					//				gelatinas) de momentos anteriores del juego,
					//				con los botones de flecha izquierda/derecha:
					//				 '<'	 ->	ver momento anterior
					//				 '>'	 ->	ver momento siguiente

/* definiciones del programa */
						// definiciones para el estado actual del juego
#define E_INIT		0		// inicializar nivel actual del juego
#define E_PLAY		1		// interacciÃ³n con el usuario
#define E_BREAK		2		// romper secuencias y gelatinas
#define E_FALL		3		// caÃ­da de los elementos
#define E_CHECK		4		// comprobar condiciones de fin de nivel

						// definiciones para la funciÃ³n procesa_caida()
#define PC_FALLING	0		// todavÃ­a estan cayendo elementos
#define PC_ENDNOSQ	1		// ya no hay caÃ­das y no se ha generado ninguna secuencia
#define PC_ENDSEQ	2		// ya no hay caÃ­das y se han generado nuevas secuencias

						// definiciones para la funciÃ³n comprueba_jugada()
#define CJ_CONT		0		// no ha pasado nada especial, seguir jugando en el mismo nivel
#define	CJ_LEVEL	1		// el nivel se ha superado o no, hay que iniciar siguiente nivel o reiniciar nivel actual
#define	CJ_RCOMB	2		// se ha producido una recombinaciÃ³n y se han generado nuevas combinaciones
#define	CJ_RNOCMB	3		// se ha producido una recombinaciÃ³n pero no hay nuevas combinaciones

						// definiciones para la gestiÃ³n de sugerencias
#define T_INACT		192		// tiempo de inactividad del usuario (3 seg. aprox.)
#define T_MOSUG		64		// tiempo entre mostrar sugerencias (1 seg. aprox.)


/* variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
char mat_mar[ROWS][COLUMNS];	// matriz de marcas
unsigned char pos_sug[6];		// posiciones de una sugerencia de combinaciÃ³n

unsigned int seed32;			// semilla de nÃºmeros aleatorios


#ifdef TRUCOS

#define MAXBACKUP	36			// memoria para el 'backup' de la evoluciÃ³n del
char b_mat[MAXBACKUP][ROWS][COLUMNS];	// tablero mÃ¡s la informaciÃ³n de juego
unsigned int b_info[MAXBACKUP];			// (puntos, movimientos, gelatinas)
unsigned short b_last, b_num;			// Ãºltimo Ã­ndice y nÃºmero de backups


/* guarda_backup(*mat,p,m,g): guarda una copia de la matriz que se pasa por
	parÃ¡metro, junto con los valores de informaciÃ³n del juego (puntos, 
	movimientos restantes, gelatinas); utiliza las variables globales b_mat y
	b_info, incrementando el valor de b_last como Ã­ndice de la Ãºltima entrada
	de b_mat e incrementa el nÃºmero de momentos registrados en b_num, hasta
	un mÃ¡ximo establecido con MAXBACKUP.
*/
void guarda_backup(char mat[][COLUMNS], short p, unsigned char m,
													unsigned char g)
{
	b_last = (b_last + 1) % MAXBACKUP;		// incremento circular Ãºltimo Ã­ndice
	copia_matriz(b_mat[b_last], mat);
	b_info[b_last] = (p << 16) | (m << 8) | g;
	if (b_num < MAXBACKUP) b_num++;	// aumentar nÃºmero backups (hasta MAXBACKUP)
}



/* actualizar_contadores_backup(p,m,g): escribe la informaciÃ³n de juego que
	se pasa por parÃ¡metro, utilizando un color diferente del habitual (amarillo)
	para dar la sensaciÃ³n al usuario que estÃ¡ visualizando un momento anterior
	del juego.
*/
void actualiza_contadores_backup(short p, unsigned char m, unsigned char g)
{
	printf("\x1b[43m\x1b[2;8H %d  ", p);
	printf("\x1b[43m\x1b[1;28H %d ", m);
	printf("\x1b[43m\x1b[2;28H %d ", g);
}



/* muestra_recuadro(modo): permite mostrar un recuadro al tablero de juego para
	dar la sensaciÃ³n al usuario de que estÃ¡ en modo backup; el parÃ metro de modo
	servirÃ¡ para canviar el color del recuadro (o borrarlo):
		modo = 0	-> ocultar recuadro (negro)
		modo = 1	-> recuadro de momentos genÃ©ricos (amarillo oscuro)
		modo = 2	-> recuadro de interacciÃ³n con usuario (verde)
		modo = 3	-> recuadro del Ãºltimo momento disponible (rojo oscuro)
*/
void muestra_recuadro(unsigned char modo)
{
	unsigned char i;
	unsigned char colors[] = {30, 33, 42, 31};
	
	for (i = 0; i < ROWS*2-1; i++)		// lÃ­mites verticales
	{
		printf("\x1b[%dm\x1b[%d;0H|", colors[modo], DFIL+i);
		printf("\x1b[%dm\x1b[%d;%dH|", colors[modo], DFIL+i, COLUMNS*2);
	}
	for (i = 0; i < COLUMNS-1; i++)		// lÃ­mites horizontales
	{
		printf("\x1b[%dm\x1b[%d;%dH--", colors[modo], DFIL-1, i*2+1);
		printf("\x1b[%dm\x1b[23;%dH--", colors[modo], i*2+1);
	}
	printf("\x1b[%dm\x1b[%d;0H+", colors[modo], DFIL-1);		// esquinas
	printf("\x1b[%dm\x1b[%d;%dH-+", colors[modo], DFIL-1, COLUMNS*2-1);
	printf("\x1b[%dm\x1b[23;0H+", colors[modo]);
	printf("\x1b[%dm\x1b[23;%dH-+", colors[modo], COLUMNS*2-1);
}



/* control_backup(): permite recuperar el estado del tablero y la informaciÃ³n
	del juego almacenada en las variables globales b_mat y b_info, variando
	un Ã­ndice entre -1 y -b_num.
*/
void control_backup()
{
	short b_ind, puntos;
	unsigned char movimientos, gelatinas;
	unsigned char modo, modo_ant;
	unsigned short ind = 1;
	
	if (b_num > 1)		// solo se podrÃ¡ consultar el backup cuando haya por lo
	{			// menos dos copias, porque la Ãºltima copia es el tablero actual
		borra_puntuaciones();
		modo_ant = 10;	// valor fuera de rango para forzar primera
						// visualizaciÃ³n del recuadro
		do
		{
			while (keysHeld() & (KEY_LEFT | KEY_RIGHT))
			{	swiWaitForVBlank();
				scanKeys();				// esperar liberaciÃ³n teclas de control
			}
			b_ind = b_last - ind;		// resta Ã­ndice de acceso a backups,
			if (b_ind < 0) b_ind += MAXBACKUP;			// con ajuste circular
			escribe_matriz_testing(b_mat[b_ind]);
			puntos = b_info[b_ind] >> 16;
			movimientos = (b_info[b_ind] >> 8) & 0xFF;
			gelatinas = b_info[b_ind] & 0xFF;
			actualiza_contadores_backup(puntos, movimientos, gelatinas);
			printf("\x1b[33m\x1b[22;20H|Backup %03d|", -(b_num-1));
			printf("\x1b[39m\x1b[23;20H|Posic. %03d|", -ind);
			
			b_ind = (b_ind + 1) % MAXBACKUP;	// acceso al siguiente momento
			if (movimientos != ((b_info[b_ind] >> 8) & 0xFF)) modo = 2;
			else modo = 1;
			if (ind == b_num-1) modo = 3;
			if (modo != modo_ant)
			{
				muestra_recuadro(modo);
				modo_ant = modo;
			}
			
			while (!(keysHeld() & (KEY_LEFT | KEY_RIGHT)))
			{	swiWaitForVBlank();
				scanKeys();				// espera pulsaciÃ³n teclas de control
			}
			if ((keysHeld() & KEY_LEFT) && (ind < b_num-1)) ind++;
			if ((keysHeld() & KEY_RIGHT) && (ind > 0)) ind--;
		} while (ind > 0);
		printf("\x1b[22;20H            "); 	// borra mensajes de control backup
		printf("\x1b[23;20H            ");
		muestra_recuadro(0);				// borra recuadro (escribe en negro)
	}
}

#endif




/* actualiza_contadores(lev,p,m,g): actualiza los contadores que se indican con
	los parÃ¡metros correspondientes:
		lev:	nivel (level)
		p:	puntos
		m:	movimientos
		g:	gelatinas
*/
void actualiza_contadores(unsigned char lev, short p, unsigned char m,
											unsigned char g)
{
	printf("\x1b[38m\x1b[1;8H %d", lev);
	printf("\x1b[39m\x1b[2;8H %d  ", p);
	printf("\x1b[38m\x1b[1;28H %d ", m);
	printf("\x1b[37m\x1b[2;28H %d ", g);
}



/* inicializa_nivel(mat,lev,*p,*m,*g): inicializa un nivel de juego a partir
	del parÃ¡metro lev (level), modificando la matriz y la informaciÃ³n de juego
	(puntos, movimientos, gelatinas) que se pasan por referencia.
*/
void inicializa_nivel(char mat[][COLUMNS], unsigned char lev,
							short *p, unsigned char *m, unsigned char *g)
{
	inicializa_matriz(mat, lev);
	escribe_matriz(mat);
	*p = pun_obj[lev];
	*m = max_mov[lev];
	*g = cuenta_gelatinas(mat);
	actualiza_contadores(lev, *p, *m, *g);
	borra_puntuaciones();
	retardo(3);			// tiempo para ver matriz inicial
#ifdef TRUCOS
	b_last = MAXBACKUP-1; b_num = 0;
	guarda_backup(mat, *p, *m, *g);
#endif
}



/* procesa_pulsacion(mat,p,*m,g): procesa la pulsaciÃ³n de la pantalla tÃ¡ctil
	y, en caso de que se genere alguna secuencia, decrementa el nÃºmero de
	movimientos y retorna un cÃ³digo diferente de cero.
*/



unsigned char procesa_pulsacion(char mat[][COLUMNS], 
							short p, unsigned char *m, unsigned char g)
{
	unsigned char mX, mY, dX, dY;	// variables de posiciones de intercambio
	unsigned char result = 0;
	
	if (procesa_touchscreen(mat, &mX, &mY, &dX, &dY))
	{
		intercambia_posiciones(mat, mX, mY, dX, dY);
		escribe_matriz(mat);
		/*if (hay_secuencia(mat))
		{
			(*m)--;				// un movimiento utilizado
			borra_puntuaciones();
			result = 1;			// notifica que hay secuencia
#ifdef TRUCOS
			guarda_backup(mat, p, *m, g);
#endif
		}
		else*/						
		{				// si no se genera secuencia,
			retardo(3);			// deshace el cambio
			intercambia_posiciones(mat, mX, mY, dX, dY);
			escribe_matriz(mat);
		}
	}
	while (keysHeld() & KEY_TOUCH)	// espera liberaciÃ³n
	{	swiWaitForVBlank();			// pantalla tÃ¡ctil
		scanKeys();
	}
	return(result);
}






#ifdef TRUCOS

/* testing(*est,mat,lev,*p,*m,*g): funciÃ³n para detectar pulsaciones de botones
	que permiten al programador efectuar determinados trucos de testeo del
	programa (ver comentarios sobre los trucos al inicio de este fichero);
	la funciÃ³n puede modificar (por referencia) las variables de informaciÃ³n
	puntos (p), movimientos restantes (m) o gelatinas (g), ademÃ¡s de la variable
	de estado del juego, fijando E_CHECK si debe haber un reinicio de nivel.
*/
void testing(unsigned char *est, char mat[][COLUMNS], unsigned char lev,
							short *p, unsigned char *m, unsigned char *g)
{
	if (keysHeld() & KEY_B)
	{	*p = 0;				// fuerza cambio de nivel (puntos y gelatinas a 0)
		*g = 0;
		*est = E_CHECK;
	}
	else if (keysHeld() & KEY_START)	
	{	*m = 0;				// repite nivel (movimientos restantes a 0)
		*est = E_CHECK;
	}
	else if (keysHeld() & KEY_LEFT)	
	{							// control de backup
		control_backup();
		escribe_matriz(mat);
		actualiza_contadores(lev, *p, *m, *g);
	}
}

#endif



/* procesa_rotura(mat,lev,*p,m,*g): procesa la eliminaciÃ³n de secuencias y
	actualiza el nuevo valor de puntos y gelatinas (parÃ¡metros pasados por
	referencia); utiliza la variable globla mat_mar[][]; tambiÃ©n se pasan
	los parÃ¡metros lev (level) y m (moves) con el fin de llamar a la funciÃ³n
	de actualizaciÃ³n de contadores.
*/
void procesa_rotura(char mat[][COLUMNS], unsigned char lev,
								short *p, unsigned char m, unsigned char *g)
{
	//elimina_secuencias(mat, mat_mar);
	escribe_matriz(mat);
	*p += calcula_puntuaciones(mat_mar);
	if (*g > 0) *g = cuenta_gelatinas(matrix);
	actualiza_contadores(lev, *p, m, *g);
#ifdef TRUCOS
	guarda_backup(mat, *p, m, *g);
#endif
}



/* procesa_caida(mat,p,m,g): procesa la caÃ­da de elementos; la funciÃ³n devuelve
	un cÃ³digo que representa las siguientes situaciones:
		PC_FALLING (0):	ha habido caÃ­da de algÃºn elemento
		PC_ENDNOSQ (1):	no ha habido caÃ­da y no se han formado nuevas secuencias
		PC_ENDSEQ  (2):	no ha habido caÃ­da y se han formado nuevas secuencias
*/
unsigned char procesa_caida(char mat[][COLUMNS],
								short p, unsigned char m, unsigned char g)
{
	unsigned char result = PC_FALLING;

	retardo(3);			// tiempo para ver la bajada
	if (baja_elementos(mat))
	{
		escribe_matriz(mat);
#ifdef TRUCOS			
		guarda_backup(mat, p, m, g);
#endif
	}
	/*else
	{						// cuando ya no hay mÃ¡s bajadas
		if (hay_secuencia(matrix))
		{
			retardo(3);		// tiempo para ver la secuencia
			result = PC_ENDSEQ;
		}
		else result = PC_ENDNOSQ;
	}*/
	return(result);
}



/* comprueba_jugada(mat,*lev,p,m,g): comprueba las posibles situaciones que se
	pueden generar despuÃ©s de una jugada; la funciÃ³n devuelve un cÃ³digo que
	representa dichas situaciones:
		CJ_CONT   (0):	no ha pasado nada especial, seguir jugando en el mismo nivel
		CJ_LEVEL  (1):	el nivel se ha superado o no, hay que reiniciar nivel actual o siguiente
		CJ_RCOMB  (2):	se ha producido una recombinaciÃ³n y se han generado nuevas combinaciones
		CJ_RNOCMB (3):	se ha producido una recombinaciÃ³n pero no hay nuevas combinaciones
*/
unsigned char comprueba_jugada(char mat[][COLUMNS], unsigned char *lev,
								short p, unsigned char m, unsigned char g)
{
	unsigned char result = CJ_CONT;
	
	if (((p >= 0) && (g == 0)) || (m == 0) || !hay_combinacion(mat))
	{
		if ((p >= 0) && (g == 0)) 	printf("\x1b[39m\x1b[6;20H _SUPERADO_");
		else if (m == 0)			printf("\x1b[39m\x1b[6;20H _REPETIR_");
		else						printf("\x1b[39m\x1b[6;20H _BARAJAR_");
		
		printf("\x1b[39m\x1b[8;20H (pulse A)");
		while (!(keysHeld() & KEY_A))
		{	swiWaitForVBlank();
			scanKeys();						// espera pulsaciÃ³n 'A'
		}
		printf("\x1b[6;20H           ");
		printf("\x1b[8;20H           "); 	// borra mensajes
		borra_puntuaciones();
		if (((p >= 0) && (g == 0)) || (m == 0))
		{
			if ((p >= 0) && (g == 0))  			// si nivel superado
				*lev =	(*lev + 1) % MAXLEVEL;	 	// incrementa nivel
			printf("\x1b[2;8H      ");				// borra puntos anteriores
			result = CJ_LEVEL;
		}
		else					// si no hay combinaciones
		{
			recombina_elementos(mat);
			escribe_matriz(mat);
			if (!hay_combinacion(mat))  result = CJ_RNOCMB;
			else						result = CJ_RCOMB;
#ifdef TRUCOS
			guarda_backup(mat, p, m, g);
#endif
		}
	}
	return(result);
}




/* procesa_sugerencia(mat,lap): segÃºn el valor del parÃ¡metro lap (nÃºmero de
	vertical blanks esperando a que el usuario realice un movimiento), esta
	funciÃ³n calcula una posible combinaciÃ³n guardando las coordenadas de los
	elementos involucrados sobre el vector global pos_sug[6]; ademÃ¡s, cada
	cierto tiempo efectÃºa una visualizaciÃ³n momentÃ¡nea de caracteres '_' en
	dichas posiciones.
*/
void procesa_sugerencia(char mat[][COLUMNS], unsigned short lap)
{
	if (lap == T_INACT) 
	{				// activa el cÃ¡lculo de posiciones de una combinaciÃ³n
		sugiere_combinacion(mat, pos_sug);
		borra_puntuaciones();
	}
	if ((lap % T_MOSUG) == 0)
	{							// activa mostrar elementos sugeridos
		oculta_elementos(mat, pos_sug);
		escribe_matriz(mat);
		retardo(3);
		muestra_elementos(mat, pos_sug);
		escribe_matriz(mat);
	}
}


/* Programa principal: control general del juego */
int main(void)
{
	unsigned char level = 0;		// nivel del juego (nivel inicial = 0)
	short points = 0;				// contador de puntos
	unsigned char moves = 0;		// nÃºmero de movimientos restantes
	unsigned char gelees = 0;		// nÃºmero de gelatinas restantes
	
	unsigned char state = E_INIT;	// estado actual del programa
	unsigned short lapse = 0;		// contador VBLs inactividad del usuario
	unsigned char ret;				// cÃ³digo de retorno de funciones auxiliares

	seed32 = time(NULL);			// fija semilla inicial nÃºmeros aleatorios
	consoleDemoInit();				// inicializa pantalla de texto
	printf("candyNDS (version 1: texto)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	printf("\x1b[39m\x1b[2;0H puntos:");
	printf("\x1b[38m\x1b[1;15H movimientos:");
	printf("\x1b[37m\x1b[2;15H   gelatinas:");

	do								// bucle principal del juego
	{
		swiWaitForVBlank();
		scanKeys();
		switch (state)
		{
			case E_INIT:		//////	ESTADO DE INICIALIZACIÃ“N	//////
						inicializa_nivel(matrix, level, &points, &moves, &gelees);
						lapse = 0;
						//if (hay_secuencia(matrix))	state = E_BREAK;
						if (!hay_combinacion(matrix))	state = E_CHECK;
						else	state = E_PLAY;
						break;
			case E_PLAY:		//////	ESTADO DE INTERACCIÃ“N CON USUARIO //////
						if (keysHeld() & KEY_TOUCH)		// detecta pulsaciÃ³n en pantalla
						{
							lapse = 0;				// reinicia tiempo de inactividad
							if (procesa_pulsacion(matrix, points, &moves, gelees))
								state = E_BREAK;	// si hay secuencia, pasa a romperla
						}
						else
						{	lapse++;				// cuenta tiempo (VBLs) de inactividad
							if (lapse >= T_INACT)	// a partir de cierto tiempo de inactividad,
								procesa_sugerencia(matrix, lapse);
						}
#ifdef TRUCOS
						testing(&state, matrix, level, &points, &moves, &gelees);
#endif
						break;
			case E_BREAK:		//////	ESTADO DE ROMPER SECUENCIAS	//////
						procesa_rotura(matrix, level, &points, moves, &gelees);
						lapse = 0;
						state = E_FALL;
						break;
			case E_FALL:		//////	ESTADO DE CAÃDA DE ELEMENTOS	//////
						ret = procesa_caida(matrix, points, moves, gelees);
											// cuando ya no haya mÃ¡s bajadas,
						if (ret == PC_ENDNOSQ)	state = E_CHECK;		// comprueba situaciÃ³n del juego
						else if (ret == PC_ENDSEQ)	state = E_BREAK;	// o rompe secuencia (si la hay)
						// si ha habido algÃºn movimiento de caÃ­da, sigue en estado E_FALL
						break;
			case E_CHECK:		//////	ESTADO DE VERIFICACIÃ“N	//////
						ret = comprueba_jugada(matrix, &level, points, moves, gelees);
						if (ret == CJ_LEVEL)	state = E_INIT;			// nuevo nivel o reiniciar nivel
						else if ((ret == CJ_CONT) || (ret == CJ_RCOMB))	// si no ha pasado nada especial o ha habido recombinaciÃ³n con posible secuencia,
							state = E_PLAY;		//  sigue jugando
						// si ha habido recombinaciÃ³n sin nueva combinaciÃ³n, sigue en estado E_CHECK
						break;
		}
	} while (1);				// bucle infinito

	return(0);					// nunca retornarÃ¡ del main
}

