;funciones.asm
sys_exit        equ     1
sys_read        equ     3
sys_write       equ     4
sys_open        equ     5      ;apertura de archivo
sys_close       equ     6     ;cierre de archivo
sys_creat       equ     8      ;crear archivo
sys_sync        equ    36      ;sincronizar con disco (forzar escritura)
stdin           equ     0   ;entrada estandar (teclado)
stdout          equ     1   ;salida estandar (pantalla)
stderr          equ     3   ;salida de error estandar
O_RDONLY        equ     0   ;open for read only
O_RDWR          equ     1   ;open for read and write

;Recibe direccion de cadena a medir longitud en EAX
;Regresa en EAX el conteo de caracteres de la cadena
  strlen:
    push EBX		;salvamos el valor de EBX en la pila (stack)
    mov EBX,EAX		;copiamos la direccion del mensaje a EBX

  sigcar:
    cmp byte[EAX],0	;comparamos el byte que esta en la direccion
			             ;a la que apunta EAX comn 0 (estamos buscando el caracter de terminacion 0)
    jz finalizar 	;JUMP if Zero, salta a finalizar si es cero
    inc EAX		;incrementamos en 1 el acumulador
    jmp sigcar		;salto incondicional al siguiente caracter

  finalizar:
    sub EAX,EBX		;restamos al valor inicial de memoria el valor final de memoria
    pop EBX		;establecer EBX
    ret			;regresar al punto en que llamaron a la funcion

  sprint:
    push EDX		;salvamos valor de EDX
    push ECX		;salvamos valor de ECX
    push EBX		;salvamos valor de ECX
    push EAX		;salvamos valor de EAX
    call strlen 	;llamamos a la funcion strlen

    mov EDX,EAX 	;movemos la longitud de cadena a EDX
    pop EAX		;traemos del stack el valor de EAX
    mov ECX,EAX 	;la direccion del mensaje a ECx
    mov EBX,stdout		;descriptor de archivo(stdout)
    mov EAX,sys_write		;sys_write
    int 80h		;ejecuta

    pop EBX		;re-establecemos EBX
    pop ECX		;re-establecemos ECX
    pop EDX		;re-establecemos EDX
    ret

;imprime cadenas de texto con una nueva linea (LF o Line Feed)
  sprintLF:
    call sprint		;llama e imprime el mensaje
    push EAX		;salvamos EAX,vamos a utilizarlo en esta funcion
    mov EAX,0xA		;Hexadecimal para caracter de lineFeed
    push EAX		;salvamos el 0xA en el stack
    mov EAX,ESP		;Lo que apunta ESP a EAX
    call sprint		;Imprimimos el LF
    pop EAX		;Recuperamos el caracter 0xA
    pop EAX		;Recuperamos el valor original de 0xA
    ret			;Regresamos

; funcion iprint (integer print ) o impresion de enteros
  iprint:
  	push eax ; salvamos eax en el stack (acumulador)
  	push ecx ; salvamos ecx en el stack (contador)
    push edx ; salvamos edx en el stack 	(base)
  	push esi ; salvamos esi en el stack ( source index)
  	mov ecx,0 ; vamos a contar cuantos bytes necesitamos imprimir

  dividirLoop:
  	inc ecx      ; incrementamos en 1 ecx
  	mov edx,0    ; limpiamos edx
  	mov esi,10   ; guardamos 10 en esi , vamos a divir entre 10
  	idiv esi     ;divide eax entre esi
  	add edx , 48   ; agregamos el caracter 48 '0'
  	push edx          ;la representacion de ascii de nuestro numero
  	cmp eax,0    ; se puede dividir mas el numero entero ?
  	jnz dividirLoop   ; jum if not zero (salta si no es cero)

  imprimirloop:
  	dec ecx     ; vamos a contar hacia abajo cada byte en el stack
  	mov eax,esp ; aputador del stack a eax
  	call sprint ;llamamos ala funcion sprint
  	pop eax      ; removemos el ultimo caracter del stack
  	cmp ecx ,0   ; ya imprimos todos los bytes del stack ?
  	jnz imprimirloop   ; todabia hay numeros que imprimir ?

  	pop esi ; re - estabnlecemos el valor de esi
  	pop edx    ; re-establecemos el valor de edx
  	pop ecx ; re-establecemos el valor de ecx
  	pop eax   ; re-establecemos el valor de eax
  	ret ; regresamos

; funcion iprintlf (integer print ) o impresion de enteros con line feed
  iprintLF:
    call iprint ;imprimimo el numeros
    push eax   ;salvamos el dato que traemos en el acumulador

    mov eax,0xA ; copiamos el line feed a eax
    push eax ; salvamos el line feed en el stack
    mov eax, esp ; copiamos el apuntador del stack a eax  estamos apuntando a una direccion de memoria
    call sprint   ; imiprimos el line feed
	  pop EAX		;remomovemos el linefeed del stack
    pop EAX		;re-establecemos el dato que traiamos en eax
    ret			;Regresamos

; ----------------------------------   3 parcial
; int atoi  ( entero)
;convierte ascii a entero
;------------------------------------------------
    atoi:
      push ebx  ; preservamos ebx
      push ecx  ; preservamos edx
      push edx  ; preservamos edx
      push esi  ; preservamos esi
      mov  esi,eax ; nuestro numero a convertir va a esi
      mov eax,0   ;inicializamos a cero eax
      mov ecx,0  ; inicializamos a cero ecx

    ciclomult:    ; ciclo multiplicacion
      xor ebx,ebx   ; resetteamos a 0 ebx, tanto  bh como bl
      mov bl,[esi+ecx]     ; movemos un solo byte a ala parte baja de ebx
      cmp bl, 48          ; comparamos con ascii ´0´
      jl  finalizado ; si es menor , saltamos a finalizado.
      cmp bl,57     ; comparamos con ascci "9"
      jg  finalizado ; si es mayor, saltamos a finalizado
      cmp bl, 10   ; comparamos con linefeed
      je  finalizado ; si es igual, saltamos a finalizado
      cmp bl, 0    ; comparamos con caracter null ](fin de caneda)
      jz finalizado ; si es cero saltamos a finalizado
      sub bl,48     ;convertimos el caracter en entero
      add eax,ebx ; agreagamos el valor a eax
      mov ebx,10 ; movemos el decimal 10 a ebx
      mul ebx  ; multiplicamos eax por ebc para obtener el lugar decimal
      inc ecx    ; incrementamos ecx (conttador)
      jmp ciclomult ; seguimos nuestro ciclo de multiplicacion

    finalizado:
      mov ebx,10 ; movemos el valor decimal 10 a ebx
      div ebx ; dividimos eax entre 10
      pop esi ; re-establecemos esi
      pop edx    ; re-establecemos edx
      pop ecx  ; re-establecemos ecx
      pop ebx ; re-establecemos ebx
      ret

    quit:
      mov eax, sys_exit
      int 0x80

;se agrego en la clase del dia 23 de Abril del 2018
    LeerTexto:
      mov ebx, stdin
      mov eax, sys_read
      int 80H
      ret

    copystring:
      push ecx ;salvamos ecx en stack
      push ebx
      mov ebx, 0
      mov ecx, 0 ;ecx a 0

    .sigcar:
      mov BL, byte[EAX] ;copiamos la direccion del mensaje a EBX
      cmp BL, 0xA       ;comparamos con salto de linea
      je .salto

      mov byte[ESI+ECX],BL  ;movemos un caracter al array
      cmp byte[EAX],0       ;comparamos el byte que esta en la direccion
                            ;a la que apunta EAX con 0
      jz .finalizar
    .salto:
      inc EAX       ;incrementamos en 1 el acumulador
      inc ECX       ;incrementamos en 1 el acumulador
      jmp .sigcar   ;salto incondicional al sguiente caracter

    .finalizar:
      pop EBX
      pop ECX       ;restablecer ECX
      ret           ;regresa al punto en que llamamos a la funcion



;====== Numero mayor y menor de un arreglo =======;
readArray:
  mov ECX, 0
  mov EDX, 0            ;Inicializamos ebx en 0 esta almacena el mayor
  mov EDX, [ESI+ECX*4]  ;Sacamos el primer valor del arreglo para almacenar el numero menor

loopRead:
  cmp ECX, EDI          ;llegamos a 0?
  je quitRead           ;Salimos de la lectura
  mov EAX, [ESI+ECX*4]  ;traemos de array numero a comparar
  inc ECX               ;incrementamos indice de array
  jne numMax            ;Vamos a la comparaciòn

numMax:
  cmp EAX, EBX          ;El numero del array lo comparamos con el almacenado
  jle numMin            ;Si eax es menor al almacenado
  jge setSecond         ;Si eax es mayor al almacenado

setSecond:
  mov EBX, EAX          ;Movemos el numero del arreglo a EBX
  jmp numMin            ;Vamos a la funciòn del numero menor

numMin:
  cmp EAX, EDX          ;El numero de array lo comparamos con el almacenado
  jle setMinus          ;Si eax es menor al almacenado
  jge loopRead          ;Si eax es mayor al almacenado (Nos vamos al siguiente numero)

setMinus:
  mov EDX, EAX          ;Movemos del array el numero menor al almacenado
  jmp loopRead          ;Leemos el siguiente numero

quitRead:
  mov EAX, num_max      ;Movemos para imprimir el mensaje
  call sprint           ;Imprimimos el mensaje
  mov EAX, EBX          ;movemos el numero mayor
  call iprintLF         ;Lo imprimimos
  mov EAX, num_min      ;Movemos para imprimir el mensaje
  call sprint           ;Imprimimos el mensaje
  mov EAX, EDX          ;Movemo el numero menor
  call iprintLF         ;Imprimimos el numero
  ret                   ;Regresamos

;====== Numero mayor y menor de un arreglo =======;
