/*============================================================*/
/* mrfdata_tpx4pixelmatrix.h                                  */
/* MVD Readout Framework Data Storage                         */
/* Provides Access to ToPix 4 Pixel Configuration             */
/*                                                    S. Esch */
/*============================================================*/


#ifndef MRFDATA_TPX4PIXELMATRIX_H
#define MRFDATA_TPX4PIXELMATRIX_H

#include "mrfdataadv1d.h"
#include "mrfdataadv3dmatrix.h"

namespace topix {
static const unsigned int colcount = 8;
static const unsigned int longrowcount = 128;
static const unsigned int shortrowcount = 32;
static const unsigned int matrixcolumncount = 32;
static const unsigned int matrixrowcount = 20;
}

class TMrfData_Tpx4PixelMatrix : virtual public TMrfDataAdv3DMatrix
{
public:
    TMrfData_Tpx4PixelMatrix(const u_int32_t& blocklength = bitsinablock, const u_int32_t& defaultindex = 0, const u_int32_t& defaultstreamoffset = 0, const u_int32_t& defaultvalueoffset = 0, const bool& defaultreverse = false, const bool& defaultstreamreverse = false);

    void initMaps();
    void assemble(int col, int row);

    virtual void setPixConf(const unsigned int& col, const unsigned int& row, const std::string& item, const u_int32_t& value, bool matrix=false);
    virtual void setPixMask(const unsigned int& col, const unsigned int& row,const int &mask, bool matrix);
    virtual void setPixComparatorEnable(const unsigned int& col, const unsigned int& row,const int &enable, bool matrix);
    virtual void setPixPDAC(const unsigned int& col, const unsigned int& row,const unsigned int& pdac, bool matrix);
    virtual void setPixPDACSign(const unsigned int& col, const unsigned int& row,const unsigned int& pdacsign, bool matrix);
    virtual void setPixTextPulsEnable(const unsigned int& col, const unsigned int& row, const int &enable, bool matrix);
    virtual void setPixCommand(const unsigned int& col, const unsigned int & row, u_int32_t command, bool matrix=false);

    virtual const unsigned int& getPixMask(const unsigned int& col, const unsigned int& row, bool matrix=false);
    virtual const unsigned int& getPixComparatorEnable(const unsigned int& col, const unsigned int& row, bool matrix=false);
    virtual const unsigned int& getPixPDAC(const unsigned int& col, const unsigned int& row, bool matrix=false);
    virtual const unsigned int& getPixPDACSign(const unsigned int& col, const unsigned int& row, bool matrix=false);
    virtual const unsigned int& getPixTestPulsEnable(const unsigned int& col, const unsigned int& row, bool matrix=false);

    virtual const unsigned int& getNumCols() const;
    virtual const unsigned int& getNumRows(const unsigned int& col) const;
    virtual const unsigned int& getMatrixCols() const;
    virtual const unsigned int& getMatrixRows() const;

    virtual TMrfDataAdv1D::itemMap& getPixel(const unsigned int& col, const unsigned int& row);

private:
    unsigned int _colcount;
    std::map<std::string, TConfItem > _pixelregister;
    std::vector<unsigned int> _rowcount;
    unsigned int _matrixcolount;
    unsigned int _matrixrowcout;

    void convert_matrix_to_line(int, int, int &, int &);
};

#endif // MRFDATA_TPX4PIXELMATRIX_H
