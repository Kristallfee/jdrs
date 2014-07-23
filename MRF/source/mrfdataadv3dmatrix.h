/*============================================================*/
/* mrfdataadv3dmatrix.h                                       */
/* MVD Readout Framework Data Storage                         */
/* Provides generic 3D TConfItem map and accessors.           */
/*                                                     S.Esch */
/*============================================================*/

#ifndef MRFDATAADV3DMATRIX_H
#define MRFDATAADV3DMATRIX_H

#include "mrfdataadvbase.h"
#include "mrfdataadv1d.h"
//#include <map>
//#include <string>
#include "mrf_confitem.h"

class TMrfDataAdv3DMatrix : virtual public TMrfDataAdvBase
{
    typedef std::map<std::string, TConfItem>::const_iterator constItemIterator;
    typedef std::map<std::string, TConfItem>::iterator itemIterator;

    typedef std::vector<std::map<std::string, TConfItem> >::const_iterator constRowIterator;
    typedef std::vector<std::map<std::string, TConfItem> >::iterator RowIterator;

    typedef std::vector<std::vector<std::map<std::string, TConfItem> > >::const_iterator constColumnIterator;
    typedef std::vector<std::vector<std::map<std::string, TConfItem> > >::iterator columnIterator;

public:

    TMrfDataAdv3DMatrix(const u_int32_t& blocklength = bitsinablock);
    virtual ~TMrfDataAdv3DMatrix();
    virtual void assemble();
    virtual void disassemble();

    virtual int getColumnCount() const;
    virtual int getRowCount(const int column) const;
    virtual int getItemCount(const int column, const int row) const;
    virtual itemIterator getItemIteratorBegin(const int column, const int row);
    virtual itemIterator getItemIteratorEnd(const int column, const int row);
    virtual constItemIterator getConstItemIteratorBegin(const int column, const int row) const;
    virtual constItemIterator getConstItemIteratorEnd(const int column, const int row) const;
    const u_int32_t& getLocalItemValue(const int column, const int row, const std::string& item) const;
    void setLocalItemValue(const int column, const int row, const std::string& item, const u_int32_t& value);


protected:


//    virtual itemIterator getItemIteratorBegin(const std::map<std::string, std::map<std::string, TConfItem> >::iterator& type);
//    virtual itemIterator getItemIteratorEnd(const std::map<std::string, std::map<std::string, TConfItem> >::iterator& type);

   std::vector<std::vector<std::map<std::string, TConfItem> > > _localdata;

};

#endif // MRFDATAADV3DMATRIX_H
