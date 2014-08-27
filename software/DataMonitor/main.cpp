#include <iostream>
#include "FairMQLogger.h"
#include <csignal>
#include "datamonitor.h"
#include "TApplication.h"

#ifdef NANOMSG
  #include "FairMQTransportFactoryNN.h"
#else
  #include "FairMQTransportFactoryZMQ.h"
#endif

DataMonitor datamonitor;

static void s_signal_handler (int signal)
{
  cout << endl << "Caught signal " << signal << endl;

  datamonitor.ChangeState(DataMonitor::STOP);
  datamonitor.ChangeState(DataMonitor::END);

  cout << "Shutdown complete. Bye!" << endl;
  exit(1);
}

static void s_catch_signals (void)
{
  struct sigaction action;
  action.sa_handler = s_signal_handler;
  action.sa_flags = 0;
  sigemptyset(&action.sa_mask);
  sigaction(SIGINT, &action, NULL);
  sigaction(SIGTERM, &action, NULL);
}



int main(int argc, char** argv)
{
    cout << "Hello World!" << endl;

    TApplication theApp("App",0,0);



    if ( argc != 7 ) {
        cout << "Usage: run_topix4_fairmq_receiver \tID numIoTreads\n"
                  << "\t\tinputSocketType inputRcvBufSize inputMethod inputAddress\n"
                  << endl;
        return 1;
    }

    s_catch_signals();

#ifdef NANOMSG
    FairMQTransportFactory* transportFactory = new FairMQTransportFactoryNN();
#else
    FairMQTransportFactory* transportFactory = new FairMQTransportFactoryZMQ();
#endif

    datamonitor.SetTransport(transportFactory);

    int i = 1;

    datamonitor.SetProperty(DataMonitor::Id, argv[i]);
    ++i;

    int numIoThreads;
    stringstream(argv[i]) >> numIoThreads;
    datamonitor.SetProperty(DataMonitor::EventSize, numIoThreads);
    ++i;


    datamonitor.SetProperty(DataMonitor::NumInputs, 1);
    datamonitor.SetProperty(DataMonitor::NumOutputs, 0);


    datamonitor.ChangeState(DataMonitor::INIT);


    datamonitor.SetProperty(DataMonitor::InputSocketType, argv[i], 0);
    ++i;
    int inputRcvBufSize;
    stringstream(argv[i]) >> inputRcvBufSize;
    datamonitor.SetProperty(DataMonitor::InputRcvBufSize, inputRcvBufSize, 0);
    ++i;
    datamonitor.SetProperty(DataMonitor::InputMethod, argv[i], 0);
    ++i;
    datamonitor.SetProperty(DataMonitor::InputAddress, argv[i], 0);
    ++i;


    datamonitor.ChangeState(DataMonitor::SETOUTPUT);
    datamonitor.ChangeState(DataMonitor::SETINPUT);
    datamonitor.ChangeState(DataMonitor::RUN);

    theApp.Run();
    char ch;
    cin.get(ch);


    datamonitor.ChangeState(DataMonitor::STOP);
    datamonitor.ChangeState(DataMonitor::END);

    return 0;
}

