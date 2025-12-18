#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#define SERIAL_PORT "/dev/ttyUSB2"
#define BAUDRATE    B115200


#define FRAC_BITS   7
#define SCALE       (1 << FRAC_BITS)
#define MAX_VAL     255.992f
#define MIN_VAL    -256.0f

#define OP_NOP		    0
#define OP_ADD		    1
#define OP_SUB		    2
#define OP_MUL		    3
#define OP_AND		    4
#define OP_OR		    5
#define OP_NOT		    6
#define OP_XOR		    7

static int setup_serial(const char *device) {
    int fd = open(device, O_RDWR | O_NOCTTY);
    if (fd < 0) {
        perror("open");
        return -1;
    }

    struct termios options;
    tcgetattr(fd, &options);
    options.c_cflag = BAUDRATE | CS8 | CLOCAL | CREAD;
    options.c_iflag = IGNPAR;
    options.c_oflag = 0;
    options.c_lflag = 0;
    tcflush(fd, TCIFLUSH);
    tcsetattr(fd, TCSANOW, &options);
    return fd;
}

// =======================
// SAFE WRITE 
// =======================
static int uart_write_full(int fd, uint8_t *buf, int size) {
    int sent = 0;
    while (sent < size) {
        int n = write(fd, buf + sent, size - sent);
        if (n <= 0) return -1;
        sent += n;
    }
    return 0;
}

// =======================
// SAFE READ 
// =======================
static int uart_read_full(int fd, uint8_t *buf, int size) {
    int r = 0;
    while (r < size) {
        int n = read(fd, buf + r, size - r);
        if (n <= 0) return -1;
        r += n;
    }
    return 0;
}

// =======================
// MAIN
// =======================
int main(void) {
    uint8_t plaintext[16] = {
        0x41, 0x64, 0x76, 0x61, 
        0x6E, 0x63, 0x65, 0x64, 
        0x20, 0x45, 0x6E, 0x63, 
        0x72, 0x79, 0x70, 0x74
    };

    uint8_t key[16] = {
        0x54, 0x68, 0x61, 0x74, 
        0x73, 0x20, 0x4D, 0x79, 
        0x20, 0x4B, 0x75, 0x6E, 
        0x67, 0x20, 0x46, 0x75
    };

    printf("Opening UART...\n");

    int fd = setup_serial(SERIAL_PORT);
    if (fd < 0) return 1;

    // =======================
    // SEND 64 BYTE MESSAGE
    // =======================
    printf("Sending 16-byte plaintext...\n");
    if (uart_write_full(fd, plaintext, 16) < 0) {
        printf("UART write error!\n");
        close(fd);
        return 1;
    }
    printf("Sending 16-byte key...\n ");
    if (uart_write_full(fd, key, 16) < 0) {
        printf("UART write error!\n");
        close(fd);
        return 1;
    }

    // =======================
    // READ 32 BYTE OUTPUT HASH
    // =======================
    uint8_t cipher_out[16];
    printf("Waiting for output...\n");

    if (uart_read_full(fd, cipher_out, 16) < 0) {
        printf("UART read error!\n");
        close(fd);
        return 1;
    }

    // PRINT RESULT
    printf("\n----------------------------------------\n");
    printf("Expected: 6F 5D DB 7F 39 56 0B 0F E9 EA DA 49 F8 7C 49 04\n");
    printf("Actual  : ");
    for (int i = 0; i < 16; i++)
        printf("%02X ", cipher_out[i]);
    printf("\n----------------------------------------\n");

    close(fd);
    return 0;
}