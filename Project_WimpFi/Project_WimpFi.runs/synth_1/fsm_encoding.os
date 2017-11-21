
 add_fsm_encoding \
       {txd_fsm.state} \
       { }  \
       {{0000 000} {0001 001} {0011 011} {0100 010} {0101 100} }

 add_fsm_encoding \
       {txd_transmit_fsm.state} \
       { }  \
       {{0000 000} {0001 001} {0010 010} {0011 011} {0100 100} }

 add_fsm_encoding \
       {rxd_fsm.state} \
       { }  \
       {{0000 000000001} {0001 000000010} {0010 000001000} {0011 000010000} {0100 000100000} {0101 001000000} {0110 100000000} {0111 010000000} {1000 000000100} }

 add_fsm_encoding \
       {store_fsm.state} \
       { }  \
       {{0001 00} {0010 01} {0011 10} {0100 11} }

 add_fsm_encoding \
       {config_mac_fsm.state} \
       { }  \
       {{000 000} {001 010} {010 001} {011 100} {100 011} }
