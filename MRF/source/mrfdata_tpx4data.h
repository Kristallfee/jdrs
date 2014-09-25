/*============================================================*/
/* mrfdata_tpxpixel.h                                         */
/* MVD Readout Framework Data Storage                         */
/* Provides Access to ToPiX Pixel Configuration               */
/*                                               M.C. Mertens */
/*============================================================*/

#ifndef __MRFDATA_TPX4DATA_H__
#define __MRFDATA_TPX4DATA_H__

#include "mrfdataadv1d.h"

class TMrfData_Tpx4Data : virtual public TMrfDataAdv1D
{
        public:
                TMrfData_Tpx4Data(const u_int32_t& blocklength = bitsinablock, const u_int32_t& defaultindex = 0, const u_int32_t& defaultstreamoffset = 0, const u_int32_t& defaultvalueoffset = 0, const bool& defaultreverse = true, const bool& defaultstreamreverse = false);

		//From TMrfDataAdvBase
		virtual void initMaps();

                u_int32_t getPixelAddress();     // Address of Pixel
                u_int32_t getChipAddress();     // Address of Pixel
                u_int32_t getLeadingEdge();
                u_int32_t getTrailingEdge();
                u_int32_t getFrameCounter();

        protected:

	private:
		void convert_matrix_to_line(int matrixcol,int matrixrow,int &col, int &row);
		void convert_line_to_matrix(int col, int row, int &matrixcol, int&matrixrow);
};

#endif /* __MRFDATA_TPX4DATA_H__ */
