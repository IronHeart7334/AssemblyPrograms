#include<stdio.h>

int main();
void forEachLineIn(char* fName, void consumer(char*));
void concatFiles(char** fileNames, int numFiles);
(*void)(char* newLine) createBasicAppender(FILE* file);
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
void concatFiles(char** fileNames, int numFiles, (*void)(char* newLine) appender(FILE* appendToMe)){
    FILE* resultFile = fopen("result.txt", "w");
    int currFileIdx = 0;
    while(currFileIdx < numFiles){
        forEachLineIn(fileNames[currFileIdx], appender(resultFile));
        currFileIdx++;
    }
    fclose(resultFile);
}
(*void)(char* newLine) createBasicAppender(FILE* file){
    // wait... I don't know how to do this
    return 0;
}
void printLn(char* ln){
    printf("%s\n", ln);
}
