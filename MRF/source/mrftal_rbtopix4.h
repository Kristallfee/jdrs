/*============================================================*/
/* mrftal_rbtopix4.h                                          */
/* MVD Readout Framework Transport Access Layer               */
/* Transport Access Layer for ml605                           */
/* connected via SIS1100 Gigabit Link                         */
/* including ToPiX protocol                                   */
/*                                                  S.U. Esch */
/*============================================================*/

#ifndef MRFTAL_RBTOPIX4_H
#define MRFTAL_RBTOPIX4_H

#include "mrftal_rbbase_v6.h"
#include "mrfdata_topix4flags.h"
#include "mrfdata_chain2ltc2604.h"
#include "mrfdata_8b.h"

//! Topix Firmware Register Addresses
namespace tpx_address {
        // Register Adresses
        static const mrf::addresstype outputfifo = 0x400;
        static const mrf::addresstype dummyfiforeg = 0x420;
        static const mrf::addresstype sdataout = 0x424;
        static const mrf::addresstype inputfifodatacount = 0x440;
        static const mrf::addresstype delaycountertestp = 0x444;
        static const mrf::addresstype waittestp = 0x448;
        static const mrf::addresstype flags = 0x480;
        static const mrf::addresstype input = 0x484;
        static const mrf::addresstype inputcount = 0x488;
        static const mrf::addresstype datatest = 0x48c;
        static const mrf::addresstype triggercount = 0x490;
        static const mrf::addresstype ltcconfig = 0x494;
        static const mrf::addresstype bussel1data = 0x498;
        static const mrf::addresstype bussel0data = 0x49c;
        static const mrf::addresstype aprechrgdata = 0x4a0;
        static const mrf::addresstype dprechrgdata = 0x4a4;
        static const mrf::addresstype alatchdata = 0x4a8;
        static const mrf::addresstype dlatchdata = 0x4ac;
        static const mrf::addresstype readcmddata = 0x4b0;
        static const mrf::addresstype readledata = 0x4b4;
        static const mrf::addresstype readtedata = 0x4b8;
        static const mrf::addresstype triggerlodata = 0x4bc;
        static const mrf::addresstype triggerhidata = 0x4c0;
        static const mrf::addresstype masterbitcount = 0x4c4;
}

//! Topix Control Register Values
namespace tpxctrl_value {
	//0..7: System --> mrftal_rbbase.h
	//static const mrf::registertype daqreset = 3;			//CM_MODE(0+1)
	//static const mrf::registertype pandareset = 4;		//CM_MODE(2)
	//static const mrf::registertype led0 = 8;			//CM_MODE(3)
	//static const mrf::registertype led1 = 16;			//CM_MODE(4)
	//static const mrf::registertype configdcm = 32;		//CM_MODE(5)
	static const mrf::registertype continuousreadout = 0x2;

	//8..31: User
	static const mrf::registertype tpxfakedata = 0x100;		//CM_MODE(8)
	static const mrf::registertype topix4config = 0x200;            //CM_MODE(9)
	static const mrf::registertype startshifter = 0x1000;		//CM_MODE(12)
	static const mrf::registertype startmaster = 0x2000;		//CM_MODE(13)
	static const mrf::registertype ltcconfig = 0x4000;		//CM_MODE(14)
	static const mrf::registertype triggerread = 0x8000;		//CM_MODE(15)
	static const mrf::registertype triggerwithlo = 0x10000;         //CM_MODE(16)
}


class TMrfTal_RBTopix4 : public TMrfTal_RBBase_V6
{
public:
    TMrfTal_RBTopix4();
    virtual ~TMrfTal_RBTopix4();

    // From TMrfGal
    //! Opens the device file and enables essential IRQs
    //virtual void openDevice(const char* const devicefile);

    // From TMrfTal
    //! Sends the stream stored in data to the connected frontend.
    virtual void writeRemoteData(const TMrfData& data) const;

    //! Retrieves data from the readout board's buffer.
    virtual void readRemoteData(TMrfData_8b &data);

    virtual void triggerRead(const u_int32_t& triggercount, const bool& withlo) const;

    virtual void configTopixSlowReg(const TMrfData_Topix4Flags& data) const;

    virtual void writeLTCData(const TMrfData_Chain2LTC2604& data) const;

    virtual void startSerializer(const u_int32_t& count) const;


    //! Arms the data output buffer
    /*!
    Prepares the output buffer to accept a certain amount of data. Needs to be called before data can be read out to the PC.
    \param datacount: Number of dwords to be stored in the output buffer for later retrieval.

    Error codes are set by the underlying write() functions.
    */
    //void prepareOutputBuffer(const mrf::registertype& datacount) const;

    //! Arms the event output buffer.
    /*!
    Prepares the output buffer to accept event data with EOE markers.
    */
    //void prepareEventOutputBuffer(const mrf::registertype& eventcount = 1) const;

protected:

private:
    //u_int32_t* buf;
    //bool databuffered;
};

#endif // MRFTAL_RBTOPIX4_H
