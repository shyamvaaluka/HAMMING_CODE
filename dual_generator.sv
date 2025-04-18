////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_generator.sv                                          //
//                                                                                //
//                                                                                //
//  File Description : This generator class initiates the packets and drives      //
//                     them to either port-a or port-b drivers based on the       //
//                     post randomized values of the enum data type porting       // 
//                     that is defined in the transaction class.                  //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_generator;

  // This is a user defined data type for transaction class, t_1 which is of type trans.
	typedef trans t_1;
  // Object handles for transaction class.
	t_1 t1,t2,t3,t4;
  
  // Mailbox for driving port-a transactions.
	mailbox#(t_1)gen2drv_a;
  // Mailbox for driving port-b transactions.
	mailbox#(t_1)gen2drv_b;

  extern function new(mailbox#(t_1)gen2drv_a,
		                  mailbox#(t_1)gen2drv_b);
  extern task start();

endclass

  // Constructor new function that defines the local mailbox connections from driver class
  // to generator class, and creates objects for transaction class handles.               
	function dual_generator::new(mailbox#(t_1)gen2drv_a,
	                             mailbox#(t_1)gen2drv_b);
	  this.gen2drv_a = gen2drv_a;
	  this.gen2drv_b = gen2drv_b;
    t1             = new;
    t2             = new;
	endfunction

  // Start task defines the logic to drive packets from generator class to driver class
	// conditionally for port-a and port-b by using blocking methods like put().         
	task dual_generator::start();
  begin
	  t1.randomize()with{porting dist{PORTA := 80, PORTB := 50};};
    t2=new t1;
    if(t2.porting == PORTA)
	    gen2drv_a.put(t2);
    else
     gen2drv_b.put(t2);
  end
	endtask
