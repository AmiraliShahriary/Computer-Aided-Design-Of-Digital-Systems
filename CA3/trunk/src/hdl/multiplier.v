module mult_4x4 (input [4:0] D1 , D2 , output [9:0] out);
	wire w10 , w20 , w30 , w40;
	And and00(D1[0] , D2[0] , out[0]);
	And and10(D1[1] , D2[0] , w10 );
	And and20(D1[2] , D2[0] , w20 );
	And and30(D1[3] , D2[0] , w30 );
	NAnd nand40(D1[4] , D2[0] , w40 );


	wire w01 , w11 , w21 , w31 , w41 ;
	And and01(D1[0] , D2[1] , w01);
	And and11(D1[1] , D2[1] , w11);
	And and21(D1[2] , D2[1] , w21);
	And and31(D1[3] , D2[1] , w31);
	NAnd and41(D1[4] , D2[1] , w41);


	wire c10 , c11 , c12 , c13 , c14 , s11 , s12 , s13 , s14;
	fa fa01(w01, w10 , 1'b0 , out[1] , c10);
	fa fa11(w11, w20 , c10 , s11 , c11);
	fa fa21(w21, w30 , c11 , s12 , c12);
	fa fa31(w31, w40 , c12 , s13 , c13);
	fa fa41(w41, 1'b1 , c13 , s14 , c14);



	wire w02 , w12 , w22 , w32 , w42 ;
	And and02(D1[0] , D2[2] , w02);
	And and12(D1[1] , D2[2] , w12);
	And and22(D1[2] , D2[2] , w22);
	And and32(D1[3] , D2[2] , w32);
	NAnd nand42(D1[4] , D2[2] , w42);


	wire c20 , c21 , c22 , c23 , c24 , s21 , s22 , s23 , s24;
	fa fa02(w02, s11 , 1'b0 , out[2] , c20);
	fa fa12(w12, s12 , c20 , s21 , c21);
	fa fa22(w22, s13 , c21 , s22 , c22);
	fa fa32(w32, s14 , c22 , s23 , c23);
	fa fa42(w42, c14 , c23 , s24 , c24);


	wire w03 , w13 , w23 , w33 , w43 ;
	And and03(D1[0] , D2[3] , w03);
	And and13(D1[1] , D2[3] , w13);
	And and23(D1[2] , D2[3] , w23);
	And and33(D1[3] , D2[3] , w33);
	NAnd nand43(D1[4] , D2[3] , w43);

	wire c30 , c31 , c32 , c33 , c34 , s31 , s32 , s33 , s34;
	fa fa03(w03,s21 , 1'b0 , out[3] , c30);
	fa fa13(w13,s22 , c30 , s31 , c31);
	fa fa23(w23,s23 , c31 , s32 , c32);
	fa fa33(w33,s24 , c32 , s33 , c33);
	fa fa43(w43,c24 , c33 , s34 , c34);


	wire w04 , w14 , w24 , w34 , w44 ;
	NAnd and04(D1[0] , D2[4] , w04);
	NAnd and14(D1[1] , D2[4] , w14) ;
	NAnd and24(D1[2] , D2[4] , w24) ;
	NAnd and34(D1[3] , D2[4] , w34) ;
	And nand44(D1[4] , D2[4] , w44) ;

	wire c40 , c41 , c42 , c43 , c44 , s41 , s42 , s43 , s44;
	fa fa04(w04 ,s31 , 1'b0 , out[4] , c40);
	fa fa14(w14 ,s32 , c40 , out[5] , c41);
	fa fa24(w24 ,s33 , c41 , out[6] , c42);
	fa fa34(w34 ,s34 , c42 , out[7] , c43);
	fa fa44(w44 ,c34 , c43 , out[8] , c44);
	fa fa54(c44 ,1'b1 , 1'd0 , out[9] , );

endmodule
