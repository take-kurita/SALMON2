!
!  Copyright 2019 SALMON developers
!
!  Licensed under the Apache License, Version 2.0 (the "License");
!  you may not use this file except in compliance with the License.
!  You may obtain a copy of the License at
!
!      http://www.apache.org/licenses/LICENSE-2.0
!
!  Unless required by applicable law or agreed to in writing, software
!  distributed under the License is distributed on an "AS IS" BASIS,
!  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
!  See the License for the specific language governing permissions and
!  limitations under the License.
!
MODULE scf_data
use salmon_global
use salmon_xc, only: s_xc_functional
implicit none
!-------------------- Parameters
integer, parameter :: maxntmg=10

! Physical constants
real(8),parameter :: E2=14.4d0, H2M=3.81d0, a_B=0.529177d0
real(8),parameter :: Ry=13.6058d0, Pi=3.141592653589793d0
real(8),parameter :: fs2eVinv = 1.51925d0

! Coefficients of finite-difference
integer,parameter :: Nd=4       ! (2*Nd+1)-points finite-difference used in Taylor expansion
integer,parameter :: Ndh=4       ! (2*Nd+1)-points finite-difference used in Hartree routine
real(8),parameter :: cN0=-205.d0/72.d0                 ! for Laplacian
real(8),parameter :: cN1=8.d0/5.d0  , cN2=-1.d0/5.d0
real(8),parameter :: cN3=8.d0/315.d0, cN4=-1.d0/560.d0
real(8),parameter :: bN1=4.d0/5.d0  , bN2=-1.d0/5.d0   ! for Nabla
real(8),parameter :: bN3=4.d0/105.d0, bN4=-1.d0/280.d0

real(8),parameter :: cN0_Nd1=-2.d0
real(8),parameter :: cN1_Nd1=1.d0
real(8),parameter :: bN1_Nd1=1.d0/2.d0

real(8),parameter :: cN0_Nd2=-5.d0/2.d0
real(8),parameter :: cN1_Nd2=4.d0/3.d0, cN2_Nd2=-1.d0/12.d0
real(8),parameter :: bN1_Nd2=2.d0/3.d0, bN2_Nd2=-1.d0/12.d0

real(8),parameter :: cN0_Nd3=-49.d0/18.d0 
real(8),parameter :: cN1_Nd3=3.d0/2.d0, cN2_Nd3=-3.d0/20.d0
real(8),parameter :: cN3_Nd3=1.d0/90.d0
real(8),parameter :: bN1_Nd3=3.d0/4.d0, bN2_Nd3=-3.d0/20.d0 
real(8),parameter :: bN3_Nd3=1.d0/60.d0

real(8),parameter :: cN0_Nd5=-5269.d0/1800.d0 
real(8),parameter :: cN1_Nd5=5.d0/3.d0, cN2_Nd5=-5.d0/21.d0
real(8),parameter :: cN3_Nd5=5.d0/126.d0, cN4_Nd5=-5.d0/1008.d0
real(8),parameter :: cN5_Nd5=1.d0/3150.d0

real(8),parameter :: cN0_Nd6=-5369.d0/1800.d0 
real(8),parameter :: cN1_Nd6=12.d0/7.d0, cN2_Nd6=-15.d0/56.d0
real(8),parameter :: cN3_Nd6=10.d0/189.d0, cN4_Nd6=-1.d0/112.d0
real(8),parameter :: cN5_Nd6=2.d0/1925.d0, cN6_Nd6=-1.d0/16632.d0

real(8),parameter :: cN0_Nd7=-266681.d0/88200.d0
real(8),parameter :: cN1_Nd7=7.d0/4.d0, cN2_Nd7=-7.d0/24.d0
real(8),parameter :: cN3_Nd7=7.d0/108.d0, cN4_Nd7=-7.d0/528.d0
real(8),parameter :: cN5_Nd7=7.d0/3300.d0, cN6_Nd7=-7.d0/30888.d0
real(8),parameter :: cN7_Nd7=1.d0/84084.d0

real(8),parameter :: cN0_Nd8=-1077749.d0/352800.d0 
real(8),parameter :: cN1_Nd8=16.d0/9.d0, cN2_Nd8=-14.d0/45.d0
real(8),parameter :: cN3_Nd8=112.d0/1485.d0, cN4_Nd8=-7.d0/396.d0
real(8),parameter :: cN5_Nd8=112.d0/32175.d0, cN6_Nd8=-2.d0/3861.d0
real(8),parameter :: cN7_Nd8=16.d0/315315.d0, cN8_Nd8=-1.d0/411840.d0

real(8),parameter :: cN0_Nd9=-9778141.d0/3175200.d0
real(8),parameter :: cN1_Nd9=9.d0/5.d0, cN2_Nd9=-18.d0/55.d0
real(8),parameter :: cN3_Nd9=14.d0/165.d0, cN4_Nd9=-63.d0/2860.d0
real(8),parameter :: cN5_Nd9=18.d0/3575.d0, cN6_Nd9=-2.d0/2145.d0
real(8),parameter :: cN7_Nd9=9.d0/70070.d0, cN8_Nd9=-9.d0/777920.d0
real(8),parameter :: cN9_Nd9=1.d0/1969110.d0

real(8),parameter :: cN0_Nd10=-1968329.d0/635040.d0
real(8),parameter :: cN1_Nd10=20.d0/11.d0, cN2_Nd10=-15.d0/44.d0
real(8),parameter :: cN3_Nd10=40.d0/429.d0, cN4_Nd10=-15.d0/572.d0
real(8),parameter :: cN5_Nd10=24.d0/3575.d0, cN6_Nd10=-5.d0/3432.d0
real(8),parameter :: cN7_Nd10=30.d0/119119.d0, cN8_Nd10=-5.d0/155584.d0
real(8),parameter :: cN9_Nd10=10.d0/3741309.d0, cN10_Nd10=-1.d0/9237800.d0

real(8),parameter :: cN0_Nd11=-239437889.d0/76839840.d0
real(8),parameter :: cN1_Nd11=11.d0/6.d0, cN2_Nd11=-55.d0/156.d0
real(8),parameter :: cN3_Nd11=55.d0/546.d0, cN4_Nd11=-11.d0/364.d0
real(8),parameter :: cN5_Nd11=11.d0/1300.d0, cN6_Nd11=-11.d0/5304.d0
real(8),parameter :: cN7_Nd11=55.d0/129948.d0, cN8_Nd11=-55.d0/806208.d0
real(8),parameter :: cN9_Nd11=11.d0/1360476.d0, cN10_Nd11=-11.d0/17635800.d0
real(8),parameter :: cN11_Nd11=1.d0/42678636.d0

real(8),parameter :: cN0_Nd12=-240505109.d0/76839840.d0
real(8),parameter :: cN1_Nd12=24.d0/13.d0, cN2_Nd12=-33.d0/91.d0
real(8),parameter :: cN3_Nd12=88.d0/819.d0, cN4_Nd12=-99.d0/2912.d0
real(8),parameter :: cN5_Nd12=396.d0/38675.d0, cN6_Nd12=-11.d0/3978.d0
real(8),parameter :: cN7_Nd12=132.d0/205751.d0, cN8_Nd12=-33.d0/268736.d0
real(8),parameter :: cN9_Nd12=44.d0/2380833.d0, cN10_Nd12=-3.d0/1469650.d0
real(8),parameter :: cN11_Nd12=12.d0/81800719.d0, cN12_Nd12=-1.d0/194699232.d0

real(8) :: cnmat(0:12,12),bnmat(4,4)

!-------------------- Global variables

! Exchange Correlation
type(s_xc_functional) :: xc_func

integer :: iflag_ps

integer :: inumcpu_check

integer,allocatable :: ob_sta_all_kgrid(:),ob_end_all_kgrid(:),iobnum_all_kgrid(:)

integer :: nproc_d_o(3),nproc_d_o_mul
integer :: nproc_ob_spin(2)
integer :: nproc_d_g(3), nproc_d_o_mul_s
integer :: nproc_d_g_dm(3), nproc_d_g_mul_dm

integer :: ista_Mx_ori(3),iend_Mx_ori(3),inum_Mx_ori(3)
integer,allocatable :: ista_Mxin(:,:),iend_Mxin(:,:),inum_Mxin(:,:)
integer,allocatable :: ista_Mxin_old(:,:),iend_Mxin_old(:,:),inum_Mxin_old(:,:)
integer,allocatable :: ista_Mxin_s(:,:),iend_Mxin_s(:,:),inum_Mxin_s(:,:)
integer :: max_lg_num

integer :: Miter       ! Total number of Iteration for SCF calculation
integer :: Miter_rt    ! Total number of Iteration for RT calculation

integer :: iflag_diisjump

integer :: iflag_write_psi
real(8),allocatable :: rto(:)
integer ,allocatable:: idip2int(:)
real(8),allocatable :: rto_ix(:,:)
real(8),allocatable :: rbox_array_dip2(:,:)
real(8),allocatable :: rbox_array2_dip2(:,:)
real(8),allocatable :: rbox_array_dip2q(:,:,:)
real(8),allocatable :: rbox_array2_dip2q(:,:,:)
real(8),allocatable :: rbox_array_dip2e(:)
real(8),allocatable :: rbox_array2_dip2e(:)

integer :: ilsda

logical :: flag_opt_conv
integer :: iflag_opt
integer :: iter_opt
integer :: iopt

integer :: MST(2),ifMST(2),itotMST
integer :: itotfMST
integer :: MST0(2),itotMST0
integer :: Mx(3),Mxin(3),Mxin_old(3)

real(8) :: rnetot

!character(8),allocatable :: AtomName(:)   
!integer,allocatable :: iAtomicNumber(:)   

real(8) :: Hgs(3)        ! Grid spacing
real(8) :: Hold(3)     ! Grid spacing
real(8) :: Hvol
real(8) :: Harray(3,maxntmg)  ! Grid spacing
real(8) :: rLsize(3,maxntmg)    ! size of the box

! Pseudopotential
integer,parameter :: Lmax=4
integer,allocatable :: NRloc(:)
real(8),allocatable :: Rloc(:)
real(8),allocatable :: Zps(:)              ! Pseudo charge
real(8),allocatable :: Rps(:)              ! Core radius
integer :: Mlps(maxMKI),Lref(maxMKI)
real(8),allocatable :: Vpsl(:,:,:)                 ! Local pseudopotential
real(8),allocatable :: Vpsl_atom(:,:,:,:)
!Nonlinear core correction
logical :: flag_nlcc = .false.

real(8),allocatable :: rocc(:,:)                    ! Occupation number
real(8),allocatable :: psi(:,:,:,:,:)              ! Single particle orbitals
real(8),allocatable :: psi_mesh(:,:,:,:,:)         ! Single particle orbitals
real(8),allocatable :: zpsi_mesh(:,:,:,:,:)        ! Single particle orbitals
real(8),allocatable :: psi_old(:,:,:,:,:)
complex(8),allocatable :: zpsi_old(:,:,:,:,:)

real(8),allocatable :: esp(:,:)         ! Single particle energy
real(8),allocatable :: esp2(:,:)        ! Single particle energy
real(8),allocatable :: rho(:,:,:)       ! Single particle density
real(8),allocatable :: rho0(:,:,:)      ! Single particle density
real(8),allocatable :: rho_diff(:,:,:)  ! Single particle density
real(8),allocatable :: rho_s(:,:,:,:)   ! Single particle density for each spin
real(8),allocatable :: Vh(:,:,:)        ! Hartree potential
real(8),allocatable :: Vxc(:,:,:)       ! Exchange-Correlation potential
real(8),allocatable :: Vxc_s(:,:,:,:)   ! Exchange-Correlation potential for each spin 
integer :: ihpsieff
real(8),allocatable :: elf(:,:,:)
complex(8),allocatable :: zpsi(:,:,:,:,:)
complex(8),allocatable :: zpsi_in(:,:,:,:,:),zpsi_out(:,:,:,:,:)
complex(8),allocatable :: zpsi_t0(:,:,:,:,:)
complex(8),allocatable :: ttpsi(:,:,:)
integer :: iSCFRT

real(8),allocatable :: Vbox(:,:,:)

real(8),allocatable :: Ex_fast(:,:,:),Ec_fast(:,:,:)

integer, allocatable :: idiis_sd(:)


integer :: maxlm

integer :: imesh_oddeven(3)

integer :: version_num(2)

complex(8), allocatable :: zc(:)
real(8), allocatable :: Dp(:,:), Dp2(:,:,:)
real(8), allocatable :: Qp(:,:,:), Qp2(:,:,:,:)
real(8), allocatable :: rIe(:), rIe2(:,:)
real(8), allocatable :: tene(:)
real(8) :: vecDs(3)
real(8),allocatable :: vecDs2(:,:)
real(8) :: vecQs(3,3)
real(8),allocatable :: vecQs2(:,:,:)

integer :: itotNtime

integer :: num_datafiles_OUT2

real(8),allocatable :: Gs(:,:,:),Gl(:,:,:)
complex(8),allocatable :: tx_exp(:,:),ty_exp(:,:),tz_exp(:,:)

integer :: lg_sta(3),lg_end(3),lg_num(3)
integer :: mg_sta(3),mg_end(3),mg_num(3)
integer :: ng_sta(3),ng_end(3),ng_num(3)

integer :: lg_old_sta(3),lg_old_end(3),lg_old_num(3)
integer :: mg_old_sta(3),mg_old_end(3),mg_old_num(3)
integer :: ng_old_sta(3),ng_old_end(3),ng_old_num(3)

integer :: igc_is,igc_ie

integer :: iobnum

integer :: k_sta,k_end,k_num

integer :: kx_hock_sta(3),kx_hock_end(3),kx_hock_num(3)

integer :: num_kpoints_3d(3)
integer :: num_kpoints_rd

real(8),allocatable :: wtk(:)

real(8),allocatable :: norm_diff_psi_stock(:,:)

real(8) :: Etot
real(8) :: Exc

integer :: imr(3),imrs(3),igroup

integer :: iflag_subspace_diag

real(8),allocatable :: Vh_stock1(:,:,:)
real(8),allocatable :: Vh_stock2(:,:,:)

real(8),allocatable :: Vlocal(:,:,:,:)
real(8),allocatable :: Vlocal2(:,:,:,:)

real(8),allocatable :: vloc_t(:,:,:,:)
real(8),allocatable :: vloc_new(:,:,:,:)
real(8),allocatable :: vloc_old(:,:,:,:,:)

real(8),allocatable :: rhobox(:,:,:)
real(8),allocatable :: rhobox_s(:,:,:,:)

integer :: lg_num_fmax(3)

real(8), allocatable :: rhobox1_all(:,:,:), rhobox2_all(:,:,:)

integer :: iDiter(maxntmg)
integer :: lg_sta_ini(3),lg_end_ini(3),lg_num_ini(3)
integer :: mg_sta_ini(3),mg_end_ini(3),mg_num_ini(3)
integer :: img

integer :: itt
integer :: ikind_eext   !0:No external field, 1: dipoleApprox

character(3)  :: dir
character(2)  :: dir2 

real(8) :: Fst,Fst2(2)
real(8) :: romega, romega2(2)
real(8) :: pulse_T, pulse_T2(2) 
real(8) :: rlaser_I, rlaser_I2(2) 
real(8) :: tau, tau2(2), delay, rcycle

character(2)  :: denplane  ! plane for writing density (xy, yz, xz)
integer       :: idensum   ! whether density is summed up along direction
                           ! perpendicular to the plane
                           ! (0: not summed, 1: summed)
real(8)       :: posplane  ! position of the plane
                           ! (only for idensum = 0)

character(1) :: circular

character(100):: rtOutFile
character(100):: rtDiffOutFile
character(100):: rtELFOutFile
character(100):: file_Projection
character(20) :: fileNumber

real(8), allocatable :: rho_n(:,:,:)
real(8), allocatable :: Vh_n(:,:,:)
real(8), allocatable :: Vh0(:,:,:)
complex(8), allocatable :: zpsi_n(:,:,:,:,:)

real(8),allocatable :: Ex_static(:,:,:),Ey_static(:,:,:),Ez_static(:,:,:)

real(8),allocatable :: curr(:,:), curr_ion(:,:)
real(8),allocatable :: sumcurr(:,:)
real(8),allocatable :: rE_ind(:,:)

integer :: ilasbound_sta(3),ilasbound_end(3)
real(8) :: rlaser_center(3)

complex(8) :: cumnum

real(8) :: Eion

integer :: iblacsinit
integer :: CONTEXT, IAM, MYCOL, MYROW, NPCOL, NPROCS2, NPROW
integer :: DESCA( 50 ), DESCZ( 50 )

real(8) :: rho_region1(100)
real(8) :: rho_region2(100)
integer :: num_rho_region(100)
integer,allocatable :: rho_region_nx(:,:)
integer,allocatable :: rho_region_ny(:,:)
integer,allocatable :: rho_region_nz(:,:)

integer :: numspin

integer :: icalcforce
integer :: iflag_md

real(8) :: fcN(0:12)
real(8) :: fbN(0:12)

real(8),allocatable :: k_rd(:,:),ksquare(:)
real(8),allocatable :: k_rd0(:,:),ksquare0(:)

real(8),allocatable :: A_ext(:,:)
real(8),allocatable :: A_ind(:,:)
real(8),allocatable :: A_tot(:,:)
real(8),allocatable :: E_ext(:,:)
real(8),allocatable :: E_ind(:,:)
real(8),allocatable :: E_tot(:,:)

integer,allocatable :: oblist(:)
integer,allocatable ::icoo1d(:,:)

integer :: MI_read

real(8) :: absorption(0:100000)
real(8) :: absorption_d(0:100000)
real(8) :: absorption_id(0:100000)

integer :: iflag_dos
integer :: iflag_pdos
integer :: iflag_ELF
integer :: iflag_indA
integer :: iflag_hartree

real(8),allocatable :: vonf_sd(:,:,:),eonf_sd(:,:,:,:)

!filename
character(100) :: file_out_gs_bin
character(100) :: file_in_gs_bin
!character(100) :: file_gs_info
character(100) :: file_eigen
character(100) :: file_RT
character(100) :: file_alpha_lr
character(100) :: file_alpha_pulse
character(100) :: file_RT_q
character(100) :: file_alpha_q
character(100) :: file_RT_e
character(100) :: file_RT_dip2
character(100) :: file_alpha_dip2
character(100) :: file_RT_dip2_q
character(100) :: file_alpha_dip2_q
character(100) :: file_RT_dip2_e
character(100) :: file_external
character(100) :: file_out_rt_bin
character(100) :: file_in_rt_bin

!arrays for isend and irecv


CONTAINS

!=========================================================================
!-------------------------------------------------------------------------
!-------------------------------------------------------------------------
!=========================================================================
subroutine snum_procs
use salmon_parallel, only: nproc_size_global
implicit none
integer :: i,ibox,ipow

nproc_d_o_mul=nproc_size_global/nproc_ob

ibox=1
ipow=0
do i=1,29
  if(ibox<nproc_d_o_mul)then
    ipow=ipow+1
    ibox=ibox*2
  end if
end do

nproc_d_o(1:3)=1
do i=1,ipow
  if(mod(i,3)==1)then
    nproc_d_o(3)=nproc_d_o(3)*2
  else if(mod(i,3)==2)then
    nproc_d_o(2)=nproc_d_o(2)*2
  else
    nproc_d_o(1)=nproc_d_o(1)*2
  end if
end do

ibox=1
ipow=0
do i=1,29
  if(ibox<nproc_size_global)then
    ipow=ipow+1
    ibox=ibox*2
  end if
end do

nproc_d_g(1:3)=1
do i=1,ipow
  if(mod(i,3)==1)then
    nproc_d_g(3)=nproc_d_g(3)*2
  else if(mod(i,3)==2)then
    nproc_d_g(2)=nproc_d_g(2)*2
  else
    nproc_d_g(1)=nproc_d_g(1)*2
  end if
end do

end subroutine snum_procs

!======================================================================
subroutine old_mesh(lg,mg,ng)
use salmon_parallel, only: nproc_size_global
use structures, only: s_rgrid
implicit none
type(s_rgrid),intent(in) :: lg,mg,ng

lg_sta(1:3) = lg%is(1:3)
lg_end(1:3) = lg%ie(1:3)
lg_num(1:3) = lg%num(1:3)
call check_fourier(lg)

mg_sta(1:3) = mg%is(1:3)
mg_end(1:3) = mg%ie(1:3)
mg_num(1:3) = mg%num(1:3)

ng_sta(1:3) = ng%is(1:3)
ng_end(1:3) = ng%ie(1:3)
ng_num(1:3) = ng%num(1:3)

allocate(ista_Mxin(3,0:nproc_size_global-1),iend_Mxin(3,0:nproc_size_global-1))
allocate(inum_Mxin(3,0:nproc_size_global-1))

allocate(ista_Mxin_s(3,0:nproc_size_global-1),iend_Mxin_s(3,0:nproc_size_global-1))
allocate(inum_Mxin_s(3,0:nproc_size_global-1))

ista_mxin = mg%is_all
iend_mxin = mg%ie_all
inum_mxin = mg%ie_all - mg%is_all + 1

ista_mxin_s = ng%is_all
iend_mxin_s = ng%ie_all
inum_mxin_s = ng%ie_all - ng%is_all + 1

end subroutine old_mesh

function check_rion_update() result(rion_update)
  implicit none
  logical :: rion_update
  ! iflag_opt <= calculation%yn_opt (in scf)
  ! iflag_md  <= calculation%yn_md (in rt)
  if (iscfrt == 1) then
    rion_update = (iflag_opt == 1)
  else if (iscfrt == 2) then
    rion_update = (iflag_md == 1)
  else
    rion_update = .true.
  end if
end function

END MODULE scf_data

