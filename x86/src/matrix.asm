.486
.model flat, stdcall
option casemap :none

; 调用系统库
include kernel32.inc
includelib kernel32.lib
includelib msvcrt.lib

; 输入输出进行定义
fscanf	PROTO C :ptr sbyte, :ptr sbyte, :vararg
fprintf	PROTO C :ptr sbyte, :ptr sbyte, :vararg
printf	PROTO C :ptr sbyte, :vararg

; 对文件打开进行定义
fopen	      PROTO C :ptr sbyte, :ptr sbyte
fclose	PROTO C :ptr sbyte

; 数据段
.data

; 文件操作相关数据
dataFile	byte	"data.txt", 0
resultFile	byte	"result.txt", 0
readFlag	byte	"r", 0
writeFlag	byte	"w", 0
pf	      dword	?

; 输入输出相关数据
InputFmt    byte "%d"  , 0
OutputFmt   byte "%d " , 0
OutFmtNext	byte "%d", 0ah, 0
BeginStr    byte "Matrix multiplication implemented",
                "  by Intel x86 Assembly.", 0ah, 0
Pttime    byte	"cost time: %d ms.", 0ah, 0

rowHead	dword	?
colHead	dword	?
line		dword	?

; 矩阵操作相关数据
A_row     dword   ?
B_row     dword   ?
B_col     dword   ?
A_col     dword   ?
A    	    dword   510 * 510 dup(?)
B	    dword   510 * 510 dup(?)
Ans	    dword   510 * 510 dup(?)
tail	    dword   ?

.code 
; 读取矩阵文件
readMatrix 	proc	stdcall	file:dword, M:dword, row:dword, col:dword
      ; 行 
      mov esi, row
      invoke fscanf, file, offset InputFmt, esi
      
      ; 列
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
	jb READ  ; 转移，类似一直读取数据
	ret
readMatrix 	endp

; 进行乘法计算
comptu_matrix	proc	stdcall X:dword, Y:dword, Z:dword
	; 为了避免其他因素影响寄存器的值，将其压入栈中
      push ebx
	push ecx
	push edx
	push esi
	push edi
    
      ; 为Z分配一定空间
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
	mul edx        ; 表示一行数据已经进行计算
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
	cmp ecx, A_row  ; 判断是否填入整行数据
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

; 写入文件
write2file		proc	stdcall	file:dword, M:dword
	mov esi, M
	mov tail, esi
	mov eax, A_row
	mov edx, B_col
	mul edx     ; row*col  矩阵行列
    	mov edx, 4  
	mul edx    ; 4*row*col
      ;invoke printf, offset OutputFmt, eax
	add tail, eax   ; tail + 4*row*col

      invoke fprintf, file, offset OutputFmt, A_row
      invoke fprintf, file, offset OutFmtNext, B_col      ; 输入第一行: 行列
	xor edi, edi   ; 清零
LOP:
	inc edi    ; 自增
	cmp edi, A_row ; 判断是否到一行
	je EN
	invoke fprintf, file, offset OutputFmt, dword ptr [esi]
	jmp OVER
EN:
	invoke fprintf, file, offset OutFmtNext, dword ptr [esi]  ; 输出一行后换行
	xor edi, edi ; 清零
OVER:

	add esi, 4
	cmp esi, tail
	jb LOP
	ret
write2file 	endp

; 主函数
begin:
    ; 打印开始提示字符
    invoke printf, offset BeginStr 
    xor eax, eax
    
    ; 开始进行文件操作
    invoke fopen, offset dataFile, offset readFlag
    ; 获取文件地址起始地址，将其存在之前定义好的pf文件指针中
    mov pf, eax
    ; 读取矩阵，以及行列
    invoke readMatrix, pf, offset A, offset A_row, offset A_col
    invoke readMatrix, pf, offset B, offset B_row, offset B_col
    invoke fclose, pf

    ; 获取当前时间
    invoke GetTickCount
    mov ebx, eax  ; 将获取的时间存入ebx
    invoke comptu_matrix, offset A, offset B, offset Ans
    invoke GetTickCount
    sub eax, ebx  ; 计算矩阵相乘所消耗的时间
    invoke printf, offset Pttime, eax

    ; 打开预先设定的写入文件
    invoke fopen, offset resultFile, offset writeFlag
    mov pf, eax
    invoke write2file, pf, offset Ans
    invoke fclose, pf
    
end begin