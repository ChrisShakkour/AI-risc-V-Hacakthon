#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <stdio.h>

#include "include/neural_network.h"

// Convert a pixel value from 0-255 to one from 0 to 1
#define PIXEL_SCALE(x) (((uint32_t) (x)<<8) )
//#define DEBUG_ON
//#define PIXEL_SCALE(x) (((float) (x)) / 255.0f)

#define PLF_ACCEL_ADDR 0xf0010000

/**
 * Calculate the softmax vector from the activations. This uses a more
 * numerically stable algorithm that normalises the activations to prevent
 * large exponents.
 */
void neural_network_softmax(fix16_t * activations, int length)
{
    int i;
    fix16_t sum, max;
    fix16_t tmp;

    for (i = 1, max = activations[0]; i < length; i++) {
        tmp = fix16_ssub(activations[i],  max);
        if ((tmp & 0x80000000) ==0) {
        //if (activations[i] > max) {
            max = activations[i];
        }
    }

    for (i = 0, sum = 0; i < length; i++) {
	activations[i] = fix16_exp(fix16_ssub(activations[i], max));
        //activations[i] = exp(activations[i] - max);
        sum = fix16_sadd(sum, activations[i]);
	//sum += activations[i];
    }

    for (i = 0; i < length; i++) {
        activations[i] = fix16_div(activations[i], sum);
        //activations[i] /= sum;
    }
}

/**
 * Use the weights and bias vector to forward propogate through the neural
 * network and calculate the activations.
 */
void neural_network_hypothesis(uint8_t * image, neural_network_t * network, fix16_t activations[MNIST_LABELS])
{
    int i, j;
    fix16_t tmp;
    /*
    for (i = 0; i < MNIST_LABELS; i++) {
        activations[i] = network->b[i];

        for (j = 0; j < MNIST_IMAGE_SIZE; j++) {
            tmp = fix16_smul(network->W[i][j], PIXEL_SCALE(image[j]));
	    //#ifdef DEBUG_ON
	    //printf("weight=0x%x, data=0x%x, result=0x%x", network->W[i][j], PIXEL_SCALE(image[j]), tmp);
	    //#endif
	    activations[i] = fix16_sadd(activations[i], tmp);
	    //activations[i] += network->W[i][j] * PIXEL_SCALE(image[j]);
        }
	printf("activations = 0x%x\n", activations[i]);
    }
    */

    uint32_t *accelAddr;
    accelAddr = (uint32_t*)(PLF_ACCEL_ADDR);

    //uint32_t *img;
    //    img = (uint32_t*)(0xf00016cc\n);
      
    // new layer trigger
    *(accelAddr) = 0xffffffff; 
    *(accelAddr+510) = *(image);
    *(accelAddr+510) = *(image+1);
    *(accelAddr+510) = *(image+2);
    *(accelAddr+510) = *(image+3);
    *(accelAddr+510) = *(image+4);
    *(accelAddr+510) = *(image+5);
    *(accelAddr+510) = *(image+6);
    *(accelAddr+510) = *(image+7);
    *(accelAddr+510) = *(image+8);
    *(accelAddr+510) = *(image+9);
    *(accelAddr+510) = *(image+10);      
    *(accelAddr+510) = *(image+11);
    *(accelAddr+510) = *(image+12);

    /*
    *(accelAddr+510) = (uint32_t)(image[0]);
    *(accelAddr+510) = (uint32_t)(image[1]);
    *(accelAddr+510) = (uint32_t)(image[2]);
    *(accelAddr+510) = (uint32_t)(image[3]); 
    *(accelAddr+510) = (uint32_t)(image[4]);
    *(accelAddr+510) = (uint32_t)(image[5]);
    *(accelAddr+510) = (uint32_t)(image[5]);
    *(accelAddr+510) = (uint32_t)(image[6]);
    *(accelAddr+510) = (uint32_t)(image[7]);
    *(accelAddr+510) = (uint32_t)(image[8]);
    *(accelAddr+510) = (uint32_t)(image[9]);
    *(accelAddr+510) = (uint32_t)(image[10]);
    *(accelAddr+510) = (uint32_t)(image[11]);
    *(accelAddr+510) = (uint32_t)(image[12]);    
    *(accelAddr+510) = (uint32_t)(image[13]);
    *(accelAddr+510) = (uint32_t)(image[14]);
    *(accelAddr+510) = (uint32_t)(image[15]);
    *(accelAddr+510) = (uint32_t)(image[16]);
    *(accelAddr+510) = (uint32_t)(image[17]);
    *(accelAddr+510) = (uint32_t)(image[18]);
    *(accelAddr+510) = (uint32_t)(image[19]);
    *(accelAddr+510) = (uint32_t)(image[20]);
    *(accelAddr+510) = (uint32_t)(image[21]);
    *(accelAddr+510) = (uint32_t)(image[22]);
    *(accelAddr+510) = (uint32_t)(image[23]);
    *(accelAddr+510) = (uint32_t)(image[24]);
    *(accelAddr+510) = (uint32_t)(image[25]);
    *(accelAddr+510) = (uint32_t)(image[26]);
    *(accelAddr+510) = (uint32_t)(image[27]);
    *(accelAddr+510) = (uint32_t)(image[28]);
    *(accelAddr+510) = (uint32_t)(image[29]);
    *(accelAddr+510) = (uint32_t)(image[30]);
    *(accelAddr+510) = (uint32_t)(image[31]);
    *(accelAddr+510) = (uint32_t)(image[32]);
    *(accelAddr+510) = (uint32_t)(image[33]);
    *(accelAddr+510) = (uint32_t)(image[34]);
    *(accelAddr+510) = (uint32_t)(image[35]);
    *(accelAddr+510) = (uint32_t)(image[36]);
    *(accelAddr+510) = (uint32_t)(image[37]);
    *(accelAddr+510) = (uint32_t)(image[38]);
    *(accelAddr+510) = (uint32_t)(image[39]);
    *(accelAddr+510) = (uint32_t)(image[40]);
    *(accelAddr+510) = (uint32_t)(image[41]);
    *(accelAddr+510) = (uint32_t)(image[42]);
    *(accelAddr+510) = (uint32_t)(image[43]);
    *(accelAddr+510) = (uint32_t)(image[44]);
    *(accelAddr+510) = (uint32_t)(image[45]);
    *(accelAddr+510) = (uint32_t)(image[46]);
    *(accelAddr+510) = (uint32_t)(image[47]);
    *(accelAddr+510) = (uint32_t)(image[48]);
    */
    //    for(int i=0; i<48; i++)
    //  printf("0x%x\n", (uint32_t)(image[i]));
    
    activations[0] = *(accelAddr+520);
    activations[1] = *(accelAddr+521);
    activations[2] = *(accelAddr+522);
    activations[3] = *(accelAddr+523);
    activations[4] = *(accelAddr+524);
    activations[5] = *(accelAddr+525);
    activations[6] = *(accelAddr+526);
    activations[7] = *(accelAddr+527);
    activations[8] = *(accelAddr+528);
    activations[9] = *(accelAddr+529);

    //    for(int i=0; i<10; i++){
    //  printf("labels = 0x%x\n", *(accelAddr+520+i));
    //}
    
    neural_network_softmax(activations, MNIST_LABELS);
}

