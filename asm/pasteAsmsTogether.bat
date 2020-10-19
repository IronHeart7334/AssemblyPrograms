gcc -c pasteAllAsmTogether.c -o out.o
gcc -o main.exe out.o
main.exe
rm out.o
rm main.exe
