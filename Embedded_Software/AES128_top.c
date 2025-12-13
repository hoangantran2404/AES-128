#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "/home/hoangan2404/Project_0/code_C/Prpject_AES128/AES128_ core.c"

int main(){
    uint32_t plaintext[4] ={
        0x41647661, 
        0x6E636564, 
        0x20456E63, 
        0x72797074
    };

    uint32_t key[4] ={
        0x54686174,
        0x73204D79,
        0x204B756E,
        0x67204675
    };
    uint32_t ciphertext[4];

    AES128_Encrypt(plaintext, key, ciphertext);

    printf("AES-128 Encryption Result= \n");
    for (int i = 0; i < 4; i++)
    {
        printf("Ciphertext[%02d] = %08x\n ",i, ciphertext[i]);
    }   
    return 0;
}