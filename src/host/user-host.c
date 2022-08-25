
 #include <stdio.h>
 #include <stdlib.h>
 #include <time.h>


 #include "experimental/xrt_kernel.h"
 #include "experimental/xrt_aie.h"

#define DATA_SIZE 4096
#define IP_START 0x1
#define IP_IDLE 0x4
#define USER_OFFSET 0x0
#define A_OFFSET 0x18
#define B_OFFSET 0x24

int main(int argc, char** argv){

	int i;
	printf("argc = %d \n", argc);

	for(i=0; i < argc; i++){
	    printf("argv [%d] = %s \n",i, argv[i]);
	}

	int device_index = atoi(argv[1]);
 	char *xclbin_path = argv[2];


 	//Open a Device (use "xbutil scan" to show the available devices)
	xrtDeviceHandle device_handle = xrtDeviceOpen(device_index);
	if(device_handle == NULL)
	{
	printf("ERROR: %s --> xrtDeviceOpen(%i)\n",argv[0], device_index);
	return -1;
	}

	//Load compiled kernel binary onto the device
	xrtXclbinHandle xclbin_handle = xrtXclbinAllocFilename(xclbin_path);
	if(xclbin_handle == NULL)
	{
	printf("ERROR: %s --> xrtXclbinAllocFilename(%s)\n",argv[0], xclbin_path);
	return -1;
	}


	if(xrtDeviceLoadXclbinHandle(device_handle, xclbin_handle))
	{
	printf("ERROR: %s --> xrtDeviceLoadXclbinHandle()\n",argv[0]);
	return -1;
	}


	xuid_t xclbin_uuid;
 
    //Get UUID of xclbin handle
    if(xrtXclbinGetUUID(xclbin_handle, xclbin_uuid))
    {
    	printf("ERROR: %s --> xrtXclbinGetUUID()\n",argv[0]);
    	return -1;
    }
 


	return 0;
}