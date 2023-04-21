`timescale 1ns / 1ps

// module iob_ram_sp #(
//   parameter HEXFILE = "none",
//   parameter DATA_W  = 8     ,
//   parameter ADDR_W  = 14
// ) (
//   input                     ap_clk,
//   input                     en    ,
//   input                     we    ,
//   input      [(ADDR_W-1):0] addr  ,
//   output reg [(DATA_W-1):0] dout  ,
//   input      [(DATA_W-1):0] din
// );

//   //this allows ISE 14.7 to work; do not remove
//   localparam mem_init_file_int = HEXFILE;

//   // Declare the RAM
//   reg [DATA_W-1:0] ram[2**ADDR_W-1:0];

//   // Initialize the RAM
//   initial
//     if(mem_init_file_int != "none")
//       $readmemh(mem_init_file_int, ram, 0, 2**ADDR_W - 1);

//   // Operate the RAM
//   always @ (posedge ap_clk)
//     if(en)
//       if (we)
//         ram[addr] <= din;
//     else
//       dout <= ram[addr];

// endmodule

module iob_ram_sp #(
  parameter HEXFILE = "none",
  parameter DATA_W  = 8     ,
  parameter ADDR_W  = 14
) (
  input                 ap_clk,
  input                 rsta  ,
  input                 en    ,
  input                 we    ,
  input  [(ADDR_W-1):0] addr  ,
  output [(DATA_W-1):0] dout  ,
  input  [(DATA_W-1):0] din
);

  localparam MEMORY_SIZE       = DATA_W * (2**ADDR_W);
  localparam mem_init_file_int = HEXFILE             ;

  // xpm_memory_spram: Single Port RAM
  // Xilinx Parameterized Macro, Version 2017.4
  xpm_memory_spram #(
    // Common module parameters
    .MEMORY_SIZE        (MEMORY_SIZE      ), //positive integer
    .MEMORY_PRIMITIVE   ("ultra"          ), //string; "auto", "distributed", "block" or "ultra";
    .MEMORY_INIT_FILE   (mem_init_file_int), //string; "none" or "<filename>.mem"
    .MEMORY_INIT_PARAM  (""               ), //string;
    .USE_MEM_INIT       (1                ), //integer; 0,1
    .WAKEUP_TIME        ("disable_sleep"  ), //string; "disable_sleep" or "use_sleep_pin"
    .MESSAGE_CONTROL    (0                ), //integer; 0,1
    .MEMORY_OPTIMIZATION("true"           ), //string; "true", "false"
    // Port A module parameters
    .WRITE_DATA_WIDTH_A (DATA_W           ), //positive integer
    .READ_DATA_WIDTH_A  (DATA_W           ), //positive integer
    .BYTE_WRITE_WIDTH_A (DATA_W           ), //integer; 8, 9, or WRITE_DATA_WIDTH_A value
    .ADDR_WIDTH_A       (ADDR_W           ), //positive integer
    .READ_RESET_VALUE_A ("0"              ), //string
    .ECC_MODE           ("no_ecc"         ), //string; "no_ecc", "encode_only", "decode_only" or "both_encode_and_decode"
    .AUTO_SLEEP_TIME    (0                ), //Do not Change
    .READ_LATENCY_A     (1                ), //non-negative integer
    .WRITE_MODE_A       ("write_first"    )  //string; "write_first", "read_first", "no_change"
  ) xpm_memory_spram_inst (
    // Common module ports
    .sleep         (1'b0  ),
    // Port A module ports
    .clka          (ap_clk),
    .rsta          (rsta  ),
    .ena           (en    ),
    .regcea        (1'b0  ),
    .wea           (we    ),
    .addra         (addr  ),
    .dina          (din   ),
    .injectsbiterra(1'b0  ),
    .injectdbiterra(1'b0  ),
    .douta         (dout  ),
    .sbiterra      (      ),
    .dbiterra      (      )
  );

endmodule


module iob_ram_sp_dual #(
  parameter HEXFILE = "none",
  parameter DATA_W  = 8     ,
  parameter ADDR_W  = 14
) (
  input                     ap_clk,
  input                     rsta  ,
  input  reg                en    ,
  input  reg                we    ,
  input  reg [(ADDR_W-1):0] addr  ,
  output reg [(DATA_W-1):0] dout  ,
  input  reg [(DATA_W-1):0] din
);

  localparam MEMORY_SIZE       = DATA_W * (2**ADDR_W);
  localparam mem_init_file_int = HEXFILE             ;

  localparam ADDRESS_RANGE_VALUE = (2**ADDR_W)            ;
  localparam ADDRESS_RANGE_CHUNK = ADDRESS_RANGE_VALUE / 2;

  reg                en_0  ;
  reg                we_0  ;
  reg [(ADDR_W-2):0] addr_0;
  reg [(DATA_W-1):0] dout_0;
  reg [(DATA_W-1):0] din_0 ;

  reg                en_1  ;
  reg                we_1  ;
  reg [(ADDR_W-2):0] addr_1;
  reg [(DATA_W-1):0] dout_1;
  reg [(DATA_W-1):0] din_1 ;

  reg en_0_reg;
  reg en_1_reg;

  always @(*)begin
    if(addr[ADDR_W-1]) begin
      en_1   = en;
      we_1   = we;
      addr_1 = addr[(ADDR_W-2):0];
      din_1  = din;
      en_0   = 0;
      we_0   = 0;
      addr_0 = 0;
      din_0  = 0;
    end else begin
      en_1   = 0;
      we_1   = 0;
      addr_1 = 0;
      din_1  = 0;
      en_0   = en;
      we_0   = we;
      addr_0 = addr[(ADDR_W-2):0];
      din_0  = din;
    end
  end

  always @(posedge ap_clk) begin
    if(rsta) begin
      en_0_reg <= 0;
      en_1_reg <= 0;
    end else begin
      en_0_reg <= en_0;
      en_1_reg <= en_1;
    end
  end

  always @(*)begin
    if(en_0_reg) begin
      dout = dout_0;
    end else if (en_1_reg) begin
      dout = dout_1;
    end else begin
      dout = 0;
    end
  end

  iob_ram_sp #(
    .HEXFILE(HEXFILE ),
    .DATA_W (DATA_W  ),
    .ADDR_W (ADDR_W-1)
  ) inst_iob_ram_sp_0 (
    .ap_clk(ap_clk),
    .rsta  (rsta  ),
    .en    (en_0  ),
    .we    (we_0  ),
    .addr  (addr_0),
    .dout  (dout_0),
    .din   (din_0 )
  );

  iob_ram_sp #(
    .HEXFILE(HEXFILE ),
    .DATA_W (DATA_W  ),
    .ADDR_W (ADDR_W-1)
  ) inst_iob_ram_sp_1 (
    .ap_clk(ap_clk),
    .rsta  (rsta  ),
    .en    (en_1  ),
    .we    (we_1  ),
    .addr  (addr_1),
    .dout  (dout_1),
    .din   (din_1 )
  );

endmodule

module iob_ram_sp_parent #(
  parameter HEXFILE = "none",
  parameter DATA_W  = 8     ,
  parameter ADDR_W  = 14
) (
  input                     ap_clk,
  input                     rsta  ,
  input  reg                en    ,
  input  reg                we    ,
  input  reg [(ADDR_W-1):0] addr  ,
  output reg [(DATA_W-1):0] dout  ,
  input  reg [(DATA_W-1):0] din
);

  localparam MEMORY_SIZE       = DATA_W * (2**ADDR_W);
  localparam mem_init_file_int = HEXFILE             ;

  localparam ADDRESS_RANGE_VALUE = (2**ADDR_W)            ;
  localparam ADDRESS_RANGE_CHUNK = ADDRESS_RANGE_VALUE / 2;

  reg                en_0  ;
  reg                we_0  ;
  reg [(ADDR_W-2):0] addr_0;
  reg [(DATA_W-1):0] dout_0;
  reg [(DATA_W-1):0] din_0 ;

  reg                en_1  ;
  reg                we_1  ;
  reg [(ADDR_W-2):0] addr_1;
  reg [(DATA_W-1):0] dout_1;
  reg [(DATA_W-1):0] din_1 ;

  reg en_0_reg;
  reg en_1_reg;

  always @(*)begin
    if(addr[ADDR_W-1]) begin
      en_1   = en;
      we_1   = we;
      addr_1 = addr[(ADDR_W-2):0];
      din_1  = din;
      en_0   = 0;
      we_0   = 0;
      addr_0 = 0;
      din_0  = 0;
    end else begin
      en_1   = 0;
      we_1   = 0;
      addr_1 = 0;
      din_1  = 0;
      en_0   = en;
      we_0   = we;
      addr_0 = addr[(ADDR_W-2):0];
      din_0  = din;
    end
  end

  always @(posedge ap_clk) begin
    if(rsta) begin
      en_0_reg <= 0;
      en_1_reg <= 0;
    end else begin
      en_0_reg <= en_0;
      en_1_reg <= en_1;
    end
  end

  always @(*)begin
    if(en_0_reg) begin
      dout = dout_0;
    end else if (en_1_reg) begin
      dout = dout_1;
    end else begin
      dout = 0;
    end
  end

  iob_ram_sp_child #(
    .HEXFILE(HEXFILE ),
    .DATA_W (DATA_W  ),
    .ADDR_W (ADDR_W-1)
  ) inst_iob_ram_sp_0 (
    .ap_clk(ap_clk),
    .rsta  (rsta  ),
    .en    (en_0  ),
    .we    (we_0  ),
    .addr  (addr_0),
    .dout  (dout_0),
    .din   (din_0 )
  );

  iob_ram_sp_child #(
    .HEXFILE(HEXFILE ),
    .DATA_W (DATA_W  ),
    .ADDR_W (ADDR_W-1)
  ) inst_iob_ram_sp_1 (
    .ap_clk(ap_clk),
    .rsta  (rsta  ),
    .en    (en_1  ),
    .we    (we_1  ),
    .addr  (addr_1),
    .dout  (dout_1),
    .din   (din_1 )
  );

endmodule


module iob_ram_sp_child #(
  parameter HEXFILE = "none",
  parameter DATA_W  = 8     ,
  parameter ADDR_W  = 14
) (
  input                     ap_clk,
  input                     rsta  ,
  input  reg                en    ,
  input  reg                we    ,
  input  reg [(ADDR_W-1):0] addr  ,
  output reg [(DATA_W-1):0] dout  ,
  input  reg [(DATA_W-1):0] din
);

  localparam MEMORY_SIZE       = DATA_W * (2**ADDR_W);
  localparam mem_init_file_int = HEXFILE             ;

  localparam ADDRESS_RANGE_VALUE = (2**ADDR_W)            ;
  localparam ADDRESS_RANGE_CHUNK = ADDRESS_RANGE_VALUE / 2;

  reg                en_0  ;
  reg                we_0  ;
  reg [(ADDR_W-2):0] addr_0;
  reg [(DATA_W-1):0] dout_0;
  reg [(DATA_W-1):0] din_0 ;

  reg                en_1  ;
  reg                we_1  ;
  reg [(ADDR_W-2):0] addr_1;
  reg [(DATA_W-1):0] dout_1;
  reg [(DATA_W-1):0] din_1 ;

  always @(*) begin
    if(addr[ADDR_W-1]) begin
      en_1   = en;
      we_1   = we;
      addr_1 = addr[(ADDR_W-2):0];
      din_1  = din;
      en_0   = 0;
      we_0   = 0;
      addr_0 = 0;
      din_0  = 0;
      dout   = dout_1;
    end else begin
      en_1   = 0;
      we_1   = 0;
      addr_1 = 0;
      din_1  = 0;
      en_0   = en;
      we_0   = we;
      addr_0 = addr[(ADDR_W-2):0];
      din_0  = din;
      dout   = dout_0;
    end
  end

  iob_ram_sp #(
    .HEXFILE(HEXFILE ),
    .DATA_W (DATA_W  ),
    .ADDR_W (ADDR_W-1)
  ) inst_iob_ram_sp_0 (
    .ap_clk(ap_clk),
    .rsta  (rsta  ),
    .en    (en_0  ),
    .we    (we_0  ),
    .addr  (addr_0),
    .dout  (dout_0),
    .din   (din_0 )
  );

  iob_ram_sp #(
    .HEXFILE(HEXFILE ),
    .DATA_W (DATA_W  ),
    .ADDR_W (ADDR_W-1)
  ) inst_iob_ram_sp_1 (
    .ap_clk(ap_clk),
    .rsta  (rsta  ),
    .en    (en_1  ),
    .we    (we_1  ),
    .addr  (addr_1),
    .dout  (dout_1),
    .din   (din_1 )
  );

endmodule

