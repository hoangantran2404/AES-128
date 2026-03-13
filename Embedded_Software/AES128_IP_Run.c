#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>


#include <fcntl.h>
#include <stdint.h>
#include <math.h>

#include "AES128_Driver.c" // call fpga driver


#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

//Address in Write Channel
#define START_BASE_PHYS         (0x0000000>>2)
#define DONE_BASE_PHYS          (0x0000008>>2)
#define PLAINTEXT_BASE_PHYS     (0x0000010>>2)
#define KEY_BASE_PHYS           (0x0000020>>2)
//Address in Ouput Channel
#define VALID_BASE_PHYS         (0x0000000>>2)
#define RESULT_BASE_PHYS        (0x0000030>>2)

void hex_string_to_uint32_array(const char* hex_str, uint32_t* output_array) {
    char temp_str[9]; // Rổ chứa tạm 8 ký tự Hex (32-bit) + 1 ký tự kết thúc chuỗi '\0'
    
    for(int i = 0; i < 4; i++) {
        // Copy từng cụm 8 ký tự từ chuỗi gốc sang rổ tạm
        strncpy(temp_str, hex_str + (i * 8), 8);
        temp_str[8] = '\0'; // Chốt sổ chuỗi
        
        // Đổi chuỗi Hex sang số nguyên uint32_t (Cơ số 16)
        output_array[i] = (uint32_t)strtoul(temp_str, NULL, 16);
    }
}
int main()
{   
    //Neu FPGA_Driver.c mo thanh cong no se return to 1. Vi 1=1 nen no skip trong if.
    //Neu FPGA_Driver.c returns to -1. No se in dong ... vao stderr.
    //fprintf cho ta chi dich den cua viec in (!=printf) vao stdout(hay in kq) or stderr(in errors)
    //"exit" la dung program ngay tai do va tra ve Linux = 1
    if(fpga_open() !=1) {
        fprintf(stderr,"Failed to open FPGA device.\n");
        exit(EXIT_FAILURE);
    }
    char input[32];
    while(1) {
        printf("\n====AES128-Encryption=====\n");
        printf("Enter 'q' to quit, or press Enter to continue.\n");
        printf("Your choice:  ");
        fgets(input,sizeof(input),stdin);

        if(input[0] == 'q' || input[0] == 'Q'){
            printf("Existing program.\n");
            break;
        }

        char plaintext[33];
        char key[33];

        uint32_t pt_words[4];
        uint32_t key_words[4];
        uint32_t result_words[4];

        printf("Enter plaintext(32 Hex characters):   ");
        scanf("%32s",&plaintext);
        printf("Enter key(32 Hex characters):   ");
        scanf("%32s",&key);
        getchar();

        hex_string_to_uint32_array(plaintext, pt_words);
        hex_string_to_uint32_array(key, key_words);
        
       for(int i = 0; i < 4; i++){
            *(AES128_IP_info.pio_32_mmap + PLAINTEXT_BASE_PHYS + i) = pt_words[i];
            *(AES128_IP_info.pio_32_mmap + KEY_BASE_PHYS + i) = key_words[i];
        }
        *(AES128_IP_info.pio_32_mmap + START_BASE_PHYS) = 1;
        while(1){
            if(*(AES128_IP_info.pio_32_mmap + VALID_BASE_PHYS)==1) {
                printf("Completed the encryption process!!\n");
                break;
            }
        }
        for(int i = 0; i < 4; i++){
            result_words[i] = *(AES128_IP_info.pio_32_mmap + RESULT_BASE_PHYS + i);
        }
        *(AES128_IP_info.pio_32_mmap + DONE_BASE_PHYS) = 1;
        printf("Ciphertext from KR260: ");
        printf("%08X%08X%08X%08X\n", result_words[0], result_words[1], result_words[2], result_words[3]);
    }
    return 0;
}