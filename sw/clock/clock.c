/*



*/

// STD INCLUDES
#include <stdio.h>
#include <stdint.h>

// custom INCLUDES
#include "plf_de10lite_scr1.h"
#include "arch.h"
#include "rtc.h"
#include "leds.h"
#include "stringify.h"

// DEFINES
#define LEDS_TASK_DELAY_MS  200
#define MAX_HEX_LEDS        8

// FUNCTIONS
//static void hex_leds_task(void);
//static void leds_task(void);
//void indication_tasks(void);
int main(int argc, char **argv);

void c_start(void)
{
  main(0, 0);
}

// MAIN FUNCTION
int main(int argc, char **argv)
{
    printf("Running Clock program\n");
    scr_rtc_init();
    //sc1f_leds_init();
    //while(1){
      for (int i = 0; i < MAX_HEX_LEDS; i++) {
	sc1f_leds_hex(i, 0x0);
      }
      rtc_delay_us(1000000);
      for (int i = 0; i < MAX_HEX_LEDS; i++) {
	sc1f_leds_hex(i, 0x1);
      }
      rtc_delay_us(1000000);
      //    }    
    //sc1f_leds_hex(3, 4);
    //    while(1){
      
    //}
    return 0;
}


/*
static void hex_leds_task(void)
{
#ifdef PLF_HEXLED_ADDR
    static uint32_t id_val, idx_i, idx_j;
    static sys_tick_t start_time;
    sys_tick_t t2;

    if (id_val == 0) {
        for (int i = 0; i < MAX_HEX_LEDS; i++) {
            sc1f_leds_hex(i, 0x0);
        }
        id_val = get_build_id();
        start_time = now();
        idx_i = 1;
        return;
    }

    t2 = now();
    if (t2 - start_time < ms2ticks(LEDS_TASK_DELAY_MS / 6)) {
        return;
    }
    start_time = now();

    if (idx_i <= MAX_HEX_LEDS) {
        if (idx_j < 9 - idx_i) {
            if (idx_j) {
                for (int i = 1; i < MAX_HEX_LEDS - idx_i; i++) {
                    sc1f_leds_hex(MAX_HEX_LEDS - 1 - i, 0x0);
                }
                sc1f_leds_hex_digit(MAX_HEX_LEDS - 1 - idx_j,
                    id_val >> 4 * (MAX_HEX_LEDS - idx_i));
            } else {
                sc1f_leds_hex_digit(MAX_HEX_LEDS - 1 - idx_j, 0xF);
            }
            idx_j++;
        } else {
            idx_j = 0;
            idx_i++;
        }
    }
#endif // PLF_HEXLED_ADDR
}


static void leds_task(void)
{
#ifdef PLF_PINLED_NUM
#if PLF_PINLED_NUM > 0
    static unsigned long leds_val;
    static sys_tick_t start_time;
    static int right;
    sys_tick_t t2;

    if (start_time == 0) {
        start_time = now();
        leds_val = 0x1;
    }

    t2 = now();
    if (t2 - start_time < ms2ticks(LEDS_TASK_DELAY_MS)) {
        return;
    }

    start_time = now();
    sc1f_leds_set(leds_val);

    if (right) {
        leds_val <<= 1;
    } else {
        leds_val >>= 1;
    }
    if (leds_val >= (1 << (PLF_PINLED_NUM - 1))) {
        right = 0;
    }
    if (leds_val <= 0x1) {
        right = 1;
        leds_val = 0x1;
    }
#endif // PLF_PINLED_NUM > 0
#endif // PLF_PINLED_NUM
}

void indication_tasks(void)
{
    hex_leds_task();
    leds_task();
}
*/
