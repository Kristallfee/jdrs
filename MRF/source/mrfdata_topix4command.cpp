#include "mrfdata_topix4command.h"

TMrfData_ToPix4Command::TMrfData_ToPix4Command(const u_int32_t& blocklength, const u_int32_t& defaultindex, const u_int32_t& defaultstreamoffset, const u_int32_t& defaultvalueoffset, const bool& defaultreverse, const bool& defaultstreamreverse)
: TMrfDataAdv1D(blocklength, defaultindex, defaultstreamoffset, defaultvalueoffset, defaultreverse, defaultstreamreverse)
{
    initMaps();
}

void TMrfData_ToPix4Command::initMaps()
{
    _localdata.clear();
    _localdata["Data"]                      = TConfItem(0, 0,12);
    _localdata["OperationCode"]             = TConfItem(0,12, 6);
    _localdata["Padding"]                   = TConfItem(0,18,14);

    _datastreamlength = 0;
    std::map<std::string, TConfItem>::const_iterator iter;
    for (iter = getItemIteratorBegin(); iter != getItemIteratorEnd(); ++iter) {
        _datastreamlength += iter->second.length;
    }

}

void TMrfData_ToPix4Command::assemble()
{
    if (getNumBits() < _datastreamlength) {
        setNumBits(_datastreamlength);
    }
    setStreamConfItemValue(_localdata.find("Data")->second);
    setStreamConfItemValue(_localdata.find("OperationCode")->second);
    setStreamConfItemValue(_localdata.find("Padding")->second);
}

void TMrfData_ToPix4Command::setOperationCode(u_int32_t operationcode)
{
    _localdata.find("OperationCode")->second.value = operationcode;
}

void TMrfData_ToPix4Command::setData(u_int32_t data)
{
    _localdata.find("Data")->second.value = data;
}
