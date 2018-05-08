;=========================================;
;              Proyecto.asm               ;
;                                         ;
;        Bernal Lopez Jose Antonio        ;
;        Fierros Mora Luis Ricardo        ;
;     Saavedra Garcìa Abraham Gildardo    ;
;                                         ;
;                                         ;
; El programa funciona de la siguiente    ;
;es opcional al iniciar el programa dar un;
;argumento que sea el nombre del archiv o ;
;si no se da un nombre se pasa directamen-;
;te a iniciar el programa.                ;
;                                         ;
;                                         ;
;            Fecha: 25/04/2018            ;
;=========================================;

%include 'funciones_basicas.asm'

section .data
  msg1       DB 'MENU', 0x0
  num_max    DB 'Mayor: ', 0x0
  num_min    DB 'Menor: ', 0x0
  op1        DB 'Numero entero> ', 0x0
  print      DB 'Arreglo de entrada                 Arreglo de resultados', 0xA, '==================                 =====================', 0x0
  printSpace DB '                                           ',0x0
  mnu DB "**Menu**", 0xA, '1. Agregar dato', 0xA, '2. Generar linea', 0xA,   '3. Generar curva', 0xA, '4. Mostrar datos (imprimir)', 0xA,'5. Guardar Archivo', 0xA, '0. Salir',0xA, 'Opcion >', 0x0

segment .bss
  arreglo         resb     200         ;50 casillas de 4 bytes c/u
  arreglo_curva   resb     200         ;50 casillas de 4 bytes c/u
  arreglo_linea   resb     200         ;50 casillas de 4 bytes c/u
  buffer          resb    1024
  len             equ     1024
  file            resb      20
  filelen         resb       4
  letra           resb       2
  buffer_num      resb       4
  buffer_num_len  equ $ - buffer_num
  buffer_opc      resb       4
  buffer_opc_len  equ $-buffer_opc

section .text
  global _start:

_start:
  pop ecx             ;Sacamos el numero de argumento
  pop eax             ;Sacamos el nombre del programa
  dec ecx             ;Quitamos el nombre del programa
  mov edi, 0          ;Movemos a edi 0
  mov ebp, 0    ;Pasamos la direccion del arreglo a ebp

  cmp ecx, 0          ;¿Hay un argumento?
  jz menu             ;Si no iniciamos el menu
  jmp readFile        ;Leemos el archivo


readFile:

  pop ebx             ;extraemos el nombre del archivo a leer
  mov eax, sys_open   ;operaciòn: abrir archivo
  mov ecx, 0          ;0_RDONLY (Solo lectura)
  int 80h             ;Ejecutamos
  cmp eax, 0          ;Si file handler es > 0 bien (sino mal :v)
  jle error

  ;lee archivo
  mov ebx, eax        ;Pasamos el file handler de eax a ebx
  mov eax, sys_read   ;Operacion: Lectura
  mov ecx, buffer     ;Direcciòn de buffer de lectura
  mov edx, len        ;Cantidad de bytes a leer
  int 80h             ;Ejecutamaos

  ;cerrar archivo
  mov eax, sys_close  ;Operacion: cerrar
  int 80h             ;Ejecutamos

  mov eax, buffer     ;Movemos la lectura del archivo a eax
  call strlen         ;Obtenemos el length de el string
  mov ecx, eax            ;Movemos el valor obtenido a ecx
  mov esi, buffer         ;Movemos el string de lectura a esi
  mov edx, 0              ;Movemos 0 a edx
  cmp ecx, 0              ;El string esta vacio ?
  jz menu                 ;Iniciamos el menu
  mov eax, letra          ;Movemos el valor vacio de letra (Lo hago para prevenir el registro alto y bajo)
  jmp getNumFile          ;Obtenemos los valores del string

getNumFile:
  mov ebx, 0              ;Movemos a ebx el valor de 0
  cmp ecx, 0              ;ecx vale 0 (ecx vale el length del string del archivo)?
  jz menu                 ;Iniciamos el menu
  mov bl, byte[esi+edx]   ;Movemos un byte al registro bajo de ebx
  inc edx                 ;Incrementamos edx
  dec ecx                 ;Decrementamos ecx

cleanNumbers:
  cmp bl, 0xA             ;bl vale un salto de linea ?
  je setNum               ;Si lo vale vamos al siguiente caracter
  mov [eax+ebp], bl       ;Movemos ese byte a eax
  inc ebp
  jmp getNumFile          ;Leemos el siguiente caracter

setNum:
  call atoi               ;Convertimos el valor a entero
  mov ebp, arreglo
  mov [ebp+edi*4], eax    ;lo guardamos en array
  mov eax, letra          ;Movemos el valor vacio de letra (Lo hago para prevenir el registro alto y bajo)
  mov ebp,0
  inc edi                 ;Incrementamos el valaor del index para el arreglo
  jmp getNumFile



menu:
  mov ebp, arreglo
  mov eax, mnu                  ;Movemos a eax el valor de mnu que es nuestro menu
  call sprint                   ;Imprimimos el menu

  mov ecx, buffer_opc           ;Movemos a ecx el valor de buffer_opc
  mov edx, buffer_opc_len       ;Movemos a edx el valor de la longitud del buffer
  call LeerTexto                ;Llamamos a la funcion LeerTexto de funciones basicas
  mov eax, buffer_opc           ;Movemos a eax el valor de buffer_opc
  mov ecx, 0                    ;Le damos valor de 0 a ecx


  mov bl, [eax+ecx]             ;Movemos un byte a un registro bajo
  cmp bl, 48                    ;Comparamos de bl con 48 (0)
  jl menu                       ;Saltamos si es menor el valor y volvemos a imprimir el menu
  cmp bl, 53                    ;Comparamos bl con 53 (5)
  jg menu                       ;Saltamos a la seccion menu si bl es mayor a 53
  jmp set_menu                  ;Saltamos a la seccion set_menu

set_menu:
  cmp bl, 49                    ;Comparamos bl con 49 (1)
  je addNumberArray             ;Saltamos a la funcion addNumberArray
  cmp bl, 50                    ;Comparamos bl con 50 (2)
  je generarLinea               ;Saltamos a la funcion generarLinea
  cmp bl, 51                    ;Comparamos bl con 51 (3)
  je generarCurva               ;Saltamos a la funcion generarCurva
  cmp bl, 52                    ;Comparamos bl con 52 (4)
  je prePrintarray              ;Saltamos a la funcion printArray
  cmp bl, 53                    ;Comparamos bl con 53 (5)
  je guardarArchivo             ;Saltamos a la funcion guardarArchivo
  cmp bl, 48                    ;Comparamos bl con 48 (0)
  je quit                       ;Saltamos a la funcion quit

; ======= Generar Linea ======= ;

;Guardamos en el arreglo generar_linea
;en base al arreglo inicial generamos los
;nuevos digitos

generarLinea:
  cmp ecx, edi          ;preguntamos si llegamos al final del arreglo
  je menu               ;Volvemos al menu
  mov eax, [ebp+ecx*4]  ;sacamos un numero del array
  imul eax, 4           ;multiplicamos 4(eax)
  add eax, 3            ;a la multiplicacion anterior le sumamos 3 : 4(eax)+3
  mov [esi+ecx*4], eax  ;guardamos el array
  inc ecx               ;incrementamos el indice del array
  jmp generarLinea      ;Vamos a la siguiente iteraciòn

; ======= Fin Generar Linea ======= ;

; ======= Generar curva ======= ;

;En base al arreglo inicial tomamos sus valores
;y los guardamos en el arreglo_curva

generarCurva:
  cmp ecx, edi              ;Recorremos el arreglo
  je menu                   ;Si llegamos al tamaño volvemos al menu
  mov ebx, 0                ;Movemos a ebx 0
  mov eax, [ebp+ecx*4]      ;Movemos una posiciòn del arreglo a eax
  mov ebx, eax              ;Movemos ese valor a ebx
  imul ebx, eax             ;Ebx lo multiplicamos por el valor inicial
  imul ebx, eax             ;Lo volvemos a multiplicar
  mov edx, eax              ;Movemos a edx eax
  imul edx, eax             ;Elevamos al cuadrado
  imul edx, 4               ;Multiplicamos ese numero por 4
  imul eax, 6               ;Lo multiplicamos por 6
  sub ebx, edx              ;Restamos lo que teniamos en ebx - edx
  add ebx, eax              ;Sumamos del resultado anterior eax
  sub ebx, 24               ;Le restamos 24
  mov eax, ebx              ;Movemos nuestro resultado a eax
  mov [esi+ecx*4], eax      ;Movemos ese valor a la posiciòn del array de curva
  inc ecx                   ;Incrementamos el index
  jmp generarCurva          ;Volvemos al ciclo

; ======= Fin Generar curva ======= ;


; ======= Impresion ======= ;

;Ponemos esta parte para imprimir la cabecera
;y mover el index a 0
; Seguimos con el recorrido del arreglo
; imprimiremos el arreglo inicial y por otra parte
; el arreglo generado, al finalizar obtenemos el maximo y minimo

prePrintarray:
  mov eax, print            ;Movemos a eax la cabecera de los resultados
  call sprintLF             ;Lo mostramos en consola
  mov ecx, 0                ;Inicializamos el index en 0

printArray:
  cmp ecx, edi            ;Comparamos el tamaño del arreglo con el index
  je maxmin                ;Optenemos el maximo y minimo
  mov eax, [ebp+ecx*4]    ;Movemos un numero a eax
  call iprint             ;Imprimimos el numero
  mov eax, printSpace     ;Movemos espacio en blanco a eax
  call sprint             ;Imprimimos el espacio en blanco
  mov eax, [esi+ecx*4]    ;Movemos del ultimo arreglo seleccionado (curva o linea) a eax
  call iprintLF           ;Imprimimos el numero
  inc ecx                 ;Incrementamos el index
  jmp printArray          ;Siguiente index

; ======= Fin impresion ======= ;


; ======= Agregar Numero ======= ;

;Añade numero a nuestro arreglo, dependiendo de la posiciòn
;en que este el arreglo

addNumberArray:
  mov eax, op1              ;Movemos el mensaje de agregar dato
  call sprint               ;Lo imprimimos
  mov ecx, buffer_num       ;Movemos lo que leeremos a ecx
  mov edx, buffer_num_len   ;Movemos el tamaño a edx
  call LeerTexto            ;Llamamos a la funciòn de leer
  mov eax, buffer_num       ;Movemos lo ingresado a eax
  call atoi                 ;Lo convertimos a numero
  mov [ebp+edi*4], eax      ;Movemos a la posiciòn que quedo disponible del arreglo
  inc edi                   ;Incrementamos la posiciòn del arreglo
  jmp menu

; ======= Fin Agregar Numero ======= ;


; ======= Maximo y minimo ======= ;

;Obtenemos el numero mayor y menor de un arreglo
;para eso hay que apuntar el arreglo generado a esi

maxmin:
  mov ecx, 0                ;Movemos a ecx 0 por que lo necesitaremos
  call readArray            ;Funciòn que leera el arreglo y buscara max y min
  jmp menu                  ;Volvemos al menu

; ======= Fin Maximo y minimo ======= ;

guardarArchivo:

error:
  mov ebx, eax        ;exit code = sys call result
  mov eax, sys_exit   ;salir
  int 80h             ;ejecutar
