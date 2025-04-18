////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_driver_b.sv                                           //
//                                                                                //
//                                                                                //
//  File Description : This is the driver class for port-b. This class            //
//                     receives packets from generator and drives them to         //
//                     port-a signals of the DUT through virtual interface.       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_driver_b;

	// User defined data type for virtual interface of port-a driver.
  typedef  virtual dual_iff d_if1;
	// Object handle for the virtual interface
  d_if1 vif;
	
	// User defined data type for transaction class, t_3 of type trans.
  typedef trans t_3;
  // Object handle for transaction class.
  t_3 t5,t6;
  
  // Local variable to determine the number of transactions driven.
  dual_generator genh_b;
	// Mailbox for getting the transactions from generator class.
  mailbox#(t_3)gen2drv_b;
  // Channel descriptor for printing driver transactions of port-b.
  int fd_b;
  // Local variable to count number of port-b transactions driven.
  int drv_b_xtn;

  extern function new(mailbox#(t_3)gen2drv_b,
		                  d_if1 vif);
  extern task start;
  extern task send_to_dut(t_3 rcv_xtn1);

endclass

	
  // Constructor new that defines local mailbox connections between driver and interface
  // and defines the connection between virtual to static inteface. Also creates objects
  // for transaction class handles.                                                     
  function dual_driver_b::new(mailbox#(t_3)gen2drv_b,
		                          d_if1 vif);
		this.gen2drv_b = gen2drv_b;
		this.vif       = vif;
		t5             = new;
	endfunction

  // This start method gets all the port-b transactions through the mailbox using get() method from genrator and
  // drives them to the user defined task send_to_dut. Also it prints all the transactions in a text file called
  // drv_b.txt for debugging purposes.                                                                          
	task dual_driver_b::start;
	  fork
    fd_b = $fopen("PORT-B/drv_b.txt","w");
	  	forever
	  	begin
        genh_b.start();
	  		gen2drv_b.get(t5);
	  		t6 = new t5;
	  		send_to_dut(t6);
	  	end
	  join_none
	endtask
  
  // This local task drives the recieved transactions to the DUT via virtual interface of port-b.
	task dual_driver_b::send_to_dut(t_3 rcv_xtn1);
    drv_b_xtn++;
		@(vif.drv_portb);
    if(rcv_xtn1.op == WRITE && rcv_xtn1.porting == PORTB)
    begin
	    vif.drv_portb.i_enb <= 1'b1;
	    vif.drv_portb.i_web <= 1'b1;
    end
    else if(rcv_xtn1.op == READ && rcv_xtn1.porting == PORTB)
    begin
      vif.drv_portb.i_enb <= 1'b1;
      vif.drv_portb.i_web <= 1'b0;
    end
    else
    begin
      vif.drv_portb.i_enb <= 1'b0;
    end
    if(gen2drv_b.num == 0)
      vif.drv_portb.i_enb <= 1'b0;
	  vif.drv_portb.i_addrb <= rcv_xtn1.addr;
	  vif.drv_portb.i_dinb  <= rcv_xtn1.din;
    $fdisplay(fd_b,$sformatf("=====================TIME:%0dns=====TRANS_NO_B:%0d=================================",$time,drv_b_xtn));
    rcv_xtn1.fdisplay(fd_b,"PORT B: Driving Data to DUT");
	endtask
