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

    int ReductionRate() const;
    void setReductionRate(int ReductionRate);

protected:
    virtual void Init();
    virtual void Run();

private:
    TCanvas* canvas;
    TH1F* leading_Edge;
    TH1F* trailing_Edge;
    TH2F* hit_map;

    int _counter;
    int _ReductionCounter;
    int _ReductionRate;

    void pixeladdressToMatrixAddress(u_int32_t pixelglobaladdress, u_int32_t &matrix_row, u_int32_t &matrix_column);
};

#endif // DATAMONITOR_H
