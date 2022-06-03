#include <stdio.h>

#include "plf_de10lite_scr1.h"
#include "leds.h"
#include "rtc.h"
#include "csr.h"

#define SECOND 1000000

#ifdef PLF_HEXLED_ADDR

static const uint8_t HEX_DIGITS_TABLE[16] = {
    HEXLED_0,
    HEXLED_1,
    HEXLED_2,
    HEXLED_3,
    HEXLED_4,
    HEXLED_5,
    HEXLED_6,
    HEXLED_7,
    HEXLED_8,
    HEXLED_9,
    HEXLED_A,
    HEXLED_B,
    HEXLED_C,
    HEXLED_D,
    HEXLED_E,
    HEXLED_F
};

static const uint8_t HEX_DISPLAY_TABLE[6] =
  {
   0x80,                             //.
   0x08 | 0x10 | 0x40,               //c
   0x04 | 0x10 | 0x20 | 0x40,        //h
   0x10 | 0x40,                      //r
   0x10,                             //i
   0x01 | 0x20 | 0x40 | 0x04 | 0x08  //s
};

struct hex_seg_map {
    unsigned long addr;
    unsigned shift;
};

#ifdef PLF_HEXLED_ADDR_MAP
static const struct hex_seg_map HEX_MAP[] = {
    PLF_HEXLED_ADDR_MAP
};
#endif // PLF_HEXLED_ADDR_MAP

#if PLF_HEXLED_PORT_WIDTH == 4
typedef uint32_t pinled_port_mem;
#elif PLF_HEXLED_PORT_WIDTH == 2
typedef uint16_t pinled_port_mem;
#else
typedef uint8_t pinled_port_mem;
#endif

void sc1f_leds_hex(unsigned n, unsigned v)
{
#ifdef PLF_HEXLED_ADDR_MAP
    if (n < sizeof(HEX_MAP) / sizeof(*HEX_MAP)) {
        volatile pinled_port_mem *p = (volatile pinled_port_mem*)(HEX_MAP[n].addr);
        unsigned shift = HEX_MAP[n].shift;
        pinled_port_mem mask = ~(0xff << shift);
        *p = (*p & mask) | ((v ^ PLF_HEXLED_INV) << shift);
    }
#elif defined(PLF_HEXLED_ADDR) // PLF_HEXLED_ADDR_MAP
    volatile pinled_port_mem *p = (volatile pinled_port_mem*)PLF_HEXLED_ADDR;
    p[n] = v ^ PLF_HEXLED_INV;
#endif // PLF_HEXLED_ADDR_MAP
}

void sc1f_leds_hex_digit(unsigned n, unsigned v)
{
    sc1f_leds_hex(n, HEX_DIGITS_TABLE[v & 0xf]);
}
#endif // PLF_HEXLED_ADDR

int main(void)
{
    printf("Main function called\n");

    printf("Initializing RTC\n");
    scr_rtc_init();

    printf("Displaying \".chriS\" on the HEX digits\n");
    for(int n=0; n<(sizeof(HEX_MAP)/sizeof(*HEX_MAP)); n++){
      volatile pinled_port_mem *p = (volatile pinled_port_mem*)(HEX_MAP[n].addr);
      unsigned shift = HEX_MAP[n].shift;
      pinled_port_mem mask = ~(0xff << shift);
      *p = (*p & mask) | ((HEX_DISPLAY_TABLE[n] ^ PLF_HEXLED_INV) << shift);
      rtc_delay_us(SECOND);    
    }

    uint8_t count=0;
    while(1){
      rtc_delay_us(200000);
      sc1f_leds_set(count++);
    }


    //read_csr(reg);
    //write_csr(reg, val);

    
    /*
    sc1f_leds_hex_digit(0, 1);
    sc1f_leds_hex_digit(1, 2);
    sc1f_leds_hex_digit(2, 3);
    sc1f_leds_hex_digit(3, 4);
    sc1f_leds_hex_digit(4, 5);
    sc1f_leds_hex_digit(5, 6);
    */
    
    return 0;
}
