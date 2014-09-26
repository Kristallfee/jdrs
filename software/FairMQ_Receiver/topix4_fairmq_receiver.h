#ifndef TOPIX4_FAIRMQ_RECEIVER_H
#define TOPIX4_FAIRMQ_RECEIVER_H

#include "FairMQDevice.h"
#include "../writetofile.h"

class topix4_fairmq_receiver : public FairMQDevice
{
public:
    enum {
      InputFile = FairMQDevice::Last,
      EventRate,
      EventSize,
      Last
    };

    topix4_fairmq_receiver();
    virtual ~topix4_fairmq_receiver();
    void SetBigCounter(string value);
   // void Log(int intervalInMs);
protected:
    virtual void Run();
    virtual void Init();
    int fEventSize;
    int fEventRate;
    int fEventCounter;

private:
    WriteToFile* writetofile;
    u_int64_t previous_comandoword;
    u_int64_t previous_dataword;
    bool bigcounter;
};

#endif // TOPIX4_FAIRMQ_RECEIVER_H
