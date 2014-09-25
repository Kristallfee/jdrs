#include "mrfdata_tpx4pixel.h"
#include "mrf_confitem.h"
#include "mrfdataadv1d.h"

/*============================================================*/
/* mrfdata_tpx4pixel.h                                        */
/* MVD Readout Framework Data Storage                         */
/* Provides Access to ToPix 4 Pixel Configuration             */
/*                                                    S. Esch */
/*============================================================*/

TMrfData_Tpx4Pixel::TMrfData_Tpx4Pixel(const u_int32_t& blocklength, const u_int32_t& defaultindex, const u_int32_t& defaultstreamoffset, const u_int32_t& defaultvalueoffset, const bool& defaultreverse, const bool& defaultstreamreverse)
: TMrfDataAdv1D(blocklength, defaultindex, defaultstreamoffset, defaultvalueoffset, defaultreverse, defaultstreamreverse)
{
        initMaps();
}

void TMrfData_Tpx4Pixel::initMaps()
{
    _localdata.clear();
    _localdata["Mask"]                      = TConfItem(0, 0, 1);
    _localdata["TestPulsEnable"]            = TConfItem(0, 1, 1);
    _localdata["ComparatorTestOutEnable"]   = TConfItem(0, 2, 1);
    _localdata["PDAC"]                      = TConfItem(0, 3, 4);
    _localdata["NotUsed"]                   = TConfItem(0, 7, 5);
    _localdata["OperationCode"]             = TConfItem(0,12, 6);
    _localdata["Padding"]                   = TConfItem(0,18,14);

	_datastreamlength = 0;
	std::map<std::string, TConfItem>::const_iterator iter;
	for (iter = getItemIteratorBegin(); iter != getItemIteratorEnd(); ++iter) {
		_datastreamlength += iter->second.length;
		if (getNumBits() < _datastreamlength) {
			setNumBits(_datastreamlength);
	       }

	}
}

void TMrfData_Tpx4Pixel::setCommand(u_int32_t command)
{
        _localdata.find("OperationCode")->second.value = command;
}

u_int32_t TMrfData_Tpx4Pixel::getAddress()
{
   return  _localdata.find("PixelAddress")->second.value;
}

u_int32_t TMrfData_Tpx4Pixel::getPixelMask()
{
    return _localdata.find("Mask")->second.value;
}

u_int32_t TMrfData_Tpx4Pixel::getComparatorTestOutEnable()
{
    return _localdata.find("ComparatorTestOutEnable")->second.value;
}

u_int32_t TMrfData_Tpx4Pixel::getThresholdDAC()
{
    return _localdata.find("PDAC")->second.value;
}

u_int32_t TMrfData_Tpx4Pixel::getTestPulsEnable()
{
    return _localdata.find("TestPulsEnable")->second.value;
}

u_int32_t TMrfData_Tpx4Pixel::getPadding()
{
    return _localdata.find("Padding")->second.value;
}

u_int32_t TMrfData_Tpx4Pixel::getOperationCode()
{
    return _localdata.find("OperationCode")->second.value;
}
