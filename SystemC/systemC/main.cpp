#include <systemc.h>
#include "ImpulseGen.h"
#include "ImpulseGenTest.h"

// main is defined in systemc.lib
int sc_main(int argc,char *argv[])
{
    // create modules
    ImpulseGen              igen("igen");
    ImpulseGenTest          igentest("igen_test");

    //create 200MHz clock
    sc_clock                s_clk("clk",5,SC_NS);

    // create signals
    sc_signal<bool>         s_reset("reset");
    sc_signal<bool>         s_sync("sync");
    sc_signal<sc_uint<4> >  s_count("count");
    sc_signal<bool>         s_impulses("impulses");
    
    // connect signals
    igentest.clk(s_clk);
    igentest.reset(s_reset);
    igentest.sync(s_sync);
    igentest.count(s_count);
    igentest.impulses(s_impulses);
    
    igen.clk(s_clk);
    igen.reset(s_reset);
    igen.sync(s_sync);
    igen.count(s_count);
    igen.impulses(s_impulses);
    
    // create output trace file 
    sc_trace_file *tf = sc_create_vcd_trace_file("lab1");
    tf->set_time_unit(1,SC_NS);
        
    // all changed in signals will be auto output'ed to trace file
    sc_trace(tf,s_clk,"clk");
    sc_trace(tf,s_reset,"reset");
    sc_trace(tf,s_sync,"sync");
    sc_trace(tf,s_count,"count");
    sc_trace(tf,s_impulses,"impulses");
//    sc_trace(tf,igen.count_left,"igen.count_left");

    sc_start(20000,SC_NS);
    
    sc_close_vcd_trace_file(tf);
    
    return 0;
}
