//
//  sleep.c
//  hemu
//
//  Created by hades on 2021/4/1.
//

#include "sleep.h"
#include <IOKit/pwr_mgt/IOPMLib.h>

void sleepNow()
{
    io_connect_t fb = IOPMFindPowerManagement(MACH_PORT_NULL);
    if (fb != MACH_PORT_NULL)
    {
        IOPMSleepSystem(fb);
        IOServiceClose(fb);
    }
}
