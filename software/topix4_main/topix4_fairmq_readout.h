#ifndef TOPIX4_FAIRMQ_READOUT_H
#define TOPIX4_FAIRMQ_READOUT_H

#include "FairMQDevice.h"
#include "mrfcal_topix4.h"
#include "QString"
//#include "../writetofile.h"
#include "QTextEdit"
#include <fstream>
#include "mrf_writetofile_boost.h"
#include <string>

class ToPix4_FairMQ_Readout: public FairMQDevice
{
public:
    enum {
      InputFile = FairMQDevice::Last,
      EventRate,
      EventSize,
      Last
    };
    ToPix4_FairMQ_Readout();
    virtual ~ToPix4_FairMQ_Readout();
    int CloseASICConnection();
    int OpenASICConnection(QString connectionparamter);
    virtual void SetProperty(const int key, const string& value, const int slot = 0);
    virtual string GetProperty(const int key, const string& default_ = "", const int slot = 0);
    virtual void SetProperty(const int key, const int value, const int slot = 0);
    virtual int GetProperty(const int key, const int default_ = 0, const int slot = 0);
    void SetOutputWindow(QTextEdit* window);
    void SetBigCounter(bool value);
    void SetSaveData(bool value, std::string path);
    void SetFakeDataCheck(bool value);

protected:
    virtual void Run();
    virtual void Init();
    int fEventSize;
    int fEventRate;

private:
    TMrfCal_Topix4 _topix4control;
    QTextEdit * _window;
  //  WriteToFile* writetofile;
    TMrf_WriteToFile_Boost *writetofile_boost;
    u_int64_t previous_dataword;
    u_int64_t previous_comandoword;
    bool bigcounter;
    bool savedata;
    bool fakedatacheck;
    std::ofstream ofs;
};

#endif // TOPIX4_FAIRMQ_READOUT_H
