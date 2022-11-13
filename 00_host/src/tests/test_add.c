#include "glayenv.h"

#ifdef __cplusplus
extern "C" {
#endif

#define DATA_SIZE 4096
#define IP_START 0x1
#define IP_IDLE 0x4
#define USER_OFFSET 0x0
#define A_OFFSET 0x18
#define B_OFFSET 0x24

void vadd_A_B(int *a, int *b, int scalar);



int main(int argc, char** argv){

	int i;
	printf("argc = %d \n", argc);

	for(i=0; i < argc; i++){
	    printf("argv [%d] = %s \n",i, argv[i]);
	}

	int device_index = atoi(argv[1]);
 	char *xclbin_path = argv[2];
 	struct xrtGLAYHandle *glayHandle = NULL;

 	setupGLAYDevice(glayHandle, device_index, xclbin_path);

    releaseGLAY(glayHandle);
  

	return 0;
}


void vadd_A_B(int *a, int *b, int scalar){


}

#ifdef __cplusplus
}
#endif