TEMPLATE = app

TARGET = run_topix4_fairmq_receiver
CONFIG += console
#CONFIG -= qt



DEPENDPATH += ../helper_functions.h

SOURCES +=  topix4_fairmq_receiver.cpp \
	   ../../MRF/source/mrfdata_8b.cpp \
	   ../../MRF/source/mrftools.cpp \
    ../writetofile.cpp \
     run_topix4_fairmq_receiver.cpp \
    ../../MRF/source/mrfdataadv1d.cpp \
    ../../MRF/source/mrfdata.cpp \
    ../../MRF/source/mrfdataadvbase.cpp \
    ../../MRF/source/mrfdataadv2d.cpp \




HEADERS += topix4_fairmq_receiver.h \
	   ../../MRF/source/mrfdata_8b.h \
	   ../../MRF/source/mrftools.h \
    ../writetofile.h \
    ../../MRF/source/mrfdataadv1d.h \
    ../../MRF/source/mrfdata.h \
    ../../MRF/source/mrfdataadvbase.h \
    ../../MRF/source/mrfdataadv2d.h \
	../helper_functions.h

INCLUDEPATH += ../../MRF/source/ /home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/include/ /private/esch/external_packages/FairSoft_build/include/


LIBS += -L/private/esch/external_packages/FairSoft_build/lib -lzmq -lboost_thread -lboost_timer -lboost_system
LIBS += -L/home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/lib -lFairMQ
