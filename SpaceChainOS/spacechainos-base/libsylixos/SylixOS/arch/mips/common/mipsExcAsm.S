;/*********************************************************************************************************
;**
;**                                    �й�������Դ��֯
;**
;**                                   Ƕ��ʽʵʱ����ϵͳ
;**
;**                                       SylixOS(TM)
;**
;**                               Copyright  All Rights Reserved
;**
;**--------------�ļ���Ϣ--------------------------------------------------------------------------------
;**
;** ��   ��   ��: mipsExcAsm.S
;**
;** ��   ��   ��: Ryan.Xin (�Ž���)
;**
;** �ļ���������: 2015 �� 09 �� 01 ��
;**
;** ��        ��: MIPS ��ϵ�����쳣����.
;*********************************************************************************************************/

#ifndef ASSEMBLY
#define ASSEMBLY 1
#endif

#include <arch/assembler.h>
#include "mipsContextAsm.h"

    FILE_BEGIN()

    IMPORT_LABEL(API_ThreadTcbInter)
    IMPORT_LABEL(API_InterStackBaseGet)
    IMPORT_LABEL(API_InterEnter)
    IMPORT_LABEL(API_InterExit)

    IMPORT_LABEL(bspIntHandle)
    IMPORT_LABEL(archCacheErrorHandle)
    IMPORT_LABEL(archExceptionHandle)

    EXPORT_LABEL(archInterruptEntry)
    EXPORT_LABEL(archCacheErrorEntry)
    EXPORT_LABEL(archExceptionEntry)

;/*********************************************************************************************************
;  ������ʱ�����쳣������
;*********************************************************************************************************/

#define TEMP_CTX_OFFSET_LOCK        0
#define TEMP_CTX_OFFSET_SR          4
#define TEMP_CTX_OFFSET_EPC         8
#define TEMP_CTX_OFFSET_CAUSE       12
#define TEMP_CTX_OFFSET_BADVADDR    16

    SECTION(.bss)
    .align (4)
LINE_LABEL(archExcTempCtx)
    .space    32

;/*********************************************************************************************************
;  �����쳣������
;*********************************************************************************************************/

MACRO_DEF(EXC_SAVE_REGS)
    .set    push
    .set    noat
    .set    noreorder
    .set    volatile

    ;/*
    ; * ��Ϊ��Щ�����ں˴��룬���� TLB ת��������ִ��ʱ���ᷢ�� TLB �����쳣
    ; */
;/*********************************************************************************************************
;  1. �� archExcTempCtx ���м���
;*********************************************************************************************************/
    ;/*
    ; * archExcTempCtx ���ں��ڴ棬���� TLB ת�������Է���ʱ���ᷢ�� TLB �����쳣
    ; * ���������ķ�ʽ���� archExcTempCtx
    ; */
1:
    LA      K0 , archExcTempCtx
    LL      K1 , TEMP_CTX_OFFSET_LOCK(K0)
    BNEZ    K1 , 1b
    NOP

    LI      K1 , 1
    SC      K1 , TEMP_CTX_OFFSET_LOCK(K0)
    BEQZ    K1 , 1b
    SYNC

;/*********************************************************************************************************
;  2. �����쳣ʱ�� EPC CAUSE BADVADDR �Ĵ������쳣ǰ�� STATUS �Ĵ����� archExcTempCtx
;*********************************************************************************************************/

    MFC0(K1, CP0_EPC)                                                   ;/*  ��ʱ�����쳣ʱ�� EPC �Ĵ��� */
    SW      K1 , TEMP_CTX_OFFSET_EPC(K0)

    MFC0(K1, CP0_CAUSE)                                                 ;/*  ��ʱ�����쳣ʱ CAUSE �Ĵ��� */
    SW      K1 , TEMP_CTX_OFFSET_CAUSE(K0)

    MFC0(K1, CP0_BADVADDR)                                              ;/*  ��ʱ�����쳣ʱ�� BADVADDR   */
    SW      K1 , TEMP_CTX_OFFSET_BADVADDR(K0)

    MFC0(K1, CP0_STATUS)
    LI      K0 , ~(M_StatusEXL | M_StatusERL)
    AND     K1 , K1, K0                                                 ;/*  K1 �����쳣ǰ�� SR �Ĵ���   */
    LA      K0 , archExcTempCtx
    SW      K1 , TEMP_CTX_OFFSET_SR(K0)                                 ;/*  ��ʱ�����쳣ǰ�� SR �Ĵ���  */

;/*********************************************************************************************************
;  3. �ص��ں�ģʽ�����ж�
;*********************************************************************************************************/

    LI      K0 , ~(M_StatusIE | M_StatusKSU)
    AND     K1 , K1, K0                                                 ;/*  �ص��ں�ģʽ�����ж�        */
    MTC0(K1, CP0_STATUS)
    ;/*
    ; * �Ѿ���� EXL λ��TLB ����������Լ����쳣�������
    ; */

;/*********************************************************************************************************
;  4. Ԥ���ʣ���ǰ���� TLB �����쳣
;*********************************************************************************************************/
    ;/*
    ; * ���ڿ��ܷ��� TLB ������ƻ� CAUSE STATUS K0 K1 EPC BADVADDR �Ĵ���������û��ϵ��
    ; * ��Ϊ�����Ѿ������Ƕ��������
    ; */
    SUBU    SP , STK_CTX_SIZE                                           ;/*  �޸� SP                     */

    SW      ZERO , 0(SP)
    SW      ZERO , STK_OFFSET_LAST(SP)
    SYNC
    ;/*
    ; * ���治���ٷ��� TLB �����쳣
    ; */

;/*********************************************************************************************************
;  5. ����������
;*********************************************************************************************************/

    SAVE_GREGS                                                          ;/*  ���мĴ�����ջ              */

    LA      T0 , archExcTempCtx

    LW      T1 , TEMP_CTX_OFFSET_SR(T0)
    SW      T1 , STK_OFFSET_SR(SP)                                      ;/*  ���������쳣ǰ�� SR �Ĵ���  */

    LW      S0 , TEMP_CTX_OFFSET_EPC(T0)                                ;/*  S0 = EPC                    */
    SW      S0 , STK_OFFSET_EPC(SP)                                     ;/*  ���������쳣ʱ�� EPC �Ĵ��� */

    LW      S1 , TEMP_CTX_OFFSET_CAUSE(T0)                              ;/*  S1 = CAUSE                  */
    SW      S1 , STK_OFFSET_CAUSE(SP)                                   ;/*  ���������쳣ʱ CAUSE �Ĵ��� */

    LW      S2 , TEMP_CTX_OFFSET_BADVADDR(T0)                           ;/*  S2 = BADVADDR               */
    SW      S2 , STK_OFFSET_BADVADDR(SP)                                ;/*  ���������쳣ʱ BADVADDR     */

    MOV     S3 , SP                                                     ;/*  S3 = SP                     */

    MFLO    T1
    EHB
    SW      T1 , STK_OFFSET_LO(SP)                                      ;/*  ���� LO �Ĵ���              */

    MFHI    T1
    EHB
    SW      T1 , STK_OFFSET_HI(SP)                                      ;/*  ���� HI �Ĵ���              */

    LA      GP , _gp                                                    ;/*  �������� GP �Ĵ���          */

;/*********************************************************************************************************
;  6. ���� archExcTempCtx
;*********************************************************************************************************/

    SYNC
    SW      ZERO , TEMP_CTX_OFFSET_LOCK(T0)                             ;/*  ���� archExcTempCtx         */

    .set    pop
    MACRO_END()

;/*********************************************************************************************************
;  �쳣��ں�
;*********************************************************************************************************/

MACRO_DEF(EXCEPTION_ENTRY handle)
    .set    push
    .set    noat
    .set    noreorder
    .set    volatile

    EXC_SAVE_REGS                                                       ;/*  ���мĴ�����ջ              */

    ;/*
    ; * ע�����µ��Ӻ������ò����ƻ� S0 S1 S2 S3 �Ĵ���
    ; */

    ;/*
    ; *  if (API_InterEnter() == 1) {
    ; *      current stack = SP;
    ; *      SP = interrupt stack;
    ; *  }
    ; */
    SUBU    SP , 32
    JAL     API_InterEnter                                              ;/*  ��ȡ�жϲ����ŵ�����ֵ V0   */
    NOP
    ADDU    SP , 32

    LI      V1 , 1
    BNE     V0 , V1 , 1f
    NOP

    SUBU    SP , 32
    JAL     API_ThreadTcbInter                                          ;/*  get current tcb             */
    NOP
    ADDU    SP , 32
    SW      SP , 0(V0)                                                  ;/*  current stack = SP          */

    SUBU    SP , 32
    JAL     API_InterStackBaseGet                                       ;/*  ��õ�ǰ CPU �ж϶�ջջ��   */
    NOP
    MOV     SP , V0

1:
    MOV     A0 , S0                                                     ;/*  ARG0: EPC                   */
    MOV     A1 , S1                                                     ;/*  ARG1: CAUSE                 */
    MOV     A2 , S2                                                     ;/*  ARG2: BADVADDR              */
    MOV     A3 , S3                                                     ;/*  ARG3: SP                    */
    SUBU    SP , 32
    JAL     \handle
    NOP

    JAL     API_InterExit
    NOP
    ADDU    SP , 32

    RESTORE_REGS                                                        ;/*  ���мĴ�����ջ              */

    .set    pop
    MACRO_END()

;/*********************************************************************************************************
;  �ж����
;*********************************************************************************************************/

FUNC_DEF(archInterruptEntry)
    .set    push
    .set    noat
    .set    noreorder
    .set    volatile

    EXCEPTION_ENTRY     bspIntHandle

    .set    pop
    FUNC_END(archInterruptEntry)

;/*********************************************************************************************************
;  Cache �����쳣���
;*********************************************************************************************************/

FUNC_DEF(archCacheErrorEntry)
    .set    push
    .set    noat
    .set    noreorder
    .set    volatile

    EXCEPTION_ENTRY     archCacheErrorHandle

    .set    pop
    FUNC_END(archCacheErrorEntry)

;/*********************************************************************************************************
;  ͨ���쳣���
;*********************************************************************************************************/

FUNC_DEF(archExceptionEntry)
    .set    push
    .set    noat
    .set    noreorder
    .set    volatile

    EXCEPTION_ENTRY     archExceptionHandle

    .set    pop
    FUNC_END(archExceptionEntry)

    FILE_END()

;/*********************************************************************************************************
;  END
;*********************************************************************************************************/