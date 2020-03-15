;---------Reloj de la Tiva--------------------------------
SYSCTL_RCGCGPIO_R 	   EQU 0x400FE608
;---------Modo Analógico----------------------------------
GPIO_PORTF_AMSEL_R     EQU 0x40025528;
;---------Permite desactivarFuncion Alternativa-----------
GPIO_PORTF_PCTL_R      EQU 0x4002552C;
;---------Especificación de dirección---------------------
GPIO_PORTF_DIR_R      EQU   0x40025400;
;---------Funciones Alternativas--------------------------
GPIO_PORTF_AFSEL_R    EQU   0x40025420;
;---------Habilita el modo digital------------------------
GPIO_PORTF_DEN_R      EQU   0x4002551C;
;---------Deshabilita la resistencia de F0 y F4-----------
GPIO_PORTF_PUR_R   EQU 0x40025510 ; 
;---------Permite desbloquear los pines F-----------------
GPIO_PORTF_LOCK_R  EQU 0x40025520 ;
;---------Permite desbloquear el puerto PF0---------------	
GPIO_PORTF_CR_R    EQU 0x40025524 
;---------Desbloquea el Pin-------------------------------
GPIO_LOCK_KEY      EQU 0x4C4F434B 
					 
	
;---------Modo Analógico----------------------------------
GPIO_PORTB_AMSEL_R     EQU 0x40005528;
;---------Permite desactivarFuncion Alternativa-----------
GPIO_PORTB_PCTL_R      EQU 0x4000552C;
;---------Especificación de dirección---------------------
GPIO_PORTB_DIR_R      EQU  0x40005400;
;---------Funciones Alternativas--------------------------
GPIO_PORTB_AFSEL_R    EQU  0x40005420;
;---------Habilita el modo digital------------------------
GPIO_PORTB_DEN_R      EQU   0x4000551C;
						 
	
;------------Pines que se utilizarán------------------------
PB			   EQU	0x400053FC;Todos los pines del puerto B
PF4			   EQU 0x40025040;Puerto F4
 ;-----------Delay de un segundo----------------------------
ONESEC         EQU 5333333  ;[[16*10E6]/3]=5333333.333, numero asociado a 1 segundo

	AREA    |.text|, CODE, READONLY, ALIGN=2	
	THUMB										
	EXPORT  Start		
		

Start
;-----------Comando para asignar el valor de un arreglo a un registro.
	ADR R2, arreglo0; R2 es igual a Arreglo2 					
    BL  Puertos_iniciar               	
   
;--------------Orden en el que se ejecutarán los comandos------	
Ciclo                                
	LDR R7, =ONESEC             	  	
    BL  retardo                        	
    BL  Display						
	
	BL  Boton				
	BL  Reset							
    B   Ciclo						

;------------Habilitar Reloj------------------------------
Puertos_iniciar
    LDR R1, =SYSCTL_RCGCGPIO_R		; activar reloj
    LDR R0, [R1]                    
    ORR R0, R0, #0x22			 
    STR R0, [R1]                    
    NOP								 
    NOP								
    NOP                            	 
	;PORT F
;--------Declarar puertos como Entrada------------------
;---------Desbloquear los pines PF0 y PF1----------------    
    LDR R1, =GPIO_PORTF_LOCK_R      
    LDR R0, =GPIO_LOCK_KEY          
    STR R0, [R1]                    
   
    LDR R1, =GPIO_PORTF_CR_R        
    MOV R0, #0xFF                  
    STR R0, [R1]                    
;--------Configuración como I/O--------------------------	
    LDR R1, =GPIO_PORTF_DIR_R       
    LDR R0, [R1]                    
    BIC R0, R0, #0x10          
    STR R0, [R1]                    
;--------Deshabilita las funciones alternativas----------    
    LDR R1, =GPIO_PORTF_AFSEL_R     
    LDR R0, [R1]                   
    BIC R0, R0, #0x10          
    STR R0, [R1]                    
;--------Desactiva la resistencia pull up----------------
    LDR R1, =GPIO_PORTF_PUR_R       
    LDR R0, [R1]                    
    ORR R0, R0, #0x10       
    STR R0, [R1]                   
;--------Habilita el puerto como entrada y salida digital-
    LDR R1, =GPIO_PORTF_DEN_R       
    LDR R0, [R1]                    
    ORR R0, R0, #0x10          
    STR R0, [R1]                    
;--------Permite deshabilitar las funciones alternativas-    
    LDR R1, =GPIO_PORTF_PCTL_R      
    LDR R0, [R1]                    
    BIC R0, R0, #0x000F0000                 
    STR R0, [R1]         
	
	;PORT B
;--------Configuración como I/O--------------------------
	LDR R1, =GPIO_PORTB_DIR_R 
	LDR R0, [R1]
	ORR R0, R0, #0xFF;  Output. Valor segun el numero del puerto.
	STR R0, [R1]                 ;	
;--------Deshabilita las funciones alternativas----------	
	LDR R1, =GPIO_PORTB_AFSEL_R 
	LDR R0, [R1]
	BIC R0, R0, #0xFF;  Desabilita las demas funciones. 
	STR R0, [R1]
;--------Habilita el puerto como entrada y salida digital-
	LDR R1, =GPIO_PORTB_DEN_R       
    LDR R0, [R1]                    
    ORR	 R0,#0xFF;		Activa el puerto digital.    
    STR R0, [R1]   
;--------Permite deshabilitar las funciones alternativas-
	LDR R1, =GPIO_PORTB_PCTL_R 
	LDR R0, [R1]
	BIC R0, R0, #2_11111111;  Configura el puerto como GPIO. 
	STR R0, [R1]       				
    
;--------Desactiva la función analógica------------------	
	LDR R1, =GPIO_PORTB_AMSEL_R;
	LDR R0, [R1]
	BIC R0, R0, #0xFF; Valor segun el numero del puerto.
	STR R0, [R1]

    BX  LR


									 
;---------Retardo para que no ocurra rebote------------------	
retardo
    SUBS R7, R7, #1
    BNE retardo						
	BX  LR                          
;----------Leerá el estado del pin PF4-----------------------	
Boton
	LDR R4, =PF4
    LDR R0, [R4]                    
	CMP R0, #0x10                   
	BEQ Boton						
    BX LR                        	
	
;------------Encender Display---------------------------------
;LDRB: A R3 se le asigna los valores que se encuentran de la dirección 
;guardada en R2 y a R2 se le indica que se moverá una posicion 
;dentro del vector
;-------------------------------------------------------------
Display
	LDRB R3,[R2],#1;					
    LDR R1, =PB; A R1 se le asigna el vector de PB                   	
	STR R3, [R1]; En esta linea se le asignan los valores de R3 a R1,
				;En otras palabras los valores del vector a PB
    BX  LR                          

;------------Reset------------
Reset
	CMP R3, #2_10000000; Compara si ya tiene el valor deseado
						;Aun que hayan mas valores no continuará.
	BEQ Start
    BX  LR                           
	
    ALIGN                           
;-----------Declara los valores del arreglo-------------
arreglo0	DCB 2_01110111,2_00010001,2_01101011
			DCB 2_00111011,2_00011101,2_00111110
			DCB 2_01111110,2_00010011,2_01111111
			DCB 2_00011111,2_10000000,2_00000000	
				
		
    END                             