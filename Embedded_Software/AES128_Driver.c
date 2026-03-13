//Doc file giai thich tai:  https://docs.google.com/document/d/1CHxICUHpy5NZ8Um0o1H0LHSHjDoid-fWUObs84PnHq0/edit?tab=t.0
#ifndef _GNU_SOURCE                     //Feature Test Macro, contains <dirent.h>
#define _GNU_SOURCE
#endif

#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <errno.h>
#include <linux/ioctl.h>
#include <dirent.h>

#ifndef alphasort
#define alphasort(x,y) strcoll((*(struct dirent **)x)->d_name , (*(struct dirent **)y)->d_name) 
#endif

#define AES_IP_BASE_PHYS     0x00A0000000LL  
#define REG_MMAP_SIZE        0x0010000000LL  

typedef uint64_t U64;
typedef uint32_t U32;

volatile struct {
    U64 reg_phys;          
    U32 *pio_32_mmap;       
} AES128_IP_info;


static int filter(const struct dirent *dir) {
    return dir->d_name[0] == '.'? 0 : 1;
}

static void trim(char *d_name){
    char *p = strchr(d_name,'\n');
    if(p!=NULL) *p ='\0';
}

static int is_target_dev(char *d_name, const char *target){
    char path[64], name[64];
    FILE *fp;

    snprintf(path,sizeof(path),"/sys/class/uio/%s/name",d_name);   
    fp = fopen(path,"r");                                          
    if(fp==NULL) return 0;                                          

    if(fgets(name,sizeof(name),fp)==NULL){                
        return 0;
    }

    fclose(fp);
    return strcmp(name,target) == 0;                                
}
int fpga_open(){
    struct dirent **namelist;           
    int num_dirs;
    char path[128];
    int fd_reg;                       
    const char *UIO_MY_IP = "AES128\n";  

    num_dirs = scandir("/sys/class/uio",&namelist, filter, alphasort);
    if(num_dirs==-1) return -1;

    for(int dir=0;dir<num_dirs;++dir) {
        trim(namelist[dir]->d_name);

        if(is_target_dev(namelist[dir]->d_name, UIO_MY_IP)) {
            snprintf(path,sizeof(path),"/dev/%s",namelist[dir]->d_name);    
            free(namelist[dir]);

            fd_reg = open(path,O_RDWR | O_SYNC);    
            if(fd_reg == -1) {
                perror("Open failed");
                free(namelist);
                return -1;
            }

            printf("Opened device: %s (%s)",path, UIO_MY_IP);
            AES128_IP_info.reg_phys     = AES_IP_BASE_PHYS;
            AES128_IP_info.pio_32_mmap  = (U32*)mmap(NULL,REG_MMAP_SIZE,PROT_READ|PROT_WRITE,MAP_SHARED, fd_reg,0);
            
            if(AES128_IP_info.pio_32_mmap == MAP_FAILED) {
                perror("mmap failed");
                close(fd_reg);
                free(namelist);
                return -1;
            }

            close(fd_reg);
            break;
        }
    }
    free(namelist);
    return 1;
}