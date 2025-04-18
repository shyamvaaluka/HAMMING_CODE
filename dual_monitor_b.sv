////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_monitor_b.sv                                          // 
//                                                                                //
//                                                                                //
//  File Description : This is the monitor class for port-b, This class           //
//                     collects the processed DUT data of port-b transactions     // 
//                     via interface and stores this data in a local transaction  //
//                     handle, which is later sent to reference model and         // 
//                     scoreboard. It also calculates coverage of write and       //
//                     read operations of port-b.                                 //
//                                                                                //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_monitor_b;
	
	// User defined data type for virtual interface of monitor port-b.
  typedef virtual dual_iff.MON_PB m_if1;
	// Object handle for virtual interface.
  m_if1 vif;
  
  // These real data type variables store the coverage percentage of port-b read and write.
  real wr_port_b,rd_port_b;	
	
  // User defined data type for transaction class, t_7 of type trans.
  typedef trans t_7;
  // Object handles of transaction class for collecting coverage data.
  t_7 cov_wr_b,cov_rd_b;

	// Mailbox declaration for monitor to scoreboard connection.
  mailbox#(t_7)mon2sb_b;
	// Milbox declaration for monitor to reference model connection
  mailbox#(t_7)mon2rm_b;
  
  // event declaration for event triggering.
  event done_b;
  // Channel descriptor for printing monitor transactions of port-b.
  int fd_mon_b;

  // Covergroup for sampling write operation data of port-b transactions.
  covergroup write_port_b;
    ENB : coverpoint cov_wr_b.en{
                            bins HIGH = {1};
                            }
                      
    WEB:  coverpoint cov_wr_b.we {  
                            bins HIGH = {1};}

    ADDRB: coverpoint cov_wr_b.addr;

    DATA_IN_B: coverpoint cov_wr_b.din{
                                bins LOW   = {[0:5]};
                            bins MIN   = {[6:9]};
                                bins MIN1  = {[10:20]};
                                bins MID   = {[21:50]};
                                bins MID1  = {[51:100]};
                                bins HIGH  = {[101:200]};
                                bins HIGH1 = {[201:255]};}

    WEB_X_ADDRB_X_DATA_IN_B: cross WEB,ADDRB,DATA_IN_B; 

  endgroup

  // Covergroup for sampling read operation data of port-b transactions.
 covergroup read_port_b;
    ENB : coverpoint cov_rd_b.en{
                            bins HIGH = {1};
                            }
                      
    WEB:  coverpoint cov_rd_b.we {  
                            bins HIGH = {0};}

    ADDRB: coverpoint cov_rd_b.addr;

    DATA_IN_B: coverpoint cov_rd_b.din{
                                bins LOW   = {[0:5]};
                                bins MIN   = {[6:9]};
                                bins MIN1  = {[10:20]};
                                bins MID   = {[21:50]};
                                bins MID1  = {[51:100]};
                                bins HIGH  = {[101:200]};
                                bins HIGH1 = {[201:255]};}

    WEB_X_ADDRB_X_DATA_IN_B: cross WEB,ADDRB,DATA_IN_B; 

  endgroup

  extern function new(m_if1 vif,
		                  mailbox#(t_7)mon2rm_b,
		                  mailbox#(t_7)mon2sb_b);
  extern task start;
  extern task send_to_task;

endclass

	// Constructor new that defines local to global mailbox connections and connects virtual to static interface,
  // also creates objects for transaction handles.                                                             
  function dual_monitor_b::new(m_if1 vif,
		                           mailbox#(t_7)mon2rm_b,
		                           mailbox#(t_7)mon2sb_b);
		 this.mon2sb_b = mon2sb_b;
		 this.mon2rm_b = mon2rm_b;
		 this.vif      = vif;
     write_port_b  = new();
     read_port_b   = new();
	endfunction

	
  // Start task opens a file for printing monitor transactions and calls local task send_to_task. 
  task dual_monitor_b::start;
  fd_mon_b = $fopen("PORT-B/mon_b.txt","w");
		fork
			forever
			begin
				send_to_task();
			end
		join_none
	endtask

	// Task send_to_task collects the DUT outputs of port-b via virtual interface and stores them in transction handle which is later
  // sent to reference model and scoreboard classes through mailbox connections.                                                   
  task dual_monitor_b::send_to_task;
    t_7 t11 = new;
		@(vif.mon_portb);
		t11.we   = vif.mon_portb.i_web;
		t11.din  = vif.mon_portb.i_dinb;
		t11.addr = vif.mon_portb.i_addrb;
		t11.en   = vif.mon_portb.i_enb;
		if(t11.we == 1'b1 && t11.en == 1'b1)
		begin
		  t11.porting = PORTB;
	    t11.op      = WRITE;
      fork
      begin
        repeat(WR_LATENCYB-1) @(vif.mon_portb);
        #1;
        mon2rm_b.put(t11);
        t11.fdisplay(fd_mon_b,"Sending WR to REF MODEL from monitor B") ; 
      end
      join_none
		end
   	else if(t11.we == 1'b0 && t11.en == 1'b1)
		begin
	 		t11.porting = PORTB;
			t11.op      = READ;
      mon2rm_b.put(t11);
      t11.fdisplay(fd_mon_b,"Sending  RD to REF MODEL from monitor B");
      fork
      begin
        repeat(RD_LATENCYB)
        @(vif.mon_portb);
        t11.doutb    = vif.mon_portb.o_doutb;
        t11.o_errorb = vif.mon_portb.o_errorb;
        mon2sb_b.put(t11);
        t11.fdisplay(fd_mon_b,"Sending RD data collected from DUT to SB from B");
      end
      join_none
		end
		else
		begin
			t11.porting = PORTB;
			t11.op      = NONE;
		end
 	   cov_wr_b  = t11;
     cov_rd_b  = t11;
     write_port_b.sample();
     read_port_b.sample();
     wr_port_b = write_port_b.get_coverage();
     rd_port_b = read_port_b.get_coverage();
     if(wr_port_b == 100.000000 && rd_port_b == 100.000000)
       ->done_b;	
		
	endtask
