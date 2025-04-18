////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_test.sv                                               //
//                                                                                //
//                                                                                //
//  File Description : The test class initiates the run and build tasks in        //
//                     the environment class which inturn initializes the         //
//                     start tasks of all TB components.                          //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_test;

  // Object handle for environment class
  dual_env envh;
  // User defined data tpye for driver class of port-a.
  typedef virtual dual_iff.DRV_PA d_iff1;
  // User defined data tpye for monitor class of port-a.
  typedef virtual dual_iff.MON_PA d_iff2;
  // User defined data tpye for driver class of port-b.
  typedef virtual dual_iff.DRV_PB d_iff3;
  // User defined data tpye for monitor class of port-b.
  typedef virtual dual_iff.MON_PB d_iff4;

  // Object handle for virtual interface of driver class port-a.
  d_iff1 vif1;
  // Object handle for virtual interface of monitor class port-a.
  d_iff2 vif2;
  // Object handle for virtual interface of driver class port-b.
  d_iff3 vif3;
  // object handle for virtual interface of monitor class port-b.
  d_iff4 vif4;

  
  extern function new(d_iff1 vif1, 
                      d_iff2 vif2,
                      d_iff3 vif3,
                      d_iff4 vif4);
  extern task run();

endclass

  // Constructor new function that connects local virtual interfaces with
  // global virtual interfaces of driver and monitor classes of port-a and
  // port-b. Also it creates object for environment class handle.
  function dual_test::new(d_iff1 vif1, 
                          d_iff2 vif2,
                          d_iff3 vif3,
                          d_iff4 vif4
                          );
    this.vif1  = vif1;
    this.vif2  = vif2;
    this.vif3  = vif3;
    this.vif4  = vif4;
    envh       = new(vif1,vif3,vif2,vif4);
  endfunction

  // Run task initializes the build task and run task in environment class.
  task dual_test::run();
    envh.build();
    envh.run();
	endtask
