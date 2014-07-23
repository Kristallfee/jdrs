TEMPLATE = app

TARGET = run_topix4_fairmq_receiver
CONFIG += console
CONFIG -= qt


SOURCES += run_topix4_fairmq_receiver.cpp \
	   topix4_fairmq_receiver.cpp \
	   ../../MRF/source/mrfdata.cpp \
	   ../../MRF/source/mrftools.cpp

HEADERS += topix4_fairmq_receiver.h \
	   ../../MRF/source/mrfdata.h \
	   ../../MRF/source/mrftools.h

INCLUDEPATH +=  /home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/include/ /private/esch/external_packages/FairSoft_build/include/


LIBS += -L/private/esch/external_packages/FairSoft_build/lib -lzmq -lboost_thread -lboost_timer -lboost_system
LIBS += -L/home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/lib -lFairMQ
