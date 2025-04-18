////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_driver_a.sv                                           //
//                                                                                //
//                                                                                //
//  File Description : This is the driver class for port-a. This class            //
//                     receives packets from generator and drives them to         //
//                     port-a signals of the DUT through virtual interface.       //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class dual_driver_a;

  // User defined data type for virtual interface of port-a driver.
  typedef virtual dual_iff.DRV_PA d_if;
  // Object handle for the virtual interface
  d_if vif;

  // User defined data type for transaction class, t_2 of type trans.
  typedef trans t_2;

  // Channel descriptor for printing driver transactions in a text file.
  int fd_a;
  // Local handle for generator class
  dual_generator genh_a;

  // Object handles for transaction class.
  t_2 t3,t4;
  // Mailbox for getting the transactions from generator class.
  mailbox#(t_2)gen2drv_a;
  // Local variable to determine the number of transactions driven.
  int drv_xtn_a;

  extern function new(d_if vif,
                      mailbox#(t_2)gen2drv_a);
  extern task start;
  extern task send_to_dut(t_2 rcv_xtn);

endclass
  
  // Constructor new that defines local mailbox connections between driver and interface,
  // and defines the connection between virtual to static inteface. Also creates objects
  // for transaction class handles.                                                     
  function dual_driver_a::new( d_if vif,
                               mailbox#(t_2)gen2drv_a);
    this.gen2drv_a = gen2drv_a;
    this.vif       = vif;
    t3             = new;
  endfunction

  // This start method gets all the port-a transactions through the mailbox using get() method from genrator and
  // drives them to the user defined task send_to_dut. Also it prints all the transactions in a text file called
  // drv_a.txt for debugging purposes.                                                                          
  task dual_driver_a::start;
   fd_a = $fopen("PORT-A/drv_a.txt","w");
    fork
      forever
      begin
        genh_a.start();
        gen2drv_a.get(t3);
        t4 = new t3;
        send_to_dut(t3);
      end
    join_none
  endtask

  // This local task drives the recieved transactions to the DUT via virtual interface of port-a.
  task dual_driver_a::send_to_dut(t_2 rcv_xtn);
    drv_xtn_a++;
    @(vif.drv_porta);
    if(rcv_xtn.op == WRITE && rcv_xtn.porting == PORTA)
    begin
       vif.drv_porta.i_ena <= 1'b1;
       vif.drv_porta.i_wea <= 1'b1;
    end
    else if(rcv_xtn.op == READ && rcv_xtn.porting == PORTA)
    begin
       vif.drv_porta.i_ena <= 1'b1;
       vif.drv_porta.i_wea <= 1'b0;
    end
    else
    begin
    vif.drv_porta.i_ena <= 1'b0;
    end
    if(gen2drv_a.num == 0)
      vif.drv_porta.i_ena <= 1'b0;
    vif.drv_porta.i_addra <= rcv_xtn.addr;
    vif.drv_porta.i_dina  <= rcv_xtn.din;
    $fdisplay(fd_a,$sformatf("=====================TIME:%0dns===TRANS_NO_A:%0d=================================",$time,drv_xtn_a));
    rcv_xtn.fdisplay(fd_a,"PORT A: Driving Data to DUT");
  endtask
