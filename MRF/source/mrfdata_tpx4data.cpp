/*============================================================*/
/* mrfdata_tpx4pixel.cpp                                      */
/* MVD Readout Framework Data Storage                         */
/* Provides Access to ToPiX 4 Data                            */
/*                                                 S. U. Esch */
/*============================================================*/

#include "mrfdata_tpx4data.h"
#include "mrf_confitem.h"
#include "mrfdataadv1d.h"
#include <iostream>

TMrfData_Tpx4Data::TMrfData_Tpx4Data(const u_int32_t& blocklength, const u_int32_t& defaultindex, const u_int32_t& defaultstreamoffset, const u_int32_t& defaultvalueoffset, const bool& defaultreverse, const bool& defaultstreamreverse)
 : TMrfDataAdvBase(blocklength, defaultindex, defaultstreamoffset, defaultvalueoffset, defaultreverse, defaultstreamreverse),
     TMrfDataAdv1D(blocklength, defaultindex, defaultstreamoffset, defaultvalueoffset, defaultreverse, defaultstreamreverse)
{
         initMaps();
}

void TMrfData_Tpx4Data::initMaps()
{
	_localdata.clear();
	_localdata["pixeladdress"]  = TConfItem(0, 0,14); // address of the pixel
	_localdata["chipaddress"]   = TConfItem(0,14,12); // address of the chip
	_localdata["leadingedge"]   = TConfItem(0,26,12); // leading edge timestamp
	_localdata["trailingedge"]  = TConfItem(0,38,12); // trailing edge timestamp
	_localdata["framecounter"]  = TConfItem(0,50, 8); // framecounter

	_datastreamlength = 0;
	std::map<std::string, TConfItem>::const_iterator iter;
	for (iter = getItemIteratorBegin(); iter != getItemIteratorEnd(); ++iter) {
		_datastreamlength += iter->second.length;
	}
	if (getNumBits() < _datastreamlength) {
		setNumBits(_datastreamlength);
	}
}

u_int32_t TMrfData_Tpx4Data::getPixelAddress()
{
    return _localdata.find("pixeladdress")->second.value;
}

u_int32_t TMrfData_Tpx4Data::getLeadingEdge()
{
    return _localdata.find("leadingedge")->second.value;
}

u_int32_t TMrfData_Tpx4Data::getTrailingEdge()
{
    return _localdata.find("trailingedge")->second.value;
}

u_int32_t TMrfData_Tpx4Data::getFrameCounter()
{
     return _localdata.find("framecounter")->second.value;
}

u_int32_t TMrfData_Tpx4Data::getChipAddress()
{
     return _localdata.find("chipaddress")->second.value;
}

void TMrfData_Tpx4Data::convert_line_to_matrix(int col, int row, int &matrixcol, int&matrixrow)
{
    if(col==0)
    {
        matrixrow=18;
        matrixcol=31-row;
    }

}

void TMrfData_Tpx4Data::convert_matrix_to_line(int matrixcol,int matrixrow,int &col, int &row)
{
    if(matrixrow == 0)
    {
        col=6;
        row=31-matrixcol;
    }
    else if(matrixrow == 1)
    {
        col=7;
        row=31-matrixcol;
    }
    else if(matrixrow == 2)
    {
        col=4;
        row=31-matrixcol;
    }
    else if(matrixrow == 3)
    {
        col=5;
        row=31-matrixcol;
    }
    else if(matrixrow == 4)
    {
        col=5;
        row=matrixcol+32;
    }
    else if(matrixrow == 5)
    {
        col=4;
        row= matrixcol+32;
    }
    else if(matrixrow == 6)
    {
        col=4;
        row=(31-matrixcol)+64;
    }
    else if(matrixrow == 7)
    {
        col=5;
        row=(31-matrixcol)+64;
    }
    else if(matrixrow == 8)
    {
        col=5;
        row=matrixcol+96;
    }
    else if(matrixrow == 9)
    {
        col=4;
        row=matrixcol+96;
    }
    else if(matrixrow == 10)
    {
        col= 2;
        row= 31-matrixcol;
    }
    else if(matrixrow == 11)
    {
        col= 3;
        row= 31-matrixcol;
    }
    else if(matrixrow == 12)
    {
        col= 3;
        row= matrixcol+32;
    }
    else if(matrixrow == 13)
    {
        col=2;
        row=matrixcol+32;
    }
    else if(matrixrow == 14)
    {
        col=2;
        row= (31-matrixcol)+64;
    }
    else if(matrixrow == 15)
    {
        col=3;
        row= (31-matrixcol)+64;
    }
    else if(matrixrow == 16)
    {
        col= 3;
        row= matrixcol+96;
    }
    else if(matrixrow == 17)
    {
        col=2;
        row= matrixcol+96;
    }
    else if(matrixrow == 18)
    {
        col=0;
        row= 31-matrixcol;
    }
    else if(matrixrow == 19)
    {
        col=1;
        row=31-matrixcol;
    }
}
