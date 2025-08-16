
module testbench_mp ;
  
  
  // define input signal of the design
  reg           clk;
  reg [31:0]    instruction;
  
  // define output signal of the design
  wire  [32:0]    result;

  
  //Define and declare expected signal to assistant when calculte the expected_result
  reg signed [32:0]  mem [31:0]; 
  
  reg signed     [32:0] 			exp_result ; 
  reg signed 	[32:0]	a;
  reg signed	[32:0]	b ;
  reg           [5:0] 	opcode ;
  reg[4:0]  			addr1;
  reg[4:0]  			addr2;
  reg[4:0]  			addr3;

  
  // define flag variable to use it in the report
  reg isPass ;

  
  // 
  reg [31:0]    array_instruction [16]; 
  
  //Initialize all variable 
  initial begin
    clk = 0;
    instruction = 0;
    isPass = 1 ; 
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

    
    
    array_instruction[0]=32'h00153524;
    array_instruction[1]=32'h00197b0d;
    array_instruction[2]=32'h001f998d;
    array_instruction[3]=32'h00153524;
    array_instruction[4]=32'h000dcd3d;
    array_instruction[5]=32'h001457ed;
    array_instruction[6]=32'h000df78c;
    array_instruction[7]=32'h001de9f9;
    array_instruction[8]=32'h001724c6;
    array_instruction[9]=32'h00153524;
    array_instruction[10]=32'h001784c5;
    array_instruction[11]=32'h0013d2aa;
    array_instruction[12]=32'h0012d612;
    array_instruction[13]=32'h001069f2;
    array_instruction[14]=32'h001696ce;
    array_instruction[15]=32'h000a4ec5;

  end


  
  // create instance from the design
  mp_top DUT (
    .clk(clk),
    .instruction(instruction),
    .result(result)
  );
  

  
  
  // generate value clk 
  initial begin
    repeat (140)begin 
      #5;
      clk <= !clk ; 
    end
    print_report();

  end
  
  //generate instruction value 
  initial begin
    for(int i = 0 ; i < 16 ; i++)begin
       @(posedge clk);
      instruction[20:0] <= array_instruction[i];
      @(posedge clk);
      @(posedge clk);
      @(posedge clk);
    end
  end
  
  // Generate Expected Result and compare the result with expected_result 
    initial begin
      repeat (100) begin
        @(posedge clk);
        opcode =instruction[5:0];
        addr1 = instruction[10:6];
        addr2 = instruction[15:11];
        addr3 = instruction[20:16];
		
        $display("@time : %0t ns : instruction=%0h opcode=%0h addr1=%0h , addr2=%0h , addr3=%0h ,mem[addr1]=%0h ,mem[addr2]=%0h ,mem[addr3]=%0h ",$time,instruction , opcode,addr1,addr2,addr3,mem[addr1] ,mem[addr2] , mem[addr3]);

        if(checkIsValidOpCode(opcode))begin
          exp_result = aluAnswer(mem[addr1],mem[addr2],opcode);
          mem[addr3] =exp_result;
        end
        else begin
          exp_result = 0 ;
        end
        
        @(posedge clk);
        if(result != exp_result)begin
          isPass = 0 ; 
          $display("[Fail]\t @time : %0t ns , result=%0h  , expected_result=%0h",$time , result , exp_result );
        end else begin
          $display("[Pass]\t @time : %0t ns , result=%0h  , expected_result=%0h",$time , result , exp_result );

        end
      end
    end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
	
  function reg checkIsValidOpCode (reg [5:0] valid_opcode);
    case (valid_opcode)
      'd3:     checkIsValidOpCode = 1;
      'd15:    checkIsValidOpCode = 1;
      'd13:    checkIsValidOpCode = 1;
      'd12:    checkIsValidOpCode = 1;
      'd7:     checkIsValidOpCode = 1;
      'd1:     checkIsValidOpCode = 1;
      'd9:     checkIsValidOpCode = 1;
      'd10:    checkIsValidOpCode = 1;
      'd14:    checkIsValidOpCode = 1;
      'd11:    checkIsValidOpCode = 1;
      'd5:     checkIsValidOpCode = 1;
      
      default :checkIsValidOpCode = 0 ;
    endcase 
  endfunction
  
  
  // Declare helper finction to use it when calculate expected_result
  function [32:0] aluAnswer(reg signed[32:0] a ,reg signed [32:0] b ,reg[5:0] opcode );
    case (opcode)
      'd3: begin
        aluAnswer =  a+b ; 
      end 
      'd15: begin
        aluAnswer =  a-b;
      end
      'd13: begin 
        aluAnswer =  abs(a);
      end
      'd12: begin 
        aluAnswer =  invert(a) ;
      end
      'd7:  begin 
        aluAnswer =  max(a,b);
      end
      'd1: begin 
        aluAnswer =  min(a,b);
      end
      'd9:  begin 
        aluAnswer =  avg(a,b);
      end
      'd10: begin
        aluAnswer = ~a ;
      end
      'd14: begin
        aluAnswer =  a|b ; 

      end
      'd11: begin 
        aluAnswer =  a&b ;

      end 
      'd5: begin
        aluAnswer =   a^b ; 
      end
      default :begin aluAnswer = 0; end
    endcase 
  endfunction
  
  
  // declare abs function to find absolute value
  function  signed [32:0]  abs(input signed [32:0] a);
    if ($signed(a) < 0)
      abs = -$signed(a);
    else
      abs = a;     
  endfunction
            
  // declare abs function to find invert value
  function  signed [32:0]  invert(input signed [32:0] a);
    invert =~a;     
  endfunction
  
  
  // declare max function to find max value
  function  signed [32:0]  max(input signed [32:0] a , b);
    max = (a >= b)? a : b ;
  endfunction
  
  // declare min function to find min value
  function  signed [32:0]  min (input signed [32:0] a , b);
    min = (a <= b)? a : b ;
  endfunction
  
  // declare avg function to find avg value
  function  signed [32:0]  avg (input signed [32:0] a , b);
    avg = (a + b)/2; 
  endfunction

  
  //function to print report of the test
  function void print_report();
    if(isPass)begin
      $display("\n=====================");
      $display("||\tPass\t   ||");
      $display("=====================");
    end
    else begin
      $display("\n=====================");
      $display("\tFail\t   ||");
      $display("=====================");

    end
  endfunction
  
endmodule



// module aluTb; 
  
//   reg  	  [32:0]  result 	    ;
  
//   reg  	[31:0]	a;
//   reg 	[31:0]	b  		;
//   reg 	[5:0] 	opcode  		;
 
//   alu DUT (
//     .a(a),
//     .b(b),
//     .opcode(opcode),
//     .result(result)
//   );
  
  
//   initial begin
//       a = 0;
//       b = 0;
//       opcode = 0 ;
//   end 
  


  
//     initial begin
//       repeat(20) begin
//         a = $urandom_range(1,7);
//         b = $urandom_range(1,7);
//         #($urandom_range(5,10));
//         opcode = 3 ; 
//         #($urandom_range(5,10));
//         opcode = 15 ; 
//         #($urandom_range(5,10));
//         opcode = 13 ; 
//         #($urandom_range(5,10));
//         opcode = 12 ; 
//         #($urandom_range(5,10));
//         opcode = 7 ; 
//         #($urandom_range(5,10));
//         opcode = 1 ; 
//         #($urandom_range(5,10));
//         opcode = 9 ; 
//         #($urandom_range(5,10));
//         opcode = 10 ; 
//         #($urandom_range(5,10));
//         opcode = 14 ; 
//         #($urandom_range(5,10));
//         opcode = 11 ; 
//         #($urandom_range(5,10));
//         opcode = 5 ; 

//       end
// //       $finish;

//     end

//     initial begin
//       $dumpfile("dump.vcd");
//       $dumpvars;
//     end
  

  
  
// endmodule

// module tb; 
  
//   reg clk;
//   reg valid_opcode ;
//   reg [4:0]  addr1;
//   reg [4:0]  addr2;
//   reg [4:0]  addr3;
//   reg [31:0] in;
  
  
//   //output signals
//    wire [31:0] out1 ;
//    wire [31:0] out2 ; 

  
//   reg_file u1 (
//     .clk(clk),
//     .valid_opcode(valid_opcode),
//     .addr1(addr1),
//     .addr2(addr2),
//     .addr3(addr3),
//     .in(in),
//     .out1(out1),
//     .out2(out2)
//   );
  
//   initial begin
//     clk = 0 ;
//     addr1 = 0 ;
//     addr2 = 0 ;
//     addr3 = 0 ;
//     in = 0;
//     valid_opcode = 0 ;  
//   end
  
  
//     initial begin
//       repeat (33)begin 
//         #5;
//         clk = !clk ; 
//       end
//     end
  
//   initial begin
//     repeat (33)begin
      
//       in <= $urandom_range(1,30) ;
//       addr1 <= $urandom_range(1,16) ;
//       addr2 <= $urandom_range(1,16)  ;
//       addr3 <= $urandom_range(1,16)  ;
//       valid_opcode <=  $urandom;

//       #($urandom_range(5,10));

//     end
        
//   end
//   initial begin
//     $dumpfile("dump.vcd");
//     $dumpvars;
//   end
  
// endmodule


// module tb ;
  
  
//   reg[5:0] opcode ;
//   wire valid ;

//   valid_opcode_module (.opcode(opcode),.valid(valid));
                       
                       
//   initial begin
//     opcode = 0 ;
//   end 
  
//   initial begin
//     repeat (33)begin
//       opcode = $urandom ;
//       #($urandom_range(5,10));
//     end
        
//   end
//   initial begin
//     $dumpfile("dump.vcd");
//     $dumpvars;
//   end


  
  
  
  
  
  
// endmodule
