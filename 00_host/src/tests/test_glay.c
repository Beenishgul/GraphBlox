#include "glayenv.h"

#ifdef __cplusplus
extern "C" {
#endif


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

#ifdef __cplusplus
}
#endif