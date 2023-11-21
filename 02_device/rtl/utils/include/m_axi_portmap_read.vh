.araddr             (m_axi_read.out.araddr  ), //Address read channel address
.arburst            (m_axi_read.out.arburst ), //Address read channel burst type
.arcache            (m_axi_read.out.arcache ), //Address read channel memory type. Transactions set with Normal Non-cacheable Modifiable and Bufferable (0011).
.arid               (m_axi_read.out.arid    ), //Address read channel ID
.arlen              (m_axi_read.out.arlen   ), //Address read channel burst length
.arlock             (m_axi_read.out.arlock  ), //Address read channel lock type
.arprot             (m_axi_read.out.arprot  ), //Address read channel protection type. Transactions set with Normal, Secure, and Data attributes (000).
.arqos              (m_axi_read.out.arqos   ), //Address read channel quality of service
.arready            (m_axi_read.in.arready  ), //Address read channel ready
.arsize             (m_axi_read.out.arsize  ), //Address read channel burst size. This signal indicates the size of each transfer in the burst
.arvalid            (m_axi_read.out.arvalid ), //Address read channel valid
.rdata              (m_axi_read.in.rdata    ), //Read channel data
.rid                (m_axi_read.in.rid      ), //Read channel ID
.rlast              (m_axi_read.in.rlast    ), //Read channel last word
.rready             (m_axi_read.out.rready  ), //Read channel ready
.rresp              (m_axi_read.in.rresp    ), //Read channel response
.rvalid             (m_axi_read.in.rvalid   ), //Read channel valid