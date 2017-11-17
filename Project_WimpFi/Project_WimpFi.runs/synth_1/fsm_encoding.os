
 add_fsm_encoding \
       {txd_fsm.state} \
       { }  \
       {{0000 000} {0001 001} {0011 011} {0100 010} {0101 100} }

 add_fsm_encoding \
       {txd_transmit_fsm.state} \
       { }  \
       {{0000 000} {0001 001} {0010 010} {0011 011} {0100 100} }

 add_fsm_encoding \
       {config_mac_fsm.state} \
       { }  \
       {{000 000} {001 010} {010 001} {011 100} {100 011} }
