/*============================================================*/
/* mrfdata.cpp                                                */
/* MVD Readout Framework Data Storage                         */
/*                                               M.C. Mertens */
/*============================================================*/


#include "mrfdata_8b.h"
#include "mrftools.h"
#include <string>
#include <sstream>

using mrftools::getIntBit;
using mrftools::setIntBit;
using mrftools::shiftBy;

const u_int32_t TMrfData_8b::zeroval;
const u_int32_t TMrfData_8b::bitsinablock;

TMrfData_8b::TMrfData_8b()
: reglengthbits(0), reglengthwords(0), lastreglengthbits(0),  errcode(0) //, bitsinablock(sizeof(mrf::registertype) * CHAR_BIT)
{
}

TMrfData_8b::TMrfData_8b(u_int32_t _reglengthbits, u_int32_t _reglengthwords, u_int32_t _lastreglengthbits, std::vector<u_int8_t> _regdata)
{
    reglengthbits = _reglengthbits;
    reglengthwords = _reglengthwords;
    lastreglengthbits = _lastreglengthbits;
    regdata =_regdata;

}

void TMrfData_8b::setNumBits(const u_int32_t& length)
{
	reglengthbits = length;
	reglengthwords = (length + bitsinablock - 1) / bitsinablock;
	regdata.resize(reglengthwords);
	lastreglengthbits = length % bitsinablock;
	if (lastreglengthbits) {
		regdata.at(reglengthwords-1) &= (~((~0) << lastreglengthbits));
	}
}

const u_int32_t& TMrfData_8b::getNumBits() const
{
	return reglengthbits;
}

void TMrfData_8b::setNumWords(const u_int32_t& length)
{
	reglengthwords = length;
	reglengthbits = length * bitsinablock;
	regdata.resize(reglengthwords);
}

const u_int32_t& TMrfData_8b::getNumWords() const
{
	return reglengthwords;
}

void TMrfData_8b::setBit(const u_int32_t& position, const bool& state)
{
	if ((position < reglengthbits) && (reglengthbits > 0)) {
		/*
		if (state) {
			regdata.at(position / bitsinablock) |= ((mrf::registertype) 1<<(position % bitsinablock));
		} else {
			regdata.at(position / bitsinablock) &= (~((mrf::registertype) 1<<(position % bitsinablock))) ;
		}
		*/
	    setIntBit(position % bitsinablock,(u_int32_t&)regdata.at(position / bitsinablock), state);
		errcode = 0;
	} else {
		errcode |= mrfdata_8b_error::out_of_bounds;
	}
}

bool TMrfData_8b::getBit(const u_int32_t& position) const
{
	if (position < reglengthbits) {
		errcode = 0;
		return bool (regdata.at(position / bitsinablock) & ((u_int8_t) 1<<(position % bitsinablock)));
	} else {
		errcode |= mrfdata_8b_error::out_of_bounds;
		return false;
	}
}

const u_int32_t& TMrfData_8b::appendBit(const bool& state)
{
	setNumBits(reglengthbits + 1);
	setBit(reglengthbits - 1, state);
	return reglengthbits;
}

void TMrfData_8b::setWord(const u_int32_t& position, const u_int8_t &dataword, const bool& truncate_ok)
{
	// Noch aendern, um stattdessen die masked funktion mit konstanter einsmaske zu benutzen
	if (((position < (reglengthwords - 1)) || ((position < reglengthwords) && ((reglengthbits % bitsinablock) == 0))) && (reglengthbits > 0)) {
		regdata.at(position) = dataword;
		errcode = 0;
	} else if (position < reglengthwords) {
		mrf::registertype bitmask = 1;
		for (uint i = 0; i < ((reglengthbits % bitsinablock) - 1); ++i) {
			bitmask |= bitmask << 1;
		}
		regdata.at(position) = (dataword & bitmask);
		if (!(dataword & (~bitmask)) || truncate_ok) {
			//regdata.at(position) = (dataword & bitmask);
			errcode = 0;
		} else {
			errcode |= mrfdata_8b_error::out_of_bounds;
		}
	} else {
		errcode |= mrfdata_8b_error::out_of_bounds;
	}
}

void TMrfData_8b::setWordMasked(const u_int32_t& position, const u_int8_t &dataword, const u_int8_t &mask, const bool& truncate_ok)
{
	if (((position < (reglengthwords - 1)) || ((position < reglengthwords) && ((reglengthbits % bitsinablock) == 0))) && (reglengthbits > 0)) {
		regdata.at(position) = dataword;
		errcode = 0;
	} else if (position < reglengthwords) {
		u_int8_t bitmask = 1;
		for (uint i = 0; i < ((reglengthbits % bitsinablock) - 1); ++i) {
			bitmask |= bitmask << 1;
		}
		//regdata.at(position) = (((dataword & mask) | (regdata.at(position) & (~ mask))) & bitmask);
		regdata.at(position) &= (~ mask);
		regdata.at(position) |= (dataword & mask);
		regdata.at(position) &= bitmask;
		if (!((dataword & mask) & (~bitmask)) || truncate_ok) {
			//regdata.at(position) = (dataword & bitmask);
			errcode = 0;
		} else {
			errcode |= mrfdata_8b_error::out_of_bounds;
		}
	} else {
		errcode |= mrfdata_8b_error::out_of_bounds;
	}
}

const u_int8_t &TMrfData_8b::getWord(const u_int32_t& position) const
{
	if (position < reglengthwords) {
		errcode = 0;
		return regdata.at(position);
	} else {
		errcode |= mrfdata_8b_error::out_of_bounds;
		return zeroval;
	}
}

const u_int8_t &TMrfData_8b::appendWord(const u_int8_t& dataword)
{
	setNumWords(getNumWords() + 1);
	setWord(getNumWords()-1, dataword);
	return getNumWords();
}


void TMrfData_8b::setBitBlock(const u_int32_t& position, const u_int32_t& length, const u_int8_t& value, const u_int32_t& offset, const bool& reverse)
{
	u_int32_t i;
	if (reverse) {
		for (i = 0; i < length; ++i) {
			setBit(position + length - 1 - i, getIntBit(offset + i, value));
		}
	} else {
		for (i = 0; i < length; ++i) {
			setBit(position + i, getIntBit(offset + i, value));
		}
	}
}

const u_int32_t& TMrfData_8b::getBitBlock(const u_int32_t& position, const u_int32_t& length, const u_int32_t& offset, const bool& reverse) const
{
	u_int32_t i;
	_bitblock = 0;
	if (reverse) {
		for (i = 0; i < length; ++i) {
			//setBit(position + length - 1 - i, getIntBit(value, offset + i));
			setIntBit(offset + i, _bitblock, getBit(position + length - 1 - i));
		}
	} else {
		for (i = 0; i < length; ++i) {
			//setBit(position + i, getIntBit(value, offset + i));
			setIntBit(offset + i, _bitblock, getBit(position + i));
		}
	}
	return _bitblock;
}

/*
void TMrfData_8b::copyFragment(const u_int32_t sourcestart, const u_int32_t destposition, const u_int32_t size, const mrf::registertype value)
{
	if (destposition + size < reglengthbits) {
		u_int32_t mask;
		mrf::registertype pattern;
		// Data fits in one block.
		if ((destposition % bitsinablock) + size < bitsinablock) {
			pattern = shiftBy(sourcestart - (destposition % bitsinablock), value);
			mask = 0;
			for (u_int32_t i = (destposition % bitsinablock); i < ((destposition % bitsinablock) + size); ++i) {
				setIntBit(mask, i, true);
			}
			setWordMasked(bitInBlock(destposition), pattern, mask, false);
		} else {
			// Data goes to two adjacent blocks.
			// Left pattern

			//linkes pattern:
			//Nach rechts shiften: destpos % bitsinablock - sourcestart
			//Soviel Nullen links: destpos % bitsinablock

			pattern = shiftBy((destposition % bitsinablock) - sourcestart, value);
			mask = (~ 0);
			for (u_int32_t i = 0; i < (destposition % bitsinablock); ++i) {
				setIntBit(mask, i, false);
			}
			setWordMasked(bitInBlock(destposition), pattern, mask, false);
			// Right Pattern
			pattern = shiftBy(-(bitsinablock + sourcestart - (destposition % bitsinablock)), value);
			mask = 0;
			for (u_int32_t i = 0; i < (size + (destposition % bitsinablock) - bitsinablock); ++i) {
				setIntBit(mask, i, true);
			}
			setWordMasked(bitInBlock(destposition) + 1, pattern, mask, false);
			//linkes pattern:
			//Nach rechts shiften: destpos % bitsinablock - sourcestart
			//Soviel Nullen links: destpos % bitsinablock
			//rechtes pattern:
			//Nach links shiften: bitsinablock - leftshifts
			//					= bitsinablock + sourcestart - destpos % bitsinablock
			//Soviel Einsen links: size - linkebits
			//					= size - (bitsinablock - destpos % bitsinablock)
			//					= size + destpos % bitsinablock - bitsinablock
		}
	} else {
		errcode |= mrfdata_8b_error::out_of_bounds;
	}
}
*/

u_int32_t TMrfData_8b::bitInBlock(const u_int32_t& position) const
{
	return (position / bitsinablock);
}

void TMrfData_8b::clearDataStream()
{
	//setNumBits(0);
	setNumWords(0);
}

bool TMrfData_8b::sameDataStream(const TMrfData_8b& other) const
{
	return (regdata == other.regdata);
}

void TMrfData_8b::importBinString(const std::string& data, const u_int32_t& offset)
{
	u_int32_t i;
	u_int32_t reglength = data.length();
	if (getNumBits() < (offset + reglength)) {
		setNumBits(offset + reglength);
	}
	for (i = 0; i < reglength; ++i) {
		setBit(offset + i, (data.compare(i, 1, "1") == 0));
	}
}

//void TMrfData_8b::importHexString(const std::string data, const u_int32_t offset)
//{
//	//setBitBlock(position + offset);
//}

const std::string& TMrfData_8b::exportBinString() const
{
	u_int8_t i;
	_data.clear();
	for (i = 0; i < getNumBits(); ++i) {
		if (getBit(i)) {
			_data.append("1");
		} else {
			_data.append("0");
		}
	}
	return _data;
}


//const std::string TMrfData_8b::exportHexString() const
//{
//	// throw "Not implemented yet.";
//	return "nix";
//}

void TMrfData_8b::resample(const u_int32_t& offset, const u_int32_t& factor, const bool& reverse, const u_int32_t& cutoff)
{
	std::vector<u_int8_t> tmp = regdata;
	u_int32_t newlength = 0;
	if (reverse) {
		for (u_int32_t i = offset; i < getNumBits(); i += factor) {
			setBit((i - offset) / factor, getIntBit(bitsinablock - 1 - (i % bitsinablock), tmp.at(i / bitsinablock)));
			++newlength;
		}
	} else {
		for (u_int32_t i = offset; i < getNumBits(); i += factor) {
			setBit((i - offset) / factor, getIntBit(i % bitsinablock, tmp.at(i / bitsinablock)));
			++newlength;
		}
	}
	if (cutoff == 0) {
		setNumBits(newlength);
	} else {
		setNumBits(cutoff);
	}
}

const u_int32_t& TMrfData_8b::getLastError() const
{
	return errcode;
}

bool TMrfData_8b::lastActionSuccessful() const
{
	return !(errcode);
}








