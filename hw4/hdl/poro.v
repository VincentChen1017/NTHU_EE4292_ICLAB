module poro(
    input clk,
    input srstn,
    input poro_valid,
    input sram_rdata,
    output reg [11:0] sram_raddr,
    output reg SRAM_done,
    output reg [624:0]qr_array
  );
  localparam IDLE = 0,
             PO_RO = 1, // Load data from SRAM, determine the position & rotation of　QR code from qr_array
             DE_MASK = 2, // Find the mask pattern ID, and do the de-masking
             DE_CODEWORD = 3,
             DE_TEXT = 4;

  reg [6:0]height, width;
  reg [6:0]nheight, nwidth;
  reg [11:0] nsram_raddr;
  ///// load data from SRAM /////
  always@*
  begin
    if(poro_valid==1 && width!=24)
      nwidth = width + 1;
    else
      nwidth = 0;
    //---------//
    if(width==24)
      nheight = height + 1;
    else
      nheight = height;
    //---------//
    nsram_raddr = 64*nheight + nwidth;
    //---------//
    if(nheight==25)
      SRAM_done = 1;
    else
      SRAM_done = 0;
  end

  always@(posedge clk)
    if(~srstn)
    begin
      height <= 0;
      width <= 0;
      sram_raddr <= 0;
    end
    else
    begin
      height <= nheight;
      width <= nwidth;
      sram_raddr <= nsram_raddr;
      if(poro_valid)
        qr_array[25*height + width] <= sram_rdata;
    end
  ////////////////////////////////////////////////

endmodule
