
#include <unistd.h>
#include <iostream>
#include <csignal>

#include "FairMQLogger.h"
#include "topix4_fairmq_receiver.h"

#ifdef NANOMSG
  #include "FairMQTransportFactoryNN.h"
#else
  #include "FairMQTransportFactoryZMQ.h"
#endif

//using std::cout;
//using std::cin;
//using std::endl;
//using std::stringstream;

topix4_fairmq_receiver topix4_receiver;

static void s_signal_handler (int signal)
{
  cout << endl << "Caught signal " << signal << endl;

  topix4_receiver.ChangeState(topix4_fairmq_receiver::STOP);
  topix4_receiver.ChangeState(topix4_fairmq_receiver::END);

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
    if ( argc != 9 ) {
        cout << "Usage: testToPix4_FairMQ_Receiver ID eventSize eventRate numIoTreads\n"
             << "\t\toutputSocketType outputSndBufSize outputMethod outputAddress\n"
             << endl;
        return 1;
    }

    s_catch_signals();

    LOG(INFO) << "PID: " << getpid();

   #ifdef NANOMSG
     FairMQTransportFactory* transportFactory = new FairMQTransportFactoryNN();
   #else
     FairMQTransportFactory* transportFactory = new FairMQTransportFactoryZMQ();
   #endif

     topix4_receiver.SetTransport(transportFactory);

     int i = 1;

     topix4_receiver.SetProperty(topix4_fairmq_receiver::Id, argv[i]);
     ++i;

     int eventSize;
     stringstream(argv[i]) >> eventSize;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::EventSize, eventSize);
     ++i;

     int eventRate;
     stringstream(argv[i]) >> eventRate;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::EventRate, eventRate);
     ++i;

     int numIoThreads;
     stringstream(argv[i]) >> numIoThreads;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::NumIoThreads, numIoThreads);
     ++i;

     topix4_receiver.SetProperty(topix4_fairmq_receiver::NumInputs, 0);
     topix4_receiver.SetProperty(topix4_fairmq_receiver::NumOutputs, 1);


     topix4_receiver.ChangeState(topix4_fairmq_receiver::INIT);


     topix4_receiver.SetProperty(topix4_fairmq_receiver::OutputSocketType, argv[i], 0);
     ++i;
     int outputSndBufSize;
     stringstream(argv[i]) >> outputSndBufSize;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::OutputSndBufSize, outputSndBufSize, 0);
     ++i;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::OutputMethod, argv[i], 0);
     ++i;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::OutputAddress, argv[i], 0);
     ++i;


     topix4_receiver.ChangeState(topix4_fairmq_receiver::SETOUTPUT);
     topix4_receiver.ChangeState(topix4_fairmq_receiver::SETINPUT);
     topix4_receiver.ChangeState(topix4_fairmq_receiver::RUN);


     char ch;
     cin.get(ch);


     topix4_receiver.ChangeState(topix4_fairmq_receiver::STOP);
     topix4_receiver.ChangeState(topix4_fairmq_receiver::END);

     return 0;


}
