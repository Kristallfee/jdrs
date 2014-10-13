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
    ../../MRF/source/mrf_writetofile_boost.cpp




HEADERS += topix4_fairmq_receiver.h \
	   ../../MRF/source/mrfdata_8b.h \
	   ../../MRF/source/mrftools.h \
    ../writetofile.h \
    ../../MRF/source/mrfdataadv1d.h \
    ../../MRF/source/mrfdata.h \
    ../../MRF/source/mrfdataadvbase.h \
    ../../MRF/source/mrfdataadv2d.h \
	../helper_functions.h \
    ../../MRF/source/mrf_writetofile_boost.h

INCLUDEPATH += ../../MRF/source/ $(FAIRROOTPATH)/include/ $(SIMPATH)/include/



LIBS += -L$(SIMPATH)/lib -lzmq -lboost_thread -lboost_timer -lboost_serialization -lboost_system -lboost_chrono
LIBS += -L$(FAIRROOTPATH)lib -lFairMQ
