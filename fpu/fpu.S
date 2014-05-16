# Dzielenie PI przez PI i sprawdzenie czy da 1.0
# kompilacja
# as --32 -o fpu.o fpu.S
# ld -o fpu fpu.o -lc -dynamic-linker /lib/ld-linux.so.2 -melf_i386
# ./fpu

.data
jeden:	.ascii	"Jeden\0"
nie_jeden:	.ascii	"Nie rowne jeden\0"
frm_float:	.ascii	"PI / PI = %f\n\0"

wynik:	.float	0
.text
.globl _start
_start:
	finit			#inicjalizaca FPU
	
	fldpi			#zaladuj PI na stos FPU
	fldpi			#zaladuj PI znowu na stos
	fdivp			#podziel st(1) / st(0) czyli PI / PI

	fld1			#zaladuj 1.0 na stos
	fcomip			#porownaj wynik PI / PI z 1.0 i sciagnij ze stosu i wrzuc flagi do eflags
	jnz		nie_jest_jeden	#jezeli nie sa rowne to skocz

jest_jeden:
	pushl	$jeden
	call	puts
	addl	$4, %esp
	jmp		wypisz_wynik

nie_jest_jeden:
	pushl	$nie_jeden
	call	puts
	addl	$4, %esp
	
wypisz_wynik:
	fstps	wynik		#zapisz wynik do zmiennej typu .float (32 bity) i sciagnij ze stosu FPU
	flds	wynik		#załaduj wynik ze zmiennej typu .float na stos FPU
	fstpl	(%esp)		#zwroc wynik typu double (printf takie przyjmuje) i zapisz na stosie programowym
	pushl	$frm_float
	call	printf
	addl	$4, %esp	#stos czyszczony tylko po push frm_float bo nic wiecej nie zmienialo esp

	pushl	$0
	call	exit		#wyjscie z kodem blędu 0 (mozna sprawdzic w bashu po wpisaniu echo $? )

