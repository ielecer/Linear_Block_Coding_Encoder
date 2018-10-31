#include <xparameters.h>
#include <stdio.h>
#include <encoder_ip.h>
#include <xil_io.h>

int main(void) {
	char i;
	u32 Co;

	for(i = 0; i < 256; i++) {
		ENCODER_IP_mWriteReg(XPAR_ENCODER_IP_0_S00_AXI_BASEADDR, 0, i);
		Co = ENCODER_IP_mReadReg(XPAR_ENCODER_IP_0_S00_AXI_BASEADDR, 0);
		printf("Din: 0x%02x --> Co: 0x%02x\n", i, Co);
	}

	while(1);

	return 0;
}
