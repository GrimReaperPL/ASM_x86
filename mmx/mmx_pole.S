# Program obliczający pole trójkąta o zadanej podstawie i wysokości
# Kompilacja:
# as --32 -o fpu_pole.o fpu_pole.S
# ld -o fpu_pole fpu_pole.o -lc -dynamic-linker /lib/ld-linux.so.2 -melf_i386

.data

wynik_fmt:	.ascii	"Pole trojkata wynosi: %d\n\0"
pods_fmt:	.ascii	"Podaj dlugosc podstawy trojkata: \0"
wys_fmt:	.ascii	"Podaj wysokosc trojkata: \0"
scan_fmt:	.ascii	"%d\0"

podstawa:	.long	0
wysokosc:	.long	0

pole:		.long	0

.text
.globl	_start
_start:
	#finit					#inicjalizacja FPU (!!!ważne nie zapomnieć!!!)
	
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

	pushl	%eax
	pushl	$wynik_fmt
	call	printf
	addl	$4 * 2, %esp
	
	pushl	$0
	call	exit
	

.globl	poleTrojkata			#int poleTrojkata(int postawa, int wysokosc)	
.type	poleTrojkata, @function	#wynik jest przechowywany w eax
poleTrojkata:
	pushl	%ebp
	movl	%esp, %ebp
	movd	8(%ebp), %mm0
	movd	12(%ebp), %mm1
	paddusw	%mm1, %mm0
	movd	%mm0, %eax
	movl	$0, %edx
	movl	$2, %ebx
	divl	%ebx
	emms	
	movl	%ebp, %esp
	popl	%ebp
	ret
	
