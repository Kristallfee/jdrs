/*============================================================*/
/* mrftal.h                                                   */
/* MVD Readout Framework Transport Access Layer               */
/*                                               M.C. Mertens */
/*============================================================*/


#ifndef __MRFTAL_H__
#define __MRFTAL_H__

#include "mrfgal.h"
#include "mrfbase.h"
#include "mrfdata_8b.h"

//! Important registers of the Panda Readout Board
namespace rb_address {
    // Register Adresses
    static const mrf::addresstype ident = 1024;		//0x400
    static const mrf::addresstype doorbell = 1028;	//0x404
    static const mrf::addresstype control = 8;		//0x408   // vorher 1032 - 0x408
    static const mrf::addresstype busy = 1040;		//0x410
    static const mrf::addresstype dcmconfigreg = 0x414;	//0x414
    static const mrf::addresstype ledlinereg = 0x41c;	//0x41c

    // from mrftal_rb.h
    static const mrf::addresstype strblen = 1048;	//0x418
    static const mrf::addresstype lvl1delay = 1052;	//0x41C
    static const mrf::addresstype timer = 1056;		//0x420
    static const mrf::addresstype inputreg = 1060;	//0x424
    static const mrf::addresstype bitcountreg = 1064;	//0x428
    static const mrf::addresstype lvl1length = 1068;	//0x42C
    static const mrf::addresstype synclength = 1072;	//0x430
    static const mrf::addresstype bitcountoreg = 1076;	//0x434

    // LCD stuff
    static const mrf::addresstype lcd_mode = 0x4cc;     //0x4cc
    static const mrf::addresstype lcd_fifo = 0x4d0;     //0x4d0
}

//! Important register values of the Panda Readout Board
namespace rb_value {
	static const mrf::registertype daqreset = 3;		//Bits 0+1
	static const mrf::registertype pandareset = 4;		//Bit 2
	static const mrf::registertype led0 = 8;		//Bit 3
	static const mrf::registertype led1 = 16;		//Bit 4
	static const mrf::registertype configdcm = 32;		//Bit 5
	static const mrf::registertype configmmcm = 32;		//Bit 5

        // from mrftal_rb.h
        static const mrf::registertype startinput = 32;		//Bit 5
        static const mrf::registertype startsync = 64;		//Bit 6
        static const mrf::registertype strblvl1 = 128;		//Bit 7
        static const mrf::registertype eoedetect = 256;		//Bit 8
        static const mrf::registertype outputenable = 512;	//Bit 9
        static const mrf::registertype xckrenable = 1024;	//Bit A
}

//! Readout Board Interrupts
namespace rb_irq {
        static const u_int32_t button = 0x2;
}

//! Positions of the LED enable/disable flags of the Panda Readout Board
namespace sis_led {
	//enum led_id {
	//	led0 = 8,
	//	led1 = 16,
	//};
	static const mrf::registertype led[2] = {rb_value::led0, rb_value::led1};
}

//! Error flags set by functions accessing the Panda Readout Board
namespace rb_error {
	static const u_int32_t success = 0;
	static const u_int32_t read_failed = 1;
	static const u_int32_t initreadout_failed = 4;
	static const u_int32_t doreadout_failed = 8;
	static const u_int32_t more_data_available = 16;
	static const u_int32_t device_not_open = 32;
}

//! Magic numbers used by SIS 1100 interface
namespace sis_magic {
	static const u_int32_t success = 0;
	static const u_int32_t nomoredata = 0x209;
}

//! Transport access layer for the Mrf.
/*!
Provides an interface to send data to the frontend via a transport device.
*/
class TMrfTal : virtual public TMrfGal
{
	public:
		TMrfTal();

		//! Writes an arbitrary data stream to the frontend
		/*!
		The device must be open.
		\param data TMrfData structure storing the data to be written

		<b>Error codes:</b>

		<b>Implementation notes:</b>
		*/
		virtual void writeRemoteData(const TMrfData& data) const = 0;

		//! Reads an arbitrary data stream from the frontend
		/*!
		The device must be open.
		\param data TMrfData structure which provides space for the data to be read
		
		<b>Error codes:</b>

		<b>Implementation notes:</b>
		*/
		virtual void readRemoteData(TMrfData_8b& data) const = 0;
	protected:
		
	private:
		
};


#endif // __MRFTAL_H__

