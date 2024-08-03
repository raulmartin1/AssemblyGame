/*------------------------------------------------------------------------------

	$ candy1_sopo.c $

	Funciones de soporte para el programa principal (ver 'candy1_main.c')
	
	Analista-programador: santiago.romani@urv.cat
	Programador auxiliar: pere.millan@urv.cat

------------------------------------------------------------------------------*/
#include <nds.h>
#include <stdio.h>
#include "candy1_incl.h"


/* variables globales */
char ele_sug[3];				// elementos de las posiciones sugeridas
char texto[12];					// texto de puntuaciones
unsigned char ult_tex = 0;		// último número de textos de puntuación
unsigned char num_pun = 0;		// número de puntuaciones



/* escribe_matriz_h(*mat, debug): escribe por pantalla de texto de la NDS el
	contenido de la matriz usando secuencias escape de posicionamiento en fila
	y columna (\x1b['fila';'columna'H), donde 'fila' es una coordenada entre 0
	y 23, y 'columna' es una coordenada entre 0 y 31, y la posición (0,0) 
	corresponde a la casilla superior izquierda; además, se usa la secuencia de
	escape (\x1b['color'm) para cambiar el color del texto, donde 'color' es un
	código de color de la librería NDS;
 
	Oct/2020: versió adaptada per a debug/test *** pere.millan@urv.cat ***
	Jul/2021: versió híbrida, amb paràmetre debug=0, visualització normal,
				amb paràmetre debug=1, visualització per a test/depuració
	Jul/2024: s'ha eliminat un espai en blanc darrera de cada símbol '_', '#',
				':' i el codi d'element (amb color) o bloc sòlid '7'.
*/
void escribe_matriz_h(char mat[][COLUMNS], int debug)
{
	unsigned char i, j, value, color;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			value = mat[i][j];			// obtiene el valor del elemento (i,j)
			
			if ((value == 0) || ((value & 7) == 7))
				color = 39;						// color del hueco, bloque sólido o vacío (light white)
			else if (value >= 16)
				color = 38;						// color de la gelatina doble (dark grey)
			else if (value >= 8)
				color = 37;						// color de la gelatina simple (light grey)
			else
				color = 40 + value;				// color normal (brillant)
			printf("\x1b[%dm", color);
			
			printf("\x1b[%d;%dH", (i*2+DFIL), (j*2+1));	// posiciona cursor
			
			if (value == 255)
				printf("_");					// sugiere
			else if ((value == 7) && debug)
				printf("#");					// bloque sólido en modo debug
			else if ((value == 15) && debug)
				printf(":");					// hueco en modo debug
			else if (value != 15)
				printf("%d", (value & 7));		// valor en modo normal
			else
				printf(" ");					// hueco en modo normal
		}
	}
}

/* escribe_matriz(*mat): llama a escribe_matriz_h() con visualitzación normal.
*/
void escribe_matriz(char mat[][COLUMNS])
{
	escribe_matriz_h(mat, 0);
}

/* escribe_matriz_testing(*mat): llama a escribe_matriz_h() con visualitzación
	para testeo y depuración de errores.
*/
void escribe_matriz_testing(char mat[][COLUMNS])
{
	escribe_matriz_h(mat, 1);
}


/* cuenta_gelatinas(*mat): calcula cuántas gelatinas quedan en la matriz de
	juego, contando 1 para gelatines simples y 2 para gelatinas dobles. */
unsigned char cuenta_gelatinas(char mat[][COLUMNS])
{
	unsigned char i, j, count = 0;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			if (mat[i][j] != 15)		// exceptuando los huecos,
			{							// suma 0, 1 o 2 según el valor
				count += (mat[i][j] & 0x18) >> 3;
			}							// de los bits 4..3 (código gelatina)
		}
	}
	return(count);
}


/* retardo(dsecs): pone el programa en pausa durante el número de décimas de
	segundo que indica el parámetro dsec. */
void retardo(unsigned short dsecs)
{	
	unsigned short i, j;
	
	for (i = 0; i < dsecs; i++)		// por cada décima de segundo
		for (j = 0; j < 6; j++)		// espera 6 retrocesos verticales
			swiWaitForVBlank();
}



/* procesa_touchscreen(*mat, *p1X, *p1Y, *p2X, *p2Y): procesa la entrada de la
	pantalla táctil esperando a que el usuario realice un movimiento de
	intercambio válido, desde una posición de la matriz (p1X,p1Y) hasta otra
	posición (p2X,p2Y) que deberá ser contigüa en horizontal o en vertical,
	y solo deberá contener elementos (sin espacios ni bloques sólidos);
	devuelve cierto (1) si el movimiento es posible, o falso (0) si no lo es,
	además de cargar las coordenadas en las variables que se han pasado por
	referencia. */
int procesa_touchscreen(char mat[][COLUMNS],
						unsigned char *p1X, unsigned char *p1Y,
						unsigned char *p2X, unsigned char *p2Y)
{
	touchPosition posXY;				// variables de detección de pulsaciones
	unsigned char v1X, v1Y, v2X, v2Y;
	char temp1, temp2;
	unsigned char result = 0;

	touchRead(&posXY);					// captura posición (x,y), en píxeles
	v1X = (posXY.px >> 3) / 2;			// convierte a posición de matriz
	if (v1X >= COLUMNS)
	{ v1X = COLUMNS-1; }				// limitando coordenadas
	v1Y = ((posXY.py >> 3)-DFIL) / 2;
	if (v1Y >= ROWS)					// si supera ROWS significa que la resta 
	{									// (posXY.py >> 3)-DFIL ha resultado 
		v1Y = 0;						// negativa, aunque al ser posXY.py un 
	}									// natural, el resultado será 255 (aprox.)
	v2X = v1X;	v2Y = v1Y;				// iguala coordenadas segunda pos.
	while ((keysHeld() & KEY_TOUCH) &&		// mientras se esté tocando
			(v2X == v1X) && (v2Y == v1Y))	// y no haya nueva posición
	{
		touchRead(&posXY);					// captura nuevas posiciones
		v2X = (posXY.px >> 3) / 2;
		v2Y = ((posXY.py >> 3)-DFIL) / 2;
		if ((v2X >= COLUMNS) || (v2Y >= ROWS))	// si fuera de límites,
		{	v2X = v1X; 						// iguala coordenadas
			v2Y = v1Y;
		}
		swiWaitForVBlank();
		scanKeys();
	}
	if ((v2X != v1X) || (v2Y != v1Y))		// si tenemos nueva posición
	{
		if (v2X > v1X) v2X = v1X + 1;		// limita rango de movimientos
		else if (v2X < v1X)
		{ v2X = v1X - 1; }
		if (v2Y > v1Y) v2Y = v1Y + 1;
		else if (v2Y < v1Y)
		{ v2Y = v1Y - 1; }
		if ((v2X != v1X) && (v2Y != v1Y))	// si hay movimiento en dos
		{	v2Y = v1Y;	}					// direcciones, priorizar X
			
		temp1 = mat[v1Y][v1X] & 0x7;
		temp2 = mat[v2Y][v2X] & 0x7;
		if ((temp1 > 0) && (temp1 < 7) && (temp2 > 0) && (temp2 < 7))
		{
			*p1X = v1X; *p1Y = v1Y;
			*p2X = v2X; *p2Y = v2Y;
			result = 1;
		}
	}
	return(result);
}


/* oculta_elementos(*mat, *psug): almacena dentro del vector ele_sug[3]
	(variable global) los códigos de los 3 elementos contenidos en las
	posiciones de la matriz de juego indicadas en el parámetro psug[6],
	para luego colocar un código -1  en dichas posiciones, lo cual provocará
	que la función escribe_matriz() muestre un carácter '_' (elemento oculto).*/
void oculta_elementos(char mat[][COLUMNS], unsigned char psug[6])
{
	unsigned char i, x, y;
	
	for (i = 0; i < 3; i++)
	{
		x = psug[i*2];
		y = psug[i*2 + 1];
		ele_sug[i] = mat[y][x];
		mat[y][x] = -1;
	}
}


/* muestra_elementos(*mat, *psug): restablece los códigos de los 3 elementos
	contenidos en las posiciones de la matriz de juego indicadas en el parámetro
	psug[6], según el contenido del vector ele_sug[3] (variable global). */
void muestra_elementos(char mat[][COLUMNS], unsigned char psug[6])
{
	unsigned char i, x, y;
	
	for (i = 0; i < 3; i++)
	{
		x = psug[i*2];
		y = psug[i*2 + 1];
		mat[y][x] = ele_sug[i];
	}
}



/* intercambia_posiciones(*mat, p1X, p1Y, p2X, p2Y): intercambia los
	elementos de las dos posiciones de la matriz que indican los parámetros,
	conservando las características de gelatina en las posiciones originales. */
void intercambia_posiciones(char mat[][COLUMNS],
							unsigned char p1X, unsigned char p1Y,
							unsigned char p2X, unsigned char p2Y)
{
	char temp1 = mat[p1Y][p1X];
	char temp2 = mat[p2Y][p2X];
	mat[p1Y][p1X] = (temp2 & 0x7) | (temp1 & 0xF8);
	mat[p2Y][p2X] = (temp1 & 0x7) | (temp2 & 0xF8);
}


unsigned short puntuaciones[] = {PUNT_SEC3, PUNT_SEC4, PUNT_SEC5,
								 PUNT_COM5, PUNT_COM6, PUNT_COM7};


/* detecta_combo(nhor, nver, mensaje): función auxiliar para detectar el tipo
	de combinación de secuencias a partir de las longitudes máximas de secuencia
	horizontal 'nhor' y vertical 'nver', generando el mensaje correspondiente
	sobre el string pasado por referencia 'mensaje' y devolviendo como resultado
	los puntos correspondientes a la combinación. */
unsigned short detecta_combo(unsigned char nhor, unsigned char nver,
																char mensaje[])
{
	unsigned char combi = 0;
	unsigned short puntos = 0;
	
	if ((nhor >= 3)	&& (nver < 3))		// si solo hay secuencia horizontal
	{
		puntos = puntuaciones[nhor-3];
		sprintf(mensaje, "SH%c: %3d", '0'+nhor, puntos);
	}
	else if ((nver >= 3) && (nhor < 3))		// si solo hay secuencia vertical
	{
		puntos = puntuaciones[nver-3];
		sprintf(mensaje, "SV%c: %3d", '0'+nver, puntos);
	}
	else					// en caso de combinación de secuencias
	{						// calcula la suma de sec. horizontal y vertical
		combi = nhor + nver - 1;	// restando 1 por la casilla de coincidencia
		if (combi >= 5)				// filtra combinaciones válidas
		{
			if (combi > 7) combi = 7;
			puntos = puntuaciones[combi-2];
			sprintf(mensaje, "CB%c: %3d", '0'+combi, puntos);
		}
	}
	return(puntos);
}


#define FI_PUNTOS	11		// fila inicial para mostrar puntuaciones

/* calcula_puntuaciones(*mar): detecta los conjuntos de secuencias indicados en
	la matriz que se pasa por parámetro, donde cada conjunto se marca con un
	identificador único, y obtiene el tipo de combinación (combo) que 
	corresponde a la longitud máxima de secuencias en horizontal y en vertical;
	dicho tipo se muestra por pantalla (para cada conjunto) y se devuelve el
	total de puntos acumulados como resultado de la función.
 ATENCIÓN:	esta función requiere de la correcta implementación de la rutina
			cuenta_repeticiones(), ubicada en el fichero 'candy1_move.s'. */
unsigned short calcula_puntuaciones(char mar[][COLUMNS])
{
	unsigned char i, j, k, m, m2, n;
	unsigned char nh, nv;
	unsigned short puntos, total;
	
	total = 0;
	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)	// para todas las columnas
		{
			if (mar[i][j] != 0)			// si detecta un identificador
			{
				nh = cuenta_repeticiones(mar, i, j, 0);
				if (nh > 1)	
				{							// hay una secuencia horizontal
					nv = 1; k = 0;
					do
					{			// busca combinaciones verticales
						m = cuenta_repeticiones(mar, i, j+k, 1);
						if (m > nv) nv = m;			// actualiza máximo vert.
						for (n = 0; n < m; n++)
							mar[i+n][j+k] = 0;		// elimina marca
						k++;
					} while (k < nh);
				}
				else
				{							// hay una secuencia vertical
					nv = cuenta_repeticiones(mar, i, j, 1);
					nh = 1; k = 0;
					do
					{			// busca combinaciones horizontales 
						m = cuenta_repeticiones(mar, i+k, j, 0);
							// también hacia atrás (Oeste), para comb. cruzadas
						m2 = cuenta_repeticiones(mar, i+k, j, 2) - 1;
						m += m2;					// m = longitud total sec.
						if (m > nh) nh = m;			// actualiza máximo hor.
						for (n = 0; n < m; n++)
							mar[i+k][j+n-m2] = 0;	// elimina marca
						k++;
					}  while (k < nv);
				}
				puntos = detecta_combo(nh, nv, texto);
				if (puntos > 0)			// posibles marcas filtradas
				{
					printf("\x1b[%dm\x1b[%d;20H %s", 37 + num_pun % 3,
												FI_PUNTOS + ult_tex, texto);
					ult_tex++;
					total += puntos;
				}
			}
		}
	}
	return(total);
}


/* borra_puntuaciones(): permite eliminar los textos de puntuaciones anteriores,
	además de poner a cero el contador ult_tex e incrementar el contador num_pun
	(variables globales). */
void borra_puntuaciones()
{
	unsigned char i;
	
	for (i = 0; i < ult_tex; i++)
		printf("\x1b[%d;20H            ", FI_PUNTOS + i);
	ult_tex = 0;
	num_pun++;
}



/* copia_matriz(*mat_dst, *mat_src): copia el contenido de una matriz de juego
	fuente mat_src[][] sobre otra matriz destino mat_dst[][], suponiendo que
	las dos matrices tienen dimensiones [ROWS][COLUMNS]. */
void copia_matriz(char mat_dst[][COLUMNS], char mat_src[][COLUMNS])
{
	unsigned char i, j;

	for (i = 0; i < ROWS; i++)			// para todas las filas
	{
		for (j = 0; j < COLUMNS; j++)		// para todas las columnas
		{
			mat_dst[i][j] = mat_src[i][j];		// copia elemento (i,j)
		}
	}
}
