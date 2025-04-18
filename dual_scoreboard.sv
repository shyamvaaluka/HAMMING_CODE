////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_scoreboard.sv                                         //
//                                                                                //
//                                                                                //
//  File Description : The scoreboard class collects actual transactions from     //
//                     monitor and golden values from refrence model and          //
//                     compares both the transactions to checks for any           //
//                     mismatch.                                                  //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_scoreboard;

	//User defined data type for transaction class, t_sb of type trans.
  typedef trans t_sb;
	
  // Mailbox declaration for reference model to scoreboard connection for port-a.
  mailbox#(t_sb)rm2sb_a;
	// Mailbox declaration for reference model to scoreboard connection for port-b.
  mailbox#(t_sb)rm2sb_b;
	// Mailbox declaration for monitor to scoreboard connection for port-a.
  mailbox#(t_sb)mon2sb_a;
	// Mailbox declaration for monitor to scoreboard connection for port-b.
  mailbox#(t_sb)mon2sb_b;

  
  // Channel descriptor for printing scoreboard transactions in a text file.
  int fd_sb;
  // Internal variables for counting pass and fail transactions for port-a.
  int sb_xtn_pass_a,sb_xtn_fail_a;
  // Internal variables for counting pass and fail transactions for port-b.
  int sb_xtn_pass_b,sb_xtn_fail_b;
	// Internal variable to count number of transactions recieved for port-a and port-b.
  int rcv_xtn_a,rcv_xtn_b;
  
  extern function new(mailbox#(t_sb)rm2sb_a,
		                  mailbox#(t_sb)rm2sb_b,
		                  mailbox#(t_sb)mon2sb_a,
		                  mailbox#(t_sb)mon2sb_b);
  extern task start_a;
  extern task start_b;
  extern task start;

endclass
  
	// Constructor new that defines all the local mailbox connections with global mailboxes.
  function dual_scoreboard::new(mailbox#(t_sb)rm2sb_a,
		                            mailbox#(t_sb)rm2sb_b,
		                            mailbox#(t_sb)mon2sb_a,
		                            mailbox#(t_sb)mon2sb_b);
		this.rm2sb_a  = rm2sb_a;
		this.rm2sb_b  = rm2sb_b;
		this.mon2sb_a = mon2sb_a;
		this.mon2sb_b = mon2sb_b;

	endfunction

  // Task start_a collects all the transactions from reference model and monitor of port-a and compares both the transactions
  // for any mismatch. Also indicates double bit errors.                                                                                                       
  task dual_scoreboard::start_a;
   t_sb tmon2sb_a;
   t_sb tref2sb_a;
  fork
    forever begin
      fork
        begin
          mon2sb_a.get(tmon2sb_a);
          tmon2sb_a.fdisplay(fd_sb,"Packet Received from PORTA MONITOR");
        end
        begin
          rm2sb_a.get(tref2sb_a);
          tref2sb_a.fdisplay(fd_sb,"Packet Received from PORTA Reference Model");
        end
      join
      if(tmon2sb_a.o_errora != 1)
      begin
        if(tref2sb_a.compare(tmon2sb_a))
        begin
          sb_xtn_pass_a++;
          tref2sb_a.fdisplay(fd_sb,"Comparison Successful - Expected Data");
          tmon2sb_a.fdisplay(fd_sb,"Actual Data");
          $display("===========================PORT_A===================================");
          $display("Passed: output of reference model: %0d and output of monitor: %0d at time %0t\n",tref2sb_a.douta,tmon2sb_a.douta,$time);
        end

        else
        begin
          sb_xtn_fail_a++;
          tref2sb_a.fdisplay(fd_sb,"Actual Data Not matched with the Expected Data");
          tmon2sb_a.fdisplay(fd_sb,"Actual Data");  
          $display("===========================PORT_A====================================");
          $display("Failed: output of reference model: %0d and output of monitor: %0d at time %0t\n",tref2sb_a.douta,tmon2sb_a.douta,$time);
        end
        rcv_xtn_a++;
      end
      else
        $display("DOUBLE_BIT_SCENARIO IN PORT-A");
    end
  join_none
  endtask

  // Task start_a collects all the transactions from reference model and monitor of port-b and compares both the transactions
  // for any mismatch. Also indicates double bit errors.                                                                                                      
  task dual_scoreboard::start_b;
  t_sb tmon2sb_b;
  t_sb tref2sb_b;
  fork
    forever begin
      fork
        begin
          mon2sb_b.get(tmon2sb_b);
          tmon2sb_b.fdisplay(fd_sb,"Packet recieved from PORTB monitor");
        end
        begin
          rm2sb_b.get(tref2sb_b);
          tref2sb_b.fdisplay(fd_sb,"Packet recieved from PORTB reference Model");
        end
      join
      if(tmon2sb_b.o_errorb != 1)
      begin
        if(tmon2sb_b.compare(tref2sb_b))
        begin
          sb_xtn_pass_b++;
          tref2sb_b.fdisplay(fd_sb,"Comparison Successful - Expected Data");
          tmon2sb_b.fdisplay(fd_sb,"Actual Data");
          $display("===========================PORT_B===================================");                                                  
          $display("Passed: output of reference model: %0d and output of monitor: %0d at time %0t\n",tref2sb_b.doutb,tmon2sb_b.doutb,$time);
        end
        else
        begin
          sb_xtn_fail_b++;
          tref2sb_b.fdisplay(fd_sb,"Actual Data Not matched with the Expected Data");
          tmon2sb_b.fdisplay(fd_sb,"Actual Data");
          $display("===========================PORT_B===================================");                                                    
          $display("Failed: output of reference model: %0d and output of monitor: %0d at time %0t\n",tref2sb_b.doutb,tmon2sb_b.doutb,$time);
        end


        rcv_xtn_b++;
      end
        else
        $display("DOUBLE_BIT_SCENARIO IN PORT-B");  
    end
          
  join_none
  endtask 

  // Task start initiates both the local tasks start_a and start_b in parallel execution and also opens the channel descriptor in write mode.
  task dual_scoreboard::start();
    fd_sb=$fopen("port_sb.txt","w");
    fork
      start_a();
      start_b();
    join_none
  endtask
