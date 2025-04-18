////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_monitor_a.sv                                          // 
//                                                                                //
//                                                                                //
//  File Description : This is the monitor class for port-a, This class           //
//                     collects the processed DUT data of port-a transactions     // 
//                     via interface and stores this data in a local transaction  //
//                     handle, which is later sent to reference model and         // 
//                     scoreboard. It also calculates coverage of write and       //
//                     read operations of port-a.                                 //
//                                                                                //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_monitor_a;

  // These real data type variables store the coverage percentage of port-a read and write.
  real wr_port_a,rd_port_a;
  // event declaration for event triggering.
  event done_a;
  // Channel descriptor for printing monitor transactions of port-a.
  int fd_mon_a;

	// User defined data type for virtual interface of monitor port-a.
  typedef virtual dual_iff.MON_PA m_if;
	// Object handle for virtual interface.
  m_if vif;
	
  // User defined data type for transaction class, t_3 of type trans.
  typedef trans t_3;
  // Object handles of transaction class for collecting coverage data.
  t_3 cov_wr_a,cov_rd_a; 

  // Mailbox declaration for monitor to scoreboard connection.
  mailbox#(t_3)mon2sb_a;
	// Milbox declaration for monitor to reference model connection
  mailbox#(t_3)mon2rm_a;

  // Covergroup for sampling write operation data of port-a transactions. 
  covergroup write_port_a;
    ENA : coverpoint cov_wr_a.en{
                            bins HIGH = {1};
                            }
                      
    WEA:  coverpoint cov_wr_a.we {  
                            bins HIGH = {1};}

    ADDRA: coverpoint cov_wr_a.addr;

    DATA_IN_A: coverpoint cov_wr_a.din{
                                bins LOW   = {[0:5]};
                                bins MIN   = {[6:9]};
                                bins MIN1  = {[10:20]};
                                bins MID   = {[21:50]};
                                bins MID1  = {[51:100]};
                                bins HIGH  = {[101:200]};
                                bins HIGH1 = {[201:255]};}

    WEA_X_ADDRA_X_DATA_IN_A: cross WEA,ADDRA,DATA_IN_A; 
  endgroup


  // Covergroup for sampling read operation data of port-a transactions.
  covergroup read_port_a;
    ENA : coverpoint cov_rd_a.en{
                            bins HIGH = {1};
                            }
                      
    WEA:  coverpoint cov_rd_a.we {  
                            bins LOW = {0};}

    ADDRA: coverpoint cov_rd_a.addr;

    DATA_IN_A: coverpoint cov_rd_a.din{
                                bins LOW   = {[0:5]};
                                bins MIN   = {[6:9]};
                                bins MIN1  = {[10:20]};
                                bins MID   = {[21:50]};
                                bins MID1  = {[51:100]};
                                bins HIGH  = {[101:200]};
                                bins HIGH1 = {[201:255]};}

    WEA_X_ADDRA_X_DATA_IN_A: cross WEA,ADDRA,DATA_IN_A; 

  endgroup

  extern function new(m_if vif,            
                      mailbox#(t_3)mon2rm_a,
                      mailbox#(t_3)mon2sb_a);
  extern task start;
  extern task send_to_task;

endclass

  // Constructor new that defines local to global mailbox connections and connects virtual to static interface,
  // also creates objects for transaction handles.                                                             
	function dual_monitor_a::new(m_if vif,
		                           mailbox#(t_3)mon2rm_a,
		                           mailbox#(t_3)mon2sb_a);
		this.mon2sb_a = mon2sb_a;
		this.mon2rm_a = mon2rm_a;
		this.vif      = vif;
    write_port_a  = new();
    read_port_a   = new();
	endfunction

  // Start task opens a file for printing monitor transactions and calls local task send_to_task.
	task dual_monitor_a::start;
  fd_mon_a = $fopen("PORT-A/mon_a.txt","w");
		fork
			forever
				begin
					send_to_task();
				end
		join_none
	endtask

  // Task send_to_task collects the DUT outputs of port-a via virtual interface and stores them in transction handle which is later
  // sent to reference model and scoreboard classes through mailbox connections.                                                   
	task dual_monitor_a::send_to_task;
		t_3 t9 = new;
    @(vif.mon_porta);
    t9.addr = vif.mon_porta.i_addra;
    t9.en   = vif.mon_porta.i_ena;
    t9.we   = vif.mon_porta.i_wea;
    t9.din  = vif.mon_porta.i_dina;
		if(t9.we == 1'b1 && t9.en == 1'b1)
		begin
		  t9.porting = PORTA;
	    t9.op      = WRITE;
      fork
      begin
      repeat(WR_LATENCYA-1)  @(vif.mon_porta);
      #1;
      mon2rm_a.put(t9);
      t9.fdisplay(fd_mon_a,"Sending WR to REF model from monitor A");
      end
      join_none
		end
   	else if(t9.we == 1'b0 && t9.en == 1'b1)
		begin
	 		t9.porting = PORTA;
			t9.op      = READ;
      mon2rm_a.put(t9);
      t9.fdisplay(fd_mon_a,"Sending Read to REF model from monitor A");
      fork
      begin
        repeat(RD_LATENCYA)
         @(vif.mon_porta);
         t9.douta    = vif.mon_porta.o_douta;
         t9.o_errora = vif.mon_porta.o_errora;
         mon2sb_a.put(t9);
         t9.fdisplay(fd_mon_a,"Sending RD Data collected from DUT to SB");
      end
      join_none
		end
		else
		begin
			t9.porting = PORTA;
			t9.op      = NONE;
		end
    cov_wr_a  = t9;
    cov_rd_a  = t9;
    write_port_a.sample();
    read_port_a.sample();
    wr_port_a = write_port_a.get_coverage();
    rd_port_a = read_port_a.get_coverage();
    if(wr_port_a == 100.000000 && rd_port_a == 100.000000)
      ->done_a;
 	endtask
