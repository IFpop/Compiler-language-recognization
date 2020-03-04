.486
.model flat, stdcall
option casemap :none

; ����ϵͳ��
include kernel32.inc
includelib kernel32.lib
includelib msvcrt.lib

; ����������ж���
fscanf	PROTO C :ptr sbyte, :ptr sbyte, :vararg
fprintf	PROTO C :ptr sbyte, :ptr sbyte, :vararg
printf	PROTO C :ptr sbyte, :vararg

; ���ļ��򿪽��ж���
fopen	      PROTO C :ptr sbyte, :ptr sbyte
fclose	PROTO C :ptr sbyte

; ���ݶ�
.data

; �ļ������������
dataFile	byte	"data.txt", 0
resultFile	byte	"result.txt", 0
readFlag	byte	"r", 0
writeFlag	byte	"w", 0
pf	      dword	?

; ��������������
InputFmt    byte "%d"  , 0
OutputFmt   byte "%d " , 0
OutFmtNext	byte "%d", 0ah, 0
BeginStr    byte "Matrix multiplication implemented",
                "  by Intel x86 Assembly.", 0ah, 0
Pttime    byte	"cost time: %d ms.", 0ah, 0

rowHead	dword	?
colHead	dword	?
line		dword	?

; ��������������
A_row     dword   ?
B_row     dword   ?
B_col     dword   ?
A_col     dword   ?
A    	    dword   510 * 510 dup(?)
B	    dword   510 * 510 dup(?)
Ans	    dword   510 * 510 dup(?)
tail	    dword   ?

.code 
; ��ȡ�����ļ�
readMatrix 	proc	stdcall	file:dword, M:dword, row:dword, col:dword
      ; �� 
      mov esi, row
      invoke fscanf, file, offset InputFmt, esi
      
      ; ��
      mov edi, col
      invoke fscanf, file, offset InputFmt, edi
      
      mov eax,[esi]
      mov ebx,[edi]
	mul ebx
    	mov ebx, 4 
    	mul ebx
      
      mov esi, M
	mov edi, M
	add edi, eax
READ:
	invoke fscanf, file, offset InputFmt, esi
	add esi, 4
	cmp esi, edi
	jb READ  ; ת�ƣ�����һֱ��ȡ����
	ret
readMatrix 	endp

; ���г˷�����
comptu_matrix	proc	stdcall X:dword, Y:dword, Z:dword
	; Ϊ�˱�����������Ӱ��Ĵ�����ֵ������ѹ��ջ��
      push ebx
	push ecx
	push edx
	push esi
	push edi
    
      ; ΪZ����һ���ռ�
	mov ebx, Z
	mov tail, ebx
	mov eax, A_row
	mov edx, B_col
	mul edx
	mov edx, 4
	mul edx
	add tail, eax   

	mov eax, X
	mov rowHead, eax
	mov eax, Y
	mov colHead, eax
	mov eax, 4
	mov edx, A_row
	mul edx        ; ��ʾһ�������Ѿ����м���
	mov line, eax

	xor ecx, ecx
HEAD:                  
	xor eax, eax
	mov [ebx], eax
	mov esi, rowHead
	mov edi, colHead

	push ecx
	xor ecx, ecx
ROWDATA:
	mov eax, [esi]
	mov edx, [edi]
	mul edx
	add [ebx], eax

	add esi, 4
	add edi, line
	inc ecx 
	cmp ecx, A_row  ; �ж��Ƿ�������������
	jb ROWDATA
	pop ecx

	inc ecx
	cmp ecx, B_col
	je NEXTROW
	add colHead, 4
	jmp DONE
NEXTROW:
	mov eax, line
	add rowHead, eax
	mov eax, Y
	mov colHead, eax
	xor ecx, ecx
DONE:

	add ebx, 4
	cmp ebx, tail
	jb HEAD
	
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx
	ret
comptu_matrix	endp

; д���ļ�
write2file		proc	stdcall	file:dword, M:dword
	mov esi, M
	mov tail, esi
	mov eax, A_row
	mov edx, B_col
	mul edx     ; row*col  ��������
    	mov edx, 4  
	mul edx    ; 4*row*col
      ;invoke printf, offset OutputFmt, eax
	add tail, eax   ; tail + 4*row*col

      invoke fprintf, file, offset OutputFmt, A_row
      invoke fprintf, file, offset OutFmtNext, B_col      ; �����һ��: ����
	xor edi, edi   ; ����
LOP:
	inc edi    ; ����
	cmp edi, A_row ; �ж��Ƿ�һ��
	je EN
	invoke fprintf, file, offset OutputFmt, dword ptr [esi]
	jmp OVER
EN:
	invoke fprintf, file, offset OutFmtNext, dword ptr [esi]  ; ���һ�к���
	xor edi, edi ; ����
OVER:

	add esi, 4
	cmp esi, tail
	jb LOP
	ret
write2file 	endp

; ������
begin:
    ; ��ӡ��ʼ��ʾ�ַ�
    invoke printf, offset BeginStr 
    xor eax, eax
    
    ; ��ʼ�����ļ�����
    invoke fopen, offset dataFile, offset readFlag
    ; ��ȡ�ļ���ַ��ʼ��ַ���������֮ǰ����õ�pf�ļ�ָ����
    mov pf, eax
    ; ��ȡ�����Լ�����
    invoke readMatrix, pf, offset A, offset A_row, offset A_col
    invoke readMatrix, pf, offset B, offset B_row, offset B_col
    invoke fclose, pf

    ; ��ȡ��ǰʱ��
    invoke GetTickCount
    mov ebx, eax  ; ����ȡ��ʱ�����ebx
    invoke comptu_matrix, offset A, offset B, offset Ans
    invoke GetTickCount
    sub eax, ebx  ; ���������������ĵ�ʱ��
    invoke printf, offset Pttime, eax

    ; ��Ԥ���趨��д���ļ�
    invoke fopen, offset resultFile, offset writeFlag
    mov pf, eax
    invoke write2file, pf, offset Ans
    invoke fclose, pf
    
end begin