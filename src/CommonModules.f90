!     Last change:  RAR  18 Sep 1999   10:54 am
!!********************************************************************
!!
!! TMSE2D - Transfer matrix method for the Anderson
!! model with diagonal disorder in two dimensions
!!
!!********************************************************************
       
!!********************************************************************
!!
!! $Header: /home/cvs/phsht/AML/src/CommonModules.f90,v 1.1 2007/09/20 16:53:39 phrfar Exp $
!!
!!********************************************************************

!!**************************************************************************
!!$Log: CommonModules.f90,v $
!!Revision 1.1  2007/09/20 16:53:39  phrfar
!!previous files from a project of Rudo's. To be used as templates.
!!
!!Revision 1.5  2006/08/07 13:58:26  phsht
!!mistake in ARG(x,y) corrected
!!
!!Revision 1.4  2006/08/04 11:36:10  phsht
!!added a proper ARG(x,y) function in CommonModules and used in OutputEVals()
!!
!!Revision 1.3  2006/06/27 16:07:35  phsht
!!matA/matB and matU/UU/invmatU now seems consistent with h MMA results
!!
!!Revision 1.2  2006/05/08 19:23:40  phsht
!!this version writes .psi files correctly
!!
!!Revision 1.1  2006/05/08 08:42:17  phsht
!!1st installement of f90 tmse2dCOE files converted from tmse2dSB
!!
!!Revision 1.1  2003/07/07 11:10:27  phsht
!!Initial revision
!!
!!Revision 1.1  2003/06/20 12:53:17  phsht
!!Initial revision
!!
!!**************************************************************************

MODULE MyNumbers     
  IMPLICIT NONE

  INTEGER, PARAMETER :: IKIND = SELECTED_INT_KIND(9)
  INTEGER, PARAMETER :: RKIND = SELECTED_REAL_KIND(15,307)

  REAL(KIND=RKIND) :: PI, ONEPLS, ONEMNS

  REAL(KIND=RKIND), PARAMETER :: ZERO = 0.0, ONE = 1.0 ,TWO = 2.0, THREE = 3.0, FOUR = 4.0
  COMPLEX(KIND=RKIND), PARAMETER :: CZERO = (0.0d0,0.0d0), CONE = (1.0d0,0.0d0), &
       CIMAGONE= (0.0d0,1.0d0)

  REAL (KIND=RKIND), PARAMETER :: HALF = 0.5D0, QUARTER = 0.25D0, EIGHTH = 0.125D0

  REAL(KIND=RKIND) :: TINY= 1.0D-9

CONTAINS
  SUBROUTINE INIT_NUMBERS
    PI = 4.0D0* ATAN(1.0D0)
    ONEMNS = SQRT(EPSILON(ONEMNS))
    ONEPLS = ONE + ONEMNS
    ONEMNS = ONE - ONEMNS
  END SUBROUTINE INIT_NUMBERS

  FUNCTION ARG(X,Y)
    
    REAL(KIND=RKIND) ARG, X, Y
    
    IF( X > 0. ) THEN 
       ARG= ATAN(Y/X)
    ELSE IF ( (X == 0.) .and. (Y > 0. )) THEN 
       ARG = PI/2.0D0
    ELSE IF ( (X == 0.) .and. (Y < 0. )) THEN 
       ARG = -PI/2.0D0
    ELSE IF ( (X < 0. ) .and. (Y >= 0.)) THEN 
       ARG = PI + ATAN(Y/X)
    ELSE IF ( (X < 0. ) .and. (Y < 0. )) THEN 
       ARG = -PI + ATAN(Y/X)
    ENDIF
    
    RETURN
  END FUNCTION ARG

END MODULE MyNumbers



MODULE SETBINS

  USE MyNumbers
!!$  USE IChannels

  IMPLICIT NONE

CONTAINS

  Subroutine SetbinsforJad(Dim, Nx, IWidth, CubeDis, TarStore)

    INTEGER(KIND=IKIND) Dim, Nx, IWidth, EnR

    INTEGER(KIND=IKIND) Nsum, Nflat, Ndisp, Nunit, k, I, IErr

    REAL(KIND=RKIND) CubeDis, EngRan
    INTEGER(KIND=IKIND),Dimension(:,:), ALLOCATABLE:: &
         TarStore

    Nsum = ( (Nx*Dim)+1 )*(IWidth**Dim)
    Nflat = (2*Nx)*(IWidth**Dim)
    Ndisp = Nsum - Nflat

    EngRan = CubeDis/2 + 1.0D0
    EnR = INT(EngRan) + 1 ! +1 insured the eigenvalues are involved


    IF(Nx == 1)THEN
       ! (-EngRan,0) (0,EngRan)
       Nunit = Int(Ndisp/(2*EnR))
       ALLOCATE(TarStore(2*EnR, 2),STAT=IErr)

       IF(IErr.NE.0) THEN
          PRINT*,"SetbinsforJad(): Allocate error, IErr=", IErr
          STOP
       ENDIF

       k=1
       DO I=-EnR, EnR
          IF(I.NE.0)THEN
             TarStore(k,1)=I
             TarStore(k,2)=Nunit
             k=k+1
          END IF
       END DO

    ELSE IF(Nx == 2)THEN
       ! (-EngRan,-1) (-1,0) (0,1) (1,EngRan)
       ALLOCATE(TarStore(2*EnR-1, 2),STAT=IErr)

       IF(IErr.NE.0) THEN
          PRINT*,"SetbinsforJad(): Allocate error, IErr=", IErr
          STOP
       END IF

       k=1
       Do I=-EnR, EnR
          IF( (I.NE.-1) .OR. (I.NE.1) )THEN
             TarStore(k,1)=I
             TarStore(k,2)=Nunit
             k=k+1
          END IF

       END DO

    ELSE
       PRINT*,"SetbinsforJad(): EOF error in .inp file, IErr=", IErr
       !PRINT*, "Not Finish yet, Erro in inout.f90 of SetbinsforJad()" 
       STOP

    END IF

    RETURN

    DEALLOCATE(TarStore)


  END Subroutine SetbinsforJad

END MODULE SETBINS
