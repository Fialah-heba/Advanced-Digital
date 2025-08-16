
module mp_top (
  			   clk, 
  			   instruction , 
               result
);

  
  input             clk;
  input  [31:0]      instruction;
  
  output reg signed [32:0] result; //***
  
  
  //internal wire
  wire [5:0]  opcode_wire ; 
  wire        valid_opcode_wire  ;
  
  
  wire signed [32:0] out1_wire ;
  wire signed [32:0] out2_wire ;

  reg [5:0] buffer_opcode ;

  wire  [4:0] address_one_wire;
  wire  [4:0] address_two_wire;
  wire  [4:0] address_three_wire;
  

 // Design Component 
  
  instruction_register instruction_register_design (
    .clk(clk),
    .instruction(instruction),
    .opcode(opcode_wire),
    .address_one(address_one_wire),
    .address_two(address_two_wire),
    .address_three(address_three_wire)
  );
  
  
  
 valid_opcode_module valid_opcode_module_design  (
      											.opcode(opcode_wire),
      											.valid_opcode(valid_opcode_wire)
  												);

  
  
  reg_file reg_file_design  (
    						.clk(clk),
    						.valid_opcode(valid_opcode_wire),
    						.addr1(address_one_wire),
    						.addr2(address_two_wire),
    						.addr3(address_three_wire),
    						.in(result),
    						.out1(out1_wire),
    						.out2(out2_wire)
  );
  
  
  
  
    alu alu_design  (
    			.a(out1_wire),
    			.b(out2_wire),
    			.opcode(buffer_opcode),
    			.result(result)
    );


  always @(posedge clk )begin   
    buffer_opcode <= opcode_wire;
  end
  

endmodule




module alu (
			a,
			b,
			opcode,
			result
			);
  
  
   //output signals
  output reg signed [32:0]  	result 	    ;//***
  
  //input singlas
  input signed 	[32:0]	a;
  input signed	[32:0]	b  		;
  input 	[5:0] 	opcode  		;
  

   
  initial begin
    result= 0;
  end
  
  always @(a,b,opcode)begin
    case (opcode)
      'd3:  result =  a+b;
      'd15: result =  a-b;
      'd13: result =  abs(a);
      'd12: result =  invert(a);
      'd7:  result =  max(a,b);
      'd1:  result =  min(a,b);
      'd9:  result =  avg(a,b);
      'd10: result = ~a;
      'd14: result =  a|b;
      'd11: result =  a&b;
      'd5: result =   a^b;
      default :result = 0 ;
    endcase 
  end

    
    
  function signed [32:0]  abs(input signed [32:0] a);
    if ($signed(a) < 0)
      abs = -$signed(a);
    else
      abs = a;     
  endfunction
            
      
  function  signed [32:0]  invert(input signed [32:0] a);
    invert =~a;     
  endfunction
  
  function  signed [32:0]  max(input signed [32:0] a , b);
    max = (a >= b)? a : b ;
  endfunction
  
  function  signed [32:0]  min (input signed [32:0] a , b);
    $displayh(a,,b);
    min = (a <= b)? a : b ;
  endfunction
  
  function  signed [32:0]  avg (input signed [32:0] a , b);
    avg = (a + b)/2; 
  endfunction

  
endmodule


module reg_file (
  				 clk,
  				 valid_opcode,
                 addr1,
                 addr2,
                 addr3,
                 in ,
                 out1,
                 out2
				);
  

  
  //input singlas
  input       clk;
  input       valid_opcode;
  
  input[4:0]  addr1;
  input[4:0]  addr2;
  input[4:0]  addr3;
  
  input signed [32:0] in; //**
  
  
  //output signals
  output reg signed [32:0] out1 ;
  output reg signed [32:0] out2 ; 
  
  
  //internal Regisiter 
  reg signed [32:0]  mem [31:0]; 				

  
  //memory initialization value 
  initial begin
    mem[0] = 32'h0 ;
    mem[1] = 32'h2D8E ;
    mem[2] = 32'h2D2A ;
    mem[3] = 32'h3BE2 ;
    mem[4] = 32'h257A ;
    mem[5] = 32'h399A ;
    mem[6] = 32'hCD8 ;
    mem[7] = 32'h172C ;
    mem[8] = 32'h7BA ;
    mem[9] = 32'h1330 ;
    mem[10] = 32'h94C ;
    mem[11] = 32'h786 ;
    mem[12] = 32'h31B6 ;
    mem[13] = 32'hB0 ;
    mem[14] = 32'h20008 ;
    mem[15] = 32'h20CA ;
    mem[16] = 32'h3524 ;
    mem[17] =  32'h27EE ;
    mem[18] =  32'h1C5E ;
    mem[19] = 32'h27CE ;
    mem[20] = 32'h221E ;
    mem[21] =  32'h3090 ;
    mem[22] =  32'h2214 ;
    mem[23] =  32'h1524 ;
    mem[24] = 32'h2B4A ;
    mem[25] = 32'h8A4 ;
    mem[26] = 32'h182C ;
    mem[27] = 32'h1B90 ;
    mem[28] = 32'hEA0 ;
    mem[29] = 32'h1686 ;
    mem[30] = 32'hD54 ;
    mem[31] = 32'h0 ;
    out1 = 0;
    out2 = 0;

  end
  
  
  // design logic
  // out1 get the value of memory of addr1
  // out2 get the value of memory of addr2
  // wirte the input value in memory of addr3

  always @(posedge clk)begin
    if(valid_opcode)begin    
      out1<= mem[addr1];
      out2<= mem[addr2];
      mem[addr3] <= in;
    end

    
  end
  
endmodule


module valid_opcode_module(
  							opcode ,
  							valid_opcode
 
  						  );
  

  // input signal
  input[5:0] opcode ;
  
  //output signal
  output reg valid_opcode ;
  
  
  // initial signal
  initial begin 
    valid_opcode = 0 ;
  end
  
  
  // check if the opcode valid or not , if it's value the output will be 1 other wise zero
  always@(opcode)begin
    
    case (opcode)
      'd3:     valid_opcode = 1;
      'd15:    valid_opcode = 1;
      'd13:    valid_opcode = 1;
      'd12:    valid_opcode = 1;
      'd7:     valid_opcode = 1;
      'd1:     valid_opcode = 1;
      'd9:     valid_opcode = 1;
      'd10:    valid_opcode = 1;
      'd14:    valid_opcode = 1;
      'd11:    valid_opcode = 1;
      'd5:     valid_opcode = 1;
      
      default :valid_opcode = 0 ;
    endcase 
    
  end
  

  
endmodule


module instruction_register(
							clk ,
							instruction,
  							opcode,
  							address_one,
  							address_two,
  							address_three
							) ;
 
  // define input signal
  input [31:0]    instruction;
  input clk ; 
  
  //define output signal
  output reg [5:0] opcode;
  output reg [4:0] address_one;
  output reg [4:0] address_two;
  output reg [4:0] address_three;
  
  
  // fetch the value from the instruction
  always @(posedge clk)begin
    
    opcode <= instruction[5:0];
    address_one <= instruction[10:6]; 
    address_two <= instruction[15:11];
    address_three <= instruction[20:16]; 
  end
  
endmodule