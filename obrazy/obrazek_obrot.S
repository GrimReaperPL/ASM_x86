# Program obracający obrazek o 90stopni zapisany w pliku .BMP

UPRAWNIENIA = 0b110110110	#chmod 666
DO_ODCZYTU = 0
DO_ZAPISU = 1
OD_POCZATKU = 0

SYS_OPEN = 5
SYS_CREAT = 8
SYS_CLOSE = 6
SYS_LSEEK = 19
STDIN = 0
STDOUT = 1
SYS_BRK = 45
READ = 3
WRITE = 4
EXIT = 1
SYSCALL = 0x80

SYGNATURA_BMP = 0x4D42
OFFSET_IMG_START = 10
OFFSET_WIDTH = 18
OFFSET_HEIGHT = 22
OFFSET_SIZE_IMG = 34

.data
plik_zrodlo:	.long	0
plik_cel:		.long	0

sygnatura:		.word	0
start_offset:	.long	0
width:			.long	0
height:			.long	0
rozmiar:		.long	0

info_zrodlo:	.ascii	"Podaj nazwe pliku wejsciowego [.bmp]: \0"
info_zrodlo_size =	. - info_zrodlo

info_cel:		.ascii	"Podaj nazwe pliku docelowego [.bmp]: \0"
info_cel_size =	. - info_cel

info_blad:	.ascii	"Blad otwarcia pliku.\n\0"
info_blad_size = . - info_blad

bufor_zwrotny:	.long	0		#przechowuje adres w pamieci

.bss

nazwa_pliku_size = 100
.lcomm nazwa_pliku, nazwa_pliku_size

nazwa_docelowa_size = 100
.lcomm nazwa_docelowa, nazwa_docelowa_size

dane_chwilowe_size = 4
.lcomm dane_chwilowe, dane_chwilowe_size

rozmiar_naglowka = 54
.lcomm naglowek, rozmiar_naglowka

.lcomm koniec_bss, 4
.lcomm bufor_tymczasowy, 4				#bedzie alokowany dynamicznie

.text
.globl	_start
_start:
	movl	$info_zrodlo_size, %edx
	movl	$info_zrodlo, %ecx
	movl	$STDOUT, %ebx
	movl	$WRITE, %eax
	int		$SYSCALL
	
	movl	$nazwa_pliku_size, %edx
	movl	$nazwa_pliku, %ecx
	movl	$STDIN, %ebx
	movl	$READ, %eax
	int		$SYSCALL
	
	decl	%eax
	movb	$0, nazwa_pliku( ,%eax, 1)		#na koncu musi byc \0 a nie \n

	movl	$info_cel_size, %edx
	movl	$info_cel, %ecx
	movl	$STDOUT, %ebx
	movl	$WRITE, %eax
	int		$SYSCALL
	
	movl	$nazwa_docelowa_size, %edx
	movl	$nazwa_docelowa, %ecx
	movl	$STDIN, %ebx
	movl	$READ, %eax
	int		$SYSCALL

	decl	%eax
	movb	$0, nazwa_docelowa( ,%eax, 1)		#na koncu musi byc \0 a nie \n
	
	movl	$UPRAWNIENIA, %edx
	movl	$DO_ODCZYTU, %ecx
	movl	$nazwa_pliku, %ebx
	movl	$SYS_OPEN, %eax
	int		$SYSCALL
	cmpl	$0, %eax
	jl		blad
	movl	%eax, plik_zrodlo			#zapisany deskryptor pliku
	
	movl	$UPRAWNIENIA, %edx
	movl	$DO_ZAPISU, %ecx
	movl	$nazwa_docelowa, %ebx
	movl	$SYS_CREAT, %eax
	int		$SYSCALL
	cmpl	$0, %eax
	jl		blad
	movl	%eax, plik_cel				#zapisany deskryptor pliku

# najpierw wczytanie nagłówka
	movl	$2, %edx
	movl	$dane_chwilowe, %ecx
	movl	plik_zrodlo, %ebx
	movl	$READ, %eax
	int		$SYSCALL

	xorl	%eax, %eax
	movw	dane_chwilowe, %ax			#powinno byc 4D42 czyli BM
	cmpw	$SYGNATURA_BMP, %ax
	movl	$-2, %eax					#plik nie jest w formacie BMP konczymy z kodem bledu -2
	jnz		zamkniecie_plikow

	movl	$OD_POCZATKU, %edx
	movl	$OFFSET_IMG_START, %ecx
	movl	plik_zrodlo, %ebx
	movl	$SYS_LSEEK, %eax
	int		$SYSCALL					#przesuwamy sie do 10 bajtu

	movl	$4, %edx
	movl	$dane_chwilowe, %ecx
	movl	plik_zrodlo, %ebx
	movl	$READ, %eax
	int		$SYSCALL
	
	movl	dane_chwilowe, %eax
	movl	%eax, start_offset			#adres startu danych z pliku (przeważnie == 54 == 0x36)

	
	movl	$OD_POCZATKU, %edx
	movl	$OFFSET_WIDTH, %ecx
	movl	plik_zrodlo, %ebx
	movl	$SYS_LSEEK, %eax
	int		$SYSCALL

	movl	$4, %edx
	movl	$dane_chwilowe, %ecx
	movl	plik_zrodlo, %ebx
	movl	$READ, %eax
	int		$SYSCALL

	movl	dane_chwilowe, %eax
	movl	%eax, width					#szerokość obrazka

	movl	$OD_POCZATKU, %edx
	movl	$OFFSET_HEIGHT, %ecx
	movl	plik_zrodlo, %ebx
	movl	$SYS_LSEEK, %eax
	int		$SYSCALL

	movl	$4, %edx
	movl	$dane_chwilowe, %ecx
	movl	plik_zrodlo, %ebx
	movl	$READ, %eax
	int		$SYSCALL

	movl	dane_chwilowe, %eax
	movl	%eax, width					#wysokość obrazka

	movl	$OD_POCZATKU, %edx
	movl	$OFFSET_SIZE_IMG, %ecx
	movl	plik_zrodlo, %ebx
	movl	$SYS_LSEEK, %eax
	int		$SYSCALL

	movl	$4, %edx
	movl	$dane_chwilowe, %ecx
	movl	plik_zrodlo, %ebx
	movl	$READ, %eax
	int		$SYSCALL

	movl	dane_chwilowe, %eax
	movl	%eax, rozmiar				#rozmiar tablicy danych (trza zaalokowac)

#skopiuj caly naglowek (przyda sie potem)
	movl	$OD_POCZATKU, %edx
	movl	$0, %ecx
	movl	plik_zrodlo, %ebx
	movl	$SYS_LSEEK, %eax
	int		$SYSCALL

	movl	$rozmiar_naglowka, %edx
	movl	$naglowek, %ecx
	movl	plik_zrodlo, %ebx
	movl	$READ, %eax
	int		$SYSCALL

#alokacja pamieci na tablice kolorow
	xorl	%ebx, %ebx
	movl	$SYS_BRK, %eax
	int		$SYSCALL

	movl	%eax, koniec_bss
	movl	%eax, bufor_tymczasowy
	movl	%eax, %ebx
	addl	rozmiar, %ebx				#dodaj rozmiar tablicy danych (do zaalokowania)
	movl	$SYS_BRK, %eax
	int		$SYSCALL					#zaalokowano pamiec (narazie tylko na tablice poczatkowa)

#wczytywanie danych
	movl	$OD_POCZATKU, %edx
	movl	start_offset, %ecx
	movl	plik_zrodlo, %ebx
	movl	$SYS_LSEEK, %eax
	int		$SYSCALL					#czytanie ustawione na poczatek pliku

	movl	rozmiar, %edx
	movl	$bufor_tymczasowy, %ecx
	movl	plik_zrodlo, %ebx
	movl	$READ, %eax
	int		$SYSCALL
#zaalokuj na bufor zwrotny (tablice z gotowymi danymi)
	xorl	%ebx, %ebx
	movl	$SYS_BRK, %eax
	int		$SYSCALL

	movl	%eax, bufor_zwrotny			#teraz w bufor_zwrotny mamy adres naszego bufora
	movl	%eax, %ebx
	addl	rozmiar, %ebx				#dodaj rozmiar tablicy danych (do zaalokowania)
	movl	$SYS_BRK, %eax
	int		$SYSCALL					#zaalokowano pamiec na tablice wynikowa

#kopiowanie przekreconego obrazka o 90 stopni (narazie tylko kopiowanie)
	movl	bufor_zwrotny, %edi
	movl	$bufor_tymczasowy, %esi
	xorl	%eax, %eax
	xorl	%edx, %edx
	movl	rozmiar, %ecx
kopiuj:
	movb	(%esi, %edx, 1), %al
	movb	%al, (%edi, %edx, 1)
	incl	%edx
	loop	kopiuj

#nanieś zmiany w nagłówku (zamien szerokość z wysokością)
	#movl	width, %eax
	#movl	$OFFSET_HEIGHT, %edi
	#movl	%eax, naglowek( ,%edi, 1)

	#movl	height, %eax
	#movl	$OFFSET_WIDTH, %edi
	#movl	%eax, naglowek( ,%edi,1)

zapisz_do_pliku:
	movl	$rozmiar_naglowka, %edx
	movl	$naglowek, %ecx
	movl	plik_cel, %ebx
	movl	$WRITE, %eax
	int		$SYSCALL					#najpierw leci naglowek

	movl	rozmiar, %edx
	movl	bufor_zwrotny, %ecx
	movl	plik_cel, %ebx
	movl	$WRITE, %eax
	int		$SYSCALL					#potem cała reszta

zwolnij_pamiec:
	movl	koniec_bss, %ebx
	movl	$SYS_BRK, %eax
	int		$SYSCALL

zamkniecie_plikow:
	movl	plik_zrodlo, %ebx
	movl	$SYS_CLOSE, %eax
	int		$SYSCALL

	movl	plik_cel, %ebx
	movl	$SYS_CLOSE, %eax
	int		$SYSCALL

	jmp		koniec

blad:
	movl	$info_blad_size, %edx
	movl	$info_blad, %ecx
	movl	$STDOUT, %ebx
	movl	$WRITE, %eax
	int		$SYSCALL

	movl	$-1, %eax 
	jmp		koniec

koniec:
	movl	$EXIT, %eax
	int		$SYSCALL
	
	
	
	
	
	
	
		






