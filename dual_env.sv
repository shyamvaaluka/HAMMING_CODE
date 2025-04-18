////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_env.sv                                                // 
//                                                                                //
//                                                                                //
//  File Description : This is the environment class that builds all the          //
//                     connections of multiple classes. And initializes all       //
//                     the start methods of all the classes in parallel           //
//                     execution. Environment class acts as a main class for      //
//                     all the TB components.                                     //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_env;

  // Userdefined data type for transaction class, t_5 of type trans.
  typedef trans t_5;

  // Global mailbox for port-a transactions in generator class.
  mailbox#(t_5)dual_env     = new();
  // Global mailbox for port-b transactions in genrator class.
  mailbox#(t_5)dual_env1    = new();
  // Global mailbox for monitor to reference model connection for port-a.
  mailbox#(t_5)dual_refa    = new();
  // Global mailbox for monitor to reference model connection for port-b.
  mailbox#(t_5)dual_refb    = new();
  // Global mailbox for monitor to scoreboard connection for port-a.
  mailbox#(t_5)dual_sb_a    = new();
  // Global mailbox for monitor to scoreboard connection for port-b.
  mailbox#(t_5)dual_sb_b    = new();
  // Global mailbox for reference model to scoreboard connection for port-a.
  mailbox#(t_5)dual_rm_sb_a = new();
  // Global mailbox for reference model to scoreboard connection for port-b.
  mailbox#(t_5)dual_rm_sb_b = new();

  // User defined data type for virtual interface of port-a driver.
  typedef virtual dual_iff.DRV_PA d_if;
  // Object handle for virtual interface of port-a driver.
  d_if vif1;

  // User defined data type for virtual interface of port-b driver.
  typedef  virtual dual_iff.DRV_PB d_if1;
  // Object handle for virtual interface of port-b driver.
  d_if1 vif2;

  // User defined data type for virtual interface of port-a monitor.
  typedef virtual dual_iff.MON_PA m_if;
  // Object handle for virtual interface of port-a monitor.
  m_if vif3;

  // User defined data type for virtual interface of port-b monitor.
  typedef virtual dual_iff.MON_PB m_if1;
  // Object handle for virtual interface of port-b monitor.
  m_if1 vif4;

  // Object handle for generator class.
  dual_generator  gen;
  // Object handle for port-a driver class.
  dual_driver_a   drv_a;
  // Object handle for port-b driver class.
  dual_driver_b   drv_b;
  // Object handle for port-a monitor class.
  dual_monitor_a  mon_a;
  // Object handle for port-b monitor class.
  dual_monitor_b  mon_b;
  // Object handle for reference model class.
  dual_refmodel   reference;
  // Object handle for scoreboard class.
  dual_scoreboard sb;

  extern function new(d_if vif1,
                      d_if1 vif2,
                      m_if vif3,
                      m_if1 vif4);
  extern task build();
  extern task run();

endclass

 
  // Constructor new that defines all port-a and port-b virtual interface to static interface
  // connections of drivers and monitors.                                                    
  function dual_env::new(d_if vif1,
                         d_if1 vif2,
                         m_if vif3,
                         m_if1 vif4
                         );
    this.vif1 = vif1;
    this.vif2 = vif2;
    this.vif3 = vif3;
    this.vif4 = vif4;
         
  endfunction

  // Build task defines all the mailbox connections from one class to another class in hierarchial manner along with global genrator class to
  // local generator class connections present in both driver classes of port-a and port-b.                                                  
  task dual_env::build();
    gen          = new(dual_env,dual_env1);
    drv_a        = new(vif1,dual_env);
    drv_b        = new(dual_env1,vif2);
    mon_a        = new(vif3,dual_refa,dual_sb_a);
    mon_b        = new(vif4,dual_refb,dual_sb_b);
    reference    = new(dual_refa,dual_refb,dual_rm_sb_a,dual_rm_sb_b);
    sb           = new(dual_rm_sb_a,dual_rm_sb_b,dual_sb_a,dual_sb_b);
    drv_a.genh_a = gen;
    drv_b.genh_b = gen;
  endtask

  task dual_env::run();
    drv_a.start();
    mon_a.start();
    drv_b.start();
    mon_b.start();
    reference.start();
    sb.start();
     fork
       begin
         #2000000;
         $display("\n");
         $display("NOT COVERED 100%% COVERAGE");      
       end
       begin
         wait(mon_a.done_a.triggered);
         wait(mon_b.done_b.triggered);
         $display("COVERED 100%% COVERAGE");
       end
     join_any

     $display($sformatf("write_coverage_a :%2f",mon_a.wr_port_a));
     $display($sformatf("read_coverage_a  :%2f",mon_a.rd_port_a));
     $display($sformatf("write_coverage_b :%2f",mon_b.wr_port_b));
     $display($sformatf("read_coverage_b  :%2f",mon_b.rd_port_b));
     $display("\n");
     
     $display("PASS COUNT PORT-A:%0d",sb.sb_xtn_pass_a);
     $display("FAIL COUNT PORT-A:%0d",sb.sb_xtn_fail_a);
     $display("PASS COUNT PORT-B:%0d",sb.sb_xtn_pass_b);
     $display("FAIL COUNT PORT-B:%0d",sb.sb_xtn_fail_b);

     $display("\n");
     $display($sformatf("write_coverage :%0f",(mon_a.wr_port_a+mon_b.wr_port_b)/2));
     $display($sformatf("read_coverage  :%0f",(mon_b.rd_port_b+mon_a.rd_port_a)/2));

     $finish;
   endtask
