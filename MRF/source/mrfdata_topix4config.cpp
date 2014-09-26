#include "mrfdata_topix4config.h"

TMrfData_Topix4Config::TMrfData_Topix4Config(const u_int32_t& blocklength, const u_int32_t& defaultindex, const u_int32_t& defaultstreamoffset, const u_int32_t& defaultvalueoffset, const bool& defaultreverse, const bool& defaultstreamreverse)
: TMrfDataAdv1D(blocklength, defaultindex, defaultstreamoffset, defaultvalueoffset, defaultreverse, defaultstreamreverse)
{
        initMaps();
}

void TMrfData_Topix4Config::initMaps()
{
        _localdata.clear();

        // CCR0

        _localdata["LeadingEdgeOnly"]       = TConfItem(0, 0, 1);
        _localdata["CounterMode"]           = TConfItem(0, 1, 1);
        _localdata["CounterEnable"]         = TConfItem(0, 2, 1);
        _localdata["ReadoutCycleHalfSpeed"] = TConfItem(0, 3, 1);
        _localdata["FrameCounterReset"]     = TConfItem(0, 4, 1);
        _localdata["IdlePacketsEnable"]     = TConfItem(0, 5, 1);
        _localdata["OutputMode"]            = TConfItem(0, 6, 1);
        _localdata["CounterHalfFrequency"]  = TConfItem(0, 7, 1);
        _localdata["SeuFifoSelect"]         = TConfItem(0, 8, 1);
        _localdata["FreezeStop"]            = TConfItem(0, 9, 3);
        _localdata["CommandCCR0"]           = TConfItem(0,12, 6);
        _localdata["PaddingCCR0"]           = TConfItem(0,18,14);


        // CCR1

        _localdata["Leak_N"]                = TConfItem(0,32, 1);
        _localdata["Leak_P"]                = TConfItem(0,33, 1);
        _localdata["SelectPol"]             = TConfItem(0,34, 1);
        _localdata["IleakCtrl1"]            = TConfItem(0,35, 1);
        _localdata["IleakCtrl2"]            = TConfItem(0,36, 1);
        _localdata["AnalogTimeoutEnable"]   = TConfItem(0,37, 1);
        _localdata["SLVSCurrentControl"]    = TConfItem(0,38, 4);
        _localdata["PreEmphasisTimeStamp"]  = TConfItem(0,42, 1);
        _localdata["PreEmphasisCommands"]   = TConfItem(0,43, 1);
        _localdata["CommandCCR1"]           = TConfItem(0,44, 6);
        _localdata["PaddingCCR1"]           = TConfItem(0,50,14);


        //CCR2

        _localdata["CounterStopValue"]      = TConfItem(0,64,12);
        _localdata["CommandCCR2"]           = TConfItem(0,76, 6);
        _localdata["PaddingCCR2"]           = TConfItem(0,82,14);

	_datastreamlength = 0;
	std::map<std::string, TConfItem>::const_iterator iter;
	for (iter = getItemIteratorBegin(); iter != getItemIteratorEnd(); ++iter) {
		_datastreamlength += iter->second.length;
	}
}

void TMrfData_Topix4Config::assemble()
{
    if (getNumBits() < _datastreamlength) {
            setNumBits(_datastreamlength);
    }

    setStreamConfItemValue(_localdata.find("LeadingEdgeOnly")->second);
    setStreamConfItemValue(_localdata.find("CounterMode")->second);
    setStreamConfItemValue(_localdata.find("CounterEnable")->second);
    setStreamConfItemValue(_localdata.find("ReadoutCycleHalfSpeed")->second);
    setStreamConfItemValue(_localdata.find("FrameCounterReset")->second);
    setStreamConfItemValue(_localdata.find("IdlePacketsEnable")->second);
    setStreamConfItemValue(_localdata.find("OutputMode")->second);
    setStreamConfItemValue(_localdata.find("CounterHalfFrequency")->second);
    setStreamConfItemValue(_localdata.find("SeuFifoSelect")->second);
    setStreamConfItemValue(_localdata.find("FreezeStop")->second);
    setStreamConfItemValue(_localdata.find("CommandCCR0")->second);
    setStreamConfItemValue(_localdata.find("PaddingCCR0")->second);


    setStreamConfItemValue(_localdata.find("Leak_N")->second);
    setStreamConfItemValue(_localdata.find("Leak_P")->second);
    setStreamConfItemValue(_localdata.find("SelectPol")->second);
    setStreamConfItemValue(_localdata.find("IleakCtrl1")->second);
    setStreamConfItemValue(_localdata.find("IleakCtrl2")->second);
    setStreamConfItemValue(_localdata.find("AnalogTimeoutEnable")->second);
    setStreamConfItemValue(_localdata.find("SLVSCurrentControl")->second);
    setStreamConfItemValue(_localdata.find("PreEmphasisTimeStamp")->second);
    setStreamConfItemValue(_localdata.find("PreEmphasisCommands")->second);
    setStreamConfItemValue(_localdata.find("CommandCCR1")->second);
    setStreamConfItemValue(_localdata.find("PaddingCCR1")->second);

    setStreamConfItemValue(_localdata.find("CounterStopValue")->second);
    setStreamConfItemValue(_localdata.find("CommandCCR2")->second);
    setStreamConfItemValue(_localdata.find("PaddingCCR2")->second);
    setStreamConfItemValue(_localdata.find("CommandCCR2")->second);
    setStreamConfItemValue(_localdata.find("PaddingCCR2")->second);
}


void TMrfData_Topix4Config::setCommand(std::string ccr, u_int32_t  command)
{
    _localdata.find(ccr)->second.value = command;
}

uint32_t TMrfData_Topix4Config::getCounterMode()
{
    return _localdata.find("CounterMode")->second.value;
}
