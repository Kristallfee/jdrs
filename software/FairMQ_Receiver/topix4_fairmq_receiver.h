#ifndef TOPIX4_FAIRMQ_RECEIVER_H
#define TOPIX4_FAIRMQ_RECEIVER_H

#include "FairMQDevice.h"

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
    void Log(int intervalInMs);
protected:
    virtual void Run();
    virtual void Init();
    int fEventSize;
    int fEventRate;
    int fEventCounter;

};

#endif // TOPIX4_FAIRMQ_RECEIVER_H
