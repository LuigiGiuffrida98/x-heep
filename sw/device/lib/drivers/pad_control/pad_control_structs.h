/*
                              *******************
******************************* H SOURCE FILE *******************************
**                            *******************                          **
**                                                                         **
** project  : x-heep                                                       **
** filename : pad_control_structs.h                                 **
** date     : 04/06/2026                                                      **
**                                                                         **
*****************************************************************************
**                                                                         **
**                                                                         **
*****************************************************************************

*/

/**
* @file   pad_control_structs.h
* @date   04/06/2026
* @brief  Contains structs for every register
*
* This file contains the structs of the registes of the peripheral.
* Each structure has the various bit fields that can be accessed
* independently.
* 
*/

#ifndef _PAD_CONTROL_STRUCTS_H
#define PAD_CONTROL_STRUCTS

/****************************************************************************/
/**                                                                        **/
/**                            MODULES USED                                **/
/**                                                                        **/
/****************************************************************************/

#include <inttypes.h>
#include "core_v_mini_mcu.h"

/****************************************************************************/
/**                                                                        **/
/**                       DEFINITIONS AND MACROS                           **/
/**                                                                        **/
/****************************************************************************/

#define pad_control_peri ((volatile pad_control *) PAD_CONTROL_START_ADDRESS)

/****************************************************************************/
/**                                                                        **/
/**                       TYPEDEFS AND STRUCTURES                          **/
/**                                                                        **/
/****************************************************************************/



typedef struct {

  uint32_t PAD_MUX_GPIO_1;                        /*!< Used to mux pad GPIO_1*/

  uint32_t PAD_MUX_GPIO_2;                        /*!< Used to mux pad GPIO_2*/

  uint32_t PAD_MUX_GPIO_3;                        /*!< Used to mux pad GPIO_3*/

  uint32_t PAD_MUX_GPIO_6;                        /*!< Used to mux pad GPIO_6*/

  uint32_t PAD_MUX_GPIO_7;                        /*!< Used to mux pad GPIO_7*/

  uint32_t PAD_MUX_GPIO_8;                        /*!< Used to mux pad GPIO_8*/

  uint32_t PAD_MUX_GPIO_9;                        /*!< Used to mux pad GPIO_9*/

  uint32_t PAD_MUX_GPIO_10;                       /*!< Used to mux pad GPIO_10*/

  uint32_t PAD_MUX_SPI_SLAVE_SCK;                 /*!< Used to mux pad SPI_SLAVE_SCK*/

  uint32_t PAD_MUX_SPI_SLAVE_CS;                  /*!< Used to mux pad SPI_SLAVE_CS*/

  uint32_t PAD_MUX_SPI_SLAVE_MISO;                /*!< Used to mux pad SPI_SLAVE_MISO*/

  uint32_t PAD_MUX_SPI_SLAVE_MOSI;                /*!< Used to mux pad SPI_SLAVE_MOSI*/

  uint32_t PAD_MUX_PDM2PCM_PDM;                   /*!< Used to mux pad PDM2PCM_PDM*/

  uint32_t PAD_MUX_PDM2PCM_CLK;                   /*!< Used to mux pad PDM2PCM_CLK*/

  uint32_t PAD_MUX_I2S_SCK;                       /*!< Used to mux pad I2S_SCK*/

  uint32_t PAD_MUX_I2S_WS;                        /*!< Used to mux pad I2S_WS*/

  uint32_t PAD_MUX_I2S_SD;                        /*!< Used to mux pad I2S_SD*/

  uint32_t PAD_MUX_SPI2_CS_0;                     /*!< Used to mux pad SPI2_CS_0*/

  uint32_t PAD_MUX_SPI2_CS_1;                     /*!< Used to mux pad SPI2_CS_1*/

  uint32_t PAD_MUX_SPI2_SCK;                      /*!< Used to mux pad SPI2_SCK*/

  uint32_t PAD_MUX_SPI2_SD_0;                     /*!< Used to mux pad SPI2_SD_0*/

  uint32_t PAD_MUX_SPI2_SD_1;                     /*!< Used to mux pad SPI2_SD_1*/

  uint32_t PAD_MUX_SPI2_SD_2;                     /*!< Used to mux pad SPI2_SD_2*/

  uint32_t PAD_MUX_SPI2_SD_3;                     /*!< Used to mux pad SPI2_SD_3*/

  uint32_t PAD_MUX_I2C_SCL;                       /*!< Used to mux pad I2C_SCL*/

  uint32_t PAD_MUX_I2C_SDA;                       /*!< Used to mux pad I2C_SDA*/

} pad_control;

/****************************************************************************/
/**                                                                        **/
/**                          EXPORTED VARIABLES                            **/
/**                                                                        **/
/****************************************************************************/

#ifndef _PAD_CONTROL_STRUCTS_C_SRC



#endif  /* _PAD_CONTROL_STRUCTS_C_SRC */

/****************************************************************************/
/**                                                                        **/
/**                          EXPORTED FUNCTIONS                            **/
/**                                                                        **/
/****************************************************************************/


/****************************************************************************/
/**                                                                        **/
/**                          INLINE FUNCTIONS                              **/
/**                                                                        **/
/****************************************************************************/



#endif /* _PAD_CONTROL_STRUCTS_H */
/****************************************************************************/
/**                                                                        **/
/**                                EOF                                     **/
/**                                                                        **/
/****************************************************************************/
