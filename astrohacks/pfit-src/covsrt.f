C	Copyright Eric Fuller, 2001-2007
C	This subroutine is derived from a subroutine of the same
C	name in Numerical Recipes in C

      SUBROUTINE COVSRT(COVAR,NPC,MA,AI,MFIT)


	INCLUDE 'pfit.cmn'


	INTEGER*4 MA,MFIT,NPC
	REAL*8 COVAR(NPC,NPC)
	INTEGER*4 AI(MFIT)

	INTEGER*4 I,J,K
	REAL*8 SWAP



	DO I=MFIT+1,MA
	  DO J=1,i
	    COVAR(I,J)=0.0
	    COVAR(J,I)=0.0
	    ENDDO
	  ENDDO

	K=MFIT

	DO J=MA,1,-1
	  IF (AI(J).NE.0) THEN
	    DO I=1,MA
	      SWAP=COVAR(I,K)
	      COVAR(I,K)=COVAR(I,J)
	      COVAR(I,J)=SWAP
	      ENDDO
	    DO I=1,MA
	      SWAP=COVAR(K,I)
	      COVAR(K,I)=COVAR(J,I)
	      COVAR(J,I)=SWAP
	      ENDDO
	    K=K-1
	    ENDIF
	  ENDDO



      RETURN

      END

