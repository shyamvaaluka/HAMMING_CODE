#Pragma#coverage exclude -src ./rtl/controller_interface.v -code s
coverage exclude -scope /top/DUT/ERROR_CORRECTION/HAM_ENCODER -togglenode j temp temp1
coverage exclude -scope /top/DUT/HAM_DECODER -togglenode o syndrome_a syndrome_b temp temp1 u

