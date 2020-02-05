%option noyywrap

%{
#include <iostream>
#include <fstream>
#include <iomanip>
#include <sstream>
#include <ctime> // Librería para obtener el tiempo actual del sistema y 
				 // usarlo para consultar automáticamente el día actual

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <string>
#include <curl/curl.h> // Librería para descargar la página web de comedores en html

using namespace std;

// Variables globales
string encontrado;	 
yyFlexLexer *flujo;  	// Objeto de la clase FlexLexer que sirve para recibir el texto y la longitud del token 								reconocido más recientemente

string n_day;			// Día del mes para comparar con el día de los menús

bool pts = false;		// Mostrar los menús generales o los menús del pts
bool escribir = true;
bool day = true;		// Mostrar solo el menú del día guardado en n_day o todos los menús
bool day_found = false; // Coincide el día encontrado en una fecha con el guardado en n_day

%}

n_dia	[0-9]|1[0-9]|2[0-9]|3[0-1]
dia		(LUNES|MARTES|MIÉRCOLES|JUEVES|VIERNES|SÁBADO|DOMINGO)
mes		(ENERO|FEBRERO|MARZO|MAYO|ABRIL|JUNIO|JULIO|AGOSTO|SEPTIEMBRE|OCTUBRE|NOVIEMBRE|DICIEMBRE)
fecha	{dia},"  "{n_dia}"  "DE"  "{mes}"  "DE"  "20[0-9][0-9]
menu	Menú" "[1-3]
ele		(Entrante|Primero|Segundo|Acompañamiento|Postre|Bebida)"  </td><td class=\"leftalign\"><strong>".+"</strong>"
pts		"Menú Comedor (PTS)</a></h1><div class=\"dokuwiki_backToTop\"><a href=\"#\" class=\"action top\" accesskey=\"x\" >Subir"

%%

{pts}	{
			if (pts)
				escribir = true;
			else
				return 0;
		}
{fecha}	{
			encontrado = flujo->YYText();
			if (escribir)
			{
				if (day)
				{
					int long_dia = 2;
					
					if (encontrado.substr(encontrado.find(",  ") + 4, 1) == " ")
						long_dia = 1;
						
					if (encontrado.substr(encontrado.find(",  ") + 3, long_dia) == n_day)
					{
						day_found = true;
						cout << "\n" << encontrado << endl;
					}
					else
						day_found = false;
				}
				else
					cout << "\n" << encontrado << endl;
			}
		}
{menu}	{
			if (escribir && (day && day_found || !day))
				cout << "\n" << flujo->YYText() << endl;
		}
{ele}	{
			encontrado = flujo->YYText();
			if (escribir && (day && day_found || !day))
			{
				cout << setw(20) << left << encontrado.substr(0, encontrado.find(" "));
				cout << setw(20) << left << encontrado.substr(encontrado.find("<strong>") + 8, encontrado.find("</strong>") - (encontrado.find("<strong>") + 8)) << endl;
			}
		}
(.|\n)	{}

%%


int writer(char *data, size_t size, size_t nmemb, std::string *writerData)
{
	if(writerData == NULL)
		return 0;
	
	writerData->append(data, size*nmemb);
	
	return size * nmemb;
}

void showHelp()
{
	cout	<< left << "Modo de empleo: scu [OPCION]... [DIA]\n"
			<< "Consulta el Servicio de Comedores Universitarios de la UGR\n\n"
			
			<< "La opción por defecto es mostrar el menú general del día actual\n\n"
			
			<< setw(20) << "  -a, --all" << setw(20) << "muestra todos los días disponibles\n"
			
			<< setw(20) << "  -h, --help" << setw(20) << "muestra esta ayuda y finaliza\n"
			
			<< setw(20) << "  -p, --pts" << setw(20) << "muestra los menús del comedor del pts\n"
			
			<< setw(20) << "  -f <file>" << setw(20) << "lee la información desde el fichero proporcionado\n\n"
			
			<< "El argumento DIA es un número entero entre 1 y 31, ambos incluidos.\n"
			<< "Si se proporciona se mostrarán solo los menús de este día si existe alguno."
			<< endl;
}

string getHTML(char *url)
{
	string buffer;
	CURL *curl_handle = NULL;

	curl_global_init(CURL_GLOBAL_ALL);
	/* init the curl session */
	curl_handle = curl_easy_init();
	/* set URL to get */
	curl_easy_setopt(curl_handle, CURLOPT_URL, url);
	/* no progress meter please */
	curl_easy_setopt(curl_handle, CURLOPT_NOPROGRESS, 1L);
	/* send all data to this function  */
	curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, writer);
	/* Escribimos los datos en el string */
	curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, &buffer);
	curl_easy_perform(curl_handle);

	/* cleanup curl stuff */
	curl_easy_cleanup(curl_handle);
	return buffer;
}

int main (int argc, char *argv[])
{
	time_t now = time(0);
	tm *ltm = localtime(&now);
	istringstream is;
	ifstream fichero;
	int dia;
	bool from_file = false;
	
	n_day = to_string(ltm->tm_mday);
	
	if (argc > 1)
	{
		for (int i = 1; i < argc; ++i)
		{
			is = istringstream(argv[i]);
			
			if (strcmp(argv[i], "--pts") == 0 || strcmp(argv[i], "-p") == 0)
			{
				pts = true;
				escribir = false;
			}
			else if (strcmp(argv[i], "--all") == 0 || strcmp(argv[i], "-a") == 0)
			{
				day = false;
			}
			else if (is >> dia && is.eof() && dia > 0 && dia <= 31)
			{
				day = true;
				n_day = string (argv[i]);
			}
			else if (strcmp(argv[i], "-f") == 0)
			{
				from_file = true;
				
				fichero.open(argv[i+1]);
				if (!fichero)
				{
					cerr << "Error de lectura" << endl;
					exit(1);
				}
				
				i++;
			}
			else
			{
				showHelp();
				return 0;
			}
		}
	}

	if (pts)
		cout << "Menú Comedor (PTS)" << endl;
	else
		cout << "Menú Comedor" << endl;
	
	if (from_file)
		flujo = new yyFlexLexer(&fichero, 0);
	else
	{
		char url[] = "https://scu.ugr.es/";
		is = istringstream(getHTML(url));
		
		flujo = new yyFlexLexer(&is, 0);
	}
	
	flujo->yylex();
	return 0;
}
