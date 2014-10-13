
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
    if ( argc != 8 ) {
        cout << "Usage: run_topix4_fairmq_receiver \tID numIoTreads\n"
                  << "\t\tinputSocketType inputRcvBufSize inputMethod inputAddress bigcounter\n"
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

     int numIoThreads;
     stringstream(argv[i]) >> numIoThreads;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::NumIoThreads, numIoThreads);
     ++i;


     topix4_receiver.SetProperty(topix4_fairmq_receiver::NumInputs, 1);
     topix4_receiver.SetProperty(topix4_fairmq_receiver::NumOutputs, 0);
     topix4_receiver.ChangeState(topix4_fairmq_receiver::INIT);
     topix4_receiver.SetProperty(topix4_fairmq_receiver::InputSocketType, argv[i], 0);
     ++i;
     int inputRcvBufSize;
     stringstream(argv[i]) >> inputRcvBufSize;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::InputRcvBufSize, inputRcvBufSize, 0);
     ++i;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::InputMethod, argv[i], 0);
     ++i;
     topix4_receiver.SetProperty(topix4_fairmq_receiver::InputAddress, argv[i], 0);
     ++i;
     topix4_receiver.SetBigCounter(argv[i]);

     topix4_receiver.ChangeState(topix4_fairmq_receiver::SETOUTPUT);
     topix4_receiver.ChangeState(topix4_fairmq_receiver::SETINPUT);
     topix4_receiver.ChangeState(topix4_fairmq_receiver::RUN);


     char ch;
     cin.get(ch);


     topix4_receiver.ChangeState(topix4_fairmq_receiver::STOP);
     topix4_receiver.ChangeState(topix4_fairmq_receiver::END);

     return 0;


}
