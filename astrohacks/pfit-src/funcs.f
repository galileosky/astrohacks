C	Copyright Eric Fuller, 2001-2007
C	This subroutine was derived from a subroutine of the same
C	name in Numerical Recipes in C

        SUBROUTINE FUNCS(X1,X2,P1,P2,NP,PHI)

        INCLUDE 'pfit.cmn'

        INTEGER*4 NP
        REAL*8 X1,X2,P1(NP),P2(NP),PHI



	P1(1) =1.0
	P1(2) =X1
        P1(3) =0.0
        P1(4) =0.0
	P1(5) =(1.0/COS(X2*D2R))
	P1(6) =TAN(X2*D2R)
	P1(7) =(-COS(X1*D2R)*TAN(X2*D2R))
	P1(8) =(SIN(X1*D2R)*TAN(X2*D2R))
	P1(9) =(COS(PHI*D2R)*SIN(X1*D2R)/COS(X2*D2R))
	P1(10)=0.0
	P1(11)=(-(COS(PHI*D2R)*COS(X1*D2R) +
     *    SIN(PHI*D2R)*TAN(X2*D2R) ))
	P1(12)=SIN(X1*D2R)
	P1(13)=COS(X1*D2R)
	P1(14)=0.0
	P1(15)=0.0
	P1(16)=TAN(X2*D2R)*SIN(X1*D2R)
	P1(17) =(-COS(X1*D2R)*TAN(X2*D2R))*SIN(X1*D2R)
	P1(18) =(-COS(X1*D2R)*TAN(X2*D2R))*COS(X1*D2R)



	P2(1) =0.0
	P2(2) =0.0
        P2(3) =1.0
        P2(4) =X2
	P2(5) =0.0
	P2(6) =0.0
	P2(7) =SIN(X1*D2R)
	P2(8) =COS(X1*D2R)
	P2(9) =COS(PHI*D2R)*COS(X1*D2R)*SIN(X2*D2R) -
     *    SIN(PHI*D2R)*COS(X2*D2R)
	P2(10)=COS(X1*D2R)
	P2(11)=0.0
	P2(12)=0.0
	P2(13)=0.0
	P2(14)=SIN(X2*D2R)
	P2(15)=COS(X2*D2R)
	P2(16)=0.0
	P2(17) =SIN(X1*D2R)*SIN(X1*D2R)
	P2(18) =SIN(X1*D2R)*COS(X1*D2R)



	RETURN

        END




