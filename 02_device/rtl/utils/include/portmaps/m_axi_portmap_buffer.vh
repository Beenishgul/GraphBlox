  .axi_araddr         (m_axi_read.out.araddr    ), //Address read channel address
  .axi_arburst        (m_axi_read.out.arburst   ), //Address read channel burst type
  .axi_arcache        (m_axi_read.out.arcache   ), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
  .axi_arid           (m_axi_read.out.arid      ), //Address read channel ID
  .axi_arlen          (m_axi_read.out.arlen     ), //Address read channel burst length
  .axi_arlock         (m_axi_read.out.arlock    ), //Address read channel lock type
  .axi_arprot         (m_axi_read.out.arprot    ), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
  .axi_arqos          (m_axi_read.out.arqos     ), //Address read channel quality of service
  .axi_arready        (m_axi_read.in.arready    ), //Address read channel ready
  .axi_arsize         (m_axi_read.out.arsize    ), //Address read channel burst size. This signal indicates the size of each transfer in the burst
  .axi_arvalid        (m_axi_read.out.arvalid   ), //Address read channel valid
  .axi_arregion       (m_axi_read.out.arregion  ), //Address read channel valid
  .axi_rdata          (m_axi_read.in.rdata      ), //Read channel data
  .axi_rid            (m_axi_read.in.rid        ), //Read channel ID
  .axi_rlast          (m_axi_read.in.rlast      ), //Read channel last word
  .axi_rready         (m_axi_read.out.rready    ), //Read channel ready
  .axi_rresp          (m_axi_read.in.rresp      ), //Read channel response
  .axi_rvalid         (m_axi_read.in.rvalid     ), //Read channel valid