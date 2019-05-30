/**
 * \brief Component description for SERCOM
 *
 * Copyright (c) 2019 Microchip Technology Inc. and its subsidiaries.
 *
 * Subject to your compliance with these terms, you may use Microchip software and any derivatives
 * exclusively with Microchip products. It is your responsibility to comply with third party license
 * terms applicable to your use of third party software (including open source software) that may
 * accompany Microchip software.
 *
 * THIS SOFTWARE IS SUPPLIED BY MICROCHIP "AS IS". NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY,
 * APPLY TO THIS SOFTWARE, INCLUDING ANY IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY, AND
 * FITNESS FOR A PARTICULAR PURPOSE.
 *
 * IN NO EVENT WILL MICROCHIP BE LIABLE FOR ANY INDIRECT, SPECIAL, PUNITIVE, INCIDENTAL OR CONSEQUENTIAL
 * LOSS, DAMAGE, COST OR EXPENSE OF ANY KIND WHATSOEVER RELATED TO THE SOFTWARE, HOWEVER CAUSED, EVEN IF
 * MICROCHIP HAS BEEN ADVISED OF THE POSSIBILITY OR THE DAMAGES ARE FORESEEABLE. TO THE FULLEST EXTENT
 * ALLOWED BY LAW, MICROCHIP'S TOTAL LIABILITY ON ALL CLAIMS IN ANY WAY RELATED TO THIS SOFTWARE WILL NOT
 * EXCEED THE AMOUNT OF FEES, IF ANY, THAT YOU HAVE PAID DIRECTLY TO MICROCHIP FOR THIS SOFTWARE.
 *
 */

/* file generated from device description version 2019-01-31T10:50:35Z */
#ifndef _SAML10_SERCOM_COMPONENT_H_
#define _SAML10_SERCOM_COMPONENT_H_

/* ************************************************************************** */
/*   SOFTWARE API DEFINITION FOR SERCOM                                       */
/* ************************************************************************** */

/* -------- SERCOM_I2CM_CTRLA : (SERCOM Offset: 0x00) (R/W 32) I2CM Control A -------- */
#define SERCOM_I2CM_CTRLA_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_I2CM_CTRLA) I2CM Control A  Reset Value */

#define SERCOM_I2CM_CTRLA_SWRST_Pos           _U_(0)                                               /**< (SERCOM_I2CM_CTRLA) Software Reset Position */
#define SERCOM_I2CM_CTRLA_SWRST_Msk           (_U_(0x1) << SERCOM_I2CM_CTRLA_SWRST_Pos)            /**< (SERCOM_I2CM_CTRLA) Software Reset Mask */
#define SERCOM_I2CM_CTRLA_SWRST(value)        (SERCOM_I2CM_CTRLA_SWRST_Msk & ((value) << SERCOM_I2CM_CTRLA_SWRST_Pos))
#define SERCOM_I2CM_CTRLA_ENABLE_Pos          _U_(1)                                               /**< (SERCOM_I2CM_CTRLA) Enable Position */
#define SERCOM_I2CM_CTRLA_ENABLE_Msk          (_U_(0x1) << SERCOM_I2CM_CTRLA_ENABLE_Pos)           /**< (SERCOM_I2CM_CTRLA) Enable Mask */
#define SERCOM_I2CM_CTRLA_ENABLE(value)       (SERCOM_I2CM_CTRLA_ENABLE_Msk & ((value) << SERCOM_I2CM_CTRLA_ENABLE_Pos))
#define SERCOM_I2CM_CTRLA_MODE_Pos            _U_(2)                                               /**< (SERCOM_I2CM_CTRLA) Operating Mode Position */
#define SERCOM_I2CM_CTRLA_MODE_Msk            (_U_(0x7) << SERCOM_I2CM_CTRLA_MODE_Pos)             /**< (SERCOM_I2CM_CTRLA) Operating Mode Mask */
#define SERCOM_I2CM_CTRLA_MODE(value)         (SERCOM_I2CM_CTRLA_MODE_Msk & ((value) << SERCOM_I2CM_CTRLA_MODE_Pos))
#define SERCOM_I2CM_CTRLA_RUNSTDBY_Pos        _U_(7)                                               /**< (SERCOM_I2CM_CTRLA) Run in Standby Position */
#define SERCOM_I2CM_CTRLA_RUNSTDBY_Msk        (_U_(0x1) << SERCOM_I2CM_CTRLA_RUNSTDBY_Pos)         /**< (SERCOM_I2CM_CTRLA) Run in Standby Mask */
#define SERCOM_I2CM_CTRLA_RUNSTDBY(value)     (SERCOM_I2CM_CTRLA_RUNSTDBY_Msk & ((value) << SERCOM_I2CM_CTRLA_RUNSTDBY_Pos))
#define SERCOM_I2CM_CTRLA_PINOUT_Pos          _U_(16)                                              /**< (SERCOM_I2CM_CTRLA) Pin Usage Position */
#define SERCOM_I2CM_CTRLA_PINOUT_Msk          (_U_(0x1) << SERCOM_I2CM_CTRLA_PINOUT_Pos)           /**< (SERCOM_I2CM_CTRLA) Pin Usage Mask */
#define SERCOM_I2CM_CTRLA_PINOUT(value)       (SERCOM_I2CM_CTRLA_PINOUT_Msk & ((value) << SERCOM_I2CM_CTRLA_PINOUT_Pos))
#define SERCOM_I2CM_CTRLA_SDAHOLD_Pos         _U_(20)                                              /**< (SERCOM_I2CM_CTRLA) SDA Hold Time Position */
#define SERCOM_I2CM_CTRLA_SDAHOLD_Msk         (_U_(0x3) << SERCOM_I2CM_CTRLA_SDAHOLD_Pos)          /**< (SERCOM_I2CM_CTRLA) SDA Hold Time Mask */
#define SERCOM_I2CM_CTRLA_SDAHOLD(value)      (SERCOM_I2CM_CTRLA_SDAHOLD_Msk & ((value) << SERCOM_I2CM_CTRLA_SDAHOLD_Pos))
#define SERCOM_I2CM_CTRLA_MEXTTOEN_Pos        _U_(22)                                              /**< (SERCOM_I2CM_CTRLA) Master SCL Low Extend Timeout Position */
#define SERCOM_I2CM_CTRLA_MEXTTOEN_Msk        (_U_(0x1) << SERCOM_I2CM_CTRLA_MEXTTOEN_Pos)         /**< (SERCOM_I2CM_CTRLA) Master SCL Low Extend Timeout Mask */
#define SERCOM_I2CM_CTRLA_MEXTTOEN(value)     (SERCOM_I2CM_CTRLA_MEXTTOEN_Msk & ((value) << SERCOM_I2CM_CTRLA_MEXTTOEN_Pos))
#define SERCOM_I2CM_CTRLA_SEXTTOEN_Pos        _U_(23)                                              /**< (SERCOM_I2CM_CTRLA) Slave SCL Low Extend Timeout Position */
#define SERCOM_I2CM_CTRLA_SEXTTOEN_Msk        (_U_(0x1) << SERCOM_I2CM_CTRLA_SEXTTOEN_Pos)         /**< (SERCOM_I2CM_CTRLA) Slave SCL Low Extend Timeout Mask */
#define SERCOM_I2CM_CTRLA_SEXTTOEN(value)     (SERCOM_I2CM_CTRLA_SEXTTOEN_Msk & ((value) << SERCOM_I2CM_CTRLA_SEXTTOEN_Pos))
#define SERCOM_I2CM_CTRLA_SPEED_Pos           _U_(24)                                              /**< (SERCOM_I2CM_CTRLA) Transfer Speed Position */
#define SERCOM_I2CM_CTRLA_SPEED_Msk           (_U_(0x3) << SERCOM_I2CM_CTRLA_SPEED_Pos)            /**< (SERCOM_I2CM_CTRLA) Transfer Speed Mask */
#define SERCOM_I2CM_CTRLA_SPEED(value)        (SERCOM_I2CM_CTRLA_SPEED_Msk & ((value) << SERCOM_I2CM_CTRLA_SPEED_Pos))
#define SERCOM_I2CM_CTRLA_SCLSM_Pos           _U_(27)                                              /**< (SERCOM_I2CM_CTRLA) SCL Clock Stretch Mode Position */
#define SERCOM_I2CM_CTRLA_SCLSM_Msk           (_U_(0x1) << SERCOM_I2CM_CTRLA_SCLSM_Pos)            /**< (SERCOM_I2CM_CTRLA) SCL Clock Stretch Mode Mask */
#define SERCOM_I2CM_CTRLA_SCLSM(value)        (SERCOM_I2CM_CTRLA_SCLSM_Msk & ((value) << SERCOM_I2CM_CTRLA_SCLSM_Pos))
#define SERCOM_I2CM_CTRLA_INACTOUT_Pos        _U_(28)                                              /**< (SERCOM_I2CM_CTRLA) Inactive Time-Out Position */
#define SERCOM_I2CM_CTRLA_INACTOUT_Msk        (_U_(0x3) << SERCOM_I2CM_CTRLA_INACTOUT_Pos)         /**< (SERCOM_I2CM_CTRLA) Inactive Time-Out Mask */
#define SERCOM_I2CM_CTRLA_INACTOUT(value)     (SERCOM_I2CM_CTRLA_INACTOUT_Msk & ((value) << SERCOM_I2CM_CTRLA_INACTOUT_Pos))
#define SERCOM_I2CM_CTRLA_LOWTOUTEN_Pos       _U_(30)                                              /**< (SERCOM_I2CM_CTRLA) SCL Low Timeout Enable Position */
#define SERCOM_I2CM_CTRLA_LOWTOUTEN_Msk       (_U_(0x1) << SERCOM_I2CM_CTRLA_LOWTOUTEN_Pos)        /**< (SERCOM_I2CM_CTRLA) SCL Low Timeout Enable Mask */
#define SERCOM_I2CM_CTRLA_LOWTOUTEN(value)    (SERCOM_I2CM_CTRLA_LOWTOUTEN_Msk & ((value) << SERCOM_I2CM_CTRLA_LOWTOUTEN_Pos))
#define SERCOM_I2CM_CTRLA_Msk                 _U_(0x7BF1009F)                                      /**< (SERCOM_I2CM_CTRLA) Register Mask  */


/* -------- SERCOM_I2CS_CTRLA : (SERCOM Offset: 0x00) (R/W 32) I2CS Control A -------- */
#define SERCOM_I2CS_CTRLA_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_I2CS_CTRLA) I2CS Control A  Reset Value */

#define SERCOM_I2CS_CTRLA_SWRST_Pos           _U_(0)                                               /**< (SERCOM_I2CS_CTRLA) Software Reset Position */
#define SERCOM_I2CS_CTRLA_SWRST_Msk           (_U_(0x1) << SERCOM_I2CS_CTRLA_SWRST_Pos)            /**< (SERCOM_I2CS_CTRLA) Software Reset Mask */
#define SERCOM_I2CS_CTRLA_SWRST(value)        (SERCOM_I2CS_CTRLA_SWRST_Msk & ((value) << SERCOM_I2CS_CTRLA_SWRST_Pos))
#define SERCOM_I2CS_CTRLA_ENABLE_Pos          _U_(1)                                               /**< (SERCOM_I2CS_CTRLA) Enable Position */
#define SERCOM_I2CS_CTRLA_ENABLE_Msk          (_U_(0x1) << SERCOM_I2CS_CTRLA_ENABLE_Pos)           /**< (SERCOM_I2CS_CTRLA) Enable Mask */
#define SERCOM_I2CS_CTRLA_ENABLE(value)       (SERCOM_I2CS_CTRLA_ENABLE_Msk & ((value) << SERCOM_I2CS_CTRLA_ENABLE_Pos))
#define SERCOM_I2CS_CTRLA_MODE_Pos            _U_(2)                                               /**< (SERCOM_I2CS_CTRLA) Operating Mode Position */
#define SERCOM_I2CS_CTRLA_MODE_Msk            (_U_(0x7) << SERCOM_I2CS_CTRLA_MODE_Pos)             /**< (SERCOM_I2CS_CTRLA) Operating Mode Mask */
#define SERCOM_I2CS_CTRLA_MODE(value)         (SERCOM_I2CS_CTRLA_MODE_Msk & ((value) << SERCOM_I2CS_CTRLA_MODE_Pos))
#define SERCOM_I2CS_CTRLA_RUNSTDBY_Pos        _U_(7)                                               /**< (SERCOM_I2CS_CTRLA) Run during Standby Position */
#define SERCOM_I2CS_CTRLA_RUNSTDBY_Msk        (_U_(0x1) << SERCOM_I2CS_CTRLA_RUNSTDBY_Pos)         /**< (SERCOM_I2CS_CTRLA) Run during Standby Mask */
#define SERCOM_I2CS_CTRLA_RUNSTDBY(value)     (SERCOM_I2CS_CTRLA_RUNSTDBY_Msk & ((value) << SERCOM_I2CS_CTRLA_RUNSTDBY_Pos))
#define SERCOM_I2CS_CTRLA_PINOUT_Pos          _U_(16)                                              /**< (SERCOM_I2CS_CTRLA) Pin Usage Position */
#define SERCOM_I2CS_CTRLA_PINOUT_Msk          (_U_(0x1) << SERCOM_I2CS_CTRLA_PINOUT_Pos)           /**< (SERCOM_I2CS_CTRLA) Pin Usage Mask */
#define SERCOM_I2CS_CTRLA_PINOUT(value)       (SERCOM_I2CS_CTRLA_PINOUT_Msk & ((value) << SERCOM_I2CS_CTRLA_PINOUT_Pos))
#define SERCOM_I2CS_CTRLA_SDAHOLD_Pos         _U_(20)                                              /**< (SERCOM_I2CS_CTRLA) SDA Hold Time Position */
#define SERCOM_I2CS_CTRLA_SDAHOLD_Msk         (_U_(0x3) << SERCOM_I2CS_CTRLA_SDAHOLD_Pos)          /**< (SERCOM_I2CS_CTRLA) SDA Hold Time Mask */
#define SERCOM_I2CS_CTRLA_SDAHOLD(value)      (SERCOM_I2CS_CTRLA_SDAHOLD_Msk & ((value) << SERCOM_I2CS_CTRLA_SDAHOLD_Pos))
#define SERCOM_I2CS_CTRLA_SEXTTOEN_Pos        _U_(23)                                              /**< (SERCOM_I2CS_CTRLA) Slave SCL Low Extend Timeout Position */
#define SERCOM_I2CS_CTRLA_SEXTTOEN_Msk        (_U_(0x1) << SERCOM_I2CS_CTRLA_SEXTTOEN_Pos)         /**< (SERCOM_I2CS_CTRLA) Slave SCL Low Extend Timeout Mask */
#define SERCOM_I2CS_CTRLA_SEXTTOEN(value)     (SERCOM_I2CS_CTRLA_SEXTTOEN_Msk & ((value) << SERCOM_I2CS_CTRLA_SEXTTOEN_Pos))
#define SERCOM_I2CS_CTRLA_SPEED_Pos           _U_(24)                                              /**< (SERCOM_I2CS_CTRLA) Transfer Speed Position */
#define SERCOM_I2CS_CTRLA_SPEED_Msk           (_U_(0x3) << SERCOM_I2CS_CTRLA_SPEED_Pos)            /**< (SERCOM_I2CS_CTRLA) Transfer Speed Mask */
#define SERCOM_I2CS_CTRLA_SPEED(value)        (SERCOM_I2CS_CTRLA_SPEED_Msk & ((value) << SERCOM_I2CS_CTRLA_SPEED_Pos))
#define SERCOM_I2CS_CTRLA_SCLSM_Pos           _U_(27)                                              /**< (SERCOM_I2CS_CTRLA) SCL Clock Stretch Mode Position */
#define SERCOM_I2CS_CTRLA_SCLSM_Msk           (_U_(0x1) << SERCOM_I2CS_CTRLA_SCLSM_Pos)            /**< (SERCOM_I2CS_CTRLA) SCL Clock Stretch Mode Mask */
#define SERCOM_I2CS_CTRLA_SCLSM(value)        (SERCOM_I2CS_CTRLA_SCLSM_Msk & ((value) << SERCOM_I2CS_CTRLA_SCLSM_Pos))
#define SERCOM_I2CS_CTRLA_LOWTOUTEN_Pos       _U_(30)                                              /**< (SERCOM_I2CS_CTRLA) SCL Low Timeout Enable Position */
#define SERCOM_I2CS_CTRLA_LOWTOUTEN_Msk       (_U_(0x1) << SERCOM_I2CS_CTRLA_LOWTOUTEN_Pos)        /**< (SERCOM_I2CS_CTRLA) SCL Low Timeout Enable Mask */
#define SERCOM_I2CS_CTRLA_LOWTOUTEN(value)    (SERCOM_I2CS_CTRLA_LOWTOUTEN_Msk & ((value) << SERCOM_I2CS_CTRLA_LOWTOUTEN_Pos))
#define SERCOM_I2CS_CTRLA_Msk                 _U_(0x4BB1009F)                                      /**< (SERCOM_I2CS_CTRLA) Register Mask  */


/* -------- SERCOM_SPI_CTRLA : (SERCOM Offset: 0x00) (R/W 32) SPI Control A -------- */
#define SERCOM_SPI_CTRLA_RESETVALUE           _U_(0x00)                                            /**<  (SERCOM_SPI_CTRLA) SPI Control A  Reset Value */

#define SERCOM_SPI_CTRLA_SWRST_Pos            _U_(0)                                               /**< (SERCOM_SPI_CTRLA) Software Reset Position */
#define SERCOM_SPI_CTRLA_SWRST_Msk            (_U_(0x1) << SERCOM_SPI_CTRLA_SWRST_Pos)             /**< (SERCOM_SPI_CTRLA) Software Reset Mask */
#define SERCOM_SPI_CTRLA_SWRST(value)         (SERCOM_SPI_CTRLA_SWRST_Msk & ((value) << SERCOM_SPI_CTRLA_SWRST_Pos))
#define SERCOM_SPI_CTRLA_ENABLE_Pos           _U_(1)                                               /**< (SERCOM_SPI_CTRLA) Enable Position */
#define SERCOM_SPI_CTRLA_ENABLE_Msk           (_U_(0x1) << SERCOM_SPI_CTRLA_ENABLE_Pos)            /**< (SERCOM_SPI_CTRLA) Enable Mask */
#define SERCOM_SPI_CTRLA_ENABLE(value)        (SERCOM_SPI_CTRLA_ENABLE_Msk & ((value) << SERCOM_SPI_CTRLA_ENABLE_Pos))
#define SERCOM_SPI_CTRLA_MODE_Pos             _U_(2)                                               /**< (SERCOM_SPI_CTRLA) Operating Mode Position */
#define SERCOM_SPI_CTRLA_MODE_Msk             (_U_(0x7) << SERCOM_SPI_CTRLA_MODE_Pos)              /**< (SERCOM_SPI_CTRLA) Operating Mode Mask */
#define SERCOM_SPI_CTRLA_MODE(value)          (SERCOM_SPI_CTRLA_MODE_Msk & ((value) << SERCOM_SPI_CTRLA_MODE_Pos))
#define SERCOM_SPI_CTRLA_RUNSTDBY_Pos         _U_(7)                                               /**< (SERCOM_SPI_CTRLA) Run during Standby Position */
#define SERCOM_SPI_CTRLA_RUNSTDBY_Msk         (_U_(0x1) << SERCOM_SPI_CTRLA_RUNSTDBY_Pos)          /**< (SERCOM_SPI_CTRLA) Run during Standby Mask */
#define SERCOM_SPI_CTRLA_RUNSTDBY(value)      (SERCOM_SPI_CTRLA_RUNSTDBY_Msk & ((value) << SERCOM_SPI_CTRLA_RUNSTDBY_Pos))
#define SERCOM_SPI_CTRLA_IBON_Pos             _U_(8)                                               /**< (SERCOM_SPI_CTRLA) Immediate Buffer Overflow Notification Position */
#define SERCOM_SPI_CTRLA_IBON_Msk             (_U_(0x1) << SERCOM_SPI_CTRLA_IBON_Pos)              /**< (SERCOM_SPI_CTRLA) Immediate Buffer Overflow Notification Mask */
#define SERCOM_SPI_CTRLA_IBON(value)          (SERCOM_SPI_CTRLA_IBON_Msk & ((value) << SERCOM_SPI_CTRLA_IBON_Pos))
#define SERCOM_SPI_CTRLA_DOPO_Pos             _U_(16)                                              /**< (SERCOM_SPI_CTRLA) Data Out Pinout Position */
#define SERCOM_SPI_CTRLA_DOPO_Msk             (_U_(0x3) << SERCOM_SPI_CTRLA_DOPO_Pos)              /**< (SERCOM_SPI_CTRLA) Data Out Pinout Mask */
#define SERCOM_SPI_CTRLA_DOPO(value)          (SERCOM_SPI_CTRLA_DOPO_Msk & ((value) << SERCOM_SPI_CTRLA_DOPO_Pos))
#define SERCOM_SPI_CTRLA_DIPO_Pos             _U_(20)                                              /**< (SERCOM_SPI_CTRLA) Data In Pinout Position */
#define SERCOM_SPI_CTRLA_DIPO_Msk             (_U_(0x3) << SERCOM_SPI_CTRLA_DIPO_Pos)              /**< (SERCOM_SPI_CTRLA) Data In Pinout Mask */
#define SERCOM_SPI_CTRLA_DIPO(value)          (SERCOM_SPI_CTRLA_DIPO_Msk & ((value) << SERCOM_SPI_CTRLA_DIPO_Pos))
#define SERCOM_SPI_CTRLA_FORM_Pos             _U_(24)                                              /**< (SERCOM_SPI_CTRLA) Frame Format Position */
#define SERCOM_SPI_CTRLA_FORM_Msk             (_U_(0xF) << SERCOM_SPI_CTRLA_FORM_Pos)              /**< (SERCOM_SPI_CTRLA) Frame Format Mask */
#define SERCOM_SPI_CTRLA_FORM(value)          (SERCOM_SPI_CTRLA_FORM_Msk & ((value) << SERCOM_SPI_CTRLA_FORM_Pos))
#define SERCOM_SPI_CTRLA_CPHA_Pos             _U_(28)                                              /**< (SERCOM_SPI_CTRLA) Clock Phase Position */
#define SERCOM_SPI_CTRLA_CPHA_Msk             (_U_(0x1) << SERCOM_SPI_CTRLA_CPHA_Pos)              /**< (SERCOM_SPI_CTRLA) Clock Phase Mask */
#define SERCOM_SPI_CTRLA_CPHA(value)          (SERCOM_SPI_CTRLA_CPHA_Msk & ((value) << SERCOM_SPI_CTRLA_CPHA_Pos))
#define SERCOM_SPI_CTRLA_CPOL_Pos             _U_(29)                                              /**< (SERCOM_SPI_CTRLA) Clock Polarity Position */
#define SERCOM_SPI_CTRLA_CPOL_Msk             (_U_(0x1) << SERCOM_SPI_CTRLA_CPOL_Pos)              /**< (SERCOM_SPI_CTRLA) Clock Polarity Mask */
#define SERCOM_SPI_CTRLA_CPOL(value)          (SERCOM_SPI_CTRLA_CPOL_Msk & ((value) << SERCOM_SPI_CTRLA_CPOL_Pos))
#define SERCOM_SPI_CTRLA_DORD_Pos             _U_(30)                                              /**< (SERCOM_SPI_CTRLA) Data Order Position */
#define SERCOM_SPI_CTRLA_DORD_Msk             (_U_(0x1) << SERCOM_SPI_CTRLA_DORD_Pos)              /**< (SERCOM_SPI_CTRLA) Data Order Mask */
#define SERCOM_SPI_CTRLA_DORD(value)          (SERCOM_SPI_CTRLA_DORD_Msk & ((value) << SERCOM_SPI_CTRLA_DORD_Pos))
#define SERCOM_SPI_CTRLA_Msk                  _U_(0x7F33019F)                                      /**< (SERCOM_SPI_CTRLA) Register Mask  */


/* -------- SERCOM_USART_CTRLA : (SERCOM Offset: 0x00) (R/W 32) USART Control A -------- */
#define SERCOM_USART_CTRLA_RESETVALUE         _U_(0x00)                                            /**<  (SERCOM_USART_CTRLA) USART Control A  Reset Value */

#define SERCOM_USART_CTRLA_SWRST_Pos          _U_(0)                                               /**< (SERCOM_USART_CTRLA) Software Reset Position */
#define SERCOM_USART_CTRLA_SWRST_Msk          (_U_(0x1) << SERCOM_USART_CTRLA_SWRST_Pos)           /**< (SERCOM_USART_CTRLA) Software Reset Mask */
#define SERCOM_USART_CTRLA_SWRST(value)       (SERCOM_USART_CTRLA_SWRST_Msk & ((value) << SERCOM_USART_CTRLA_SWRST_Pos))
#define SERCOM_USART_CTRLA_ENABLE_Pos         _U_(1)                                               /**< (SERCOM_USART_CTRLA) Enable Position */
#define SERCOM_USART_CTRLA_ENABLE_Msk         (_U_(0x1) << SERCOM_USART_CTRLA_ENABLE_Pos)          /**< (SERCOM_USART_CTRLA) Enable Mask */
#define SERCOM_USART_CTRLA_ENABLE(value)      (SERCOM_USART_CTRLA_ENABLE_Msk & ((value) << SERCOM_USART_CTRLA_ENABLE_Pos))
#define SERCOM_USART_CTRLA_MODE_Pos           _U_(2)                                               /**< (SERCOM_USART_CTRLA) Operating Mode Position */
#define SERCOM_USART_CTRLA_MODE_Msk           (_U_(0x7) << SERCOM_USART_CTRLA_MODE_Pos)            /**< (SERCOM_USART_CTRLA) Operating Mode Mask */
#define SERCOM_USART_CTRLA_MODE(value)        (SERCOM_USART_CTRLA_MODE_Msk & ((value) << SERCOM_USART_CTRLA_MODE_Pos))
#define SERCOM_USART_CTRLA_RUNSTDBY_Pos       _U_(7)                                               /**< (SERCOM_USART_CTRLA) Run during Standby Position */
#define SERCOM_USART_CTRLA_RUNSTDBY_Msk       (_U_(0x1) << SERCOM_USART_CTRLA_RUNSTDBY_Pos)        /**< (SERCOM_USART_CTRLA) Run during Standby Mask */
#define SERCOM_USART_CTRLA_RUNSTDBY(value)    (SERCOM_USART_CTRLA_RUNSTDBY_Msk & ((value) << SERCOM_USART_CTRLA_RUNSTDBY_Pos))
#define SERCOM_USART_CTRLA_IBON_Pos           _U_(8)                                               /**< (SERCOM_USART_CTRLA) Immediate Buffer Overflow Notification Position */
#define SERCOM_USART_CTRLA_IBON_Msk           (_U_(0x1) << SERCOM_USART_CTRLA_IBON_Pos)            /**< (SERCOM_USART_CTRLA) Immediate Buffer Overflow Notification Mask */
#define SERCOM_USART_CTRLA_IBON(value)        (SERCOM_USART_CTRLA_IBON_Msk & ((value) << SERCOM_USART_CTRLA_IBON_Pos))
#define SERCOM_USART_CTRLA_TXINV_Pos          _U_(9)                                               /**< (SERCOM_USART_CTRLA) Transmit Data Invert Position */
#define SERCOM_USART_CTRLA_TXINV_Msk          (_U_(0x1) << SERCOM_USART_CTRLA_TXINV_Pos)           /**< (SERCOM_USART_CTRLA) Transmit Data Invert Mask */
#define SERCOM_USART_CTRLA_TXINV(value)       (SERCOM_USART_CTRLA_TXINV_Msk & ((value) << SERCOM_USART_CTRLA_TXINV_Pos))
#define SERCOM_USART_CTRLA_RXINV_Pos          _U_(10)                                              /**< (SERCOM_USART_CTRLA) Receive Data Invert Position */
#define SERCOM_USART_CTRLA_RXINV_Msk          (_U_(0x1) << SERCOM_USART_CTRLA_RXINV_Pos)           /**< (SERCOM_USART_CTRLA) Receive Data Invert Mask */
#define SERCOM_USART_CTRLA_RXINV(value)       (SERCOM_USART_CTRLA_RXINV_Msk & ((value) << SERCOM_USART_CTRLA_RXINV_Pos))
#define SERCOM_USART_CTRLA_SAMPR_Pos          _U_(13)                                              /**< (SERCOM_USART_CTRLA) Sample Position */
#define SERCOM_USART_CTRLA_SAMPR_Msk          (_U_(0x7) << SERCOM_USART_CTRLA_SAMPR_Pos)           /**< (SERCOM_USART_CTRLA) Sample Mask */
#define SERCOM_USART_CTRLA_SAMPR(value)       (SERCOM_USART_CTRLA_SAMPR_Msk & ((value) << SERCOM_USART_CTRLA_SAMPR_Pos))
#define SERCOM_USART_CTRLA_TXPO_Pos           _U_(16)                                              /**< (SERCOM_USART_CTRLA) Transmit Data Pinout Position */
#define SERCOM_USART_CTRLA_TXPO_Msk           (_U_(0x3) << SERCOM_USART_CTRLA_TXPO_Pos)            /**< (SERCOM_USART_CTRLA) Transmit Data Pinout Mask */
#define SERCOM_USART_CTRLA_TXPO(value)        (SERCOM_USART_CTRLA_TXPO_Msk & ((value) << SERCOM_USART_CTRLA_TXPO_Pos))
#define SERCOM_USART_CTRLA_RXPO_Pos           _U_(20)                                              /**< (SERCOM_USART_CTRLA) Receive Data Pinout Position */
#define SERCOM_USART_CTRLA_RXPO_Msk           (_U_(0x3) << SERCOM_USART_CTRLA_RXPO_Pos)            /**< (SERCOM_USART_CTRLA) Receive Data Pinout Mask */
#define SERCOM_USART_CTRLA_RXPO(value)        (SERCOM_USART_CTRLA_RXPO_Msk & ((value) << SERCOM_USART_CTRLA_RXPO_Pos))
#define SERCOM_USART_CTRLA_SAMPA_Pos          _U_(22)                                              /**< (SERCOM_USART_CTRLA) Sample Adjustment Position */
#define SERCOM_USART_CTRLA_SAMPA_Msk          (_U_(0x3) << SERCOM_USART_CTRLA_SAMPA_Pos)           /**< (SERCOM_USART_CTRLA) Sample Adjustment Mask */
#define SERCOM_USART_CTRLA_SAMPA(value)       (SERCOM_USART_CTRLA_SAMPA_Msk & ((value) << SERCOM_USART_CTRLA_SAMPA_Pos))
#define SERCOM_USART_CTRLA_FORM_Pos           _U_(24)                                              /**< (SERCOM_USART_CTRLA) Frame Format Position */
#define SERCOM_USART_CTRLA_FORM_Msk           (_U_(0xF) << SERCOM_USART_CTRLA_FORM_Pos)            /**< (SERCOM_USART_CTRLA) Frame Format Mask */
#define SERCOM_USART_CTRLA_FORM(value)        (SERCOM_USART_CTRLA_FORM_Msk & ((value) << SERCOM_USART_CTRLA_FORM_Pos))
#define SERCOM_USART_CTRLA_CMODE_Pos          _U_(28)                                              /**< (SERCOM_USART_CTRLA) Communication Mode Position */
#define SERCOM_USART_CTRLA_CMODE_Msk          (_U_(0x1) << SERCOM_USART_CTRLA_CMODE_Pos)           /**< (SERCOM_USART_CTRLA) Communication Mode Mask */
#define SERCOM_USART_CTRLA_CMODE(value)       (SERCOM_USART_CTRLA_CMODE_Msk & ((value) << SERCOM_USART_CTRLA_CMODE_Pos))
#define SERCOM_USART_CTRLA_CPOL_Pos           _U_(29)                                              /**< (SERCOM_USART_CTRLA) Clock Polarity Position */
#define SERCOM_USART_CTRLA_CPOL_Msk           (_U_(0x1) << SERCOM_USART_CTRLA_CPOL_Pos)            /**< (SERCOM_USART_CTRLA) Clock Polarity Mask */
#define SERCOM_USART_CTRLA_CPOL(value)        (SERCOM_USART_CTRLA_CPOL_Msk & ((value) << SERCOM_USART_CTRLA_CPOL_Pos))
#define SERCOM_USART_CTRLA_DORD_Pos           _U_(30)                                              /**< (SERCOM_USART_CTRLA) Data Order Position */
#define SERCOM_USART_CTRLA_DORD_Msk           (_U_(0x1) << SERCOM_USART_CTRLA_DORD_Pos)            /**< (SERCOM_USART_CTRLA) Data Order Mask */
#define SERCOM_USART_CTRLA_DORD(value)        (SERCOM_USART_CTRLA_DORD_Msk & ((value) << SERCOM_USART_CTRLA_DORD_Pos))
#define SERCOM_USART_CTRLA_Msk                _U_(0x7FF3E79F)                                      /**< (SERCOM_USART_CTRLA) Register Mask  */


/* -------- SERCOM_I2CM_CTRLB : (SERCOM Offset: 0x04) (R/W 32) I2CM Control B -------- */
#define SERCOM_I2CM_CTRLB_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_I2CM_CTRLB) I2CM Control B  Reset Value */

#define SERCOM_I2CM_CTRLB_SMEN_Pos            _U_(8)                                               /**< (SERCOM_I2CM_CTRLB) Smart Mode Enable Position */
#define SERCOM_I2CM_CTRLB_SMEN_Msk            (_U_(0x1) << SERCOM_I2CM_CTRLB_SMEN_Pos)             /**< (SERCOM_I2CM_CTRLB) Smart Mode Enable Mask */
#define SERCOM_I2CM_CTRLB_SMEN(value)         (SERCOM_I2CM_CTRLB_SMEN_Msk & ((value) << SERCOM_I2CM_CTRLB_SMEN_Pos))
#define SERCOM_I2CM_CTRLB_QCEN_Pos            _U_(9)                                               /**< (SERCOM_I2CM_CTRLB) Quick Command Enable Position */
#define SERCOM_I2CM_CTRLB_QCEN_Msk            (_U_(0x1) << SERCOM_I2CM_CTRLB_QCEN_Pos)             /**< (SERCOM_I2CM_CTRLB) Quick Command Enable Mask */
#define SERCOM_I2CM_CTRLB_QCEN(value)         (SERCOM_I2CM_CTRLB_QCEN_Msk & ((value) << SERCOM_I2CM_CTRLB_QCEN_Pos))
#define SERCOM_I2CM_CTRLB_CMD_Pos             _U_(16)                                              /**< (SERCOM_I2CM_CTRLB) Command Position */
#define SERCOM_I2CM_CTRLB_CMD_Msk             (_U_(0x3) << SERCOM_I2CM_CTRLB_CMD_Pos)              /**< (SERCOM_I2CM_CTRLB) Command Mask */
#define SERCOM_I2CM_CTRLB_CMD(value)          (SERCOM_I2CM_CTRLB_CMD_Msk & ((value) << SERCOM_I2CM_CTRLB_CMD_Pos))
#define SERCOM_I2CM_CTRLB_ACKACT_Pos          _U_(18)                                              /**< (SERCOM_I2CM_CTRLB) Acknowledge Action Position */
#define SERCOM_I2CM_CTRLB_ACKACT_Msk          (_U_(0x1) << SERCOM_I2CM_CTRLB_ACKACT_Pos)           /**< (SERCOM_I2CM_CTRLB) Acknowledge Action Mask */
#define SERCOM_I2CM_CTRLB_ACKACT(value)       (SERCOM_I2CM_CTRLB_ACKACT_Msk & ((value) << SERCOM_I2CM_CTRLB_ACKACT_Pos))
#define SERCOM_I2CM_CTRLB_Msk                 _U_(0x00070300)                                      /**< (SERCOM_I2CM_CTRLB) Register Mask  */


/* -------- SERCOM_I2CS_CTRLB : (SERCOM Offset: 0x04) (R/W 32) I2CS Control B -------- */
#define SERCOM_I2CS_CTRLB_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_I2CS_CTRLB) I2CS Control B  Reset Value */

#define SERCOM_I2CS_CTRLB_SMEN_Pos            _U_(8)                                               /**< (SERCOM_I2CS_CTRLB) Smart Mode Enable Position */
#define SERCOM_I2CS_CTRLB_SMEN_Msk            (_U_(0x1) << SERCOM_I2CS_CTRLB_SMEN_Pos)             /**< (SERCOM_I2CS_CTRLB) Smart Mode Enable Mask */
#define SERCOM_I2CS_CTRLB_SMEN(value)         (SERCOM_I2CS_CTRLB_SMEN_Msk & ((value) << SERCOM_I2CS_CTRLB_SMEN_Pos))
#define SERCOM_I2CS_CTRLB_GCMD_Pos            _U_(9)                                               /**< (SERCOM_I2CS_CTRLB) PMBus Group Command Position */
#define SERCOM_I2CS_CTRLB_GCMD_Msk            (_U_(0x1) << SERCOM_I2CS_CTRLB_GCMD_Pos)             /**< (SERCOM_I2CS_CTRLB) PMBus Group Command Mask */
#define SERCOM_I2CS_CTRLB_GCMD(value)         (SERCOM_I2CS_CTRLB_GCMD_Msk & ((value) << SERCOM_I2CS_CTRLB_GCMD_Pos))
#define SERCOM_I2CS_CTRLB_AACKEN_Pos          _U_(10)                                              /**< (SERCOM_I2CS_CTRLB) Automatic Address Acknowledge Position */
#define SERCOM_I2CS_CTRLB_AACKEN_Msk          (_U_(0x1) << SERCOM_I2CS_CTRLB_AACKEN_Pos)           /**< (SERCOM_I2CS_CTRLB) Automatic Address Acknowledge Mask */
#define SERCOM_I2CS_CTRLB_AACKEN(value)       (SERCOM_I2CS_CTRLB_AACKEN_Msk & ((value) << SERCOM_I2CS_CTRLB_AACKEN_Pos))
#define SERCOM_I2CS_CTRLB_AMODE_Pos           _U_(14)                                              /**< (SERCOM_I2CS_CTRLB) Address Mode Position */
#define SERCOM_I2CS_CTRLB_AMODE_Msk           (_U_(0x3) << SERCOM_I2CS_CTRLB_AMODE_Pos)            /**< (SERCOM_I2CS_CTRLB) Address Mode Mask */
#define SERCOM_I2CS_CTRLB_AMODE(value)        (SERCOM_I2CS_CTRLB_AMODE_Msk & ((value) << SERCOM_I2CS_CTRLB_AMODE_Pos))
#define SERCOM_I2CS_CTRLB_CMD_Pos             _U_(16)                                              /**< (SERCOM_I2CS_CTRLB) Command Position */
#define SERCOM_I2CS_CTRLB_CMD_Msk             (_U_(0x3) << SERCOM_I2CS_CTRLB_CMD_Pos)              /**< (SERCOM_I2CS_CTRLB) Command Mask */
#define SERCOM_I2CS_CTRLB_CMD(value)          (SERCOM_I2CS_CTRLB_CMD_Msk & ((value) << SERCOM_I2CS_CTRLB_CMD_Pos))
#define SERCOM_I2CS_CTRLB_ACKACT_Pos          _U_(18)                                              /**< (SERCOM_I2CS_CTRLB) Acknowledge Action Position */
#define SERCOM_I2CS_CTRLB_ACKACT_Msk          (_U_(0x1) << SERCOM_I2CS_CTRLB_ACKACT_Pos)           /**< (SERCOM_I2CS_CTRLB) Acknowledge Action Mask */
#define SERCOM_I2CS_CTRLB_ACKACT(value)       (SERCOM_I2CS_CTRLB_ACKACT_Msk & ((value) << SERCOM_I2CS_CTRLB_ACKACT_Pos))
#define SERCOM_I2CS_CTRLB_Msk                 _U_(0x0007C700)                                      /**< (SERCOM_I2CS_CTRLB) Register Mask  */


/* -------- SERCOM_SPI_CTRLB : (SERCOM Offset: 0x04) (R/W 32) SPI Control B -------- */
#define SERCOM_SPI_CTRLB_RESETVALUE           _U_(0x00)                                            /**<  (SERCOM_SPI_CTRLB) SPI Control B  Reset Value */

#define SERCOM_SPI_CTRLB_CHSIZE_Pos           _U_(0)                                               /**< (SERCOM_SPI_CTRLB) Character Size Position */
#define SERCOM_SPI_CTRLB_CHSIZE_Msk           (_U_(0x7) << SERCOM_SPI_CTRLB_CHSIZE_Pos)            /**< (SERCOM_SPI_CTRLB) Character Size Mask */
#define SERCOM_SPI_CTRLB_CHSIZE(value)        (SERCOM_SPI_CTRLB_CHSIZE_Msk & ((value) << SERCOM_SPI_CTRLB_CHSIZE_Pos))
#define SERCOM_SPI_CTRLB_PLOADEN_Pos          _U_(6)                                               /**< (SERCOM_SPI_CTRLB) Data Preload Enable Position */
#define SERCOM_SPI_CTRLB_PLOADEN_Msk          (_U_(0x1) << SERCOM_SPI_CTRLB_PLOADEN_Pos)           /**< (SERCOM_SPI_CTRLB) Data Preload Enable Mask */
#define SERCOM_SPI_CTRLB_PLOADEN(value)       (SERCOM_SPI_CTRLB_PLOADEN_Msk & ((value) << SERCOM_SPI_CTRLB_PLOADEN_Pos))
#define SERCOM_SPI_CTRLB_SSDE_Pos             _U_(9)                                               /**< (SERCOM_SPI_CTRLB) Slave Select Low Detect Enable Position */
#define SERCOM_SPI_CTRLB_SSDE_Msk             (_U_(0x1) << SERCOM_SPI_CTRLB_SSDE_Pos)              /**< (SERCOM_SPI_CTRLB) Slave Select Low Detect Enable Mask */
#define SERCOM_SPI_CTRLB_SSDE(value)          (SERCOM_SPI_CTRLB_SSDE_Msk & ((value) << SERCOM_SPI_CTRLB_SSDE_Pos))
#define SERCOM_SPI_CTRLB_MSSEN_Pos            _U_(13)                                              /**< (SERCOM_SPI_CTRLB) Master Slave Select Enable Position */
#define SERCOM_SPI_CTRLB_MSSEN_Msk            (_U_(0x1) << SERCOM_SPI_CTRLB_MSSEN_Pos)             /**< (SERCOM_SPI_CTRLB) Master Slave Select Enable Mask */
#define SERCOM_SPI_CTRLB_MSSEN(value)         (SERCOM_SPI_CTRLB_MSSEN_Msk & ((value) << SERCOM_SPI_CTRLB_MSSEN_Pos))
#define SERCOM_SPI_CTRLB_AMODE_Pos            _U_(14)                                              /**< (SERCOM_SPI_CTRLB) Address Mode Position */
#define SERCOM_SPI_CTRLB_AMODE_Msk            (_U_(0x3) << SERCOM_SPI_CTRLB_AMODE_Pos)             /**< (SERCOM_SPI_CTRLB) Address Mode Mask */
#define SERCOM_SPI_CTRLB_AMODE(value)         (SERCOM_SPI_CTRLB_AMODE_Msk & ((value) << SERCOM_SPI_CTRLB_AMODE_Pos))
#define SERCOM_SPI_CTRLB_RXEN_Pos             _U_(17)                                              /**< (SERCOM_SPI_CTRLB) Receiver Enable Position */
#define SERCOM_SPI_CTRLB_RXEN_Msk             (_U_(0x1) << SERCOM_SPI_CTRLB_RXEN_Pos)              /**< (SERCOM_SPI_CTRLB) Receiver Enable Mask */
#define SERCOM_SPI_CTRLB_RXEN(value)          (SERCOM_SPI_CTRLB_RXEN_Msk & ((value) << SERCOM_SPI_CTRLB_RXEN_Pos))
#define SERCOM_SPI_CTRLB_Msk                  _U_(0x0002E247)                                      /**< (SERCOM_SPI_CTRLB) Register Mask  */


/* -------- SERCOM_USART_CTRLB : (SERCOM Offset: 0x04) (R/W 32) USART Control B -------- */
#define SERCOM_USART_CTRLB_RESETVALUE         _U_(0x00)                                            /**<  (SERCOM_USART_CTRLB) USART Control B  Reset Value */

#define SERCOM_USART_CTRLB_CHSIZE_Pos         _U_(0)                                               /**< (SERCOM_USART_CTRLB) Character Size Position */
#define SERCOM_USART_CTRLB_CHSIZE_Msk         (_U_(0x7) << SERCOM_USART_CTRLB_CHSIZE_Pos)          /**< (SERCOM_USART_CTRLB) Character Size Mask */
#define SERCOM_USART_CTRLB_CHSIZE(value)      (SERCOM_USART_CTRLB_CHSIZE_Msk & ((value) << SERCOM_USART_CTRLB_CHSIZE_Pos))
#define SERCOM_USART_CTRLB_SBMODE_Pos         _U_(6)                                               /**< (SERCOM_USART_CTRLB) Stop Bit Mode Position */
#define SERCOM_USART_CTRLB_SBMODE_Msk         (_U_(0x1) << SERCOM_USART_CTRLB_SBMODE_Pos)          /**< (SERCOM_USART_CTRLB) Stop Bit Mode Mask */
#define SERCOM_USART_CTRLB_SBMODE(value)      (SERCOM_USART_CTRLB_SBMODE_Msk & ((value) << SERCOM_USART_CTRLB_SBMODE_Pos))
#define SERCOM_USART_CTRLB_COLDEN_Pos         _U_(8)                                               /**< (SERCOM_USART_CTRLB) Collision Detection Enable Position */
#define SERCOM_USART_CTRLB_COLDEN_Msk         (_U_(0x1) << SERCOM_USART_CTRLB_COLDEN_Pos)          /**< (SERCOM_USART_CTRLB) Collision Detection Enable Mask */
#define SERCOM_USART_CTRLB_COLDEN(value)      (SERCOM_USART_CTRLB_COLDEN_Msk & ((value) << SERCOM_USART_CTRLB_COLDEN_Pos))
#define SERCOM_USART_CTRLB_SFDE_Pos           _U_(9)                                               /**< (SERCOM_USART_CTRLB) Start of Frame Detection Enable Position */
#define SERCOM_USART_CTRLB_SFDE_Msk           (_U_(0x1) << SERCOM_USART_CTRLB_SFDE_Pos)            /**< (SERCOM_USART_CTRLB) Start of Frame Detection Enable Mask */
#define SERCOM_USART_CTRLB_SFDE(value)        (SERCOM_USART_CTRLB_SFDE_Msk & ((value) << SERCOM_USART_CTRLB_SFDE_Pos))
#define SERCOM_USART_CTRLB_ENC_Pos            _U_(10)                                              /**< (SERCOM_USART_CTRLB) Encoding Format Position */
#define SERCOM_USART_CTRLB_ENC_Msk            (_U_(0x1) << SERCOM_USART_CTRLB_ENC_Pos)             /**< (SERCOM_USART_CTRLB) Encoding Format Mask */
#define SERCOM_USART_CTRLB_ENC(value)         (SERCOM_USART_CTRLB_ENC_Msk & ((value) << SERCOM_USART_CTRLB_ENC_Pos))
#define SERCOM_USART_CTRLB_PMODE_Pos          _U_(13)                                              /**< (SERCOM_USART_CTRLB) Parity Mode Position */
#define SERCOM_USART_CTRLB_PMODE_Msk          (_U_(0x1) << SERCOM_USART_CTRLB_PMODE_Pos)           /**< (SERCOM_USART_CTRLB) Parity Mode Mask */
#define SERCOM_USART_CTRLB_PMODE(value)       (SERCOM_USART_CTRLB_PMODE_Msk & ((value) << SERCOM_USART_CTRLB_PMODE_Pos))
#define SERCOM_USART_CTRLB_TXEN_Pos           _U_(16)                                              /**< (SERCOM_USART_CTRLB) Transmitter Enable Position */
#define SERCOM_USART_CTRLB_TXEN_Msk           (_U_(0x1) << SERCOM_USART_CTRLB_TXEN_Pos)            /**< (SERCOM_USART_CTRLB) Transmitter Enable Mask */
#define SERCOM_USART_CTRLB_TXEN(value)        (SERCOM_USART_CTRLB_TXEN_Msk & ((value) << SERCOM_USART_CTRLB_TXEN_Pos))
#define SERCOM_USART_CTRLB_RXEN_Pos           _U_(17)                                              /**< (SERCOM_USART_CTRLB) Receiver Enable Position */
#define SERCOM_USART_CTRLB_RXEN_Msk           (_U_(0x1) << SERCOM_USART_CTRLB_RXEN_Pos)            /**< (SERCOM_USART_CTRLB) Receiver Enable Mask */
#define SERCOM_USART_CTRLB_RXEN(value)        (SERCOM_USART_CTRLB_RXEN_Msk & ((value) << SERCOM_USART_CTRLB_RXEN_Pos))
#define SERCOM_USART_CTRLB_LINCMD_Pos         _U_(24)                                              /**< (SERCOM_USART_CTRLB) LIN Command Position */
#define SERCOM_USART_CTRLB_LINCMD_Msk         (_U_(0x3) << SERCOM_USART_CTRLB_LINCMD_Pos)          /**< (SERCOM_USART_CTRLB) LIN Command Mask */
#define SERCOM_USART_CTRLB_LINCMD(value)      (SERCOM_USART_CTRLB_LINCMD_Msk & ((value) << SERCOM_USART_CTRLB_LINCMD_Pos))
#define SERCOM_USART_CTRLB_Msk                _U_(0x03032747)                                      /**< (SERCOM_USART_CTRLB) Register Mask  */


/* -------- SERCOM_USART_CTRLC : (SERCOM Offset: 0x08) (R/W 32) USART Control C -------- */
#define SERCOM_USART_CTRLC_RESETVALUE         _U_(0x00)                                            /**<  (SERCOM_USART_CTRLC) USART Control C  Reset Value */

#define SERCOM_USART_CTRLC_GTIME_Pos          _U_(0)                                               /**< (SERCOM_USART_CTRLC) Guard Time Position */
#define SERCOM_USART_CTRLC_GTIME_Msk          (_U_(0x7) << SERCOM_USART_CTRLC_GTIME_Pos)           /**< (SERCOM_USART_CTRLC) Guard Time Mask */
#define SERCOM_USART_CTRLC_GTIME(value)       (SERCOM_USART_CTRLC_GTIME_Msk & ((value) << SERCOM_USART_CTRLC_GTIME_Pos))
#define SERCOM_USART_CTRLC_BRKLEN_Pos         _U_(8)                                               /**< (SERCOM_USART_CTRLC) LIN Master Break Length Position */
#define SERCOM_USART_CTRLC_BRKLEN_Msk         (_U_(0x3) << SERCOM_USART_CTRLC_BRKLEN_Pos)          /**< (SERCOM_USART_CTRLC) LIN Master Break Length Mask */
#define SERCOM_USART_CTRLC_BRKLEN(value)      (SERCOM_USART_CTRLC_BRKLEN_Msk & ((value) << SERCOM_USART_CTRLC_BRKLEN_Pos))
#define SERCOM_USART_CTRLC_HDRDLY_Pos         _U_(10)                                              /**< (SERCOM_USART_CTRLC) LIN Master Header Delay Position */
#define SERCOM_USART_CTRLC_HDRDLY_Msk         (_U_(0x3) << SERCOM_USART_CTRLC_HDRDLY_Pos)          /**< (SERCOM_USART_CTRLC) LIN Master Header Delay Mask */
#define SERCOM_USART_CTRLC_HDRDLY(value)      (SERCOM_USART_CTRLC_HDRDLY_Msk & ((value) << SERCOM_USART_CTRLC_HDRDLY_Pos))
#define SERCOM_USART_CTRLC_INACK_Pos          _U_(16)                                              /**< (SERCOM_USART_CTRLC) Inhibit Not Acknowledge Position */
#define SERCOM_USART_CTRLC_INACK_Msk          (_U_(0x1) << SERCOM_USART_CTRLC_INACK_Pos)           /**< (SERCOM_USART_CTRLC) Inhibit Not Acknowledge Mask */
#define SERCOM_USART_CTRLC_INACK(value)       (SERCOM_USART_CTRLC_INACK_Msk & ((value) << SERCOM_USART_CTRLC_INACK_Pos))
#define SERCOM_USART_CTRLC_DSNACK_Pos         _U_(17)                                              /**< (SERCOM_USART_CTRLC) Disable Successive NACK Position */
#define SERCOM_USART_CTRLC_DSNACK_Msk         (_U_(0x1) << SERCOM_USART_CTRLC_DSNACK_Pos)          /**< (SERCOM_USART_CTRLC) Disable Successive NACK Mask */
#define SERCOM_USART_CTRLC_DSNACK(value)      (SERCOM_USART_CTRLC_DSNACK_Msk & ((value) << SERCOM_USART_CTRLC_DSNACK_Pos))
#define SERCOM_USART_CTRLC_MAXITER_Pos        _U_(20)                                              /**< (SERCOM_USART_CTRLC) Maximum Iterations Position */
#define SERCOM_USART_CTRLC_MAXITER_Msk        (_U_(0x7) << SERCOM_USART_CTRLC_MAXITER_Pos)         /**< (SERCOM_USART_CTRLC) Maximum Iterations Mask */
#define SERCOM_USART_CTRLC_MAXITER(value)     (SERCOM_USART_CTRLC_MAXITER_Msk & ((value) << SERCOM_USART_CTRLC_MAXITER_Pos))
#define SERCOM_USART_CTRLC_Msk                _U_(0x00730F07)                                      /**< (SERCOM_USART_CTRLC) Register Mask  */


/* -------- SERCOM_I2CM_BAUD : (SERCOM Offset: 0x0C) (R/W 32) I2CM Baud Rate -------- */
#define SERCOM_I2CM_BAUD_RESETVALUE           _U_(0x00)                                            /**<  (SERCOM_I2CM_BAUD) I2CM Baud Rate  Reset Value */

#define SERCOM_I2CM_BAUD_BAUD_Pos             _U_(0)                                               /**< (SERCOM_I2CM_BAUD) Baud Rate Value Position */
#define SERCOM_I2CM_BAUD_BAUD_Msk             (_U_(0xFF) << SERCOM_I2CM_BAUD_BAUD_Pos)             /**< (SERCOM_I2CM_BAUD) Baud Rate Value Mask */
#define SERCOM_I2CM_BAUD_BAUD(value)          (SERCOM_I2CM_BAUD_BAUD_Msk & ((value) << SERCOM_I2CM_BAUD_BAUD_Pos))
#define SERCOM_I2CM_BAUD_BAUDLOW_Pos          _U_(8)                                               /**< (SERCOM_I2CM_BAUD) Baud Rate Value Low Position */
#define SERCOM_I2CM_BAUD_BAUDLOW_Msk          (_U_(0xFF) << SERCOM_I2CM_BAUD_BAUDLOW_Pos)          /**< (SERCOM_I2CM_BAUD) Baud Rate Value Low Mask */
#define SERCOM_I2CM_BAUD_BAUDLOW(value)       (SERCOM_I2CM_BAUD_BAUDLOW_Msk & ((value) << SERCOM_I2CM_BAUD_BAUDLOW_Pos))
#define SERCOM_I2CM_BAUD_HSBAUD_Pos           _U_(16)                                              /**< (SERCOM_I2CM_BAUD) High Speed Baud Rate Value Position */
#define SERCOM_I2CM_BAUD_HSBAUD_Msk           (_U_(0xFF) << SERCOM_I2CM_BAUD_HSBAUD_Pos)           /**< (SERCOM_I2CM_BAUD) High Speed Baud Rate Value Mask */
#define SERCOM_I2CM_BAUD_HSBAUD(value)        (SERCOM_I2CM_BAUD_HSBAUD_Msk & ((value) << SERCOM_I2CM_BAUD_HSBAUD_Pos))
#define SERCOM_I2CM_BAUD_HSBAUDLOW_Pos        _U_(24)                                              /**< (SERCOM_I2CM_BAUD) High Speed Baud Rate Value Low Position */
#define SERCOM_I2CM_BAUD_HSBAUDLOW_Msk        (_U_(0xFF) << SERCOM_I2CM_BAUD_HSBAUDLOW_Pos)        /**< (SERCOM_I2CM_BAUD) High Speed Baud Rate Value Low Mask */
#define SERCOM_I2CM_BAUD_HSBAUDLOW(value)     (SERCOM_I2CM_BAUD_HSBAUDLOW_Msk & ((value) << SERCOM_I2CM_BAUD_HSBAUDLOW_Pos))
#define SERCOM_I2CM_BAUD_Msk                  _U_(0xFFFFFFFF)                                      /**< (SERCOM_I2CM_BAUD) Register Mask  */


/* -------- SERCOM_SPI_BAUD : (SERCOM Offset: 0x0C) (R/W 8) SPI Baud Rate -------- */
#define SERCOM_SPI_BAUD_RESETVALUE            _U_(0x00)                                            /**<  (SERCOM_SPI_BAUD) SPI Baud Rate  Reset Value */

#define SERCOM_SPI_BAUD_BAUD_Pos              _U_(0)                                               /**< (SERCOM_SPI_BAUD) Baud Rate Value Position */
#define SERCOM_SPI_BAUD_BAUD_Msk              (_U_(0xFF) << SERCOM_SPI_BAUD_BAUD_Pos)              /**< (SERCOM_SPI_BAUD) Baud Rate Value Mask */
#define SERCOM_SPI_BAUD_BAUD(value)           (SERCOM_SPI_BAUD_BAUD_Msk & ((value) << SERCOM_SPI_BAUD_BAUD_Pos))
#define SERCOM_SPI_BAUD_Msk                   _U_(0xFF)                                            /**< (SERCOM_SPI_BAUD) Register Mask  */


/* -------- SERCOM_USART_BAUD : (SERCOM Offset: 0x0C) (R/W 16) USART Baud Rate -------- */
#define SERCOM_USART_BAUD_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_USART_BAUD) USART Baud Rate  Reset Value */

#define SERCOM_USART_BAUD_BAUD_Pos            _U_(0)                                               /**< (SERCOM_USART_BAUD) Baud Rate Value Position */
#define SERCOM_USART_BAUD_BAUD_Msk            (_U_(0xFFFF) << SERCOM_USART_BAUD_BAUD_Pos)          /**< (SERCOM_USART_BAUD) Baud Rate Value Mask */
#define SERCOM_USART_BAUD_BAUD(value)         (SERCOM_USART_BAUD_BAUD_Msk & ((value) << SERCOM_USART_BAUD_BAUD_Pos))
#define SERCOM_USART_BAUD_Msk                 _U_(0xFFFF)                                          /**< (SERCOM_USART_BAUD) Register Mask  */

/* FRAC mode */
#define SERCOM_USART_BAUD_FRAC_BAUD_Pos       _U_(0)                                               /**< (SERCOM_USART_BAUD) Baud Rate Value Position */
#define SERCOM_USART_BAUD_FRAC_BAUD_Msk       (_U_(0x1FFF) << SERCOM_USART_BAUD_FRAC_BAUD_Pos)     /**< (SERCOM_USART_BAUD) Baud Rate Value Mask */
#define SERCOM_USART_BAUD_FRAC_BAUD(value)    (SERCOM_USART_BAUD_FRAC_BAUD_Msk & ((value) << SERCOM_USART_BAUD_FRAC_BAUD_Pos))
#define SERCOM_USART_BAUD_FRAC_FP_Pos         _U_(13)                                              /**< (SERCOM_USART_BAUD) Fractional Part Position */
#define SERCOM_USART_BAUD_FRAC_FP_Msk         (_U_(0x7) << SERCOM_USART_BAUD_FRAC_FP_Pos)          /**< (SERCOM_USART_BAUD) Fractional Part Mask */
#define SERCOM_USART_BAUD_FRAC_FP(value)      (SERCOM_USART_BAUD_FRAC_FP_Msk & ((value) << SERCOM_USART_BAUD_FRAC_FP_Pos))
#define SERCOM_USART_BAUD_FRAC_Msk            _U_(0xFFFF)                                           /**< (SERCOM_USART_BAUD_FRAC) Register Mask  */

/* FRACFP mode */
#define SERCOM_USART_BAUD_FRACFP_BAUD_Pos     _U_(0)                                               /**< (SERCOM_USART_BAUD) Baud Rate Value Position */
#define SERCOM_USART_BAUD_FRACFP_BAUD_Msk     (_U_(0x1FFF) << SERCOM_USART_BAUD_FRACFP_BAUD_Pos)   /**< (SERCOM_USART_BAUD) Baud Rate Value Mask */
#define SERCOM_USART_BAUD_FRACFP_BAUD(value)  (SERCOM_USART_BAUD_FRACFP_BAUD_Msk & ((value) << SERCOM_USART_BAUD_FRACFP_BAUD_Pos))
#define SERCOM_USART_BAUD_FRACFP_FP_Pos       _U_(13)                                              /**< (SERCOM_USART_BAUD) Fractional Part Position */
#define SERCOM_USART_BAUD_FRACFP_FP_Msk       (_U_(0x7) << SERCOM_USART_BAUD_FRACFP_FP_Pos)        /**< (SERCOM_USART_BAUD) Fractional Part Mask */
#define SERCOM_USART_BAUD_FRACFP_FP(value)    (SERCOM_USART_BAUD_FRACFP_FP_Msk & ((value) << SERCOM_USART_BAUD_FRACFP_FP_Pos))
#define SERCOM_USART_BAUD_FRACFP_Msk          _U_(0xFFFF)                                           /**< (SERCOM_USART_BAUD_FRACFP) Register Mask  */

/* USARTFP mode */
#define SERCOM_USART_BAUD_USARTFP_BAUD_Pos    _U_(0)                                               /**< (SERCOM_USART_BAUD) Baud Rate Value Position */
#define SERCOM_USART_BAUD_USARTFP_BAUD_Msk    (_U_(0xFFFF) << SERCOM_USART_BAUD_USARTFP_BAUD_Pos)  /**< (SERCOM_USART_BAUD) Baud Rate Value Mask */
#define SERCOM_USART_BAUD_USARTFP_BAUD(value) (SERCOM_USART_BAUD_USARTFP_BAUD_Msk & ((value) << SERCOM_USART_BAUD_USARTFP_BAUD_Pos))
#define SERCOM_USART_BAUD_USARTFP_Msk         _U_(0xFFFF)                                           /**< (SERCOM_USART_BAUD_USARTFP) Register Mask  */


/* -------- SERCOM_USART_RXPL : (SERCOM Offset: 0x0E) (R/W 8) USART Receive Pulse Length -------- */
#define SERCOM_USART_RXPL_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_USART_RXPL) USART Receive Pulse Length  Reset Value */

#define SERCOM_USART_RXPL_RXPL_Pos            _U_(0)                                               /**< (SERCOM_USART_RXPL) Receive Pulse Length Position */
#define SERCOM_USART_RXPL_RXPL_Msk            (_U_(0xFF) << SERCOM_USART_RXPL_RXPL_Pos)            /**< (SERCOM_USART_RXPL) Receive Pulse Length Mask */
#define SERCOM_USART_RXPL_RXPL(value)         (SERCOM_USART_RXPL_RXPL_Msk & ((value) << SERCOM_USART_RXPL_RXPL_Pos))
#define SERCOM_USART_RXPL_Msk                 _U_(0xFF)                                            /**< (SERCOM_USART_RXPL) Register Mask  */


/* -------- SERCOM_I2CM_INTENCLR : (SERCOM Offset: 0x14) (R/W 8) I2CM Interrupt Enable Clear -------- */
#define SERCOM_I2CM_INTENCLR_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_I2CM_INTENCLR) I2CM Interrupt Enable Clear  Reset Value */

#define SERCOM_I2CM_INTENCLR_MB_Pos           _U_(0)                                               /**< (SERCOM_I2CM_INTENCLR) Master On Bus Interrupt Disable Position */
#define SERCOM_I2CM_INTENCLR_MB_Msk           (_U_(0x1) << SERCOM_I2CM_INTENCLR_MB_Pos)            /**< (SERCOM_I2CM_INTENCLR) Master On Bus Interrupt Disable Mask */
#define SERCOM_I2CM_INTENCLR_MB(value)        (SERCOM_I2CM_INTENCLR_MB_Msk & ((value) << SERCOM_I2CM_INTENCLR_MB_Pos))
#define SERCOM_I2CM_INTENCLR_SB_Pos           _U_(1)                                               /**< (SERCOM_I2CM_INTENCLR) Slave On Bus Interrupt Disable Position */
#define SERCOM_I2CM_INTENCLR_SB_Msk           (_U_(0x1) << SERCOM_I2CM_INTENCLR_SB_Pos)            /**< (SERCOM_I2CM_INTENCLR) Slave On Bus Interrupt Disable Mask */
#define SERCOM_I2CM_INTENCLR_SB(value)        (SERCOM_I2CM_INTENCLR_SB_Msk & ((value) << SERCOM_I2CM_INTENCLR_SB_Pos))
#define SERCOM_I2CM_INTENCLR_ERROR_Pos        _U_(7)                                               /**< (SERCOM_I2CM_INTENCLR) Combined Error Interrupt Disable Position */
#define SERCOM_I2CM_INTENCLR_ERROR_Msk        (_U_(0x1) << SERCOM_I2CM_INTENCLR_ERROR_Pos)         /**< (SERCOM_I2CM_INTENCLR) Combined Error Interrupt Disable Mask */
#define SERCOM_I2CM_INTENCLR_ERROR(value)     (SERCOM_I2CM_INTENCLR_ERROR_Msk & ((value) << SERCOM_I2CM_INTENCLR_ERROR_Pos))
#define SERCOM_I2CM_INTENCLR_Msk              _U_(0x83)                                            /**< (SERCOM_I2CM_INTENCLR) Register Mask  */


/* -------- SERCOM_I2CS_INTENCLR : (SERCOM Offset: 0x14) (R/W 8) I2CS Interrupt Enable Clear -------- */
#define SERCOM_I2CS_INTENCLR_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_I2CS_INTENCLR) I2CS Interrupt Enable Clear  Reset Value */

#define SERCOM_I2CS_INTENCLR_PREC_Pos         _U_(0)                                               /**< (SERCOM_I2CS_INTENCLR) Stop Received Interrupt Disable Position */
#define SERCOM_I2CS_INTENCLR_PREC_Msk         (_U_(0x1) << SERCOM_I2CS_INTENCLR_PREC_Pos)          /**< (SERCOM_I2CS_INTENCLR) Stop Received Interrupt Disable Mask */
#define SERCOM_I2CS_INTENCLR_PREC(value)      (SERCOM_I2CS_INTENCLR_PREC_Msk & ((value) << SERCOM_I2CS_INTENCLR_PREC_Pos))
#define SERCOM_I2CS_INTENCLR_AMATCH_Pos       _U_(1)                                               /**< (SERCOM_I2CS_INTENCLR) Address Match Interrupt Disable Position */
#define SERCOM_I2CS_INTENCLR_AMATCH_Msk       (_U_(0x1) << SERCOM_I2CS_INTENCLR_AMATCH_Pos)        /**< (SERCOM_I2CS_INTENCLR) Address Match Interrupt Disable Mask */
#define SERCOM_I2CS_INTENCLR_AMATCH(value)    (SERCOM_I2CS_INTENCLR_AMATCH_Msk & ((value) << SERCOM_I2CS_INTENCLR_AMATCH_Pos))
#define SERCOM_I2CS_INTENCLR_DRDY_Pos         _U_(2)                                               /**< (SERCOM_I2CS_INTENCLR) Data Interrupt Disable Position */
#define SERCOM_I2CS_INTENCLR_DRDY_Msk         (_U_(0x1) << SERCOM_I2CS_INTENCLR_DRDY_Pos)          /**< (SERCOM_I2CS_INTENCLR) Data Interrupt Disable Mask */
#define SERCOM_I2CS_INTENCLR_DRDY(value)      (SERCOM_I2CS_INTENCLR_DRDY_Msk & ((value) << SERCOM_I2CS_INTENCLR_DRDY_Pos))
#define SERCOM_I2CS_INTENCLR_ERROR_Pos        _U_(7)                                               /**< (SERCOM_I2CS_INTENCLR) Combined Error Interrupt Disable Position */
#define SERCOM_I2CS_INTENCLR_ERROR_Msk        (_U_(0x1) << SERCOM_I2CS_INTENCLR_ERROR_Pos)         /**< (SERCOM_I2CS_INTENCLR) Combined Error Interrupt Disable Mask */
#define SERCOM_I2CS_INTENCLR_ERROR(value)     (SERCOM_I2CS_INTENCLR_ERROR_Msk & ((value) << SERCOM_I2CS_INTENCLR_ERROR_Pos))
#define SERCOM_I2CS_INTENCLR_Msk              _U_(0x87)                                            /**< (SERCOM_I2CS_INTENCLR) Register Mask  */


/* -------- SERCOM_SPI_INTENCLR : (SERCOM Offset: 0x14) (R/W 8) SPI Interrupt Enable Clear -------- */
#define SERCOM_SPI_INTENCLR_RESETVALUE        _U_(0x00)                                            /**<  (SERCOM_SPI_INTENCLR) SPI Interrupt Enable Clear  Reset Value */

#define SERCOM_SPI_INTENCLR_DRE_Pos           _U_(0)                                               /**< (SERCOM_SPI_INTENCLR) Data Register Empty Interrupt Disable Position */
#define SERCOM_SPI_INTENCLR_DRE_Msk           (_U_(0x1) << SERCOM_SPI_INTENCLR_DRE_Pos)            /**< (SERCOM_SPI_INTENCLR) Data Register Empty Interrupt Disable Mask */
#define SERCOM_SPI_INTENCLR_DRE(value)        (SERCOM_SPI_INTENCLR_DRE_Msk & ((value) << SERCOM_SPI_INTENCLR_DRE_Pos))
#define SERCOM_SPI_INTENCLR_TXC_Pos           _U_(1)                                               /**< (SERCOM_SPI_INTENCLR) Transmit Complete Interrupt Disable Position */
#define SERCOM_SPI_INTENCLR_TXC_Msk           (_U_(0x1) << SERCOM_SPI_INTENCLR_TXC_Pos)            /**< (SERCOM_SPI_INTENCLR) Transmit Complete Interrupt Disable Mask */
#define SERCOM_SPI_INTENCLR_TXC(value)        (SERCOM_SPI_INTENCLR_TXC_Msk & ((value) << SERCOM_SPI_INTENCLR_TXC_Pos))
#define SERCOM_SPI_INTENCLR_RXC_Pos           _U_(2)                                               /**< (SERCOM_SPI_INTENCLR) Receive Complete Interrupt Disable Position */
#define SERCOM_SPI_INTENCLR_RXC_Msk           (_U_(0x1) << SERCOM_SPI_INTENCLR_RXC_Pos)            /**< (SERCOM_SPI_INTENCLR) Receive Complete Interrupt Disable Mask */
#define SERCOM_SPI_INTENCLR_RXC(value)        (SERCOM_SPI_INTENCLR_RXC_Msk & ((value) << SERCOM_SPI_INTENCLR_RXC_Pos))
#define SERCOM_SPI_INTENCLR_SSL_Pos           _U_(3)                                               /**< (SERCOM_SPI_INTENCLR) Slave Select Low Interrupt Disable Position */
#define SERCOM_SPI_INTENCLR_SSL_Msk           (_U_(0x1) << SERCOM_SPI_INTENCLR_SSL_Pos)            /**< (SERCOM_SPI_INTENCLR) Slave Select Low Interrupt Disable Mask */
#define SERCOM_SPI_INTENCLR_SSL(value)        (SERCOM_SPI_INTENCLR_SSL_Msk & ((value) << SERCOM_SPI_INTENCLR_SSL_Pos))
#define SERCOM_SPI_INTENCLR_ERROR_Pos         _U_(7)                                               /**< (SERCOM_SPI_INTENCLR) Combined Error Interrupt Disable Position */
#define SERCOM_SPI_INTENCLR_ERROR_Msk         (_U_(0x1) << SERCOM_SPI_INTENCLR_ERROR_Pos)          /**< (SERCOM_SPI_INTENCLR) Combined Error Interrupt Disable Mask */
#define SERCOM_SPI_INTENCLR_ERROR(value)      (SERCOM_SPI_INTENCLR_ERROR_Msk & ((value) << SERCOM_SPI_INTENCLR_ERROR_Pos))
#define SERCOM_SPI_INTENCLR_Msk               _U_(0x8F)                                            /**< (SERCOM_SPI_INTENCLR) Register Mask  */


/* -------- SERCOM_USART_INTENCLR : (SERCOM Offset: 0x14) (R/W 8) USART Interrupt Enable Clear -------- */
#define SERCOM_USART_INTENCLR_RESETVALUE      _U_(0x00)                                            /**<  (SERCOM_USART_INTENCLR) USART Interrupt Enable Clear  Reset Value */

#define SERCOM_USART_INTENCLR_DRE_Pos         _U_(0)                                               /**< (SERCOM_USART_INTENCLR) Data Register Empty Interrupt Disable Position */
#define SERCOM_USART_INTENCLR_DRE_Msk         (_U_(0x1) << SERCOM_USART_INTENCLR_DRE_Pos)          /**< (SERCOM_USART_INTENCLR) Data Register Empty Interrupt Disable Mask */
#define SERCOM_USART_INTENCLR_DRE(value)      (SERCOM_USART_INTENCLR_DRE_Msk & ((value) << SERCOM_USART_INTENCLR_DRE_Pos))
#define SERCOM_USART_INTENCLR_TXC_Pos         _U_(1)                                               /**< (SERCOM_USART_INTENCLR) Transmit Complete Interrupt Disable Position */
#define SERCOM_USART_INTENCLR_TXC_Msk         (_U_(0x1) << SERCOM_USART_INTENCLR_TXC_Pos)          /**< (SERCOM_USART_INTENCLR) Transmit Complete Interrupt Disable Mask */
#define SERCOM_USART_INTENCLR_TXC(value)      (SERCOM_USART_INTENCLR_TXC_Msk & ((value) << SERCOM_USART_INTENCLR_TXC_Pos))
#define SERCOM_USART_INTENCLR_RXC_Pos         _U_(2)                                               /**< (SERCOM_USART_INTENCLR) Receive Complete Interrupt Disable Position */
#define SERCOM_USART_INTENCLR_RXC_Msk         (_U_(0x1) << SERCOM_USART_INTENCLR_RXC_Pos)          /**< (SERCOM_USART_INTENCLR) Receive Complete Interrupt Disable Mask */
#define SERCOM_USART_INTENCLR_RXC(value)      (SERCOM_USART_INTENCLR_RXC_Msk & ((value) << SERCOM_USART_INTENCLR_RXC_Pos))
#define SERCOM_USART_INTENCLR_RXS_Pos         _U_(3)                                               /**< (SERCOM_USART_INTENCLR) Receive Start Interrupt Disable Position */
#define SERCOM_USART_INTENCLR_RXS_Msk         (_U_(0x1) << SERCOM_USART_INTENCLR_RXS_Pos)          /**< (SERCOM_USART_INTENCLR) Receive Start Interrupt Disable Mask */
#define SERCOM_USART_INTENCLR_RXS(value)      (SERCOM_USART_INTENCLR_RXS_Msk & ((value) << SERCOM_USART_INTENCLR_RXS_Pos))
#define SERCOM_USART_INTENCLR_CTSIC_Pos       _U_(4)                                               /**< (SERCOM_USART_INTENCLR) Clear To Send Input Change Interrupt Disable Position */
#define SERCOM_USART_INTENCLR_CTSIC_Msk       (_U_(0x1) << SERCOM_USART_INTENCLR_CTSIC_Pos)        /**< (SERCOM_USART_INTENCLR) Clear To Send Input Change Interrupt Disable Mask */
#define SERCOM_USART_INTENCLR_CTSIC(value)    (SERCOM_USART_INTENCLR_CTSIC_Msk & ((value) << SERCOM_USART_INTENCLR_CTSIC_Pos))
#define SERCOM_USART_INTENCLR_RXBRK_Pos       _U_(5)                                               /**< (SERCOM_USART_INTENCLR) Break Received Interrupt Disable Position */
#define SERCOM_USART_INTENCLR_RXBRK_Msk       (_U_(0x1) << SERCOM_USART_INTENCLR_RXBRK_Pos)        /**< (SERCOM_USART_INTENCLR) Break Received Interrupt Disable Mask */
#define SERCOM_USART_INTENCLR_RXBRK(value)    (SERCOM_USART_INTENCLR_RXBRK_Msk & ((value) << SERCOM_USART_INTENCLR_RXBRK_Pos))
#define SERCOM_USART_INTENCLR_ERROR_Pos       _U_(7)                                               /**< (SERCOM_USART_INTENCLR) Combined Error Interrupt Disable Position */
#define SERCOM_USART_INTENCLR_ERROR_Msk       (_U_(0x1) << SERCOM_USART_INTENCLR_ERROR_Pos)        /**< (SERCOM_USART_INTENCLR) Combined Error Interrupt Disable Mask */
#define SERCOM_USART_INTENCLR_ERROR(value)    (SERCOM_USART_INTENCLR_ERROR_Msk & ((value) << SERCOM_USART_INTENCLR_ERROR_Pos))
#define SERCOM_USART_INTENCLR_Msk             _U_(0xBF)                                            /**< (SERCOM_USART_INTENCLR) Register Mask  */


/* -------- SERCOM_I2CM_INTENSET : (SERCOM Offset: 0x16) (R/W 8) I2CM Interrupt Enable Set -------- */
#define SERCOM_I2CM_INTENSET_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_I2CM_INTENSET) I2CM Interrupt Enable Set  Reset Value */

#define SERCOM_I2CM_INTENSET_MB_Pos           _U_(0)                                               /**< (SERCOM_I2CM_INTENSET) Master On Bus Interrupt Enable Position */
#define SERCOM_I2CM_INTENSET_MB_Msk           (_U_(0x1) << SERCOM_I2CM_INTENSET_MB_Pos)            /**< (SERCOM_I2CM_INTENSET) Master On Bus Interrupt Enable Mask */
#define SERCOM_I2CM_INTENSET_MB(value)        (SERCOM_I2CM_INTENSET_MB_Msk & ((value) << SERCOM_I2CM_INTENSET_MB_Pos))
#define SERCOM_I2CM_INTENSET_SB_Pos           _U_(1)                                               /**< (SERCOM_I2CM_INTENSET) Slave On Bus Interrupt Enable Position */
#define SERCOM_I2CM_INTENSET_SB_Msk           (_U_(0x1) << SERCOM_I2CM_INTENSET_SB_Pos)            /**< (SERCOM_I2CM_INTENSET) Slave On Bus Interrupt Enable Mask */
#define SERCOM_I2CM_INTENSET_SB(value)        (SERCOM_I2CM_INTENSET_SB_Msk & ((value) << SERCOM_I2CM_INTENSET_SB_Pos))
#define SERCOM_I2CM_INTENSET_ERROR_Pos        _U_(7)                                               /**< (SERCOM_I2CM_INTENSET) Combined Error Interrupt Enable Position */
#define SERCOM_I2CM_INTENSET_ERROR_Msk        (_U_(0x1) << SERCOM_I2CM_INTENSET_ERROR_Pos)         /**< (SERCOM_I2CM_INTENSET) Combined Error Interrupt Enable Mask */
#define SERCOM_I2CM_INTENSET_ERROR(value)     (SERCOM_I2CM_INTENSET_ERROR_Msk & ((value) << SERCOM_I2CM_INTENSET_ERROR_Pos))
#define SERCOM_I2CM_INTENSET_Msk              _U_(0x83)                                            /**< (SERCOM_I2CM_INTENSET) Register Mask  */


/* -------- SERCOM_I2CS_INTENSET : (SERCOM Offset: 0x16) (R/W 8) I2CS Interrupt Enable Set -------- */
#define SERCOM_I2CS_INTENSET_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_I2CS_INTENSET) I2CS Interrupt Enable Set  Reset Value */

#define SERCOM_I2CS_INTENSET_PREC_Pos         _U_(0)                                               /**< (SERCOM_I2CS_INTENSET) Stop Received Interrupt Enable Position */
#define SERCOM_I2CS_INTENSET_PREC_Msk         (_U_(0x1) << SERCOM_I2CS_INTENSET_PREC_Pos)          /**< (SERCOM_I2CS_INTENSET) Stop Received Interrupt Enable Mask */
#define SERCOM_I2CS_INTENSET_PREC(value)      (SERCOM_I2CS_INTENSET_PREC_Msk & ((value) << SERCOM_I2CS_INTENSET_PREC_Pos))
#define SERCOM_I2CS_INTENSET_AMATCH_Pos       _U_(1)                                               /**< (SERCOM_I2CS_INTENSET) Address Match Interrupt Enable Position */
#define SERCOM_I2CS_INTENSET_AMATCH_Msk       (_U_(0x1) << SERCOM_I2CS_INTENSET_AMATCH_Pos)        /**< (SERCOM_I2CS_INTENSET) Address Match Interrupt Enable Mask */
#define SERCOM_I2CS_INTENSET_AMATCH(value)    (SERCOM_I2CS_INTENSET_AMATCH_Msk & ((value) << SERCOM_I2CS_INTENSET_AMATCH_Pos))
#define SERCOM_I2CS_INTENSET_DRDY_Pos         _U_(2)                                               /**< (SERCOM_I2CS_INTENSET) Data Interrupt Enable Position */
#define SERCOM_I2CS_INTENSET_DRDY_Msk         (_U_(0x1) << SERCOM_I2CS_INTENSET_DRDY_Pos)          /**< (SERCOM_I2CS_INTENSET) Data Interrupt Enable Mask */
#define SERCOM_I2CS_INTENSET_DRDY(value)      (SERCOM_I2CS_INTENSET_DRDY_Msk & ((value) << SERCOM_I2CS_INTENSET_DRDY_Pos))
#define SERCOM_I2CS_INTENSET_ERROR_Pos        _U_(7)                                               /**< (SERCOM_I2CS_INTENSET) Combined Error Interrupt Enable Position */
#define SERCOM_I2CS_INTENSET_ERROR_Msk        (_U_(0x1) << SERCOM_I2CS_INTENSET_ERROR_Pos)         /**< (SERCOM_I2CS_INTENSET) Combined Error Interrupt Enable Mask */
#define SERCOM_I2CS_INTENSET_ERROR(value)     (SERCOM_I2CS_INTENSET_ERROR_Msk & ((value) << SERCOM_I2CS_INTENSET_ERROR_Pos))
#define SERCOM_I2CS_INTENSET_Msk              _U_(0x87)                                            /**< (SERCOM_I2CS_INTENSET) Register Mask  */


/* -------- SERCOM_SPI_INTENSET : (SERCOM Offset: 0x16) (R/W 8) SPI Interrupt Enable Set -------- */
#define SERCOM_SPI_INTENSET_RESETVALUE        _U_(0x00)                                            /**<  (SERCOM_SPI_INTENSET) SPI Interrupt Enable Set  Reset Value */

#define SERCOM_SPI_INTENSET_DRE_Pos           _U_(0)                                               /**< (SERCOM_SPI_INTENSET) Data Register Empty Interrupt Enable Position */
#define SERCOM_SPI_INTENSET_DRE_Msk           (_U_(0x1) << SERCOM_SPI_INTENSET_DRE_Pos)            /**< (SERCOM_SPI_INTENSET) Data Register Empty Interrupt Enable Mask */
#define SERCOM_SPI_INTENSET_DRE(value)        (SERCOM_SPI_INTENSET_DRE_Msk & ((value) << SERCOM_SPI_INTENSET_DRE_Pos))
#define SERCOM_SPI_INTENSET_TXC_Pos           _U_(1)                                               /**< (SERCOM_SPI_INTENSET) Transmit Complete Interrupt Enable Position */
#define SERCOM_SPI_INTENSET_TXC_Msk           (_U_(0x1) << SERCOM_SPI_INTENSET_TXC_Pos)            /**< (SERCOM_SPI_INTENSET) Transmit Complete Interrupt Enable Mask */
#define SERCOM_SPI_INTENSET_TXC(value)        (SERCOM_SPI_INTENSET_TXC_Msk & ((value) << SERCOM_SPI_INTENSET_TXC_Pos))
#define SERCOM_SPI_INTENSET_RXC_Pos           _U_(2)                                               /**< (SERCOM_SPI_INTENSET) Receive Complete Interrupt Enable Position */
#define SERCOM_SPI_INTENSET_RXC_Msk           (_U_(0x1) << SERCOM_SPI_INTENSET_RXC_Pos)            /**< (SERCOM_SPI_INTENSET) Receive Complete Interrupt Enable Mask */
#define SERCOM_SPI_INTENSET_RXC(value)        (SERCOM_SPI_INTENSET_RXC_Msk & ((value) << SERCOM_SPI_INTENSET_RXC_Pos))
#define SERCOM_SPI_INTENSET_SSL_Pos           _U_(3)                                               /**< (SERCOM_SPI_INTENSET) Slave Select Low Interrupt Enable Position */
#define SERCOM_SPI_INTENSET_SSL_Msk           (_U_(0x1) << SERCOM_SPI_INTENSET_SSL_Pos)            /**< (SERCOM_SPI_INTENSET) Slave Select Low Interrupt Enable Mask */
#define SERCOM_SPI_INTENSET_SSL(value)        (SERCOM_SPI_INTENSET_SSL_Msk & ((value) << SERCOM_SPI_INTENSET_SSL_Pos))
#define SERCOM_SPI_INTENSET_ERROR_Pos         _U_(7)                                               /**< (SERCOM_SPI_INTENSET) Combined Error Interrupt Enable Position */
#define SERCOM_SPI_INTENSET_ERROR_Msk         (_U_(0x1) << SERCOM_SPI_INTENSET_ERROR_Pos)          /**< (SERCOM_SPI_INTENSET) Combined Error Interrupt Enable Mask */
#define SERCOM_SPI_INTENSET_ERROR(value)      (SERCOM_SPI_INTENSET_ERROR_Msk & ((value) << SERCOM_SPI_INTENSET_ERROR_Pos))
#define SERCOM_SPI_INTENSET_Msk               _U_(0x8F)                                            /**< (SERCOM_SPI_INTENSET) Register Mask  */


/* -------- SERCOM_USART_INTENSET : (SERCOM Offset: 0x16) (R/W 8) USART Interrupt Enable Set -------- */
#define SERCOM_USART_INTENSET_RESETVALUE      _U_(0x00)                                            /**<  (SERCOM_USART_INTENSET) USART Interrupt Enable Set  Reset Value */

#define SERCOM_USART_INTENSET_DRE_Pos         _U_(0)                                               /**< (SERCOM_USART_INTENSET) Data Register Empty Interrupt Enable Position */
#define SERCOM_USART_INTENSET_DRE_Msk         (_U_(0x1) << SERCOM_USART_INTENSET_DRE_Pos)          /**< (SERCOM_USART_INTENSET) Data Register Empty Interrupt Enable Mask */
#define SERCOM_USART_INTENSET_DRE(value)      (SERCOM_USART_INTENSET_DRE_Msk & ((value) << SERCOM_USART_INTENSET_DRE_Pos))
#define SERCOM_USART_INTENSET_TXC_Pos         _U_(1)                                               /**< (SERCOM_USART_INTENSET) Transmit Complete Interrupt Enable Position */
#define SERCOM_USART_INTENSET_TXC_Msk         (_U_(0x1) << SERCOM_USART_INTENSET_TXC_Pos)          /**< (SERCOM_USART_INTENSET) Transmit Complete Interrupt Enable Mask */
#define SERCOM_USART_INTENSET_TXC(value)      (SERCOM_USART_INTENSET_TXC_Msk & ((value) << SERCOM_USART_INTENSET_TXC_Pos))
#define SERCOM_USART_INTENSET_RXC_Pos         _U_(2)                                               /**< (SERCOM_USART_INTENSET) Receive Complete Interrupt Enable Position */
#define SERCOM_USART_INTENSET_RXC_Msk         (_U_(0x1) << SERCOM_USART_INTENSET_RXC_Pos)          /**< (SERCOM_USART_INTENSET) Receive Complete Interrupt Enable Mask */
#define SERCOM_USART_INTENSET_RXC(value)      (SERCOM_USART_INTENSET_RXC_Msk & ((value) << SERCOM_USART_INTENSET_RXC_Pos))
#define SERCOM_USART_INTENSET_RXS_Pos         _U_(3)                                               /**< (SERCOM_USART_INTENSET) Receive Start Interrupt Enable Position */
#define SERCOM_USART_INTENSET_RXS_Msk         (_U_(0x1) << SERCOM_USART_INTENSET_RXS_Pos)          /**< (SERCOM_USART_INTENSET) Receive Start Interrupt Enable Mask */
#define SERCOM_USART_INTENSET_RXS(value)      (SERCOM_USART_INTENSET_RXS_Msk & ((value) << SERCOM_USART_INTENSET_RXS_Pos))
#define SERCOM_USART_INTENSET_CTSIC_Pos       _U_(4)                                               /**< (SERCOM_USART_INTENSET) Clear To Send Input Change Interrupt Enable Position */
#define SERCOM_USART_INTENSET_CTSIC_Msk       (_U_(0x1) << SERCOM_USART_INTENSET_CTSIC_Pos)        /**< (SERCOM_USART_INTENSET) Clear To Send Input Change Interrupt Enable Mask */
#define SERCOM_USART_INTENSET_CTSIC(value)    (SERCOM_USART_INTENSET_CTSIC_Msk & ((value) << SERCOM_USART_INTENSET_CTSIC_Pos))
#define SERCOM_USART_INTENSET_RXBRK_Pos       _U_(5)                                               /**< (SERCOM_USART_INTENSET) Break Received Interrupt Enable Position */
#define SERCOM_USART_INTENSET_RXBRK_Msk       (_U_(0x1) << SERCOM_USART_INTENSET_RXBRK_Pos)        /**< (SERCOM_USART_INTENSET) Break Received Interrupt Enable Mask */
#define SERCOM_USART_INTENSET_RXBRK(value)    (SERCOM_USART_INTENSET_RXBRK_Msk & ((value) << SERCOM_USART_INTENSET_RXBRK_Pos))
#define SERCOM_USART_INTENSET_ERROR_Pos       _U_(7)                                               /**< (SERCOM_USART_INTENSET) Combined Error Interrupt Enable Position */
#define SERCOM_USART_INTENSET_ERROR_Msk       (_U_(0x1) << SERCOM_USART_INTENSET_ERROR_Pos)        /**< (SERCOM_USART_INTENSET) Combined Error Interrupt Enable Mask */
#define SERCOM_USART_INTENSET_ERROR(value)    (SERCOM_USART_INTENSET_ERROR_Msk & ((value) << SERCOM_USART_INTENSET_ERROR_Pos))
#define SERCOM_USART_INTENSET_Msk             _U_(0xBF)                                            /**< (SERCOM_USART_INTENSET) Register Mask  */


/* -------- SERCOM_I2CM_INTFLAG : (SERCOM Offset: 0x18) (R/W 8) I2CM Interrupt Flag Status and Clear -------- */
#define SERCOM_I2CM_INTFLAG_RESETVALUE        _U_(0x00)                                            /**<  (SERCOM_I2CM_INTFLAG) I2CM Interrupt Flag Status and Clear  Reset Value */

#define SERCOM_I2CM_INTFLAG_MB_Pos            _U_(0)                                               /**< (SERCOM_I2CM_INTFLAG) Master On Bus Interrupt Position */
#define SERCOM_I2CM_INTFLAG_MB_Msk            (_U_(0x1) << SERCOM_I2CM_INTFLAG_MB_Pos)             /**< (SERCOM_I2CM_INTFLAG) Master On Bus Interrupt Mask */
#define SERCOM_I2CM_INTFLAG_MB(value)         (SERCOM_I2CM_INTFLAG_MB_Msk & ((value) << SERCOM_I2CM_INTFLAG_MB_Pos))
#define SERCOM_I2CM_INTFLAG_SB_Pos            _U_(1)                                               /**< (SERCOM_I2CM_INTFLAG) Slave On Bus Interrupt Position */
#define SERCOM_I2CM_INTFLAG_SB_Msk            (_U_(0x1) << SERCOM_I2CM_INTFLAG_SB_Pos)             /**< (SERCOM_I2CM_INTFLAG) Slave On Bus Interrupt Mask */
#define SERCOM_I2CM_INTFLAG_SB(value)         (SERCOM_I2CM_INTFLAG_SB_Msk & ((value) << SERCOM_I2CM_INTFLAG_SB_Pos))
#define SERCOM_I2CM_INTFLAG_ERROR_Pos         _U_(7)                                               /**< (SERCOM_I2CM_INTFLAG) Combined Error Interrupt Position */
#define SERCOM_I2CM_INTFLAG_ERROR_Msk         (_U_(0x1) << SERCOM_I2CM_INTFLAG_ERROR_Pos)          /**< (SERCOM_I2CM_INTFLAG) Combined Error Interrupt Mask */
#define SERCOM_I2CM_INTFLAG_ERROR(value)      (SERCOM_I2CM_INTFLAG_ERROR_Msk & ((value) << SERCOM_I2CM_INTFLAG_ERROR_Pos))
#define SERCOM_I2CM_INTFLAG_Msk               _U_(0x83)                                            /**< (SERCOM_I2CM_INTFLAG) Register Mask  */


/* -------- SERCOM_I2CS_INTFLAG : (SERCOM Offset: 0x18) (R/W 8) I2CS Interrupt Flag Status and Clear -------- */
#define SERCOM_I2CS_INTFLAG_RESETVALUE        _U_(0x00)                                            /**<  (SERCOM_I2CS_INTFLAG) I2CS Interrupt Flag Status and Clear  Reset Value */

#define SERCOM_I2CS_INTFLAG_PREC_Pos          _U_(0)                                               /**< (SERCOM_I2CS_INTFLAG) Stop Received Interrupt Position */
#define SERCOM_I2CS_INTFLAG_PREC_Msk          (_U_(0x1) << SERCOM_I2CS_INTFLAG_PREC_Pos)           /**< (SERCOM_I2CS_INTFLAG) Stop Received Interrupt Mask */
#define SERCOM_I2CS_INTFLAG_PREC(value)       (SERCOM_I2CS_INTFLAG_PREC_Msk & ((value) << SERCOM_I2CS_INTFLAG_PREC_Pos))
#define SERCOM_I2CS_INTFLAG_AMATCH_Pos        _U_(1)                                               /**< (SERCOM_I2CS_INTFLAG) Address Match Interrupt Position */
#define SERCOM_I2CS_INTFLAG_AMATCH_Msk        (_U_(0x1) << SERCOM_I2CS_INTFLAG_AMATCH_Pos)         /**< (SERCOM_I2CS_INTFLAG) Address Match Interrupt Mask */
#define SERCOM_I2CS_INTFLAG_AMATCH(value)     (SERCOM_I2CS_INTFLAG_AMATCH_Msk & ((value) << SERCOM_I2CS_INTFLAG_AMATCH_Pos))
#define SERCOM_I2CS_INTFLAG_DRDY_Pos          _U_(2)                                               /**< (SERCOM_I2CS_INTFLAG) Data Interrupt Position */
#define SERCOM_I2CS_INTFLAG_DRDY_Msk          (_U_(0x1) << SERCOM_I2CS_INTFLAG_DRDY_Pos)           /**< (SERCOM_I2CS_INTFLAG) Data Interrupt Mask */
#define SERCOM_I2CS_INTFLAG_DRDY(value)       (SERCOM_I2CS_INTFLAG_DRDY_Msk & ((value) << SERCOM_I2CS_INTFLAG_DRDY_Pos))
#define SERCOM_I2CS_INTFLAG_ERROR_Pos         _U_(7)                                               /**< (SERCOM_I2CS_INTFLAG) Combined Error Interrupt Position */
#define SERCOM_I2CS_INTFLAG_ERROR_Msk         (_U_(0x1) << SERCOM_I2CS_INTFLAG_ERROR_Pos)          /**< (SERCOM_I2CS_INTFLAG) Combined Error Interrupt Mask */
#define SERCOM_I2CS_INTFLAG_ERROR(value)      (SERCOM_I2CS_INTFLAG_ERROR_Msk & ((value) << SERCOM_I2CS_INTFLAG_ERROR_Pos))
#define SERCOM_I2CS_INTFLAG_Msk               _U_(0x87)                                            /**< (SERCOM_I2CS_INTFLAG) Register Mask  */


/* -------- SERCOM_SPI_INTFLAG : (SERCOM Offset: 0x18) (R/W 8) SPI Interrupt Flag Status and Clear -------- */
#define SERCOM_SPI_INTFLAG_RESETVALUE         _U_(0x00)                                            /**<  (SERCOM_SPI_INTFLAG) SPI Interrupt Flag Status and Clear  Reset Value */

#define SERCOM_SPI_INTFLAG_DRE_Pos            _U_(0)                                               /**< (SERCOM_SPI_INTFLAG) Data Register Empty Interrupt Position */
#define SERCOM_SPI_INTFLAG_DRE_Msk            (_U_(0x1) << SERCOM_SPI_INTFLAG_DRE_Pos)             /**< (SERCOM_SPI_INTFLAG) Data Register Empty Interrupt Mask */
#define SERCOM_SPI_INTFLAG_DRE(value)         (SERCOM_SPI_INTFLAG_DRE_Msk & ((value) << SERCOM_SPI_INTFLAG_DRE_Pos))
#define SERCOM_SPI_INTFLAG_TXC_Pos            _U_(1)                                               /**< (SERCOM_SPI_INTFLAG) Transmit Complete Interrupt Position */
#define SERCOM_SPI_INTFLAG_TXC_Msk            (_U_(0x1) << SERCOM_SPI_INTFLAG_TXC_Pos)             /**< (SERCOM_SPI_INTFLAG) Transmit Complete Interrupt Mask */
#define SERCOM_SPI_INTFLAG_TXC(value)         (SERCOM_SPI_INTFLAG_TXC_Msk & ((value) << SERCOM_SPI_INTFLAG_TXC_Pos))
#define SERCOM_SPI_INTFLAG_RXC_Pos            _U_(2)                                               /**< (SERCOM_SPI_INTFLAG) Receive Complete Interrupt Position */
#define SERCOM_SPI_INTFLAG_RXC_Msk            (_U_(0x1) << SERCOM_SPI_INTFLAG_RXC_Pos)             /**< (SERCOM_SPI_INTFLAG) Receive Complete Interrupt Mask */
#define SERCOM_SPI_INTFLAG_RXC(value)         (SERCOM_SPI_INTFLAG_RXC_Msk & ((value) << SERCOM_SPI_INTFLAG_RXC_Pos))
#define SERCOM_SPI_INTFLAG_SSL_Pos            _U_(3)                                               /**< (SERCOM_SPI_INTFLAG) Slave Select Low Interrupt Flag Position */
#define SERCOM_SPI_INTFLAG_SSL_Msk            (_U_(0x1) << SERCOM_SPI_INTFLAG_SSL_Pos)             /**< (SERCOM_SPI_INTFLAG) Slave Select Low Interrupt Flag Mask */
#define SERCOM_SPI_INTFLAG_SSL(value)         (SERCOM_SPI_INTFLAG_SSL_Msk & ((value) << SERCOM_SPI_INTFLAG_SSL_Pos))
#define SERCOM_SPI_INTFLAG_ERROR_Pos          _U_(7)                                               /**< (SERCOM_SPI_INTFLAG) Combined Error Interrupt Position */
#define SERCOM_SPI_INTFLAG_ERROR_Msk          (_U_(0x1) << SERCOM_SPI_INTFLAG_ERROR_Pos)           /**< (SERCOM_SPI_INTFLAG) Combined Error Interrupt Mask */
#define SERCOM_SPI_INTFLAG_ERROR(value)       (SERCOM_SPI_INTFLAG_ERROR_Msk & ((value) << SERCOM_SPI_INTFLAG_ERROR_Pos))
#define SERCOM_SPI_INTFLAG_Msk                _U_(0x8F)                                            /**< (SERCOM_SPI_INTFLAG) Register Mask  */


/* -------- SERCOM_USART_INTFLAG : (SERCOM Offset: 0x18) (R/W 8) USART Interrupt Flag Status and Clear -------- */
#define SERCOM_USART_INTFLAG_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_USART_INTFLAG) USART Interrupt Flag Status and Clear  Reset Value */

#define SERCOM_USART_INTFLAG_DRE_Pos          _U_(0)                                               /**< (SERCOM_USART_INTFLAG) Data Register Empty Interrupt Position */
#define SERCOM_USART_INTFLAG_DRE_Msk          (_U_(0x1) << SERCOM_USART_INTFLAG_DRE_Pos)           /**< (SERCOM_USART_INTFLAG) Data Register Empty Interrupt Mask */
#define SERCOM_USART_INTFLAG_DRE(value)       (SERCOM_USART_INTFLAG_DRE_Msk & ((value) << SERCOM_USART_INTFLAG_DRE_Pos))
#define SERCOM_USART_INTFLAG_TXC_Pos          _U_(1)                                               /**< (SERCOM_USART_INTFLAG) Transmit Complete Interrupt Position */
#define SERCOM_USART_INTFLAG_TXC_Msk          (_U_(0x1) << SERCOM_USART_INTFLAG_TXC_Pos)           /**< (SERCOM_USART_INTFLAG) Transmit Complete Interrupt Mask */
#define SERCOM_USART_INTFLAG_TXC(value)       (SERCOM_USART_INTFLAG_TXC_Msk & ((value) << SERCOM_USART_INTFLAG_TXC_Pos))
#define SERCOM_USART_INTFLAG_RXC_Pos          _U_(2)                                               /**< (SERCOM_USART_INTFLAG) Receive Complete Interrupt Position */
#define SERCOM_USART_INTFLAG_RXC_Msk          (_U_(0x1) << SERCOM_USART_INTFLAG_RXC_Pos)           /**< (SERCOM_USART_INTFLAG) Receive Complete Interrupt Mask */
#define SERCOM_USART_INTFLAG_RXC(value)       (SERCOM_USART_INTFLAG_RXC_Msk & ((value) << SERCOM_USART_INTFLAG_RXC_Pos))
#define SERCOM_USART_INTFLAG_RXS_Pos          _U_(3)                                               /**< (SERCOM_USART_INTFLAG) Receive Start Interrupt Position */
#define SERCOM_USART_INTFLAG_RXS_Msk          (_U_(0x1) << SERCOM_USART_INTFLAG_RXS_Pos)           /**< (SERCOM_USART_INTFLAG) Receive Start Interrupt Mask */
#define SERCOM_USART_INTFLAG_RXS(value)       (SERCOM_USART_INTFLAG_RXS_Msk & ((value) << SERCOM_USART_INTFLAG_RXS_Pos))
#define SERCOM_USART_INTFLAG_CTSIC_Pos        _U_(4)                                               /**< (SERCOM_USART_INTFLAG) Clear To Send Input Change Interrupt Position */
#define SERCOM_USART_INTFLAG_CTSIC_Msk        (_U_(0x1) << SERCOM_USART_INTFLAG_CTSIC_Pos)         /**< (SERCOM_USART_INTFLAG) Clear To Send Input Change Interrupt Mask */
#define SERCOM_USART_INTFLAG_CTSIC(value)     (SERCOM_USART_INTFLAG_CTSIC_Msk & ((value) << SERCOM_USART_INTFLAG_CTSIC_Pos))
#define SERCOM_USART_INTFLAG_RXBRK_Pos        _U_(5)                                               /**< (SERCOM_USART_INTFLAG) Break Received Interrupt Position */
#define SERCOM_USART_INTFLAG_RXBRK_Msk        (_U_(0x1) << SERCOM_USART_INTFLAG_RXBRK_Pos)         /**< (SERCOM_USART_INTFLAG) Break Received Interrupt Mask */
#define SERCOM_USART_INTFLAG_RXBRK(value)     (SERCOM_USART_INTFLAG_RXBRK_Msk & ((value) << SERCOM_USART_INTFLAG_RXBRK_Pos))
#define SERCOM_USART_INTFLAG_ERROR_Pos        _U_(7)                                               /**< (SERCOM_USART_INTFLAG) Combined Error Interrupt Position */
#define SERCOM_USART_INTFLAG_ERROR_Msk        (_U_(0x1) << SERCOM_USART_INTFLAG_ERROR_Pos)         /**< (SERCOM_USART_INTFLAG) Combined Error Interrupt Mask */
#define SERCOM_USART_INTFLAG_ERROR(value)     (SERCOM_USART_INTFLAG_ERROR_Msk & ((value) << SERCOM_USART_INTFLAG_ERROR_Pos))
#define SERCOM_USART_INTFLAG_Msk              _U_(0xBF)                                            /**< (SERCOM_USART_INTFLAG) Register Mask  */


/* -------- SERCOM_I2CM_STATUS : (SERCOM Offset: 0x1A) (R/W 16) I2CM Status -------- */
#define SERCOM_I2CM_STATUS_RESETVALUE         _U_(0x00)                                            /**<  (SERCOM_I2CM_STATUS) I2CM Status  Reset Value */

#define SERCOM_I2CM_STATUS_BUSERR_Pos         _U_(0)                                               /**< (SERCOM_I2CM_STATUS) Bus Error Position */
#define SERCOM_I2CM_STATUS_BUSERR_Msk         (_U_(0x1) << SERCOM_I2CM_STATUS_BUSERR_Pos)          /**< (SERCOM_I2CM_STATUS) Bus Error Mask */
#define SERCOM_I2CM_STATUS_BUSERR(value)      (SERCOM_I2CM_STATUS_BUSERR_Msk & ((value) << SERCOM_I2CM_STATUS_BUSERR_Pos))
#define SERCOM_I2CM_STATUS_ARBLOST_Pos        _U_(1)                                               /**< (SERCOM_I2CM_STATUS) Arbitration Lost Position */
#define SERCOM_I2CM_STATUS_ARBLOST_Msk        (_U_(0x1) << SERCOM_I2CM_STATUS_ARBLOST_Pos)         /**< (SERCOM_I2CM_STATUS) Arbitration Lost Mask */
#define SERCOM_I2CM_STATUS_ARBLOST(value)     (SERCOM_I2CM_STATUS_ARBLOST_Msk & ((value) << SERCOM_I2CM_STATUS_ARBLOST_Pos))
#define SERCOM_I2CM_STATUS_RXNACK_Pos         _U_(2)                                               /**< (SERCOM_I2CM_STATUS) Received Not Acknowledge Position */
#define SERCOM_I2CM_STATUS_RXNACK_Msk         (_U_(0x1) << SERCOM_I2CM_STATUS_RXNACK_Pos)          /**< (SERCOM_I2CM_STATUS) Received Not Acknowledge Mask */
#define SERCOM_I2CM_STATUS_RXNACK(value)      (SERCOM_I2CM_STATUS_RXNACK_Msk & ((value) << SERCOM_I2CM_STATUS_RXNACK_Pos))
#define SERCOM_I2CM_STATUS_BUSSTATE_Pos       _U_(4)                                               /**< (SERCOM_I2CM_STATUS) Bus State Position */
#define SERCOM_I2CM_STATUS_BUSSTATE_Msk       (_U_(0x3) << SERCOM_I2CM_STATUS_BUSSTATE_Pos)        /**< (SERCOM_I2CM_STATUS) Bus State Mask */
#define SERCOM_I2CM_STATUS_BUSSTATE(value)    (SERCOM_I2CM_STATUS_BUSSTATE_Msk & ((value) << SERCOM_I2CM_STATUS_BUSSTATE_Pos))
#define SERCOM_I2CM_STATUS_LOWTOUT_Pos        _U_(6)                                               /**< (SERCOM_I2CM_STATUS) SCL Low Timeout Position */
#define SERCOM_I2CM_STATUS_LOWTOUT_Msk        (_U_(0x1) << SERCOM_I2CM_STATUS_LOWTOUT_Pos)         /**< (SERCOM_I2CM_STATUS) SCL Low Timeout Mask */
#define SERCOM_I2CM_STATUS_LOWTOUT(value)     (SERCOM_I2CM_STATUS_LOWTOUT_Msk & ((value) << SERCOM_I2CM_STATUS_LOWTOUT_Pos))
#define SERCOM_I2CM_STATUS_CLKHOLD_Pos        _U_(7)                                               /**< (SERCOM_I2CM_STATUS) Clock Hold Position */
#define SERCOM_I2CM_STATUS_CLKHOLD_Msk        (_U_(0x1) << SERCOM_I2CM_STATUS_CLKHOLD_Pos)         /**< (SERCOM_I2CM_STATUS) Clock Hold Mask */
#define SERCOM_I2CM_STATUS_CLKHOLD(value)     (SERCOM_I2CM_STATUS_CLKHOLD_Msk & ((value) << SERCOM_I2CM_STATUS_CLKHOLD_Pos))
#define SERCOM_I2CM_STATUS_MEXTTOUT_Pos       _U_(8)                                               /**< (SERCOM_I2CM_STATUS) Master SCL Low Extend Timeout Position */
#define SERCOM_I2CM_STATUS_MEXTTOUT_Msk       (_U_(0x1) << SERCOM_I2CM_STATUS_MEXTTOUT_Pos)        /**< (SERCOM_I2CM_STATUS) Master SCL Low Extend Timeout Mask */
#define SERCOM_I2CM_STATUS_MEXTTOUT(value)    (SERCOM_I2CM_STATUS_MEXTTOUT_Msk & ((value) << SERCOM_I2CM_STATUS_MEXTTOUT_Pos))
#define SERCOM_I2CM_STATUS_SEXTTOUT_Pos       _U_(9)                                               /**< (SERCOM_I2CM_STATUS) Slave SCL Low Extend Timeout Position */
#define SERCOM_I2CM_STATUS_SEXTTOUT_Msk       (_U_(0x1) << SERCOM_I2CM_STATUS_SEXTTOUT_Pos)        /**< (SERCOM_I2CM_STATUS) Slave SCL Low Extend Timeout Mask */
#define SERCOM_I2CM_STATUS_SEXTTOUT(value)    (SERCOM_I2CM_STATUS_SEXTTOUT_Msk & ((value) << SERCOM_I2CM_STATUS_SEXTTOUT_Pos))
#define SERCOM_I2CM_STATUS_LENERR_Pos         _U_(10)                                              /**< (SERCOM_I2CM_STATUS) Length Error Position */
#define SERCOM_I2CM_STATUS_LENERR_Msk         (_U_(0x1) << SERCOM_I2CM_STATUS_LENERR_Pos)          /**< (SERCOM_I2CM_STATUS) Length Error Mask */
#define SERCOM_I2CM_STATUS_LENERR(value)      (SERCOM_I2CM_STATUS_LENERR_Msk & ((value) << SERCOM_I2CM_STATUS_LENERR_Pos))
#define SERCOM_I2CM_STATUS_Msk                _U_(0x07F7)                                          /**< (SERCOM_I2CM_STATUS) Register Mask  */


/* -------- SERCOM_I2CS_STATUS : (SERCOM Offset: 0x1A) (R/W 16) I2CS Status -------- */
#define SERCOM_I2CS_STATUS_RESETVALUE         _U_(0x00)                                            /**<  (SERCOM_I2CS_STATUS) I2CS Status  Reset Value */

#define SERCOM_I2CS_STATUS_BUSERR_Pos         _U_(0)                                               /**< (SERCOM_I2CS_STATUS) Bus Error Position */
#define SERCOM_I2CS_STATUS_BUSERR_Msk         (_U_(0x1) << SERCOM_I2CS_STATUS_BUSERR_Pos)          /**< (SERCOM_I2CS_STATUS) Bus Error Mask */
#define SERCOM_I2CS_STATUS_BUSERR(value)      (SERCOM_I2CS_STATUS_BUSERR_Msk & ((value) << SERCOM_I2CS_STATUS_BUSERR_Pos))
#define SERCOM_I2CS_STATUS_COLL_Pos           _U_(1)                                               /**< (SERCOM_I2CS_STATUS) Transmit Collision Position */
#define SERCOM_I2CS_STATUS_COLL_Msk           (_U_(0x1) << SERCOM_I2CS_STATUS_COLL_Pos)            /**< (SERCOM_I2CS_STATUS) Transmit Collision Mask */
#define SERCOM_I2CS_STATUS_COLL(value)        (SERCOM_I2CS_STATUS_COLL_Msk & ((value) << SERCOM_I2CS_STATUS_COLL_Pos))
#define SERCOM_I2CS_STATUS_RXNACK_Pos         _U_(2)                                               /**< (SERCOM_I2CS_STATUS) Received Not Acknowledge Position */
#define SERCOM_I2CS_STATUS_RXNACK_Msk         (_U_(0x1) << SERCOM_I2CS_STATUS_RXNACK_Pos)          /**< (SERCOM_I2CS_STATUS) Received Not Acknowledge Mask */
#define SERCOM_I2CS_STATUS_RXNACK(value)      (SERCOM_I2CS_STATUS_RXNACK_Msk & ((value) << SERCOM_I2CS_STATUS_RXNACK_Pos))
#define SERCOM_I2CS_STATUS_DIR_Pos            _U_(3)                                               /**< (SERCOM_I2CS_STATUS) Read/Write Direction Position */
#define SERCOM_I2CS_STATUS_DIR_Msk            (_U_(0x1) << SERCOM_I2CS_STATUS_DIR_Pos)             /**< (SERCOM_I2CS_STATUS) Read/Write Direction Mask */
#define SERCOM_I2CS_STATUS_DIR(value)         (SERCOM_I2CS_STATUS_DIR_Msk & ((value) << SERCOM_I2CS_STATUS_DIR_Pos))
#define SERCOM_I2CS_STATUS_SR_Pos             _U_(4)                                               /**< (SERCOM_I2CS_STATUS) Repeated Start Position */
#define SERCOM_I2CS_STATUS_SR_Msk             (_U_(0x1) << SERCOM_I2CS_STATUS_SR_Pos)              /**< (SERCOM_I2CS_STATUS) Repeated Start Mask */
#define SERCOM_I2CS_STATUS_SR(value)          (SERCOM_I2CS_STATUS_SR_Msk & ((value) << SERCOM_I2CS_STATUS_SR_Pos))
#define SERCOM_I2CS_STATUS_LOWTOUT_Pos        _U_(6)                                               /**< (SERCOM_I2CS_STATUS) SCL Low Timeout Position */
#define SERCOM_I2CS_STATUS_LOWTOUT_Msk        (_U_(0x1) << SERCOM_I2CS_STATUS_LOWTOUT_Pos)         /**< (SERCOM_I2CS_STATUS) SCL Low Timeout Mask */
#define SERCOM_I2CS_STATUS_LOWTOUT(value)     (SERCOM_I2CS_STATUS_LOWTOUT_Msk & ((value) << SERCOM_I2CS_STATUS_LOWTOUT_Pos))
#define SERCOM_I2CS_STATUS_CLKHOLD_Pos        _U_(7)                                               /**< (SERCOM_I2CS_STATUS) Clock Hold Position */
#define SERCOM_I2CS_STATUS_CLKHOLD_Msk        (_U_(0x1) << SERCOM_I2CS_STATUS_CLKHOLD_Pos)         /**< (SERCOM_I2CS_STATUS) Clock Hold Mask */
#define SERCOM_I2CS_STATUS_CLKHOLD(value)     (SERCOM_I2CS_STATUS_CLKHOLD_Msk & ((value) << SERCOM_I2CS_STATUS_CLKHOLD_Pos))
#define SERCOM_I2CS_STATUS_SEXTTOUT_Pos       _U_(9)                                               /**< (SERCOM_I2CS_STATUS) Slave SCL Low Extend Timeout Position */
#define SERCOM_I2CS_STATUS_SEXTTOUT_Msk       (_U_(0x1) << SERCOM_I2CS_STATUS_SEXTTOUT_Pos)        /**< (SERCOM_I2CS_STATUS) Slave SCL Low Extend Timeout Mask */
#define SERCOM_I2CS_STATUS_SEXTTOUT(value)    (SERCOM_I2CS_STATUS_SEXTTOUT_Msk & ((value) << SERCOM_I2CS_STATUS_SEXTTOUT_Pos))
#define SERCOM_I2CS_STATUS_HS_Pos             _U_(10)                                              /**< (SERCOM_I2CS_STATUS) High Speed Position */
#define SERCOM_I2CS_STATUS_HS_Msk             (_U_(0x1) << SERCOM_I2CS_STATUS_HS_Pos)              /**< (SERCOM_I2CS_STATUS) High Speed Mask */
#define SERCOM_I2CS_STATUS_HS(value)          (SERCOM_I2CS_STATUS_HS_Msk & ((value) << SERCOM_I2CS_STATUS_HS_Pos))
#define SERCOM_I2CS_STATUS_Msk                _U_(0x06DF)                                          /**< (SERCOM_I2CS_STATUS) Register Mask  */


/* -------- SERCOM_SPI_STATUS : (SERCOM Offset: 0x1A) (R/W 16) SPI Status -------- */
#define SERCOM_SPI_STATUS_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_SPI_STATUS) SPI Status  Reset Value */

#define SERCOM_SPI_STATUS_BUFOVF_Pos          _U_(2)                                               /**< (SERCOM_SPI_STATUS) Buffer Overflow Position */
#define SERCOM_SPI_STATUS_BUFOVF_Msk          (_U_(0x1) << SERCOM_SPI_STATUS_BUFOVF_Pos)           /**< (SERCOM_SPI_STATUS) Buffer Overflow Mask */
#define SERCOM_SPI_STATUS_BUFOVF(value)       (SERCOM_SPI_STATUS_BUFOVF_Msk & ((value) << SERCOM_SPI_STATUS_BUFOVF_Pos))
#define SERCOM_SPI_STATUS_Msk                 _U_(0x0004)                                          /**< (SERCOM_SPI_STATUS) Register Mask  */


/* -------- SERCOM_USART_STATUS : (SERCOM Offset: 0x1A) (R/W 16) USART Status -------- */
#define SERCOM_USART_STATUS_RESETVALUE        _U_(0x00)                                            /**<  (SERCOM_USART_STATUS) USART Status  Reset Value */

#define SERCOM_USART_STATUS_PERR_Pos          _U_(0)                                               /**< (SERCOM_USART_STATUS) Parity Error Position */
#define SERCOM_USART_STATUS_PERR_Msk          (_U_(0x1) << SERCOM_USART_STATUS_PERR_Pos)           /**< (SERCOM_USART_STATUS) Parity Error Mask */
#define SERCOM_USART_STATUS_PERR(value)       (SERCOM_USART_STATUS_PERR_Msk & ((value) << SERCOM_USART_STATUS_PERR_Pos))
#define SERCOM_USART_STATUS_FERR_Pos          _U_(1)                                               /**< (SERCOM_USART_STATUS) Frame Error Position */
#define SERCOM_USART_STATUS_FERR_Msk          (_U_(0x1) << SERCOM_USART_STATUS_FERR_Pos)           /**< (SERCOM_USART_STATUS) Frame Error Mask */
#define SERCOM_USART_STATUS_FERR(value)       (SERCOM_USART_STATUS_FERR_Msk & ((value) << SERCOM_USART_STATUS_FERR_Pos))
#define SERCOM_USART_STATUS_BUFOVF_Pos        _U_(2)                                               /**< (SERCOM_USART_STATUS) Buffer Overflow Position */
#define SERCOM_USART_STATUS_BUFOVF_Msk        (_U_(0x1) << SERCOM_USART_STATUS_BUFOVF_Pos)         /**< (SERCOM_USART_STATUS) Buffer Overflow Mask */
#define SERCOM_USART_STATUS_BUFOVF(value)     (SERCOM_USART_STATUS_BUFOVF_Msk & ((value) << SERCOM_USART_STATUS_BUFOVF_Pos))
#define SERCOM_USART_STATUS_CTS_Pos           _U_(3)                                               /**< (SERCOM_USART_STATUS) Clear To Send Position */
#define SERCOM_USART_STATUS_CTS_Msk           (_U_(0x1) << SERCOM_USART_STATUS_CTS_Pos)            /**< (SERCOM_USART_STATUS) Clear To Send Mask */
#define SERCOM_USART_STATUS_CTS(value)        (SERCOM_USART_STATUS_CTS_Msk & ((value) << SERCOM_USART_STATUS_CTS_Pos))
#define SERCOM_USART_STATUS_ISF_Pos           _U_(4)                                               /**< (SERCOM_USART_STATUS) Inconsistent Sync Field Position */
#define SERCOM_USART_STATUS_ISF_Msk           (_U_(0x1) << SERCOM_USART_STATUS_ISF_Pos)            /**< (SERCOM_USART_STATUS) Inconsistent Sync Field Mask */
#define SERCOM_USART_STATUS_ISF(value)        (SERCOM_USART_STATUS_ISF_Msk & ((value) << SERCOM_USART_STATUS_ISF_Pos))
#define SERCOM_USART_STATUS_COLL_Pos          _U_(5)                                               /**< (SERCOM_USART_STATUS) Collision Detected Position */
#define SERCOM_USART_STATUS_COLL_Msk          (_U_(0x1) << SERCOM_USART_STATUS_COLL_Pos)           /**< (SERCOM_USART_STATUS) Collision Detected Mask */
#define SERCOM_USART_STATUS_COLL(value)       (SERCOM_USART_STATUS_COLL_Msk & ((value) << SERCOM_USART_STATUS_COLL_Pos))
#define SERCOM_USART_STATUS_TXE_Pos           _U_(6)                                               /**< (SERCOM_USART_STATUS) Transmitter Empty Position */
#define SERCOM_USART_STATUS_TXE_Msk           (_U_(0x1) << SERCOM_USART_STATUS_TXE_Pos)            /**< (SERCOM_USART_STATUS) Transmitter Empty Mask */
#define SERCOM_USART_STATUS_TXE(value)        (SERCOM_USART_STATUS_TXE_Msk & ((value) << SERCOM_USART_STATUS_TXE_Pos))
#define SERCOM_USART_STATUS_ITER_Pos          _U_(7)                                               /**< (SERCOM_USART_STATUS) Maximum Number of Repetitions Reached Position */
#define SERCOM_USART_STATUS_ITER_Msk          (_U_(0x1) << SERCOM_USART_STATUS_ITER_Pos)           /**< (SERCOM_USART_STATUS) Maximum Number of Repetitions Reached Mask */
#define SERCOM_USART_STATUS_ITER(value)       (SERCOM_USART_STATUS_ITER_Msk & ((value) << SERCOM_USART_STATUS_ITER_Pos))
#define SERCOM_USART_STATUS_Msk               _U_(0x00FF)                                          /**< (SERCOM_USART_STATUS) Register Mask  */


/* -------- SERCOM_I2CM_SYNCBUSY : (SERCOM Offset: 0x1C) ( R/ 32) I2CM Synchronization Busy -------- */
#define SERCOM_I2CM_SYNCBUSY_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_I2CM_SYNCBUSY) I2CM Synchronization Busy  Reset Value */

#define SERCOM_I2CM_SYNCBUSY_SWRST_Pos        _U_(0)                                               /**< (SERCOM_I2CM_SYNCBUSY) Software Reset Synchronization Busy Position */
#define SERCOM_I2CM_SYNCBUSY_SWRST_Msk        (_U_(0x1) << SERCOM_I2CM_SYNCBUSY_SWRST_Pos)         /**< (SERCOM_I2CM_SYNCBUSY) Software Reset Synchronization Busy Mask */
#define SERCOM_I2CM_SYNCBUSY_SWRST(value)     (SERCOM_I2CM_SYNCBUSY_SWRST_Msk & ((value) << SERCOM_I2CM_SYNCBUSY_SWRST_Pos))
#define SERCOM_I2CM_SYNCBUSY_ENABLE_Pos       _U_(1)                                               /**< (SERCOM_I2CM_SYNCBUSY) SERCOM Enable Synchronization Busy Position */
#define SERCOM_I2CM_SYNCBUSY_ENABLE_Msk       (_U_(0x1) << SERCOM_I2CM_SYNCBUSY_ENABLE_Pos)        /**< (SERCOM_I2CM_SYNCBUSY) SERCOM Enable Synchronization Busy Mask */
#define SERCOM_I2CM_SYNCBUSY_ENABLE(value)    (SERCOM_I2CM_SYNCBUSY_ENABLE_Msk & ((value) << SERCOM_I2CM_SYNCBUSY_ENABLE_Pos))
#define SERCOM_I2CM_SYNCBUSY_SYSOP_Pos        _U_(2)                                               /**< (SERCOM_I2CM_SYNCBUSY) System Operation Synchronization Busy Position */
#define SERCOM_I2CM_SYNCBUSY_SYSOP_Msk        (_U_(0x1) << SERCOM_I2CM_SYNCBUSY_SYSOP_Pos)         /**< (SERCOM_I2CM_SYNCBUSY) System Operation Synchronization Busy Mask */
#define SERCOM_I2CM_SYNCBUSY_SYSOP(value)     (SERCOM_I2CM_SYNCBUSY_SYSOP_Msk & ((value) << SERCOM_I2CM_SYNCBUSY_SYSOP_Pos))
#define SERCOM_I2CM_SYNCBUSY_Msk              _U_(0x00000007)                                      /**< (SERCOM_I2CM_SYNCBUSY) Register Mask  */


/* -------- SERCOM_I2CS_SYNCBUSY : (SERCOM Offset: 0x1C) ( R/ 32) I2CS Synchronization Busy -------- */
#define SERCOM_I2CS_SYNCBUSY_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_I2CS_SYNCBUSY) I2CS Synchronization Busy  Reset Value */

#define SERCOM_I2CS_SYNCBUSY_SWRST_Pos        _U_(0)                                               /**< (SERCOM_I2CS_SYNCBUSY) Software Reset Synchronization Busy Position */
#define SERCOM_I2CS_SYNCBUSY_SWRST_Msk        (_U_(0x1) << SERCOM_I2CS_SYNCBUSY_SWRST_Pos)         /**< (SERCOM_I2CS_SYNCBUSY) Software Reset Synchronization Busy Mask */
#define SERCOM_I2CS_SYNCBUSY_SWRST(value)     (SERCOM_I2CS_SYNCBUSY_SWRST_Msk & ((value) << SERCOM_I2CS_SYNCBUSY_SWRST_Pos))
#define SERCOM_I2CS_SYNCBUSY_ENABLE_Pos       _U_(1)                                               /**< (SERCOM_I2CS_SYNCBUSY) SERCOM Enable Synchronization Busy Position */
#define SERCOM_I2CS_SYNCBUSY_ENABLE_Msk       (_U_(0x1) << SERCOM_I2CS_SYNCBUSY_ENABLE_Pos)        /**< (SERCOM_I2CS_SYNCBUSY) SERCOM Enable Synchronization Busy Mask */
#define SERCOM_I2CS_SYNCBUSY_ENABLE(value)    (SERCOM_I2CS_SYNCBUSY_ENABLE_Msk & ((value) << SERCOM_I2CS_SYNCBUSY_ENABLE_Pos))
#define SERCOM_I2CS_SYNCBUSY_Msk              _U_(0x00000003)                                      /**< (SERCOM_I2CS_SYNCBUSY) Register Mask  */


/* -------- SERCOM_SPI_SYNCBUSY : (SERCOM Offset: 0x1C) ( R/ 32) SPI Synchronization Busy -------- */
#define SERCOM_SPI_SYNCBUSY_RESETVALUE        _U_(0x00)                                            /**<  (SERCOM_SPI_SYNCBUSY) SPI Synchronization Busy  Reset Value */

#define SERCOM_SPI_SYNCBUSY_SWRST_Pos         _U_(0)                                               /**< (SERCOM_SPI_SYNCBUSY) Software Reset Synchronization Busy Position */
#define SERCOM_SPI_SYNCBUSY_SWRST_Msk         (_U_(0x1) << SERCOM_SPI_SYNCBUSY_SWRST_Pos)          /**< (SERCOM_SPI_SYNCBUSY) Software Reset Synchronization Busy Mask */
#define SERCOM_SPI_SYNCBUSY_SWRST(value)      (SERCOM_SPI_SYNCBUSY_SWRST_Msk & ((value) << SERCOM_SPI_SYNCBUSY_SWRST_Pos))
#define SERCOM_SPI_SYNCBUSY_ENABLE_Pos        _U_(1)                                               /**< (SERCOM_SPI_SYNCBUSY) SERCOM Enable Synchronization Busy Position */
#define SERCOM_SPI_SYNCBUSY_ENABLE_Msk        (_U_(0x1) << SERCOM_SPI_SYNCBUSY_ENABLE_Pos)         /**< (SERCOM_SPI_SYNCBUSY) SERCOM Enable Synchronization Busy Mask */
#define SERCOM_SPI_SYNCBUSY_ENABLE(value)     (SERCOM_SPI_SYNCBUSY_ENABLE_Msk & ((value) << SERCOM_SPI_SYNCBUSY_ENABLE_Pos))
#define SERCOM_SPI_SYNCBUSY_CTRLB_Pos         _U_(2)                                               /**< (SERCOM_SPI_SYNCBUSY) CTRLB Synchronization Busy Position */
#define SERCOM_SPI_SYNCBUSY_CTRLB_Msk         (_U_(0x1) << SERCOM_SPI_SYNCBUSY_CTRLB_Pos)          /**< (SERCOM_SPI_SYNCBUSY) CTRLB Synchronization Busy Mask */
#define SERCOM_SPI_SYNCBUSY_CTRLB(value)      (SERCOM_SPI_SYNCBUSY_CTRLB_Msk & ((value) << SERCOM_SPI_SYNCBUSY_CTRLB_Pos))
#define SERCOM_SPI_SYNCBUSY_Msk               _U_(0x00000007)                                      /**< (SERCOM_SPI_SYNCBUSY) Register Mask  */


/* -------- SERCOM_USART_SYNCBUSY : (SERCOM Offset: 0x1C) ( R/ 32) USART Synchronization Busy -------- */
#define SERCOM_USART_SYNCBUSY_RESETVALUE      _U_(0x00)                                            /**<  (SERCOM_USART_SYNCBUSY) USART Synchronization Busy  Reset Value */

#define SERCOM_USART_SYNCBUSY_SWRST_Pos       _U_(0)                                               /**< (SERCOM_USART_SYNCBUSY) Software Reset Synchronization Busy Position */
#define SERCOM_USART_SYNCBUSY_SWRST_Msk       (_U_(0x1) << SERCOM_USART_SYNCBUSY_SWRST_Pos)        /**< (SERCOM_USART_SYNCBUSY) Software Reset Synchronization Busy Mask */
#define SERCOM_USART_SYNCBUSY_SWRST(value)    (SERCOM_USART_SYNCBUSY_SWRST_Msk & ((value) << SERCOM_USART_SYNCBUSY_SWRST_Pos))
#define SERCOM_USART_SYNCBUSY_ENABLE_Pos      _U_(1)                                               /**< (SERCOM_USART_SYNCBUSY) SERCOM Enable Synchronization Busy Position */
#define SERCOM_USART_SYNCBUSY_ENABLE_Msk      (_U_(0x1) << SERCOM_USART_SYNCBUSY_ENABLE_Pos)       /**< (SERCOM_USART_SYNCBUSY) SERCOM Enable Synchronization Busy Mask */
#define SERCOM_USART_SYNCBUSY_ENABLE(value)   (SERCOM_USART_SYNCBUSY_ENABLE_Msk & ((value) << SERCOM_USART_SYNCBUSY_ENABLE_Pos))
#define SERCOM_USART_SYNCBUSY_CTRLB_Pos       _U_(2)                                               /**< (SERCOM_USART_SYNCBUSY) CTRLB Synchronization Busy Position */
#define SERCOM_USART_SYNCBUSY_CTRLB_Msk       (_U_(0x1) << SERCOM_USART_SYNCBUSY_CTRLB_Pos)        /**< (SERCOM_USART_SYNCBUSY) CTRLB Synchronization Busy Mask */
#define SERCOM_USART_SYNCBUSY_CTRLB(value)    (SERCOM_USART_SYNCBUSY_CTRLB_Msk & ((value) << SERCOM_USART_SYNCBUSY_CTRLB_Pos))
#define SERCOM_USART_SYNCBUSY_RXERRCNT_Pos    _U_(3)                                               /**< (SERCOM_USART_SYNCBUSY) RXERRCNT Synchronization Busy Position */
#define SERCOM_USART_SYNCBUSY_RXERRCNT_Msk    (_U_(0x1) << SERCOM_USART_SYNCBUSY_RXERRCNT_Pos)     /**< (SERCOM_USART_SYNCBUSY) RXERRCNT Synchronization Busy Mask */
#define SERCOM_USART_SYNCBUSY_RXERRCNT(value) (SERCOM_USART_SYNCBUSY_RXERRCNT_Msk & ((value) << SERCOM_USART_SYNCBUSY_RXERRCNT_Pos))
#define SERCOM_USART_SYNCBUSY_Msk             _U_(0x0000000F)                                      /**< (SERCOM_USART_SYNCBUSY) Register Mask  */


/* -------- SERCOM_USART_RXERRCNT : (SERCOM Offset: 0x20) ( R/ 8) USART Receive Error Count -------- */
#define SERCOM_USART_RXERRCNT_RESETVALUE      _U_(0x00)                                            /**<  (SERCOM_USART_RXERRCNT) USART Receive Error Count  Reset Value */

#define SERCOM_USART_RXERRCNT_Msk             _U_(0x00)                                            /**< (SERCOM_USART_RXERRCNT) Register Mask  */


/* -------- SERCOM_I2CM_ADDR : (SERCOM Offset: 0x24) (R/W 32) I2CM Address -------- */
#define SERCOM_I2CM_ADDR_RESETVALUE           _U_(0x00)                                            /**<  (SERCOM_I2CM_ADDR) I2CM Address  Reset Value */

#define SERCOM_I2CM_ADDR_ADDR_Pos             _U_(0)                                               /**< (SERCOM_I2CM_ADDR) Address Value Position */
#define SERCOM_I2CM_ADDR_ADDR_Msk             (_U_(0x7FF) << SERCOM_I2CM_ADDR_ADDR_Pos)            /**< (SERCOM_I2CM_ADDR) Address Value Mask */
#define SERCOM_I2CM_ADDR_ADDR(value)          (SERCOM_I2CM_ADDR_ADDR_Msk & ((value) << SERCOM_I2CM_ADDR_ADDR_Pos))
#define SERCOM_I2CM_ADDR_LENEN_Pos            _U_(13)                                              /**< (SERCOM_I2CM_ADDR) Length Enable Position */
#define SERCOM_I2CM_ADDR_LENEN_Msk            (_U_(0x1) << SERCOM_I2CM_ADDR_LENEN_Pos)             /**< (SERCOM_I2CM_ADDR) Length Enable Mask */
#define SERCOM_I2CM_ADDR_LENEN(value)         (SERCOM_I2CM_ADDR_LENEN_Msk & ((value) << SERCOM_I2CM_ADDR_LENEN_Pos))
#define SERCOM_I2CM_ADDR_HS_Pos               _U_(14)                                              /**< (SERCOM_I2CM_ADDR) High Speed Mode Position */
#define SERCOM_I2CM_ADDR_HS_Msk               (_U_(0x1) << SERCOM_I2CM_ADDR_HS_Pos)                /**< (SERCOM_I2CM_ADDR) High Speed Mode Mask */
#define SERCOM_I2CM_ADDR_HS(value)            (SERCOM_I2CM_ADDR_HS_Msk & ((value) << SERCOM_I2CM_ADDR_HS_Pos))
#define SERCOM_I2CM_ADDR_TENBITEN_Pos         _U_(15)                                              /**< (SERCOM_I2CM_ADDR) Ten Bit Addressing Enable Position */
#define SERCOM_I2CM_ADDR_TENBITEN_Msk         (_U_(0x1) << SERCOM_I2CM_ADDR_TENBITEN_Pos)          /**< (SERCOM_I2CM_ADDR) Ten Bit Addressing Enable Mask */
#define SERCOM_I2CM_ADDR_TENBITEN(value)      (SERCOM_I2CM_ADDR_TENBITEN_Msk & ((value) << SERCOM_I2CM_ADDR_TENBITEN_Pos))
#define SERCOM_I2CM_ADDR_LEN_Pos              _U_(16)                                              /**< (SERCOM_I2CM_ADDR) Length Position */
#define SERCOM_I2CM_ADDR_LEN_Msk              (_U_(0xFF) << SERCOM_I2CM_ADDR_LEN_Pos)              /**< (SERCOM_I2CM_ADDR) Length Mask */
#define SERCOM_I2CM_ADDR_LEN(value)           (SERCOM_I2CM_ADDR_LEN_Msk & ((value) << SERCOM_I2CM_ADDR_LEN_Pos))
#define SERCOM_I2CM_ADDR_Msk                  _U_(0x00FFE7FF)                                      /**< (SERCOM_I2CM_ADDR) Register Mask  */


/* -------- SERCOM_I2CS_ADDR : (SERCOM Offset: 0x24) (R/W 32) I2CS Address -------- */
#define SERCOM_I2CS_ADDR_RESETVALUE           _U_(0x00)                                            /**<  (SERCOM_I2CS_ADDR) I2CS Address  Reset Value */

#define SERCOM_I2CS_ADDR_GENCEN_Pos           _U_(0)                                               /**< (SERCOM_I2CS_ADDR) General Call Address Enable Position */
#define SERCOM_I2CS_ADDR_GENCEN_Msk           (_U_(0x1) << SERCOM_I2CS_ADDR_GENCEN_Pos)            /**< (SERCOM_I2CS_ADDR) General Call Address Enable Mask */
#define SERCOM_I2CS_ADDR_GENCEN(value)        (SERCOM_I2CS_ADDR_GENCEN_Msk & ((value) << SERCOM_I2CS_ADDR_GENCEN_Pos))
#define SERCOM_I2CS_ADDR_ADDR_Pos             _U_(1)                                               /**< (SERCOM_I2CS_ADDR) Address Value Position */
#define SERCOM_I2CS_ADDR_ADDR_Msk             (_U_(0x3FF) << SERCOM_I2CS_ADDR_ADDR_Pos)            /**< (SERCOM_I2CS_ADDR) Address Value Mask */
#define SERCOM_I2CS_ADDR_ADDR(value)          (SERCOM_I2CS_ADDR_ADDR_Msk & ((value) << SERCOM_I2CS_ADDR_ADDR_Pos))
#define SERCOM_I2CS_ADDR_TENBITEN_Pos         _U_(15)                                              /**< (SERCOM_I2CS_ADDR) Ten Bit Addressing Enable Position */
#define SERCOM_I2CS_ADDR_TENBITEN_Msk         (_U_(0x1) << SERCOM_I2CS_ADDR_TENBITEN_Pos)          /**< (SERCOM_I2CS_ADDR) Ten Bit Addressing Enable Mask */
#define SERCOM_I2CS_ADDR_TENBITEN(value)      (SERCOM_I2CS_ADDR_TENBITEN_Msk & ((value) << SERCOM_I2CS_ADDR_TENBITEN_Pos))
#define SERCOM_I2CS_ADDR_ADDRMASK_Pos         _U_(17)                                              /**< (SERCOM_I2CS_ADDR) Address Mask Position */
#define SERCOM_I2CS_ADDR_ADDRMASK_Msk         (_U_(0x3FF) << SERCOM_I2CS_ADDR_ADDRMASK_Pos)        /**< (SERCOM_I2CS_ADDR) Address Mask Mask */
#define SERCOM_I2CS_ADDR_ADDRMASK(value)      (SERCOM_I2CS_ADDR_ADDRMASK_Msk & ((value) << SERCOM_I2CS_ADDR_ADDRMASK_Pos))
#define SERCOM_I2CS_ADDR_Msk                  _U_(0x07FE87FF)                                      /**< (SERCOM_I2CS_ADDR) Register Mask  */


/* -------- SERCOM_SPI_ADDR : (SERCOM Offset: 0x24) (R/W 32) SPI Address -------- */
#define SERCOM_SPI_ADDR_RESETVALUE            _U_(0x00)                                            /**<  (SERCOM_SPI_ADDR) SPI Address  Reset Value */

#define SERCOM_SPI_ADDR_ADDR_Pos              _U_(0)                                               /**< (SERCOM_SPI_ADDR) Address Value Position */
#define SERCOM_SPI_ADDR_ADDR_Msk              (_U_(0xFF) << SERCOM_SPI_ADDR_ADDR_Pos)              /**< (SERCOM_SPI_ADDR) Address Value Mask */
#define SERCOM_SPI_ADDR_ADDR(value)           (SERCOM_SPI_ADDR_ADDR_Msk & ((value) << SERCOM_SPI_ADDR_ADDR_Pos))
#define SERCOM_SPI_ADDR_ADDRMASK_Pos          _U_(16)                                              /**< (SERCOM_SPI_ADDR) Address Mask Position */
#define SERCOM_SPI_ADDR_ADDRMASK_Msk          (_U_(0xFF) << SERCOM_SPI_ADDR_ADDRMASK_Pos)          /**< (SERCOM_SPI_ADDR) Address Mask Mask */
#define SERCOM_SPI_ADDR_ADDRMASK(value)       (SERCOM_SPI_ADDR_ADDRMASK_Msk & ((value) << SERCOM_SPI_ADDR_ADDRMASK_Pos))
#define SERCOM_SPI_ADDR_Msk                   _U_(0x00FF00FF)                                      /**< (SERCOM_SPI_ADDR) Register Mask  */


/* -------- SERCOM_I2CM_DATA : (SERCOM Offset: 0x28) (R/W 8) I2CM Data -------- */
#define SERCOM_I2CM_DATA_RESETVALUE           _U_(0x00)                                            /**<  (SERCOM_I2CM_DATA) I2CM Data  Reset Value */

#define SERCOM_I2CM_DATA_DATA_Pos             _U_(0)                                               /**< (SERCOM_I2CM_DATA) Data Value Position */
#define SERCOM_I2CM_DATA_DATA_Msk             (_U_(0xFF) << SERCOM_I2CM_DATA_DATA_Pos)             /**< (SERCOM_I2CM_DATA) Data Value Mask */
#define SERCOM_I2CM_DATA_DATA(value)          (SERCOM_I2CM_DATA_DATA_Msk & ((value) << SERCOM_I2CM_DATA_DATA_Pos))
#define SERCOM_I2CM_DATA_Msk                  _U_(0xFF)                                            /**< (SERCOM_I2CM_DATA) Register Mask  */


/* -------- SERCOM_I2CS_DATA : (SERCOM Offset: 0x28) (R/W 8) I2CS Data -------- */
#define SERCOM_I2CS_DATA_RESETVALUE           _U_(0x00)                                            /**<  (SERCOM_I2CS_DATA) I2CS Data  Reset Value */

#define SERCOM_I2CS_DATA_DATA_Pos             _U_(0)                                               /**< (SERCOM_I2CS_DATA) Data Value Position */
#define SERCOM_I2CS_DATA_DATA_Msk             (_U_(0xFF) << SERCOM_I2CS_DATA_DATA_Pos)             /**< (SERCOM_I2CS_DATA) Data Value Mask */
#define SERCOM_I2CS_DATA_DATA(value)          (SERCOM_I2CS_DATA_DATA_Msk & ((value) << SERCOM_I2CS_DATA_DATA_Pos))
#define SERCOM_I2CS_DATA_Msk                  _U_(0xFF)                                            /**< (SERCOM_I2CS_DATA) Register Mask  */


/* -------- SERCOM_SPI_DATA : (SERCOM Offset: 0x28) (R/W 32) SPI Data -------- */
#define SERCOM_SPI_DATA_RESETVALUE            _U_(0x00)                                            /**<  (SERCOM_SPI_DATA) SPI Data  Reset Value */

#define SERCOM_SPI_DATA_DATA_Pos              _U_(0)                                               /**< (SERCOM_SPI_DATA) Data Value Position */
#define SERCOM_SPI_DATA_DATA_Msk              (_U_(0x1FF) << SERCOM_SPI_DATA_DATA_Pos)             /**< (SERCOM_SPI_DATA) Data Value Mask */
#define SERCOM_SPI_DATA_DATA(value)           (SERCOM_SPI_DATA_DATA_Msk & ((value) << SERCOM_SPI_DATA_DATA_Pos))
#define SERCOM_SPI_DATA_Msk                   _U_(0x000001FF)                                      /**< (SERCOM_SPI_DATA) Register Mask  */


/* -------- SERCOM_USART_DATA : (SERCOM Offset: 0x28) (R/W 16) USART Data -------- */
#define SERCOM_USART_DATA_RESETVALUE          _U_(0x00)                                            /**<  (SERCOM_USART_DATA) USART Data  Reset Value */

#define SERCOM_USART_DATA_DATA_Pos            _U_(0)                                               /**< (SERCOM_USART_DATA) Data Value Position */
#define SERCOM_USART_DATA_DATA_Msk            (_U_(0x1FF) << SERCOM_USART_DATA_DATA_Pos)           /**< (SERCOM_USART_DATA) Data Value Mask */
#define SERCOM_USART_DATA_DATA(value)         (SERCOM_USART_DATA_DATA_Msk & ((value) << SERCOM_USART_DATA_DATA_Pos))
#define SERCOM_USART_DATA_Msk                 _U_(0x01FF)                                          /**< (SERCOM_USART_DATA) Register Mask  */


/* -------- SERCOM_I2CM_DBGCTRL : (SERCOM Offset: 0x30) (R/W 8) I2CM Debug Control -------- */
#define SERCOM_I2CM_DBGCTRL_RESETVALUE        _U_(0x00)                                            /**<  (SERCOM_I2CM_DBGCTRL) I2CM Debug Control  Reset Value */

#define SERCOM_I2CM_DBGCTRL_DBGSTOP_Pos       _U_(0)                                               /**< (SERCOM_I2CM_DBGCTRL) Debug Mode Position */
#define SERCOM_I2CM_DBGCTRL_DBGSTOP_Msk       (_U_(0x1) << SERCOM_I2CM_DBGCTRL_DBGSTOP_Pos)        /**< (SERCOM_I2CM_DBGCTRL) Debug Mode Mask */
#define SERCOM_I2CM_DBGCTRL_DBGSTOP(value)    (SERCOM_I2CM_DBGCTRL_DBGSTOP_Msk & ((value) << SERCOM_I2CM_DBGCTRL_DBGSTOP_Pos))
#define SERCOM_I2CM_DBGCTRL_Msk               _U_(0x01)                                            /**< (SERCOM_I2CM_DBGCTRL) Register Mask  */


/* -------- SERCOM_SPI_DBGCTRL : (SERCOM Offset: 0x30) (R/W 8) SPI Debug Control -------- */
#define SERCOM_SPI_DBGCTRL_RESETVALUE         _U_(0x00)                                            /**<  (SERCOM_SPI_DBGCTRL) SPI Debug Control  Reset Value */

#define SERCOM_SPI_DBGCTRL_DBGSTOP_Pos        _U_(0)                                               /**< (SERCOM_SPI_DBGCTRL) Debug Mode Position */
#define SERCOM_SPI_DBGCTRL_DBGSTOP_Msk        (_U_(0x1) << SERCOM_SPI_DBGCTRL_DBGSTOP_Pos)         /**< (SERCOM_SPI_DBGCTRL) Debug Mode Mask */
#define SERCOM_SPI_DBGCTRL_DBGSTOP(value)     (SERCOM_SPI_DBGCTRL_DBGSTOP_Msk & ((value) << SERCOM_SPI_DBGCTRL_DBGSTOP_Pos))
#define SERCOM_SPI_DBGCTRL_Msk                _U_(0x01)                                            /**< (SERCOM_SPI_DBGCTRL) Register Mask  */


/* -------- SERCOM_USART_DBGCTRL : (SERCOM Offset: 0x30) (R/W 8) USART Debug Control -------- */
#define SERCOM_USART_DBGCTRL_RESETVALUE       _U_(0x00)                                            /**<  (SERCOM_USART_DBGCTRL) USART Debug Control  Reset Value */

#define SERCOM_USART_DBGCTRL_DBGSTOP_Pos      _U_(0)                                               /**< (SERCOM_USART_DBGCTRL) Debug Mode Position */
#define SERCOM_USART_DBGCTRL_DBGSTOP_Msk      (_U_(0x1) << SERCOM_USART_DBGCTRL_DBGSTOP_Pos)       /**< (SERCOM_USART_DBGCTRL) Debug Mode Mask */
#define SERCOM_USART_DBGCTRL_DBGSTOP(value)   (SERCOM_USART_DBGCTRL_DBGSTOP_Msk & ((value) << SERCOM_USART_DBGCTRL_DBGSTOP_Pos))
#define SERCOM_USART_DBGCTRL_Msk              _U_(0x01)                                            /**< (SERCOM_USART_DBGCTRL) Register Mask  */


/** \brief SERCOM register offsets definitions */
#define SERCOM_I2CM_CTRLA_REG_OFST     (0x00)              /**< (SERCOM_I2CM_CTRLA) I2CM Control A Offset */
#define SERCOM_I2CS_CTRLA_REG_OFST     (0x00)              /**< (SERCOM_I2CS_CTRLA) I2CS Control A Offset */
#define SERCOM_SPI_CTRLA_REG_OFST      (0x00)              /**< (SERCOM_SPI_CTRLA) SPI Control A Offset */
#define SERCOM_USART_CTRLA_REG_OFST    (0x00)              /**< (SERCOM_USART_CTRLA) USART Control A Offset */
#define SERCOM_I2CM_CTRLB_REG_OFST     (0x04)              /**< (SERCOM_I2CM_CTRLB) I2CM Control B Offset */
#define SERCOM_I2CS_CTRLB_REG_OFST     (0x04)              /**< (SERCOM_I2CS_CTRLB) I2CS Control B Offset */
#define SERCOM_SPI_CTRLB_REG_OFST      (0x04)              /**< (SERCOM_SPI_CTRLB) SPI Control B Offset */
#define SERCOM_USART_CTRLB_REG_OFST    (0x04)              /**< (SERCOM_USART_CTRLB) USART Control B Offset */
#define SERCOM_USART_CTRLC_REG_OFST    (0x08)              /**< (SERCOM_USART_CTRLC) USART Control C Offset */
#define SERCOM_I2CM_BAUD_REG_OFST      (0x0C)              /**< (SERCOM_I2CM_BAUD) I2CM Baud Rate Offset */
#define SERCOM_SPI_BAUD_REG_OFST       (0x0C)              /**< (SERCOM_SPI_BAUD) SPI Baud Rate Offset */
#define SERCOM_USART_BAUD_REG_OFST     (0x0C)              /**< (SERCOM_USART_BAUD) USART Baud Rate Offset */
#define SERCOM_USART_RXPL_REG_OFST     (0x0E)              /**< (SERCOM_USART_RXPL) USART Receive Pulse Length Offset */
#define SERCOM_I2CM_INTENCLR_REG_OFST  (0x14)              /**< (SERCOM_I2CM_INTENCLR) I2CM Interrupt Enable Clear Offset */
#define SERCOM_I2CS_INTENCLR_REG_OFST  (0x14)              /**< (SERCOM_I2CS_INTENCLR) I2CS Interrupt Enable Clear Offset */
#define SERCOM_SPI_INTENCLR_REG_OFST   (0x14)              /**< (SERCOM_SPI_INTENCLR) SPI Interrupt Enable Clear Offset */
#define SERCOM_USART_INTENCLR_REG_OFST (0x14)              /**< (SERCOM_USART_INTENCLR) USART Interrupt Enable Clear Offset */
#define SERCOM_I2CM_INTENSET_REG_OFST  (0x16)              /**< (SERCOM_I2CM_INTENSET) I2CM Interrupt Enable Set Offset */
#define SERCOM_I2CS_INTENSET_REG_OFST  (0x16)              /**< (SERCOM_I2CS_INTENSET) I2CS Interrupt Enable Set Offset */
#define SERCOM_SPI_INTENSET_REG_OFST   (0x16)              /**< (SERCOM_SPI_INTENSET) SPI Interrupt Enable Set Offset */
#define SERCOM_USART_INTENSET_REG_OFST (0x16)              /**< (SERCOM_USART_INTENSET) USART Interrupt Enable Set Offset */
#define SERCOM_I2CM_INTFLAG_REG_OFST   (0x18)              /**< (SERCOM_I2CM_INTFLAG) I2CM Interrupt Flag Status and Clear Offset */
#define SERCOM_I2CS_INTFLAG_REG_OFST   (0x18)              /**< (SERCOM_I2CS_INTFLAG) I2CS Interrupt Flag Status and Clear Offset */
#define SERCOM_SPI_INTFLAG_REG_OFST    (0x18)              /**< (SERCOM_SPI_INTFLAG) SPI Interrupt Flag Status and Clear Offset */
#define SERCOM_USART_INTFLAG_REG_OFST  (0x18)              /**< (SERCOM_USART_INTFLAG) USART Interrupt Flag Status and Clear Offset */
#define SERCOM_I2CM_STATUS_REG_OFST    (0x1A)              /**< (SERCOM_I2CM_STATUS) I2CM Status Offset */
#define SERCOM_I2CS_STATUS_REG_OFST    (0x1A)              /**< (SERCOM_I2CS_STATUS) I2CS Status Offset */
#define SERCOM_SPI_STATUS_REG_OFST     (0x1A)              /**< (SERCOM_SPI_STATUS) SPI Status Offset */
#define SERCOM_USART_STATUS_REG_OFST   (0x1A)              /**< (SERCOM_USART_STATUS) USART Status Offset */
#define SERCOM_I2CM_SYNCBUSY_REG_OFST  (0x1C)              /**< (SERCOM_I2CM_SYNCBUSY) I2CM Synchronization Busy Offset */
#define SERCOM_I2CS_SYNCBUSY_REG_OFST  (0x1C)              /**< (SERCOM_I2CS_SYNCBUSY) I2CS Synchronization Busy Offset */
#define SERCOM_SPI_SYNCBUSY_REG_OFST   (0x1C)              /**< (SERCOM_SPI_SYNCBUSY) SPI Synchronization Busy Offset */
#define SERCOM_USART_SYNCBUSY_REG_OFST (0x1C)              /**< (SERCOM_USART_SYNCBUSY) USART Synchronization Busy Offset */
#define SERCOM_USART_RXERRCNT_REG_OFST (0x20)              /**< (SERCOM_USART_RXERRCNT) USART Receive Error Count Offset */
#define SERCOM_I2CM_ADDR_REG_OFST      (0x24)              /**< (SERCOM_I2CM_ADDR) I2CM Address Offset */
#define SERCOM_I2CS_ADDR_REG_OFST      (0x24)              /**< (SERCOM_I2CS_ADDR) I2CS Address Offset */
#define SERCOM_SPI_ADDR_REG_OFST       (0x24)              /**< (SERCOM_SPI_ADDR) SPI Address Offset */
#define SERCOM_I2CM_DATA_REG_OFST      (0x28)              /**< (SERCOM_I2CM_DATA) I2CM Data Offset */
#define SERCOM_I2CS_DATA_REG_OFST      (0x28)              /**< (SERCOM_I2CS_DATA) I2CS Data Offset */
#define SERCOM_SPI_DATA_REG_OFST       (0x28)              /**< (SERCOM_SPI_DATA) SPI Data Offset */
#define SERCOM_USART_DATA_REG_OFST     (0x28)              /**< (SERCOM_USART_DATA) USART Data Offset */
#define SERCOM_I2CM_DBGCTRL_REG_OFST   (0x30)              /**< (SERCOM_I2CM_DBGCTRL) I2CM Debug Control Offset */
#define SERCOM_SPI_DBGCTRL_REG_OFST    (0x30)              /**< (SERCOM_SPI_DBGCTRL) SPI Debug Control Offset */
#define SERCOM_USART_DBGCTRL_REG_OFST  (0x30)              /**< (SERCOM_USART_DBGCTRL) USART Debug Control Offset */

#if !(defined(__ASSEMBLER__) || defined(__IAR_SYSTEMS_ASM__))
/** \brief SERCOM register API structure */
typedef struct
{  /* Serial Communication Interface */
  __IO  uint32_t                       SERCOM_CTRLA;       /**< Offset: 0x00 (R/W  32) I2CM Control A */
  __IO  uint32_t                       SERCOM_CTRLB;       /**< Offset: 0x04 (R/W  32) I2CM Control B */
  __I   uint8_t                        Reserved1[0x04];
  __IO  uint32_t                       SERCOM_BAUD;        /**< Offset: 0x0C (R/W  32) I2CM Baud Rate */
  __I   uint8_t                        Reserved2[0x04];
  __IO  uint8_t                        SERCOM_INTENCLR;    /**< Offset: 0x14 (R/W  8) I2CM Interrupt Enable Clear */
  __I   uint8_t                        Reserved3[0x01];
  __IO  uint8_t                        SERCOM_INTENSET;    /**< Offset: 0x16 (R/W  8) I2CM Interrupt Enable Set */
  __I   uint8_t                        Reserved4[0x01];
  __IO  uint8_t                        SERCOM_INTFLAG;     /**< Offset: 0x18 (R/W  8) I2CM Interrupt Flag Status and Clear */
  __I   uint8_t                        Reserved5[0x01];
  __IO  uint16_t                       SERCOM_STATUS;      /**< Offset: 0x1A (R/W  16) I2CM Status */
  __I   uint32_t                       SERCOM_SYNCBUSY;    /**< Offset: 0x1C (R/   32) I2CM Synchronization Busy */
  __I   uint8_t                        Reserved6[0x04];
  __IO  uint32_t                       SERCOM_ADDR;        /**< Offset: 0x24 (R/W  32) I2CM Address */
  __IO  uint8_t                        SERCOM_DATA;        /**< Offset: 0x28 (R/W  8) I2CM Data */
  __I   uint8_t                        Reserved7[0x07];
  __IO  uint8_t                        SERCOM_DBGCTRL;     /**< Offset: 0x30 (R/W  8) I2CM Debug Control */
} sercom_i2cm_registers_t;

/** \brief SERCOM register API structure */
typedef struct
{  /* Serial Communication Interface */
  __IO  uint32_t                       SERCOM_CTRLA;       /**< Offset: 0x00 (R/W  32) I2CS Control A */
  __IO  uint32_t                       SERCOM_CTRLB;       /**< Offset: 0x04 (R/W  32) I2CS Control B */
  __I   uint8_t                        Reserved1[0x0C];
  __IO  uint8_t                        SERCOM_INTENCLR;    /**< Offset: 0x14 (R/W  8) I2CS Interrupt Enable Clear */
  __I   uint8_t                        Reserved2[0x01];
  __IO  uint8_t                        SERCOM_INTENSET;    /**< Offset: 0x16 (R/W  8) I2CS Interrupt Enable Set */
  __I   uint8_t                        Reserved3[0x01];
  __IO  uint8_t                        SERCOM_INTFLAG;     /**< Offset: 0x18 (R/W  8) I2CS Interrupt Flag Status and Clear */
  __I   uint8_t                        Reserved4[0x01];
  __IO  uint16_t                       SERCOM_STATUS;      /**< Offset: 0x1A (R/W  16) I2CS Status */
  __I   uint32_t                       SERCOM_SYNCBUSY;    /**< Offset: 0x1C (R/   32) I2CS Synchronization Busy */
  __I   uint8_t                        Reserved5[0x04];
  __IO  uint32_t                       SERCOM_ADDR;        /**< Offset: 0x24 (R/W  32) I2CS Address */
  __IO  uint8_t                        SERCOM_DATA;        /**< Offset: 0x28 (R/W  8) I2CS Data */
} sercom_i2cs_registers_t;

/** \brief SERCOM register API structure */
typedef struct
{  /* Serial Communication Interface */
  __IO  uint32_t                       SERCOM_CTRLA;       /**< Offset: 0x00 (R/W  32) SPI Control A */
  __IO  uint32_t                       SERCOM_CTRLB;       /**< Offset: 0x04 (R/W  32) SPI Control B */
  __I   uint8_t                        Reserved1[0x04];
  __IO  uint8_t                        SERCOM_BAUD;        /**< Offset: 0x0C (R/W  8) SPI Baud Rate */
  __I   uint8_t                        Reserved2[0x07];
  __IO  uint8_t                        SERCOM_INTENCLR;    /**< Offset: 0x14 (R/W  8) SPI Interrupt Enable Clear */
  __I   uint8_t                        Reserved3[0x01];
  __IO  uint8_t                        SERCOM_INTENSET;    /**< Offset: 0x16 (R/W  8) SPI Interrupt Enable Set */
  __I   uint8_t                        Reserved4[0x01];
  __IO  uint8_t                        SERCOM_INTFLAG;     /**< Offset: 0x18 (R/W  8) SPI Interrupt Flag Status and Clear */
  __I   uint8_t                        Reserved5[0x01];
  __IO  uint16_t                       SERCOM_STATUS;      /**< Offset: 0x1A (R/W  16) SPI Status */
  __I   uint32_t                       SERCOM_SYNCBUSY;    /**< Offset: 0x1C (R/   32) SPI Synchronization Busy */
  __I   uint8_t                        Reserved6[0x04];
  __IO  uint32_t                       SERCOM_ADDR;        /**< Offset: 0x24 (R/W  32) SPI Address */
  __IO  uint32_t                       SERCOM_DATA;        /**< Offset: 0x28 (R/W  32) SPI Data */
  __I   uint8_t                        Reserved7[0x04];
  __IO  uint8_t                        SERCOM_DBGCTRL;     /**< Offset: 0x30 (R/W  8) SPI Debug Control */
} sercom_spi_registers_t;

/** \brief SERCOM register API structure */
typedef struct
{  /* Serial Communication Interface */
  __IO  uint32_t                       SERCOM_CTRLA;       /**< Offset: 0x00 (R/W  32) USART Control A */
  __IO  uint32_t                       SERCOM_CTRLB;       /**< Offset: 0x04 (R/W  32) USART Control B */
  __IO  uint32_t                       SERCOM_CTRLC;       /**< Offset: 0x08 (R/W  32) USART Control C */
  __IO  uint16_t                       SERCOM_BAUD;        /**< Offset: 0x0C (R/W  16) USART Baud Rate */
  __IO  uint8_t                        SERCOM_RXPL;        /**< Offset: 0x0E (R/W  8) USART Receive Pulse Length */
  __I   uint8_t                        Reserved1[0x05];
  __IO  uint8_t                        SERCOM_INTENCLR;    /**< Offset: 0x14 (R/W  8) USART Interrupt Enable Clear */
  __I   uint8_t                        Reserved2[0x01];
  __IO  uint8_t                        SERCOM_INTENSET;    /**< Offset: 0x16 (R/W  8) USART Interrupt Enable Set */
  __I   uint8_t                        Reserved3[0x01];
  __IO  uint8_t                        SERCOM_INTFLAG;     /**< Offset: 0x18 (R/W  8) USART Interrupt Flag Status and Clear */
  __I   uint8_t                        Reserved4[0x01];
  __IO  uint16_t                       SERCOM_STATUS;      /**< Offset: 0x1A (R/W  16) USART Status */
  __I   uint32_t                       SERCOM_SYNCBUSY;    /**< Offset: 0x1C (R/   32) USART Synchronization Busy */
  __I   uint8_t                        SERCOM_RXERRCNT;    /**< Offset: 0x20 (R/   8) USART Receive Error Count */
  __I   uint8_t                        Reserved5[0x07];
  __IO  uint16_t                       SERCOM_DATA;        /**< Offset: 0x28 (R/W  16) USART Data */
  __I   uint8_t                        Reserved6[0x06];
  __IO  uint8_t                        SERCOM_DBGCTRL;     /**< Offset: 0x30 (R/W  8) USART Debug Control */
} sercom_usart_registers_t;

/** \brief SERCOM hardware registers */
typedef union
{  /* Serial Communication Interface */
       sercom_i2cm_registers_t        I2CM;           /**< I2C Master Mode */
       sercom_i2cs_registers_t        I2CS;           /**< I2C Slave Mode */
       sercom_spi_registers_t         SPI;            /**< SPI Mode */
       sercom_usart_registers_t       USART;          /**< USART Mode */
} sercom_registers_t;


#endif /* !(defined(__ASSEMBLER__) || defined(__IAR_SYSTEMS_ASM__)) */
#endif /* _SAML10_SERCOM_COMPONENT_H_ */
