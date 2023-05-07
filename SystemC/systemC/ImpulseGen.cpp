#include "ImpulseGen.h"

void ImpulseGen::on_tick()
{
    if(reset)
    {
        count_left = 0;
        impulses = 0;
        return;
    }

    if(count_left.read() > 0)
    {
        if(impulses)
        {
            count_left = count_left.read() - 1;
            impulses = 0;
        }
        else
        {
            impulses = 1;
        }
    }
    else
    {
        if(sync.read())
        {
            count_left = count;
            impulses = count.read() != 0;
        }
        else
        {
            count_left = 0;
            impulses = 0;
        }
    }
}
