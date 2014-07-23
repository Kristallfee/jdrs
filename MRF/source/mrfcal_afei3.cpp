/*============================================================*/
/* mrfcal_afei3.cpp                                           */
/* MVD Readout Framework Chip Access Layer                    */
/* Chip Access Layer for Atlas Frontend I3                    */
/*                                               M.C. Mertens */
/*============================================================*/


#include "mrfcal_afei3.h"
#include <unistd.h>

static const unsigned long idletimer = 50;

TMrfCal_AFEI3::TMrfCal_AFEI3()
: TMrfCal(), TMrfTal_RB()
{
}

void TMrfCal_AFEI3::writeToChip(const TMrfData& data) const
{
	while (isBusy(rb_value::startinput)) {
		usleep(idletimer);
	}
	writeRemoteData(data);
}

void TMrfCal_AFEI3::readFromChip(TMrfData& data)
{
	readRemoteData(data);
}

void TMrfCal_AFEI3::configureGlobReg(const TMrfData_AFEI3& data) const
{
	if (deviceIsOpen()) {
		TMrfData_AFEI3 tmp;
		std::map<const std::string, TConfItem>::const_iterator iter;
		tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
		tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
		//tmp.setCommandRegValue("Address", data.getDefaultAddress());
		//tmp.setCommandRegValue("Broadcast", data.getDefaultBroadcast());
		tmp.setCommandRegValue("ClockGlobal", 1);
		tmp.assembleCommandReg();
		for (iter = data.getGlobRegIteratorBegin(); iter != data.getGlobRegIteratorEnd(); ++iter) {
			tmp.setGlobRegValue(iter->first, iter->second.value);
		}
		tmp.assembleGlobReg();
		//usleep(200000);
		//while (isBusy(rb_value::startinput)) {
		//	usleep(idletimer);
		//}
		writeToChip(tmp);
		tmp.clearDataStream();
		tmp.clearCommandReg();
		tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
		tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
		//tmp.setCommandRegValue("Address", data.getDefaultAddress());
		//tmp.setCommandRegValue("Broadcast", data.getDefaultBroadcast());
		tmp.setCommandRegValue("WriteGlobal", 3);
		tmp.assembleCommandReg();
		//usleep(200000);
		//while (isBusy(rb_value::startinput)) {
		//	usleep(idletimer);
		//}
		writeToChip(tmp);
		tmp.clearDataStream();
		tmp.clearCommandReg();
		tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
		tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
		tmp.assembleCommandReg();
		//usleep(200000);
		//while (isBusy(rb_value::startinput)) {
		//	usleep(idletimer);
		//}
		writeToChip(tmp);
	} else {
		errcode |= mrf_error::device_not_open;
	}
}

void TMrfCal_AFEI3::configurePixReg(const TMrfData_AFEI3& data) const
{
	if (deviceIsOpen()) {
		TMrfData_AFEI3 tmp;
		std::map<const std::string, TConfItem>::const_iterator iter;
		u_int32_t i, j;
		u_int32_t activecolumns = data.getActivePixCols();
		for (i = 0; i < mrf_afei3_reglength::pixcols; ++i) {
			for (j = 0; j < mrf_afei3_reglength::pixrows; ++j) {
				for (iter = data.getPixRegIteratorBegin(i, j); iter != data.getPixRegIteratorEnd(i, j); ++iter) {
					tmp.setPixRegValue(iter->first, i, j, iter->second.value);
				}
			}
		}
		for (iter = data.getPixRegIteratorBegin(0, 0); iter != data.getPixRegIteratorEnd(0, 0); ++iter) {
			//tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
			//tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
			tmp.clearDataStream();
			tmp.clearCommandReg();
			tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
			tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
			//tmp.setCommandRegValue("Address", data.getDefaultAddress());
			//tmp.setCommandRegValue("Broadcast", data.getDefaultBroadcast());
			tmp.setCommandRegValue("ClockPixel", 1);
			tmp.assembleCommandReg();
			tmp.assemblePixReg(activecolumns, iter->first);
			//usleep(200000);
			//while (isBusy(rb_value::startinput)) {
			//	usleep(idletimer);
			//}
			writeToChip(tmp);
			tmp.clearDataStream();
			tmp.clearCommandReg();
			tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
			tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
			//tmp.setCommandRegValue("Address", data.getDefaultAddress());
			//tmp.setCommandRegValue("Broadcast", data.getDefaultBroadcast());
			tmp.setCommandRegValue(iter->first, 1);
			tmp.assembleCommandReg();
			//usleep(200000);
			//while (isBusy(rb_value::startinput)) {
			//	usleep(idletimer);
			//}
			writeToChip(tmp);
			tmp.clearDataStream();
			tmp.clearCommandReg();
			tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
			tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
			tmp.assembleCommandReg();
			//usleep(200000);
			//while (isBusy(rb_value::startinput)) {
			//	usleep(idletimer);
			//}
			writeToChip(tmp);
		}
	} else {
		errcode |= mrf_error::device_not_open;
	}
}

void TMrfCal_AFEI3::shiftIntoPixReg(const TMrfData_AFEI3& data) const
{
	TMrfData_AFEI3 tmp;
	tmp.importBinString(data.exportBinString());
	//tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
	tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
	tmp.setCommandRegValue("ClockPixel", 1);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//clear command
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
	tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
	tmp.assembleCommandReg();
	writeToChip(tmp);
}

void TMrfCal_AFEI3::latchPixReg(const mrf::registertype address, const mrf::registertype broadcast, const std::string& item) const
{
	TMrfData_AFEI3 tmp;
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.setCommandRegValue(item, 1);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//clear command
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.assembleCommandReg();
	writeToChip(tmp);
}

void TMrfCal_AFEI3::readPixReg(const mrf::registertype address, const mrf::registertype broadcast, const std::string& item) const
{
	TMrfData_AFEI3 tmp;
	//readbit an
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.setCommandRegValue("ReadPixel", 1);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//zusätzlich latchauswahl
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.setCommandRegValue("ReadPixel", 1);
	tmp.setCommandRegValue(item, 1);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//zusätzlich clock und 2 takte
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.setCommandRegValue("ReadPixel", 1);
	tmp.setCommandRegValue(item, 1);
	tmp.setCommandRegValue("ClockPixel", 1);
	tmp.assembleCommandReg();
	tmp.appendBit(false);
	tmp.appendBit(false);
	writeToChip(tmp);
		//clock wieder aus, nur noch latchauswahl und read an
		//tmp.clearDataStream();
		//tmp.clearCommandReg();
		//tmp.setCommandRegValue("Address", address);
		//tmp.setCommandRegValue("Broadcast", broadcast);
		//tmp.setCommandRegValue("ReadPixel", 1);
		//tmp.setCommandRegValue(item, 1);
		//tmp.assembleCommandReg();
		//writeToChip(tmp);
	//clock und latchauswahl wieder aus, nur noch read an
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.setCommandRegValue("ReadPixel", 1);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//clear command
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.assembleCommandReg();
	writeToChip(tmp);
}

void TMrfCal_AFEI3::insertPixRegData(const TMrfData_AFEI3& data, const std::string& item) const
{
	shiftIntoPixReg(data);
	latchPixReg(data.getCommandRegValue("Address"), data.getCommandRegValue("Broadcast"), item);
}

void TMrfCal_AFEI3::shiftIntoGlobReg(const TMrfData_AFEI3& data) const
{
	TMrfData_AFEI3 tmp;
	tmp.importBinString(data.exportBinString());
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
	tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
	tmp.setCommandRegValue("ClockGlobal", 1);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//clear command
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", data.getCommandRegValue("Address"));
	tmp.setCommandRegValue("Broadcast", data.getCommandRegValue("Broadcast"));
	tmp.assembleCommandReg();
	writeToChip(tmp);
}

void TMrfCal_AFEI3::latchGlobReg(const mrf::registertype address, const mrf::registertype broadcast) const
{
	TMrfData_AFEI3 tmp;
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.setCommandRegValue("WriteGlobal", 3);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//clear command
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.assembleCommandReg();
	writeToChip(tmp);
}

void TMrfCal_AFEI3::readGlobReg(const mrf::registertype address, const mrf::registertype broadcast) const
{
	TMrfData_AFEI3 tmp;
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.setCommandRegValue("ReadGlobal", 1);
	tmp.assembleCommandReg();
	writeToChip(tmp);
	//clear command
	tmp.clearDataStream();
	tmp.clearCommandReg();
	tmp.setCommandRegValue("Address", address);
	tmp.setCommandRegValue("Broadcast", broadcast);
	tmp.assembleCommandReg();
	writeToChip(tmp);
}

void TMrfCal_AFEI3::configureFE(const TMrfData_AFEI3& data) const
{
	configureGlobReg(data);
	configurePixReg(data);
}



