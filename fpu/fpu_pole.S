# Program obliczający pole trójkąta o zadanej podstawie i wysokości
# Kompilacja:
# as --32 -o fpu_pole.o fpu_pole.S
# ld -o fpu_pole fpu_pole.o -lc -dynamic-linker /lib/ld-linux.so.2 -melf_i386

.data

wynik_fmt:	.ascii	"Pole trojkata wynosi: %f\n\0"
pods_fmt:	.ascii	"Podaj dlugosc podstawy trojkata: \0"
wys_fmt:	.ascii	"Podaj wysokosc trojkata: \0"
scan_fmt:	.ascii	"%f\0"

podstawa:	.float	0
wysokosc:	.float	0

pole:		.float	0
stala_2:	.float	2.0

.text
.globl	_start
_start:
	finit					#inicjalizacja FPU (!!!ważne nie zapomnieć!!!)
	
	pushl	$pods_fmt
	call	printf
	addl	$4, %esp

	pushl	$podstawa
	pushl	$scan_fmt
	call	scanf
	addl	$4 * 2, %esp

	pushl	$wys_fmt
	call	printf
	addl	$4, %esp

	pushl	$wysokosc
	pushl	$scan_fmt
	call	scanf
	addl	$4 * 2, %esp

	pushl	wysokosc
	pushl	podstawa
	call	poleTrojkata
	addl	$4 * 2, %esp

	fstpl	(%esp)				#wczytaj wartosc z st(0) - wynik na stos programowy i scianij ze stosu FPU
	pushl	$wynik_fmt
	call	printf
	addl	$4, %esp
	
	pushl	$0
	call	exit
	

.globl	poleTrojkata			#float poleTrojkata(float postawa, float wysokosc)	
.type	poleTrojkata, @function	#wynik jest przechowywany w st(0)
poleTrojkata:
	pushl	%ebp
	movl	%esp, %ebp
	flds	8(%ebp)
	flds	12(%ebp)
	faddp
	flds	stala_2
	fdivrp
	movl	%ebp, %esp
	popl	%ebp
	ret
	
