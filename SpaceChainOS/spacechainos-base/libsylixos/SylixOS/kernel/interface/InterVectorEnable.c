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
** ��   ��   ��: InterVectorEnable.c
**
** ��   ��   ��: Han.Hui (����)
**
** �ļ���������: 2007 �� 02 �� 02 ��
**
** ��        ��: ʹ��ָ���������ж�, ϵͳ����Ӧ�������ж�.

** BUG:
2013.08.28  �����ں��¼������.
*********************************************************************************************************/
#define  __SYLIXOS_KERNEL
#include "../SylixOS/kernel/include/k_kernel.h"
/*********************************************************************************************************
** ��������: API_InterVectorEnable
** ��������: ʹ��ָ���������ж�
** �䡡��  : ulVector                      �ж�������
** �䡡��  : ERROR
** ȫ�ֱ���: 
** ����ģ��: 
                                           API ����
*********************************************************************************************************/
LW_API  
ULONG  API_InterVectorEnable (ULONG  ulVector)
{
    INTREG  iregInterLevel;

    if (_Inter_Vector_Invalid(ulVector)) {
        _ErrorHandle(ERROR_KERNEL_VECTOR_NULL);
        return  (ERROR_KERNEL_VECTOR_NULL);
    }

    LW_SPIN_LOCK_QUICK(&_K_slVectorTable, &iregInterLevel);
    __ARCH_INT_VECTOR_ENABLE(ulVector);
    LW_SPIN_UNLOCK_QUICK(&_K_slVectorTable, iregInterLevel);
    
    MONITOR_EVT_LONG1(MONITOR_EVENT_ID_INT, MONITOR_EVENT_INT_VECT_EN, ulVector, LW_NULL);
    
    return  (ERROR_NONE);
}
/*********************************************************************************************************
** ��������: API_InterVectorDisable
** ��������: ����ָ���������ж�
** �䡡��  : ulVector                      �ж�������
** �䡡��  : ERROR
** ȫ�ֱ���: 
** ����ģ��: 
** ע  ��  : ��� ulVector Ϊ��Ƕ���ж�, �����ж��������н��ܱ��ж�, �˳��ж�ʱ���Զ���. 
             ���Խ��ܲ�����Ҫ������״̬�²���.

                                           API ����
*********************************************************************************************************/
LW_API  
ULONG  API_InterVectorDisable (ULONG  ulVector)
{
    INTREG  iregInterLevel;
    
    if (_Inter_Vector_Invalid(ulVector)) {
        _ErrorHandle(ERROR_KERNEL_VECTOR_NULL);
        return  (ERROR_KERNEL_VECTOR_NULL);
    }

    LW_SPIN_LOCK_QUICK(&_K_slVectorTable, &iregInterLevel);
    __ARCH_INT_VECTOR_DISABLE(ulVector);
    LW_SPIN_UNLOCK_QUICK(&_K_slVectorTable, iregInterLevel);
    
    MONITOR_EVT_LONG1(MONITOR_EVENT_ID_INT, MONITOR_EVENT_INT_VECT_DIS, ulVector, LW_NULL);
    
    return  (ERROR_NONE);
}
/*********************************************************************************************************
** ��������: API_InterVectorIsEnable
** ��������: ���ϵͳ��ָ�������ж���Ӧ״̬
** �䡡��  : ulVector                      �ж�������
**           pbIsEnable                    �Ƿ�ʹ��������ж�
** �䡡��  : ERROR
** ȫ�ֱ���: 
** ����ģ��: 
                                           API ����
*********************************************************************************************************/
LW_API  
ULONG  API_InterVectorIsEnable (ULONG  ulVector, BOOL  *pbIsEnable)
{
    if (_Inter_Vector_Invalid(ulVector)) {
        _ErrorHandle(ERROR_KERNEL_VECTOR_NULL);
        return  (ERROR_KERNEL_VECTOR_NULL);
    }
    
    if (!pbIsEnable) {
        _ErrorHandle(ERROR_KERNEL_MEMORY);
        return  (ERROR_KERNEL_MEMORY);
    }

    *pbIsEnable = __ARCH_INT_VECTOR_ISENABLE(ulVector);
    
    return  (ERROR_NONE);
}
/*********************************************************************************************************
  END
*********************************************************************************************************/