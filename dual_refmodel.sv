////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_refmodel.sv                                           // 
//                                                                                //
//                                                                                //
//  File Description : The reference model class mimics the DUT model, by         //
//                     taking input values sent from monitor class and            //
//                     generates golden values which are mimic of actual DUT      // 
//                     outputs.                                                   //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_refmodel;

	// User defined data type for transaction class, ref_1 is of type trans.
  typedef trans ref_1;
	// Mailbox declaration for monitor to reference model connection of port-a.
  mailbox#(ref_1)mon2rm_a;
	// Mailbox declaration for monitor to reference model connection of port-b.
  mailbox#(ref_1)mon2rm_b;
	// Mailbox declaration for reference to scoreboard connection for port-a.
  mailbox#(ref_1)rm2sb_a;
	// Mailbox declaration for reference to scoreboard connection for port-a.
  mailbox#(ref_1)rm2sb_b;
	
  // Channel descriptor for printing refrence model transactions in a text file.
  int fd_ref;

	// Local memory that mimics the DP RAM.
  static logic [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0];

  extern function new(mailbox#(ref_1)mon2rm_a,
		                  mailbox#(ref_1)mon2rm_b,
		                  mailbox#(ref_1)rm2sb_a,
		                  mailbox#(ref_1)rm2sb_b);
  extern task start;
  extern task send_to_refa(ref_1 rcv_xtn1);
  extern task send_to_refb(ref_1 rcv_xtn2);

endclass

	// Constructor new method that defines mailbox connections for monitor to refrence model and refrence model to scoreboard
  // of port-a and port-b.                                                                                                 
  function dual_refmodel::new(mailbox#(ref_1)mon2rm_a,
		                          mailbox#(ref_1)mon2rm_b,
		                          mailbox#(ref_1)rm2sb_a,
		                          mailbox#(ref_1)rm2sb_b);
		this.mon2rm_a = mon2rm_a;
		this.mon2rm_b = mon2rm_b;	
		this.rm2sb_a  = rm2sb_a;
		this.rm2sb_b  = rm2sb_b;
	endfunction

	// Task start gets all the monitor transactions from port-a and port-b and sends them to user defines tasks send_to_refa and
  // send_to_refb.                                                                                                            
  task dual_refmodel::start();
  ref_1 t12 = new;
  ref_1 t13 = new;
  ref_1 t14,t15;
  fd_ref    = $fopen("REF.txt","w");
	begin
		fork
			forever
				begin
					mon2rm_a.get(t12);
          t12.fdisplay(fd_ref,"RD packet Received from PORT_A MONITOR");
          t14 = new t12;
          send_to_refa(t14);
				end

			forever
				begin
		   		mon2rm_b.get(t13);
          t13.fdisplay(fd_ref,"RD packet Received from PORT_B MONITOR");
          t15 = new t13;
		    	send_to_refb(t15);
		    end
		join_none	
	end
	endtask

  // Task send_to_refa gets all read and write data of port-a transactions and generates golden values of outputs for read operation of
  // port-a transactions by performing write and read operations with local memory. And sends it to scoreboard.                        
	task dual_refmodel::send_to_refa(ref_1 rcv_xtn1 );
		if(rcv_xtn1.en == 1'b1)
		begin
		 	 if(rcv_xtn1.we == 1'b1)
	     begin
	     	 mem[rcv_xtn1.addr] = rcv_xtn1.din;
         $fdisplay(fd_ref,$sformatf("memory write by port-a:%p at time :%0t",mem,$time));
         rcv_xtn1.fdisplay(fd_ref,"PORT A WRITE reference data sent to SB");
	     end
	     else
	     begin
	     	 rcv_xtn1.douta = mem[rcv_xtn1.addr];
         rm2sb_a.put(rcv_xtn1);
         $fdisplay(fd_ref,$sformatf("douta in refrence model of port-a read:%0d at time: %0t",rcv_xtn1.douta,$time));
         rcv_xtn1.fdisplay(fd_ref,"PORT A Read reference data sent to SB");
	     end
		end
		else
		begin
			rcv_xtn1.douta     = rcv_xtn1.douta;
			mem[rcv_xtn1.addr] = mem[rcv_xtn1.addr];
		end
	endtask		

	// Task send_to_refb gets all read and write data of port-b transactions and generates golden values of outputs for read operation of
  // port-b transactions by performing write and read operations with local memory. And sends it to scoreboard.                        
  task dual_refmodel::send_to_refb(ref_1 rcv_xtn2);
		if(rcv_xtn2.en == 1'b1)
		begin
		  if(rcv_xtn2.we == 1'b1)
	    begin
	    	mem[rcv_xtn2.addr] = rcv_xtn2.din;
        rcv_xtn2.fdisplay(fd_ref,"PORT B WRITE reference data sent to SB");
	    end
	    else
	    begin
	    	rcv_xtn2.doutb = mem[rcv_xtn2.addr];
        rm2sb_b.put(rcv_xtn2);
        $fdisplay(fd_ref,$sformatf("doutb in refrence model of port-b read:%0d at time: %0t",rcv_xtn2.doutb,$time));
        rcv_xtn2.fdisplay(fd_ref,"PORT B READ reference data sent to SB");
	   end
		 end
		 else
		 begin
			 rcv_xtn2.doutb     = rcv_xtn2.doutb;
			 mem[rcv_xtn2.addr] = mem[rcv_xtn2.addr];
		 end
	endtask	
