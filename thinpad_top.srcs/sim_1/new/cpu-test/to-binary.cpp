#include <bits/stdc++.h>
#include <arpa/inet.h>
using namespace std;

int main() {
    FILE* fo = fopen("bin.out", "wb");
    unsigned x;
    while (scanf("%x", &x) != EOF) {
        fwrite(&x, 4, 1, fo);
    }
    fclose(fo);
}