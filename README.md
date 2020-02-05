# scu-cli

Consulta el Servicio de Comedores de la UGR desde la línea de comandos. Filtra con Flex++ el código fuente html de  https://scu.ugr.es/ para mostrar solo los menús deseados.

## Requisitos
Es necesario tener instalada la librería libcurl.

## Compilación
Si quieres hacer algún cambio en el programa instala Flex++, haz los cambios en plantilla.l y ejecuta  
```$ flex++ plantilla.l```

Para compilar con g++ en linux simplemente ejecuta en la carpeta del proyecto  
```$ make```

## Instalación
Coloca el binario scu en algún directorio de tu PATH
    
## Uso
```console
$ scu -h
Modo de empleo: scu [OPCION]... [DIA]

La opción por defecto es mostrar el menú general del día actual

	-a, --all         muestra todos los días disponibles  
	-h, --help        muestra esta ayuda y finaliza  
	-p, --pts         muestra los menús del comedor del pts
	-f <file>         lee la información desde el fichero proporcionado

El argumento DIA es un número entero entre 1 y 31, ambos incluidos.
Si se proporciona se mostrarán solo los menús de este día si existe alguno.
```
## Ejemplos

```bash
# muestra el menú comedor del día actual
$ scu

# muestra el menú comedor del día 11
$ scu 11

# muestra el menú comedor (pts) del día 21
$ scu --pts 21

# muestra todos los menús del pts
$ scu -a -p
```
