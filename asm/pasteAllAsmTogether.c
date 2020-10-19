#include<stdio.h>

int main();
void forEachLineIn(char* fName, void consumer(char*));
void printLn(char* ln);


int main(){
    forEachLineIn("pasteAllAsmTogether.c", &printLn);
    printf("%s\n", "Done pasting");
    return 0;
}



void forEachLineIn(char* fName, void consumer(char*)){
    FILE* fileToRead = fopen(fName, "r");
    int maxChars = 100;
    char* currLine;
    while((currLine = fgets(currLine, maxChars, fileToRead)) != 0){
        consumer(currLine);
    }
    fclose(fileToRead);
}
void printLn(char* ln){
    printf("%s\n", ln);
}
