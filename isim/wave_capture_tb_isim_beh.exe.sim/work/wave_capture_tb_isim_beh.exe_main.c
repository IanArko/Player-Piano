/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

#include "xsi.h"

struct XSI_INFO xsi_info;



int main(int argc, char **argv)
{
    xsi_init_design(argc, argv);
    xsi_register_info(&xsi_info);

    xsi_register_min_prec_unit(-12);
    work_m_15775776533280659933_2391653975_init();
    work_m_02580701195797488590_0546062604_init();
    work_m_15775776533280659933_2983572188_init();
    work_m_02580701195797488590_1891901324_init();
    work_m_03389591354448859605_0093769084_init();
    work_m_02580701195797488590_1424778818_init();
    work_m_03389591354448859605_0456731759_init();
    work_m_02155967515011732344_3015034311_init();
    work_m_07618462326891969560_0118774540_init();
    work_m_16541823861846354283_2073120511_init();


    xsi_register_tops("work_m_07618462326891969560_0118774540");
    xsi_register_tops("work_m_16541823861846354283_2073120511");


    return xsi_run_simulation(argc, argv);

}
