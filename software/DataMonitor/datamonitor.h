#ifndef DATAMONITOR_H
#define DATAMONITOR_H

#include "FairMQDevice.h"
#include "TCanvas.h"
#include "TH1.h"
#include "TH2.h"

class DataMonitor : public FairMQDevice
{
public:
    enum {
      InputFile = FairMQDevice::Last,
      EventRate,
      EventSize,
      Last
    };
    DataMonitor();
    virtual ~DataMonitor();


protected:
    virtual void Init();
    virtual void Run();

private:
    TCanvas* canvas;
    TH1F* leading_Edge;
    TH1F* trailing_Edge;
    TH2F* pixel_position;

    int counter;

};

#endif // DATAMONITOR_H
