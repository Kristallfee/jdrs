#include "mrfdata_tpx4pixelmatrix.h"
#include "mrf_confitem.h"
#include "mrfdataadv1d.h"
#include "mrfdataadv3dmatrix.h"
#include <iostream>


TMrfData_Tpx4PixelMatrix::TMrfData_Tpx4PixelMatrix(const u_int32_t& blocklength, const u_int32_t& , const u_int32_t& , const u_int32_t& , const bool& , const bool& )
    : TMrfDataAdv3DMatrix(blocklength),_colcount(topix::colcount), _matrixcolount(topix::matrixcolumncount),_matrixrowcout(topix::matrixrowcount)
{
        initMaps();
}

void TMrfData_Tpx4PixelMatrix::initMaps()
{
    _pixelregister.clear();
    _pixelregister["Mask"]                      = TConfItem(0, 0, 1);
    _pixelregister["TestPulsEnable"]            = TConfItem(0, 1, 1);
    _pixelregister["ComparatorTestOutEnable"]   = TConfItem(0, 2, 1);
    _pixelregister["PDAC"]                      = TConfItem(0, 3, 4);
    _pixelregister["NotUsed"]                   = TConfItem(0, 7, 5);
    _pixelregister["OperationCode"]             = TConfItem(0,12, 6);
    _pixelregister["Padding"]                   = TConfItem(0,18,14);

    _rowcount.push_back(topix::shortrowcount);
    _rowcount.push_back(topix::shortrowcount);
    _rowcount.push_back(topix::longrowcount);
    _rowcount.push_back(topix::longrowcount);
    _rowcount.push_back(topix::longrowcount);
    _rowcount.push_back(topix::longrowcount);
    _rowcount.push_back(topix::shortrowcount);
    _rowcount.push_back(topix::shortrowcount);

    _datastreamlength = 0;
    std::map<std::string, TConfItem>::const_iterator iter;
    for (iter = _pixelregister.begin(); iter != _pixelregister.end(); ++iter) {
        _datastreamlength += iter->second.length;
    }

    _localdata.clear();
    _localdata.resize(_colcount);
    for (unsigned int i = 0; i < _colcount; ++i) {
        _localdata.at(i).resize(getNumRows(i), _pixelregister);
    }
}

void TMrfData_Tpx4PixelMatrix::setPixMask(const unsigned int& col, const unsigned int& row,const int& mask, bool matrix=false)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    _localdata.at(col_intern).at(row_intern).find("Mask")->second.value = mask;
}

void TMrfData_Tpx4PixelMatrix::setPixComparatorEnable(const unsigned int &col, const unsigned int &row, const int &enable, bool matrix=false)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    _localdata.at(col_intern).at(row_intern).find("ComparatorTestOutEnable")->second.value = enable;


}

void TMrfData_Tpx4PixelMatrix::setPixPDAC(const unsigned int& col, const unsigned int& row,const unsigned int& pdac, bool matrix=false)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    _localdata.at(col_intern).at(row_intern).find("PDAC")->second.value = pdac;
}

void TMrfData_Tpx4PixelMatrix::setPixPDACSign(const unsigned int& col, const unsigned int& row,const unsigned int& pdacsign, bool matrix=false)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    _localdata.at(col_intern).at(row_intern).find("PDACSign")->second.value = pdacsign;
}

void TMrfData_Tpx4PixelMatrix::setPixTextPulsEnable(const unsigned int& col, const unsigned int& row, const int& enable, bool matrix=false)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    _localdata.at(col_intern).at(row_intern).find("TestPulsEnable")->second.value = enable;

}

void TMrfData_Tpx4PixelMatrix::setPixCommand(const unsigned int &col, const unsigned int &row, u_int32_t command, bool matrix)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    _localdata.at(col_intern).at(row_intern).find("OperationCode")->second.value = command;
}

void TMrfData_Tpx4PixelMatrix::assemble(int col, int row)
{
    if (getNumBits() < _datastreamlength) {
        setNumBits(_datastreamlength);
    }
    setStreamConfItemValue(_localdata.at(col).at(row).find("Mask")->second);
    setStreamConfItemValue(_localdata.at(col).at(row).find("TestPulsEnable")->second);
    setStreamConfItemValue(_localdata.at(col).at(row).find("ComparatorTestOutEnable")->second);
    setStreamConfItemValue(_localdata.at(col).at(row).find("PDAC")->second);
    setStreamConfItemValue(_localdata.at(col).at(row).find("NotUsed")->second);
    setStreamConfItemValue(_localdata.at(col).at(row).find("OperationCode")->second);
    setStreamConfItemValue(_localdata.at(col).at(row).find("Padding")->second);
}

TMrfDataAdv1D::itemMap& TMrfData_Tpx4PixelMatrix::getPixel(const unsigned int& col, const unsigned int& row)
{
    return _localdata.at(col).at(row);
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getPixMask(const unsigned int& col, const unsigned int& row, bool matrix)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    return _localdata.at(col_intern).at(row_intern).find("Mask")->second.value;
}

void TMrfData_Tpx4PixelMatrix::convert_matrix_to_line(int matrixcol,int matrixrow,int &col, int &row)
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

const unsigned int& TMrfData_Tpx4PixelMatrix::getPixComparatorEnable(const unsigned int& col, const unsigned int& row, bool matrix)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    return _localdata.at(col_intern).at(row_intern).find("ComparatorTestOutEnable")->second.value;
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getPixPDAC(const unsigned int& col, const unsigned int& row, bool matrix)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    return _localdata.at(col_intern).at(row_intern).find("PDAC")->second.value;
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getPixPDACSign(const unsigned int& col, const unsigned int& row, bool matrix)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    return _localdata.at(col_intern).at(row_intern).find("PDACSign")->second.value;
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getPixTestPulsEnable(const unsigned int& col, const unsigned int& row, bool matrix)
{
    int col_intern=0;
    int row_intern=0;
    if(matrix==true)
    {
        convert_matrix_to_line(col,row,col_intern,row_intern);
    }
    else
    {
        col_intern=col;
        row_intern=row;
    }
    return _localdata.at(col_intern).at(row_intern).find("TestPulsEnable")->second.value;
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getMatrixCols() const
{
    return _matrixcolount;
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getMatrixRows() const
{
    return _matrixrowcout;
}

void TMrfData_Tpx4PixelMatrix::setPixConf(const unsigned int& col, const unsigned int& row, const std::string& item, const u_int32_t& value, bool )
{
    _localdata.at(col).at(row).find(item)->second.value = value;
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getNumCols() const
{
    return _colcount;
}

const unsigned int& TMrfData_Tpx4PixelMatrix::getNumRows(const unsigned int& col) const
{
    return _rowcount.at(col);
}
