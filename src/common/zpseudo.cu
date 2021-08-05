#include <cuComplex.h>

#define ARRAY_INDEX_1D(C_i, Fort_i_start) ((C_i) - (Fort_i_start))
#define ARRAY_INDEX_3D(C_i, C_j, C_k, Fort_i_start, Fort_i_end, Fort_j_start, Fort_j_end, Fort_k_start, Fort_k_end) \
	(((C_i) - (Fort_i_start)) \
	 + ((C_j) - (Fort_j_start)) * ((Fort_i_end) - (Fort_i_start) + 1) \
	 + ((C_k) - (Fort_k_start)) * ((Fort_i_end) - (Fort_i_start) + 1) * ((Fort_j_end) - (Fort_j_start) + 1))
#define ARRAY_INDEX_7D(C0, C1, C2, C3, C4, C5, C6, F0s, F0e, F1s, F1e, F2s, F2e, F3s, F3e, F4s, F4e, F5s, F5e, F6s, F6e) \
	(((C0) - (F0s)) \
	+ ((C1) - (F1s)) * ((F0e) - (F0s) + 1) \
	+ ((C2) - (F2s)) * ((F0e) - (F0s) + 1) * ((F1e) - (F1s) + 1) \
	+ ((C3) - (F3s)) * ((F0e) - (F0s) + 1) * ((F1e) - (F1s) + 1)  * ((F2e) - (F2s) + 1) \
	+ ((C4) - (F4s)) * ((F0e) - (F0s) + 1) * ((F1e) - (F1s) + 1)  * ((F2e) - (F2s) + 1) * ((F3e) - (F3s) + 1) \
	+ ((C5) - (F5s)) * ((F0e) - (F0s) + 1) * ((F1e) - (F1s) + 1)  * ((F2e) - (F2s) + 1) * ((F3e) - (F3s) + 1) * ((F4e) - (F4s) + 1) \
	+ ((C6) - (F6s)) * ((F0e) - (F0s) + 1) * ((F1e) - (F1s) + 1)  * ((F2e) - (F2s) + 1) * ((F3e) - (F3s) + 1) * ((F4e) - (F4s) + 1) * ((F5e) - (F5s) + 1) \
	 )

extern "C" {
__host__ __device__ cuDoubleComplex operator*(const cuDoubleComplex& a, const cuDoubleComplex& b) {
	return make_double2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

__host__ __device__ cuDoubleComplex operator*=(cuDoubleComplex& a, const double b) {
	return a = make_double2(a.x * b, a.y * b);
}

__host__ __device__ cuDoubleComplex operator+=(cuDoubleComplex& a, const cuDoubleComplex& b) {
	return a = make_double2(a.x + b.x, a.y + b.y);
}

// Kernel function for (src/common/nonlocal_potential.f90: l.271)
// Num threads = (im_e - im_s + 1) * (ik_e - ik_s + 1) * (io_e - io_s + 1) * Nlma.
__global__ void zpseudo_kernel(
		// Output & Input
		cuDoubleComplex* const htpsi_zwf,
		// Shape :  (psi%zwf(mg%is_array(1):mg%ie_array(1),  &
		//           mg%is_array(2):mg%ie_array(2),  &
		//           mg%is_array(3):mg%ie_array(3),  &
		//           nspin,info%io_s:info%io_e,info%ik_s:info%ik_e,info%im_s:info%im_e))
		//
		// Input
		const int im_s,
		const int im_e,
		const int ik_s,
		const int ik_e,
		const int io_s,
		const int io_e,
		const int Nspin,
		const int Nlma,
		const int ppg_nps,
		const int natom,
		const int mg_is_array_1,
		const int mg_ie_array_1,
		const int mg_is_array_2,
		const int mg_ie_array_2,
		const int mg_is_array_3,
		const int mg_ie_array_3,
		const int* const ppg_ia_tbl,
		// Shape :  (ppg%ia_tbl(n*natom))
		const int* const ppg_mps,
		// Shape :  (ppg%mps(natom))
		const int* const ppg_jxyz,
		// Shape :  (ppg%jxyz(3,ppg%nps,natom))
		const cuDoubleComplex* const ppg_zekr_uV,
		// Shape :  (ppg%zekr_uV(ppg%nps,ppg%nlma,ik_s:ik_e))
		const double* const ppg_rinv_uvu,
		// Shape :  (ppg%rinv_uvu(n*natom))
		const cuDoubleComplex* const tpsi_zwf
		// Shape :  The same with htpsi_zwf
		) {
	const unsigned tid = blockIdx.x * blockDim.x + threadIdx.x;


	const unsigned im_size = im_e - im_s + 1;
	const unsigned ik_size = ik_e - ik_s + 1;
	const unsigned io_size = io_e - io_s + 1;
	const unsigned array_length = im_size * ik_size * io_size * Nspin;
	if (tid >= array_length) {
		return;
	}

	const unsigned im = tid % im_size + im_s;
	const unsigned ik = (tid / im_size) % ik_size + ik_s;
	const unsigned io = (tid / (im_size * ik_size)) % io_size + io_s;
	const unsigned ispin = (tid / (im_size * ik_size * io_size)) + 1;

	for (unsigned ilma = 1; ilma <= Nlma; ilma++) {
		const unsigned ia = ppg_ia_tbl[ARRAY_INDEX_1D(ilma, 1)];
		cuDoubleComplex uVpsi = make_double2(0., 0.);

		for (unsigned j = 1; j <= ppg_mps[ARRAY_INDEX_1D(ia, 1)]; j++) {
			const cuDoubleComplex ppg_zekr_uV_v = ppg_zekr_uV[ARRAY_INDEX_3D(j, ilma, ik, 1, ppg_nps, 1, Nlma, ik_s, ik_e)];
			// calculate conj
			const cuDoubleComplex conjg_ppg_zekr_uV = make_double2(ppg_zekr_uV_v.x, -ppg_zekr_uV_v.y);

			const unsigned ix = ppg_jxyz[ARRAY_INDEX_3D(1, j, ia, 1, 3, 1, ppg_nps, 1, natoms)];
			const unsigned iy = ppg_jxyz[ARRAY_INDEX_3D(2, j, ia, 1, 3, 1, ppg_nps, 1, natoms)];
			const unsigned iz = ppg_jxyz[ARRAY_INDEX_3D(3, j, ia, 1, 3, 1, ppg_nps, 1, natoms)];
			uVpsi += conjg_ppg_zekr_uV * tpsi_zwf[ARRAY_INDEX_7D(
					ix, iy, iz, ispin, io, ik, im,
					mg_is_array_1, mg_ie_array_1,
					mg_is_array_2, mg_ie_array_2,
					mg_is_array_3, mg_ie_array_3,
					1, Nspin,
					io_s, io_e,
					ik_s, ik_e,
					im_s, im_e
					)];
		}

		uVpsi *= ppg_rinv_uvu[ARRAY_INDEX_1D(ilma, 1)];

		for (unsigned j = 1; j <= ppg_mps[ARRAY_INDEX_1D(ia, 1)]; j++) {
			const cuDoubleComplex wrk = uVpsi * ppg_zekr_uV[ARRAY_INDEX_3D(j, ilma, ik, 1, ppg_nps, 1, Nlma, ik_s, ik_e)];

			const unsigned ix = ppg_jxyz[ARRAY_INDEX_3D(1, j, ia, 1, 3, 1, ppg_nps, 1, natoms)];
			const unsigned iy = ppg_jxyz[ARRAY_INDEX_3D(2, j, ia, 1, 3, 1, ppg_nps, 1, natoms)];
			const unsigned iz = ppg_jxyz[ARRAY_INDEX_3D(3, j, ia, 1, 3, 1, ppg_nps, 1, natoms)];

			const unsigned mem_offset = ARRAY_INDEX_7D(
					ix, iy, iz, ispin, io, ik, im,
					mg_is_array_1, mg_ie_array_1,
					mg_is_array_2, mg_ie_array_2,
					mg_is_array_3, mg_ie_array_3,
					1, Nspin,
					io_s, io_e,
					ik_s, ik_e,
					im_s, im_e
					);
			atomicAdd(&(htpsi_zwf[mem_offset].x), wrk.x);
			atomicAdd(&(htpsi_zwf[mem_offset].y), wrk.y);
		}
	}
}

void zpseudo_cuda(
		// Output & Input
		cuDoubleComplex* const htpsi_zwf,
		// Input
		const int n,
		const int im_s,
		const int im_e,
		const int ik_s,
		const int ik_e,
		const int io_s,
		const int io_e,
		const int Nspin,
		const int Nlma,
		const int ppg_nps,
		const int natom,
		const int mg_is_array_1,
		const int mg_ie_array_1,
		const int mg_is_array_2,
		const int mg_ie_array_2,
		const int mg_is_array_3,
		const int mg_ie_array_3,
		const int* const ppg_ia_tbl,
		const int* const ppg_mps,
		const int* const ppg_jxyz,
		const cuDoubleComplex* const ppg_zekr_uV,
		const double* const ppg_rinv_uvu,
		cuDoubleComplex* const tpsi_zwf
		) {
	const unsigned im_size = im_e - im_s + 1;
	const unsigned ik_size = ik_e - ik_s + 1;
	const unsigned io_size = io_e - io_s + 1;
	const unsigned num_threads = im_size * ik_size * io_size * Nspin;

	const unsigned block_size = 256;
	const unsigned grid_size = (num_threads + block_size - 1) / block_size;

	zpseudo_kernel<<<grid_size, block_size>>>(
		htpsi_zwf,
		// Input
		im_s,
		im_e,
		ik_s,
		ik_e,
		io_s,
		io_e,
		Nspin,
		Nlma,
		ppg_nps,
		natom,
		mg_is_array_1,
		mg_ie_array_1,
		mg_is_array_2,
		mg_ie_array_2,
		mg_is_array_3,
		mg_ie_array_3,
		ppg_ia_tbl,
		ppg_mps,
		ppg_jxyz,
		ppg_zekr_uV,
		ppg_rinv_uvu,
		tpsi_zwf
		);
	cudaDeviceSynchronize();
}
} // extern "C"
