#ifndef IMPULSEGENTEST_H
#define IMPULSEGENTEST_H

#include <iostream>
#include <systemc.h>

/**
 UnitTest for impulse generator
 */
SC_MODULE(ImpulseGenTest)
{
    /*** ImpulseGen interface signal ***/
    sc_in<bool>         clk;
    sc_out<bool>         reset;
    sc_out<bool>        sync;
    sc_out<sc_uint<4> > count;
    sc_in<bool>         impulses;

    // internal signal to call check_impulses
    sc_signal<bool>     check;
    
    // current impulse count
    unsigned int impulse_count;

    // SC_THREAD: generates sync,reset and count signals
    void generate_sync();
    // SC_METHOD: checks that impulse count is same as expected
    void check_impulses();
    // SC_METHOD: updates impulse count
    void update_impulses();

    // constructor of test bench
    SC_CTOR(ImpulseGenTest):
        impulse_count(0)
    {
        SC_THREAD(generate_sync);
        sensitive << clk.pos();
        
        SC_METHOD(check_impulses);
        dont_initialize();
        sensitive << check.posedge_event();
        
        SC_METHOD(update_impulses);
        dont_initialize();
        sensitive << impulses.pos();
    }
};

#endif // IMPULSEGENTEST_H
