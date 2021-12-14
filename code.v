`timescale 1ns / 1ps
 module code(clk1, clk2, B);
 output[31:0] B;
 input clk1, clk2; // Two-phase clock 
 reg [31:0] PC, IF_ID_IR, IF_ID_NPC; 
 reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imml,ID_EX_Imms, ID_EX_Imm,ID_EX_Immb; 
 reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type; 
 reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B,EX_MEM_A; 
 reg EX_MEM_cond; 
 reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD,DEC_REG;
 reg [31:0] Reg [0:31],Memi[0:31]; // Register bank (32 x 32) data memory
 reg [31:0] Mem [0:1023]; // 1024 x 32 memory instruction memory
 reg HALTED,TAKEN_BRANCH,BYPASS;
 integer k;//memory load *
assign B=EX_MEM_IR;
parameter AND= 7'b0111011, OR=7'b0110011, ADD=7'b0000011, 
          SUB=7'b1000011,ADDI=7'b0000001,BEQ=7'b0000110, 
          LW=7'b0010000,SW=7'b0010010,SLL=7'b0001011,
          SRA=7'b1101011,HLT=7'b0111111,MAC=7'b0000111;

parameter RR_ALU=3'b011, RM_ALU=3'b001, LOAD=3'b000, STORE=3'b010, 
           BRANCH=3'b110, MAC_ALU=3'b111, HALT=3'b101; //
 initial 
 begin
  $readmemb("Register_source.txt",Reg);
  //$readmemb("C:/Users/NK VAISHNAV/Vivado files/finalCA/register.txt",Reg);
  //$readmemb("C:/Users/NK VAISHNAV/Vivado files/finalCA/instructionmemory.txt",Memi);
  $readmemb("C:/Users/NK VAISHNAV/Vivado files/finalCA/datamemory.txt",Mem);
  
/*for (k=0;k<10;k=k+1)//for video presentation
 Reg[k]=k;
 for (k=12;k<32;k=k+1)
 Reg[k]=k;
 Reg[10]=500;
 Reg[11]=500; //memory register
 Memi[0] = 32'h0020fab3;//AND R21=R2&R1=0
 Memi[1] = 32'h0151eb33;//OR R22=R21|R3=3
 Memi[2] = 32'h015b0bb3;//ADD R23=R22+R21=3
 Memi[3] = 32'h416b8c33;//SUB R24=R23-R22=0
 Memi[4] = 32'h007c0c93;//ADDI R25=R24+(OFFSET=7)=7
 Memi[5] = 32'h00b50963;//BEQ R11=R10 PC+OFFSET
 Memi[6] = 32'h007f8f93;//ADDI R31=R31+7-->Should not get updated
 Memi[15]= 32'h007cad03;//LW R26<-Mem[R25+OFFSET] R26<-15=Mem[14]
 Memi[16]= 32'h01aca7a3;//SW M[R25+OFFSET[15]]<-R26=Mem[22]<-15
 Memi[17]= 32'h019d1db3;//SLL R27 = R26<<R25 R27 = 00000780 
 Memi[18]= 32'h4128de33;//SRA R28 = R27>>>R26
 Memi[19]= 32'h01498eff;//MAC R29=R29+(R20*R19)=>R29=199
 Mem[14]=15;*/
  /*
 //Normal TestCase
  for (k=0;k<10;k=k+1)
 Reg[k]=k;
 for (k=12;k<32;k=k+1)
 Reg[k]=k;
 Reg[10]=500;
 Reg[11]=500; //memory register
 Mem[0] = 32'h0020fab3;//AND R21=R2&R1
 Mem[1] = 32'h0041eb33;//OR R22=R4|R3
 Mem[2] = 32'h00628bb3;//ADD R23=R6+R5
 Mem[3] = 32'h40740c33;//SUB R24=R8-R7
 Mem[4] = 32'h00748c93;//ADDI R25=R9+(OFFSET=7)
 Mem[5] = 32'h00b50763;//BEQ R11=R10 PC+OFFSET
 Mem[6] = 32'h01ff8fb3;//next instruction not to be updated ADD R31=R31+R31
 Mem[13]= 32'h00762d03;//LW R26=R12+OFFSET
 Mem[14]= 32'h00e6a3a3;//SW M[R13+OFFSET]=R14
 Mem[15]= 32'h00f81db3;//SLL R27 = R16<<R15 
 Mem[16]= 32'h4128de33;//SRA R28 = R18>>>R17
 Mem[17]= 32'h01498eff;//MAC R29=R28+(R20*R19)
 Mem[19]=15;*/
//Bypassing Test Cases
/*
 for (k=0; k<31; k=k+1)
 Reg[k] = k;
 Memi[0] = 32'h00002083;//LW r1,0(r0)=>00002083
 Memi[1] = 32'h00208133;//add r2,r1,r2=>00002085
 Memi[2] = 32'h401101b3;//sub r3,r2,r1
 */
 // Bypassing in main code
 /*for (k=0; k<31; k=k+1)
 Reg[k] = 0;
 Mem[0] = 32'h00108093;//ADDI R1,R1,1->1
 Mem[1] = 32'h00210113;//ADDI R2,R2,2->2
 Mem[2] = 32'h00318193;//ADDI R3,R3,3->3
 Mem[3] = 32'h00f20213;//ADDI R4,R4,15->15
 Mem[4] = 32'h00850513;//ADDI R10,R10,8->8
 Mem[5] = 32'h00858593;//ADDI R11,R11,8->8
 Mem[6] = 32'h0020fab3;//AND R21=R2&R1=0
 Mem[7] = 32'h0151eb33;//OR R22=R21|R3=3
 Mem[8] = 32'h015b0bb3;//ADD R23=R22+R21=3
 Mem[9] = 32'h416b8c33;//SUB R24=R23-R22=0
 Mem[10]= 32'h007c0c93;//ADDI R25=R24+(OFFSET=7)=7
 Mem[11]= 32'h00b50963;//BEQ R11=R10 PC+OFFSET
 Mem[21]= 32'h00402223;//SW x4,4(x0)=>f
 Mem[22]= 32'h00402d03;//LW x26,4(x0)=>f
 Mem[23]= 32'h01a02423;//SW x26,8(x0)=>f
 Mem[24]= 32'h019d1db3;//SLL R27 = R26<<R25 R27 = 00000780 
 Mem[25]= 32'h4128de33;//SRA R28 = R27>>>R26
 Mem[26]= 32'h01398993;//ADDI R19,R19,19->19
 Mem[27]= 32'h014a0a13;//ADDI R20,R20,20->20
 Mem[28]= 32'h01de8e93;//ADDI R29,R29,29->29=>1d
 Mem[29]= 32'h01498eff;//MAC R29=R28+(R20*R19)R29=>17c
*/
 
/*
for (k=0; k<31; k=k+1)
 Reg[k] = k;
 Mem[0] = 32'h0020fab3;//AND R21=R2&R1=0
 Mem[1] = 32'h0151eb33;//OR R22=R21|R3=3
 Mem[2] = 32'h015b0bb3;//ADD R23=R22+R21=3
 Mem[3] = 32'h416b8c33;//SUB R24=R23-R22=0
 Mem[4] = 32'h007c0c93;//ADDI R25=R24+(OFFSET=7)=7
 Mem[5] = 32'h00b50763;//BEQ R11=R10 PC+OFFSET
 Mem[6] = 32'h007cad03;//LW R26<-Mem[R25+OFFSET] R26<-15=Mem[14]
 Mem[7] = 32'h01aca3a3;//SW M[R25+OFFSET[15]]<-R26=Mem[22]<-15
 Mem[8] = 32'h019d1db3;//SLL R27 = R26<<R25 R27 = 00000780 
 Mem[9] = 32'h4128de33;//SRA R28 = R27>>>R26
 Mem[10]= 32'h01498eff;//MAC R29=R28+(R20*R19)R29=199
 Mem[32]= 15;
 Mem[14]=15;
 */
 
 /*for (k=0;k<10;k=k+1)//for video presentation
 Reg[k]=k;
 for (k=12;k<32;k=k+1)
 Reg[k]=k;
 Reg[10]=500;
 Reg[11]=500; //memory register
 Mem[0] = 32'h0020fab3;//AND R21=R2&R1=0
 Mem[1] = 32'h0151eb33;//OR R22=R21|R3=3
 Mem[2] = 32'h015b0bb3;//ADD R23=R22+R21=3
 Mem[3] = 32'h416b8c33;//SUB R24=R23-R22=0
 Mem[4] = 32'h007c0c93;//ADDI R25=R24+(OFFSET=7)=7
 Mem[5] = 32'h00b50963;//BEQ R11=R10 PC+OFFSET
 Mem[15]= 32'h007cad03;//LW R26<-Mem[R25+OFFSET] R26<-15=Mem[14]
 Mem[16]= 32'h01aca7a3;//SW M[R25+OFFSET[15]]<-R26=Mem[22]<-15
 Mem[17]= 32'h019d1db3;//SLL R27 = R26<<R25 R27 = 00000780 
 Mem[18]= 32'h4128de33;//SRA R28 = R27>>>R26
 Mem[19]= 32'h01498eff;//MAC R29=R29+(R20*R19)=>R29=199
 Mem[14]=15;*/
 HALTED = 0; 
 PC = 0; 
 TAKEN_BRANCH=0 ;
 BYPASS=0;
 #280          
  for (k=0; k<6; k=k+1) 
 $display ("R%1d - %2d", k, Reg[k]); 
 end 
always @(posedge clk1) // IF Stage 
 if (HALTED == 0) 
 begin 
 if ((({EX_MEM_IR[30],EX_MEM_IR[14:12],EX_MEM_IR[6:4]} == BEQ) && (EX_MEM_cond == 1))) 
  #0.000001
 begin 
 IF_ID_IR <= #2 Memi[EX_MEM_ALUOut];
 TAKEN_BRANCH <= #2 1'b1;//
 IF_ID_NPC <= #2 EX_MEM_ALUOut + 1; 
 PC <= #2 EX_MEM_ALUOut + 1; //issue
 end
 else 
 begin 
 IF_ID_IR <= #2 Memi[PC]; 
 IF_ID_NPC <= #2 PC + 1; 
 PC <= #2 PC + 1; 
 end 
 end
always @(posedge clk2) // ID Stage 
 if (HALTED == 0) 
 begin
 if (IF_ID_IR[24:20]==ID_EX_IR[11:7]& ID_EX_type==RR_ALU)
 begin
 ID_EX_A<=#2 EX_MEM_ALUOut;
 end
 else if (IF_ID_IR[24:20]==ID_EX_IR[11:7]& ID_EX_type==LOAD)
 begin
 ID_EX_A<=#2 Mem[EX_MEM_ALUOut];
 end
 else
 begin
 ID_EX_A <= #2 Reg[IF_ID_IR[24:20]]; // "rs2"
 end 
 if (IF_ID_IR[19:15]==ID_EX_IR[11:7]& ID_EX_type==RR_ALU)
 begin
 ID_EX_B<=#2 EX_MEM_ALUOut;
 end
 else if (IF_ID_IR[19:15]==ID_EX_IR[11:7] & ID_EX_type==LOAD)
 begin
 ID_EX_B<=#2 Mem[EX_MEM_ALUOut];
 end 
 else
 begin
 ID_EX_B <= #2 Reg[IF_ID_IR[19:15]]; // "rs2"
 end 
 ID_EX_NPC <= #2 IF_ID_NPC; 
 ID_EX_IR <= #2 IF_ID_IR; 
 ID_EX_Imml <= #2 {{20{IF_ID_IR[31]}}, {IF_ID_IR[31:20]}};
 ID_EX_Imms <= #2 {{20{IF_ID_IR[31]}}, {IF_ID_IR[31:25]},{IF_ID_IR[11:7]}};
 ID_EX_Immb <= #2 {{20{IF_ID_IR[31]}}, {IF_ID_IR[31]},{IF_ID_IR[7]}, {IF_ID_IR[30:25]},{IF_ID_IR[11:8]}};//branch
 ID_EX_Imm <= #2 {{20{IF_ID_IR[31]}}, {IF_ID_IR[31:20]}};

 case ({IF_ID_IR[30],IF_ID_IR[14:12],IF_ID_IR[6:4]}) 
 ADD,SUB,AND,OR,SLL,SRA: ID_EX_type <= #2 RR_ALU; 
 ADDI: ID_EX_type <= #2 RM_ALU; 
 LW: ID_EX_type <= #2 LOAD; 
 SW: ID_EX_type <= #2 STORE; 
 BEQ: ID_EX_type <= #2 BRANCH; 
 MAC: ID_EX_type <= #2 MAC_ALU;
 HLT: ID_EX_type <= #2 HALT; 
 default: ID_EX_type <= #2 HALT; 
 // Invalid opcode
 endcase
 end


 always @(posedge clk1) // EX Stage
 if (HALTED == 0) 
 begin 
 EX_MEM_type <= #2 ID_EX_type; 
 EX_MEM_IR <= #2 ID_EX_IR; 
 TAKEN_BRANCH <= #2 0; 
 case (ID_EX_type) 
 RR_ALU: begin 
 case ({IF_ID_IR[30],IF_ID_IR[14:12],IF_ID_IR[6:4]}) // "opcode" 
 ADD: EX_MEM_ALUOut <= #2 ID_EX_A + ID_EX_B; //ADD SUB SLL SRA AND OR
 SUB: EX_MEM_ALUOut <= #2 ID_EX_B - ID_EX_A; 
 AND: EX_MEM_ALUOut <= #2 ID_EX_A & ID_EX_B; 
 OR: EX_MEM_ALUOut <= #2 ID_EX_A | ID_EX_B; 
 SLL: EX_MEM_ALUOut <= #2 ID_EX_B << ID_EX_A[4:0];
 SRA: EX_MEM_ALUOut <= #2 ID_EX_A >>> ID_EX_B[4:0];
 default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx; 
 endcase
 end
 RM_ALU: begin 
 case ({IF_ID_IR[30],IF_ID_IR[14:12],IF_ID_IR[6:4]}) // "opcode" 
 ADDI: EX_MEM_ALUOut <= #2 ID_EX_B + ID_EX_Imm; //ADDI
 default: EX_MEM_ALUOut <= #2 32'hxxxxxxxx; 
 endcase
 end
 LOAD: //LW B,7( A)
 begin 
 EX_MEM_ALUOut <= #2 ID_EX_B + ID_EX_Imml; 
 //EX_MEM_B <= #2 ID_EX_B; //doubt stop
 end
 STORE: //SW
 begin 
 EX_MEM_ALUOut <= #2 ID_EX_B + ID_EX_Imms; 
 EX_MEM_A <= #2 ID_EX_A; //doubt stop STORE THE VALUE TO THE DESTINATION OF THE 
 end
 BRANCH: begin //BEQ
 EX_MEM_ALUOut <= #2 ID_EX_NPC + ID_EX_Immb; //should change the immediate value
 EX_MEM_cond <= #2 (ID_EX_A == ID_EX_B ); // change according to the code CHANGED
 end 
 MAC_ALU: begin //MAC_ALU
 EX_MEM_ALUOut <= #2 Reg[IF_ID_IR[11:7]]+(ID_EX_A * ID_EX_B);
 end 
 endcase
 end

always @(posedge clk2) // MEM Stage 
 if (HALTED == 0) 
 begin 
 MEM_WB_type <=#2 EX_MEM_type; 
 MEM_WB_IR <= #2 EX_MEM_IR; 
 case (EX_MEM_type) 
 RR_ALU, RM_ALU: 
 MEM_WB_ALUOut <= #2 EX_MEM_ALUOut; 
 LOAD: MEM_WB_LMD <= #2 Mem[EX_MEM_ALUOut]; //GETTING THE CONTENT TO BE WRITTEN IN THE DESTINATION REGISTER
 STORE: if (TAKEN_BRANCH == 0) // Disable write 
 Mem[EX_MEM_ALUOut] <= #2 EX_MEM_A; //storing the destination value FROM THE REGISTER TO THE MEMORY
 MAC_ALU:
 MEM_WB_ALUOut <= #2 EX_MEM_ALUOut; 
 endcase
 end
integer reg_mem,data_mem,i,j;
always @(posedge clk1) // WB Stage 
 begin 
 if (TAKEN_BRANCH == 0) // Disable write if branch taken 
 case (MEM_WB_type) 
 RR_ALU: Reg[MEM_WB_IR[11:7]] <= #2 MEM_WB_ALUOut; // "rd" 
 RM_ALU: Reg[MEM_WB_IR[11:7]] <= #2 MEM_WB_ALUOut; // "rt" 
 LOAD: Reg[MEM_WB_IR[11:7]] <= #2 MEM_WB_LMD; // "rt"
 MAC_ALU: Reg[MEM_WB_IR[11:7]] <= #2 MEM_WB_ALUOut;
 HALT: HALTED <= #2 1'b1; 
 endcase
 reg_mem = $fopen("Register_Dump.txt","w");
        for (i = 0; i < 32; i = i + 1)
        begin
            //Reading the contents of the register
            $fdisplay(reg_mem,"Reg[%0d] = %h\n",i,Reg[i]);
        end
        $fclose(reg_mem);
  data_mem = $fopen("dataMem_Dump.txt","w");
        for (j = 0; j < 32; j = j + 1)
        begin
            //Reading the contents of the register
            $fdisplay(reg_mem,"dataMem[%0d] = %h\n",j,Mem[j]);
        end
        $fclose(reg_mem);

 end 
endmodule
