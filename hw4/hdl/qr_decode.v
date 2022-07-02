module qr_decode(
    input clk,                           //clock input
    input srstn,                         //synchronous reset (active low)
    input qr_decode_start,               //start decoding for one QR code
    //1: start (one-cycle pulse)
    input sram_rdata,                    //read data from SRAM
    output [11:0] sram_raddr,        //read address to SRAM

    output decode_valid,                 //decoded code is valid
    output [7:0] decode_jis8_code,       //decoded JIS8 code
    output qr_decode_finish              //1: decoding one QR code is finished
  );
  localparam IDLE = 0,
             PO_RO = 1, // Load data from SRAM, determine the position & rotation of　QR code from qr_array
             DE_MASK = 2, // Find the mask pattern ID, and do the de-masking
             DE_CODEWORD = 3,
             ECC = 4,
						 DE_TEXT = 5;
  integer i;
  reg [2:0] state, nstate;
  wire SRAM_done; // after load the data from SRAM, SRAM_done = 1
  wire MASK_done;
  wire CODE_done;
	wire ECC_done;
  wire [624:0]qr_array;
  wire [624:0]de_array;
  reg poro_valid;
  reg de_mask_valid;
  reg de_codeword_valid;
  reg de_text_valid;
	reg ecc_valid;
  wire [351:0] codeword;
	wire [351:0] correct_codeword;



  ///// FSM /////
  always@*
  begin
    nstate = IDLE;
    poro_valid = 0;
    de_mask_valid = 0;
    de_codeword_valid = 0;
    de_text_valid = 0;
		ecc_valid = 0;
    case(state)
      IDLE:
      begin
        poro_valid = 0;
        de_mask_valid = 0;
        de_codeword_valid = 0;
        de_text_valid = 0;
				ecc_valid = 0;
        if(qr_decode_start)
        begin
          nstate = PO_RO;
        end
        else
        begin
          nstate = IDLE;
        end
      end
      PO_RO:
      begin
        poro_valid = 1;
        de_mask_valid = 0;
        de_codeword_valid = 0;
        de_text_valid = 0;
				ecc_valid = 0;
        if(SRAM_done)
        begin
          nstate = DE_MASK;
        end
        else
        begin
          nstate = PO_RO;
        end
      end
      DE_MASK:
      begin
        poro_valid = 0;
        de_mask_valid = 1;
        de_codeword_valid = 0;
        de_text_valid = 0;
				ecc_valid = 0;
        if(MASK_done)
        begin
          nstate = DE_CODEWORD;
        end
        else
        begin
          nstate = DE_MASK;
        end
      end
      DE_CODEWORD:
      begin
        poro_valid = 0;
        de_mask_valid = 0;
        de_codeword_valid = 1;
        de_text_valid = 0;
				ecc_valid = 0;
        if(CODE_done)
        begin
          nstate = ECC;
        end
        else
          nstate = DE_CODEWORD;
      end
      ECC:
      begin
        poro_valid = 0;
        de_mask_valid = 0;
        de_codeword_valid = 0;
        de_text_valid = 0;
				ecc_valid = 1;
        if(ECC_done)
        begin
          nstate = DE_TEXT;
        end
        else
        begin
          nstate = ECC;
        end
      end
      DE_TEXT:
      begin
        poro_valid = 0;
        de_mask_valid = 0;
        de_codeword_valid = 0;
        de_text_valid = 1;
				ecc_valid = 0;
        if(qr_decode_finish)
        begin
          nstate = IDLE;
        end
        else
        begin
          nstate = DE_TEXT;
        end
      end
    endcase
  end

  always@(posedge clk)
    if(~srstn)
      state <= IDLE;
    else
      state <= nstate;
  //////////////////////

  poro 
		poro(
       .clk(clk),
       .srstn(srstn),
       .poro_valid(poro_valid),
       .sram_rdata(sram_rdata),
       .sram_raddr(sram_raddr),
       .SRAM_done(SRAM_done),
       .qr_array(qr_array)
     );

  de_mask
    de_mask(
      .clk(clk),
      .srstn(srstn),
      .qr_array(qr_array),
      .de_mask_valid(de_mask_valid),
      .de_array(de_array),
      .MASK_done(MASK_done)
    );

  de_codeword
    de_codeword(
      .clk(clk),
      .srstn(srstn),
      .de_array(de_array),
      .de_codeword_valid(de_codeword_valid),
      .CODE_done(CODE_done),
      .codeword(codeword)
    );

  de_text
    de_text(
      .clk(clk),
      .srstn(srstn),
      .codeword(correct_codeword),
      .de_text_valid(de_text_valid),
      .decode_valid(decode_valid),                 //decoded code is valid
      .decode_jis8_code(decode_jis8_code),       //decoded JIS8 code
      .qr_decode_finish(qr_decode_finish)
    );
	ecc
		ecc(
    .clk(clk),
    .srstn(srstn),
    .codeword(codeword),
    .ecc_valid(ecc_valid),
		.ECC_done(ECC_done),
		.correct_codeword(correct_codeword)
  );







endmodule



