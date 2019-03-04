%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .bss
	expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
    push ebp
    mov ebp, esp

    GET_STRING expr, MAX_INPUT_SIZE
    mov esi, expr
    xor ebx, ebx
    xor ecx, ecx
    xor eax, eax
        
compare:           
    cmp     byte[esi], 0x00         ;	check for string terminator
    je      print_result
    cmp     byte[esi], ' '
    je      space
    cmp     byte[esi], '+'
    je      addition
    cmp     byte[esi], '-'
    je      line
    cmp     byte[esi], '*'
    je      multiplication
    cmp     byte[esi], '/'
    je      division
    jne     positive

space:
    push ecx
    xor ecx, ecx
    add esi, 1
    jmp compare
     
addition:
    pop ecx
    pop ebx
    add ecx, ebx
    push ecx
    add esi, 2
    xor ecx, ecx
    xor ebx, ebx
    jmp compare

line:
    cmp byte[esi + 1], 0x00         ;	if minus sign is followed by the end 
    je subtraction                  ;	of the row or a blank space, it means
    cmp byte[esi + 1], ' '          ;	that the minus sign is used for subtraction 
    je subtraction
    jne negative                    ;	otherwise, it is the beginning of a negative number 
    
negative:
    mov bl, byte[esi + 1]
    sub ebx, "0"                    ;	the value of "0" is subtracted from initial value
    sub ecx, ebx                    ;	to find out the real number
    add esi, 2
    jmp compare
   
subtraction:
    pop ecx
    pop ebx
    sub ebx, ecx
    push ebx
    add esi, 2
    xor ecx, ecx
    xor ebx, ebx
    jmp compare
    
multiplication:
    pop ecx
    pop eax
    imul ecx
    push eax
    add esi, 2
    xor ecx, ecx
    xor eax, eax
    jmp compare

division:
    pop ecx
    pop eax
    xor edx, edx
    test eax, eax
    js neg_dividend                 
    jns pos_dividend                
neg_dividend:                       
    neg eax                         ;	if devidend is negative, we reverse its sign			
    idiv ecx                        ;	then we make the division and after that				
    neg eax                         ;	we reverse the sign of the result 						
    jmp division_ending
pos_dividend:    
    idiv ecx                        ;	if dividend is positive, we make the division
division_ending:                    ;	without reversing any sign
    push eax
    add esi, 2
    xor ecx, ecx
    xor eax, eax
    jmp compare
    
positive:
    mov eax, 10
    mul ecx
    mov ecx, eax
    mov bl, byte[esi]
    sub ebx, "0"
    test ecx, ecx                   ;	for number of two or more digits
    js negative_ecx
    jns positive_ecx
negative_ecx:                       ;	if the number* is negative, the current		
    sub ecx, ebx                    ;	digit is subtracred from the number* (the		
    jmp positive_ending             ;	number you found earlier multiplied by 10)
positive_ecx:
    add ecx, ebx                    ;	otherwise, the current digit is added to that number*
positive_ending:
    add esi, 1
    jmp compare    

print_result:
    pop ecx
    PRINT_DEC 4, ecx
    
    xor eax, eax
    mov esp, ebp
    pop ebp    
    ret
