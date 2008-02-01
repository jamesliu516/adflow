!
!     ******************************************************************
!     *                                                                *
!     * File:          allocMemADjoint.f90                             *
!     * Author:        Andre C. Marta ,                                *
!     *                Seongim Choi                                    *
!     * Starting date: 07-20-2006                                      *
!     * Last modified: 11-18-2007                                      *
!     *                                                                *
!     ******************************************************************
!
      subroutine allocMemADjoint(level)
!
!     ******************************************************************
!     *                                                                *
!     * Allocate the memory for the adjoint solver variables           *
!     * 'globalCell' for all blocks, at the specified grid level and   *
!     * time instance. These variables are the same for all spectral   *
!     * modes, therefore only the 1st mode needs to be allocated.      *
!     *                                                                *
!     ******************************************************************
!
!s      use BCTypes
      use blockPointers
!      use indices ! nw
      use section ! secID
      use inputtimespectral
      use flowVarRefState
      implicit none
!
!     Subroutine arguments.
!
      integer(kind=intType), intent(in) :: level
!
!     Local variables.
!
      integer :: ierr

      integer(kind=intType) :: nn, sps, secID, nTime
!
!     ******************************************************************
!     *                                                                *
!     * Begin execution.                                               *
!     *                                                                *
!     ******************************************************************
!
      ! Loop over the domains.

      domainsLoop: do nn=1,nDom

        ! Easier storage of some variables, which are independent
        ! of the time instance.

        ib = flowDoms(nn,level,1)%ib
        jb = flowDoms(nn,level,1)%jb
        kb = flowDoms(nn,level,1)%kb

        ie = flowDoms(nn,level,1)%ie
        je = flowDoms(nn,level,1)%je
        ke = flowDoms(nn,level,1)%ke

!
!       ****************************************************************
!       *                                                              *
!       * Allocate the memory for the global node numbering array that *
!       * that contains the global node numbering of all blocks in all *
!       * processors, including the halo nodes, if they exist, on the  *
!       * specified grid level. The same for the adjoint solution and  *
!       * the cost function sensitivity wrt the electric conductivity. *
!       *                                                              *
!       * The other variables of flowDoms are allocated in the         *
!       * flow solver file initFlow/allocMemFlovar.f90, on which this  *
!       * following routine portion is based on.                       *
!       *                                                              *
!       ****************************************************************
!
        secID = flowDoms(nn,level,1)%sectionID
        nTime = nTimeIntervalsSpectral!sections(secID)%nTimeInstances
        print *,'Shape',shape(flowdoms)
        spectralLoop: do sps = 1, nTime
           print *,' inspectral', nn,level,sps,ib,jb,kb
           allocate(flowDoms(nn,level,sps)%globalCell(0:ib,0:jb,0:kb), &
                    stat=ierr)
           print *,'error',ierr
           if(ierr /= 0)                       &
                call terminate("allocMemADjoint", &
                               "Memory allocation failure for globalCell")

           allocate(flowDoms(nn,level,sps)%globalNode(0:ib,0:jb,0:kb), &
                stat=ierr)
           if(ierr /= 0)                       &
                call terminate("allocMemADjoint", &
                                "Memory allocation failure for globalNode")

           ! initialization of globalCell
           flowDoms(nn,level,sps)%globalCell(0:ib,0:jb,0:kb) = 0           
           flowDoms(nn,level,sps)%globalNode(0:ib,0:jb,0:kb) = 0

           allocate(flowDoms(nn,level,sps)%psiAdj(0:ib,0:jb,0:kb,1:nw),&
                    stat=ierr)
           if(ierr /= 0)                       &
                call terminate("allocMemADjoint", &
                              "Memory allocation failure for psiAdj")

        end do spectralLoop
     enddo domainsLoop

   end subroutine allocMemADjoint
