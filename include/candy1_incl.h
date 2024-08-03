/*------------------------------------------------------------------------------

	$Id: candy1_incl.h $

	Definiciones externas en C para la versión 1 del juego (modo texto)

------------------------------------------------------------------------------*/

// Rango de los números de filas y de columnas:
// mínimo: 3, máximo: 11
#define ROWS	9						// dimensiones de la matriz de juego
#define COLUMNS	9
#define DFIL	(24-ROWS*2)				// desplazamiento vertical de filas

#define MAXLEVEL	9					// nivel máximo (niveles 0..MAXLEVEL-1)

#define PUNT_SEC3	30					// puntos secuencia de 3 elementos
#define PUNT_SEC4	60					// puntos secuencia de 4 elementos
#define PUNT_SEC5	120					// puntos secuencia de 5 elementos
#define PUNT_COM5	150					// puntos combinación de 5 elementos
#define PUNT_COM6	200					// puntos combinación de 6 elementos
#define PUNT_COM7	300					// puntos combinación de 7 elementos


	// candy1_conf.s //
extern unsigned char max_mov[MAXLEVEL];		// movimientos máximos por nivel
extern short pun_obj[MAXLEVEL];				// objetivo de puntos por nivel
extern char mapas[MAXLEVEL][ROWS][COLUMNS];	// mapas de configuración

	// candy1_sopo.c //
extern void escribe_matriz(char mat[][COLUMNS]);
extern void escribe_matriz_testing(char mat[][COLUMNS]);
extern unsigned char cuenta_gelatinas(char mat[][COLUMNS]);
extern void retardo(unsigned short dsecs);
extern int procesa_touchscreen(char mat[][COLUMNS],
								unsigned char *p1X, unsigned char *p1Y,
								unsigned char *p2X, unsigned char *p2Y);
extern void oculta_elementos(char mat[][COLUMNS], unsigned char psug[6]);
extern void muestra_elementos(char mat[][COLUMNS], unsigned char psug[6]);
extern void intercambia_posiciones(char mat[][COLUMNS],
								unsigned char p1X, unsigned char p1Y,
								unsigned char p2X, unsigned char p2Y);
extern unsigned short calcula_puntuaciones(char mar[][COLUMNS]);
extern void borra_puntuaciones();
void copia_matriz(char mat_dst[][COLUMNS], char mat_src[][COLUMNS]);


	// candy1_init.s //
extern void inicializa_matriz(char matriz[][COLUMNS],
											unsigned char num_mapa);	// 1A
extern void recombina_elementos(char matriz[][COLUMNS]);				// 1B

	// candy1_secu.s //
extern unsigned char hay_secuencia(char matriz[][COLUMNS]);				// 1C
extern void elimina_secuencias(char matriz[][COLUMNS],					// 1D
								char marcas[][COLUMNS]);

	// candy1_move.s //
extern unsigned char cuenta_repeticiones(char matriz[][COLUMNS],		// 1E
						unsigned char f, unsigned char c, unsigned char ori);
extern unsigned char baja_elementos(char matriz[][COLUMNS]);			// 1F

	// candy1_comb.s //
extern unsigned char hay_combinacion(char matriz[][COLUMNS]);			// 1G
extern void sugiere_combinacion(char matriz[][COLUMNS],
												unsigned char psug[]);	// 1H
