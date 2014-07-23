/*============================================================*/
/* mrfdataadv3dmatrix.h                                       */
/* MVD Readout Framework Data Storage                         */
/* Provides generic 3D TConfItem map and accessors.           */
/*                                                     S.Esch */
/*============================================================*/

#include "mrfdataadv3dmatrix.h"

TMrfDataAdv3DMatrix::TMrfDataAdv3DMatrix(const u_int32_t& blocklength) : TMrfDataAdvBase(blocklength)
{
}

TMrfDataAdv3DMatrix::~TMrfDataAdv3DMatrix()
{
}

void TMrfDataAdv3DMatrix::assemble()
{

}

void TMrfDataAdv3DMatrix::disassemble()
{

}

int TMrfDataAdv3DMatrix::getItemCount(const int column, const int row) const
{
    return _localdata.at(column).at(row).size();
}

int TMrfDataAdv3DMatrix::getRowCount(const int column) const
{
        return _localdata.at(column).size();
}

int TMrfDataAdv3DMatrix::getColumnCount() const
{
        return _localdata.size();
}

const u_int32_t& TMrfDataAdv3DMatrix::getLocalItemValue(const int column, const int row, const std::string& item) const
{
    return _localdata.at(column).at(row).find(item)->second.value;
}

void TMrfDataAdv3DMatrix::setLocalItemValue(const int column, const int row, const std::string& item, const u_int32_t& value)
{
    _localdata.at(column).at(row).find(item)->second.value = value;
}

TMrfDataAdv1D::itemIterator TMrfDataAdv3DMatrix::getItemIteratorEnd(const int column,const int row)
{
    //return _localdata.find(type)->second.begin();
    return _localdata.at(column).at(row).end();
}

TMrfDataAdv1D::itemIterator TMrfDataAdv3DMatrix::getItemIteratorBegin(const int column,const int row)
{
    return _localdata.at(column).at(row).begin();
}

TMrfDataAdv1D::constItemIterator TMrfDataAdv3DMatrix::getConstItemIteratorBegin(const int column,const int row) const
{
    return _localdata.at(column).at(row).begin();
}

TMrfDataAdv1D::constItemIterator TMrfDataAdv3DMatrix::getConstItemIteratorEnd(const int column,const int row) const
{
    return _localdata.at(column).at(row).end();
}
