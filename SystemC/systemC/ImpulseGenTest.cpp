#include "ImpulseGenTest.h"

void ImpulseGenTest::generate_sync()
{
    reset.write(1);
    wait();
    reset.write(0);
    check.write(0);
    sync.write(0);
    count.write(0);
    wait(200,SC_NS);
    wait();

    while(1)
    {
        //Check
        check.write(1);
        wait();
        check.write(0);

        //New iteration
        count = count.read() - 1;
        sync.write(1);
        wait();
        sync.write(0);
        wait(500,SC_NS);
    }
}

void ImpulseGenTest::check_impulses()
{
    if(impulse_count != count.read())
    {
        std::cerr << "Error at" << sc_time_stamp() << ": generated " << impulse_count;
        std::cerr << " when required " << count.read() << std::endl;
    }
    impulse_count = 0;
}

void ImpulseGenTest::update_impulses()
{
    ++impulse_count;
}
