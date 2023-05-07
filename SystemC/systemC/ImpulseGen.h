#ifndef IMPULSEGEN_H
#define IMPULSEGEN_H

#include <systemc.h>

/**
  Impulse generator:
   creates <count> impulses every <sync>
  */
SC_MODULE(ImpulseGen)
{
    /*** INPUT SIGNALS: ***/
    sc_in<bool> clk;            // input clock
    sc_in<bool> reset;          // input reset
    sc_in<bool> sync;           // input synchronisation signal
    sc_in<sc_uint<4> > count;   // impulse count
    
    /*** OUTPUT SIGNALS: ***/
    sc_out<bool> impulses;      // output impulses

    /*** INTERNAL SIGNALS: ***/
    sc_signal<sc_uint<4> > count_left; // impulses left
    
    // main method; is called on every clk
    void on_tick();

    // constructor of module
    SC_CTOR(ImpulseGen)
    {
        // on_tick will be called on every positive clk
        SC_METHOD(on_tick);
        sensitive << clk.pos();
    }
};

#endif // IMPULSEGEN_H
