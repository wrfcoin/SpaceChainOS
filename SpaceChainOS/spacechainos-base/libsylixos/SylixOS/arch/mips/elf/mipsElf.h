/*********************************************************************************************************
**
**                                    �й�������Դ��֯
**
**                                   Ƕ��ʽʵʱ����ϵͳ
**
**                                SylixOS(TM)  LW : long wing
**
**                               Copyright All Rights Reserved
**
**--------------�ļ���Ϣ--------------------------------------------------------------------------------
**
** ��   ��   ��: mipsElf.h
**
** ��   ��   ��: Ryan.Xin (�Ž���)
**
** �ļ���������: 2015 �� 09 �� 09 ��
**
** ��        ��: ʵ�� MIPS ��ϵ�ṹ�� ELF �ļ��ض�λ.
*********************************************************************************************************/

#ifndef __ARCH_MIPSELF_H
#define __ARCH_MIPSELF_H

#ifdef LW_CFG_CPU_ARCH_MIPS                                             /*  MIPS ��ϵ�ṹ               */

#define ELF_CLASS       ELFCLASS32
#define ELF_ARCH        EM_MIPS

#endif                                                                  /*  LW_CFG_CPU_ARCH_MIPS        */
#endif                                                                  /*  __ARCH_MIPSELF_H            */
/*********************************************************************************************************
  END
*********************************************************************************************************/