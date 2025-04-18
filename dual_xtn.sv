////////////////////////////////////////////////////////////////////////////////////
//  File name        : dual_xtn.sv                                                //
//                                                                                //
//                                                                                //
//  File Description : This file defines the ncessary properties that are to      //
//                     be randomized to generate the stimulus. all input          //
//                     signals are randomized in specified manner by using        //
//                     constraints.                                               //
//                                                                                //
////////////////////////////////////////////////////////////////////////////////////

class trans;

  // write_enable and enable signals.
	rand logic                   we,en;
  // Input data.
	randc logic [DATA_WIDTH-1:0] din;
  // Input address.
	rand logic  [ADDR_WIDTH-1:0] addr;
	// Enum data type that has two constants port-a and port-b.
  rand                         port porting;
	// Enum data type that has three contsants WRITE,READ and NONE
  rand                         operation op;
	// Output data for port-a
  logic       [DATA_WIDTH-1:0] douta;
	// Output data for port-b
  logic       [DATA_WIDTH-1:0] doutb;
  // Error status for port-a and port-b;
  logic       [1:0]            o_errora,o_errorb;

  // This constraint generates write operation
  constraint write{ op == WRITE -> ((en == 1'b1) && (we == 1'b1));}
  // This constraint generates read operation
  constraint read{  op == READ  -> ((en == 1'b1) && (we == 1'b0));}
  // This constraint generates none operation
  constraint none{  op == NONE  -> ((en == 1'b0) && (we == 1'b1 || we == 1'b0));}

  extern function void fdisplay(input int fd,string s);
  extern function bit compare(trans rcv_xtn);

endclass
	
  // This function is used to display all the values of the properties at that
  // instant of time when called in that corresponding class.                 
  function void trans::fdisplay(input int fd,string s);
  	$fdisplay(fd,"============================================================\n");
    $fdisplay(fd,"At time: %0tns, %s",$time,s);
  	$fdisplay(fd,"we    = %d",we);
  	$fdisplay(fd,"en    = %d",en);
  	$fdisplay(fd,"din   = %d",din);
  	$fdisplay(fd,"addr  = %d",addr);
  	$fdisplay(fd,"douta = %d",douta);
  	$fdisplay(fd,"doutb = %d",doutb);
    $fdisplay(fd,"port  = %0s",porting);
    $fdisplay(fd,"op    = %0s",op);
  	$fdisplay(fd,"============================================================\n");
  endfunction

  // This function is used to compare two transactions, when both the transactions are same it returns 1
  // and if there is any mismatch it returns 0.                                                         
  function bit trans::compare(trans rcv_xtn);
    if(this.en == rcv_xtn.en)
    begin
      if(this.we == rcv_xtn.we)
      begin
        if(this.addr == rcv_xtn.addr)
        begin
          if(porting == PORTA)
          begin
            if(this.douta === rcv_xtn.douta)
             return 1;
            else
             return 0;
          end
          else if(porting == PORTB)
          begin
            if(this.doutb === rcv_xtn.doutb)
              return 1;
            else
              return 0;
          end
          else
              return 0;
        end
        else
            return 0;
      end
      else
          return 0;
    end
    else 
      return 0;
  endfunction
