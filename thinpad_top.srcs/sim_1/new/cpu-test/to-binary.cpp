#include <cstdio>
#include <cstring>
#include <iostream>
using namespace std;
char st[1000];

int main() {
    FILE* fo = fopen("bin.out", "wb");
    unsigned x;
    while (scanf("%x", &x) != EOF) {
        cin.getline(st, 1000);
        printf("instruction: %8x\n", x);
        fwrite(&x, 4, 1, fo);
    }
    fclose(fo);
}