C	Copyright Eric Fuller, 2001-2007

	SUBROUTINE GETPARAM(MA,A,AI)

	INCLUDE 'pfit.cmn'



	INTEGER*4 MA
	REAL*8 A(MMAX)
	INTEGER*4 AI(MMAX)

	INTEGER*4 I




C	GET PARAMETERS

	OPEN(UNIT=8,FILE='control.dat',STATUS='OLD')
	DO I=1,MA
	  READ(8,*) A(I),AI(I)
	  ENDDO
	CLOSE(8)



	RETURN

	END






	SUBROUTINE GETDATA(PHI,RHO,X1,X2,Y1,Y2,
     *  SIG1,SIG2,NDAT)

	INCLUDE 'pfit.cmn'



	REAL*8 PHI,RHO,XTICKS,YTICKS
	REAL*8 X1(NMAX),X2(NMAX),Y1(NMAX),Y2(NMAX),SIG1(NMAX),SIG2(NMAX)
	INTEGER*4 NDAT

	INTEGER*4 I



C	GET DATA

	OPEN(UNIT=8,FILE='input.dat',STATUS='OLD')
	READ(8,32) PHI,RHO
	READ(8,34) XTICKS,YTICKS
C	WRITE(*,36) XTICKS,YTICKS
	DO I=1,NMAX
	  READ(8,*,END=20) X1(I),X2(I),Y1(I),Y2(I)
	  SIG1(I)=XTICKS/SQRT(3.0)/COS(X2(I)*D2R)
	  SIG2(I)=YTICKS/SQRT(3.0)
C	  WRITE(*,*) X1(I),X2(I),Y1(I),Y2(I),SIG1(I),SIG2(I)
	  ENDDO
20	CONTINUE
	NDAT=I-1
	CLOSE(8)



	WRITE(0,30) NDAT
C	WRITE(0,33) PHI
C	WRITE(0,37) RHO



30	FORMAT('Stars             : ',I5)
31	FORMAT(F11.6,2X,F11.6,2X,F11.6,2X,F11.6)
32	FORMAT(F12.6,4X,F12.6)
33	FORMAT('Latitude          : ',F11.6)
34	FORMAT(F8.6,4X,F8.6)
35	FORMAT(I6,2X,I6)
36	FORMAT('Ticks             : ',F8.6,',',F8.6)
37	FORMAT('Longitude         : ',F11.6)



	RETURN

	END



	SUBROUTINE MODEL(MA,A,SIGA)

	INCLUDE 'pfit.cmn'



	INTEGER*4 MA
	REAL*8 A(MMAX),SIGA(NMAX)

	INTEGER*4 I



C	WRITE A FILE FOR A PROGRAM TO READ THE MODEL PARAMETERS

	OPEN(UNIT=8,FILE='model.dat',STATUS='UNKNOWN')
	DO I=1,MA
	  WRITE(8,60) I,A(I),SIGA(I)
	  ENDDO
	CLOSE(8)



60	FORMAT(I2,4X,F14.6,2X,F14.6)



	RETURN

	END
