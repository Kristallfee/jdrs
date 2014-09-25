#ifndef MRFDATA_TPX4PIXEL_H
#define MRFDATA_TPX4PIXEL_H
#include "mrfdataadv1d.h"

/*============================================================*/
/* mrfdata_tpx4pixel.h                                        */
/* MVD Readout Framework Data Storage                         */
/* Provides Access to ToPix 4 Pixel Configuration             */
/*                                                    S. Esch */
/*============================================================*/

class TMrfData_Tpx4Pixel : virtual public TMrfDataAdv1D
{
        public:
                TMrfData_Tpx4Pixel(const u_int32_t& blocklength = bitsinablock, const u_int32_t& defaultindex = 0, const u_int32_t& defaultstreamoffset = 0, const u_int32_t& defaultvalueoffset = 0, const bool& defaultreverse = false, const bool& defaultstreamreverse = false);

                //From TMrfDataAdvBase
                virtual void initMaps();
                //virtual void assemble();
                virtual void setCommand(u_int32_t command);

                u_int32_t getAddress();
                u_int32_t getPixelMask();
                u_int32_t getTestPulsEnable();
                u_int32_t getComparatorTestOutEnable();
                u_int32_t getThresholdDAC();
                u_int32_t getPadding();
                u_int32_t getOperationCode();

	protected:

	private:
};


#endif // MRFDATA_TPX4PIXEL_H
