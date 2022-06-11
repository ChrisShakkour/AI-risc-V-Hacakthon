#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#define DATASET_SIZE 200
#include "include/neural_network.h"
#include "include/neural_network_weights.h"
#include "include/csr.h"
#include "data/images.h"
#include "data/labels.h"
//#define PRINT_IMAGE

#define PLF_ACCEL_ADDR 0xf0010000

unsigned int max_inf_time_h = 0;
unsigned int max_inf_time_l = 0;


void accel_write_bias(fix16_t* b);
void accel_write_weight(fix16_t* w);



/** * Calculate the accuracy of the predictions of a neural network on a dataset.  */

fix16_t calculate_accuracy(uint8_t images[][MNIST_IMAGE_SIZE], uint8_t labels[], uint32_t dataset_size, neural_network_t * network)
{
    fix16_t activations[MNIST_LABELS], max_activation;
    fix16_t tmp;
    int i, j, correct, predict;
    unsigned int inf_time_l_start, inf_time_h_start, inf_time_l_end, inf_time_h_end, inf_time_l, inf_time_h;

    // Loop through the dataset
    for (i = 0, correct = 0; i < dataset_size; i++) {
        // Calculate the activations for each image using the neural network

	#ifdef PRINT_IMAGE
	for(int k=0; k< MNIST_IMAGE_SIZE; k++){
		if(k%7==0) printf("\n");
		printf("%s", images[i][k]!=0 ? "**" : "  ");
	}
	printf("\nLabel %d\n", labels[i]);
   	#endif

    	//****** Do not remove this/modify code ******
    	inf_time_l_start = csr_read(0xc00);
    	inf_time_h_start = csr_read(0xc80);
    	//****** End of do not remove/modify this code ******
	
        neural_network_hypothesis(images[i], network, activations);
	
    	//****** Do not remove this/modify code ******
    	inf_time_l_end = csr_read(0xc00);
    	inf_time_h_end = csr_read(0xc80);

    	if(inf_time_l_end >= inf_time_l_start){
	    inf_time_l = inf_time_l_end - inf_time_l_start;
	    inf_time_h = inf_time_h_end - inf_time_h_start;
    	}
    	else{
	    inf_time_l = ((unsigned int)0xffffffff - inf_time_l_start) + 1 + inf_time_l_end;
	    inf_time_h = inf_time_h_end - inf_time_h_start-1;
    	}
    	//printf("Total inference time (hex) %08x%08x\n", inf_time_h, inf_time_l);
	if((inf_time_h > max_inf_time_h) || ((inf_time_h == max_inf_time_h)) && (inf_time_l>max_inf_time_l)){
		max_inf_time_h = inf_time_h;
		max_inf_time_l = inf_time_l;
	}
    	//****** End of do not remove/modify this code ******
	
        // Set predict to the index of the greatest activation
        for (j = 0, predict = 0, max_activation = activations[0]; j < MNIST_LABELS; j++) {
	    tmp = fix16_ssub(activations[j], max_activation);
            if ((tmp & 0x80000000) == 0) {
            //if (max_activation < activations[j]) {
                max_activation = activations[j];
                predict = j;
            }
        }

	#ifdef PRINT_IMAGE
	printf("Predicted %d\n", predict);
	#endif

        // Increment the correct count if we predicted the right label
        if (predict == labels[i]) {
            correct++;
        }
    }

    // Return the percentage we predicted correctly as the accuracy
    return fix16_div(((100*correct)<<16) , (dataset_size<<16));
    //return ((float) correct) / ((float) dataset_size);
}

int main(int argc, char *argv[])
{
    fix16_t accuracy;
    //float accuracy;
    int i;
    unsigned int mcycle_l_start, mcycle_h_start;
    unsigned int mcycle_l_end, mcycle_h_end;
    unsigned int total_time_l, total_time_h;

    //****** Do not remove this/modify code ******
    mcycle_l_start = csr_read(0xc00);
    mcycle_h_start = csr_read(0xc80);
    //****** End of do not remove/modify this code ******

    accel_write_bias(network_db.b);
    accel_write_weights(network_db.W);

    /*
    uint32_t *accelAddr;
    accelAddr = (uint32_t*)(PLF_ACCEL_ADDR);
    for(int i=0; i<10; i++){
      printf("reading bias %d is 0x%x\n", i, *(accelAddr+10+i));
    }
    for(int i=0; i<10; i++){
      printf("reading weight %d is 0x%x\n", i, *(accelAddr+20+i*49));
    }
    */
    
    accuracy = calculate_accuracy(mnist_images, mnist_labels, DATASET_SIZE, &network_db);

    //****** Do not remove this/modify code ******
    printf("***************** Performance Summary: ******************\n");
    printf("Accuracy[%%]: \t\t\t %d\n", accuracy>>16);
    printf("Start time (hex): \t\t %08x%08x\n", mcycle_h_start, mcycle_l_start);
    mcycle_l_end = csr_read(0xc00);
    mcycle_h_end = csr_read(0xc80);
    printf("End time (hex): \t\t %08x%08x\n", mcycle_h_end, mcycle_l_end);

    if(mcycle_l_end >= mcycle_l_start){
	    total_time_l = mcycle_l_end - mcycle_l_start;
	    total_time_h = mcycle_h_end - mcycle_h_start;
    }
    else{
	    total_time_l = ((unsigned int)0xffffffff - mcycle_l_start) + 1 + mcycle_l_end;
	    total_time_h = mcycle_h_end - mcycle_h_start-1;
    }
    printf("Total time (hex): \t\t %08x%08x\n", total_time_h, total_time_l);
    printf("Worst inference time (hex): \t %08x%08x\n", max_inf_time_h, max_inf_time_l);
    printf("For Throughput calculation divide %d by total time (hex) %08x%08x\n", DATASET_SIZE, total_time_h, total_time_l);
    //****** End of do not remove/modify this code ******

    return 0;
}


void accel_write_bias(fix16_t* b)
{
  uint32_t *accelAddr;
  accelAddr = (uint32_t*)(PLF_ACCEL_ADDR);

  *(accelAddr +10) = (*b);
  *(accelAddr +11) = *(b+1);
  *(accelAddr +12) = *(b+2);
  *(accelAddr +13) = *(b+3);
  *(accelAddr +14) = *(b+4);
  *(accelAddr +15) = *(b+5);
  *(accelAddr +16) = *(b+6);
  *(accelAddr +17) = *(b+7);
  *(accelAddr +18) = *(b+8);
  *(accelAddr +19) = *(b+9);
  /*
  for(int i=0; i<10; i++){
    printf("writing bias %d is 0x%x\n", i, *(b+i));
  }
  */  
  return;
}


void accel_write_weights(fix16_t* w)
{
  uint32_t *accelAddr;
  accelAddr = (uint32_t*)(PLF_ACCEL_ADDR);

  int k = 20 ;
  for(int i = 0; i<10 ; i++){
    //    printf("writing weight %d is 0x%x\n", i, *(w+k));
    for(int j = 0; j<49 ; j++){
      *(accelAddr + k)  = *(w+k);
      k++;
    }
  }
  
  /*
  for(int i=0; i<10; i++){
    printf("writing weight %d is 0x%x\n", i, *(b+i));
  }
  */  
  return;
}


/*
  
 */
/*
void proccess_layer1()
{
  uint32_t *accelAddr;
  accelAddr = (uint32_t*)(PLF_ACCEL_ADDR);

  // new layer set biases
  *(accelAddr) = 0xffffffff;
  //fetch image pixels to address
  for(49)
  *(accelAddr+520) = *(images);

  //Read proccessed data
  
  
  

}
*/
