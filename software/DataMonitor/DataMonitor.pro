TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp \
    datamonitor.cpp \
    ../../MRF/source/mrfdata_8b.cpp \
    ../../MRF/source/mrftools.cpp \

HEADERS += \
    datamonitor.h \
    ../../MRF/source/mrfdata_8b.h \
    ../../MRF/source/mrftools.h \

INCLUDEPATH += ../../MRF/source/ $(FAIRROOTPATH)/include/ $(SIMPATH)/include/


exists($(ROOTSYS))
{
INCLUDEPATH += $(ROOTSYS)/include/root/
}
LIBS += -L$(SIMPATH)/lib -lzmq -lboost_thread -lboost_timer -lboost_system -lboost_chrono
LIBS += -L$(FAIRROOTPATH)lib -lFairMQ

exists($(ROOTSYS))
{
LIBS += -L $(ROOTSYS)/lib/root/ -lCore -lGraf -lHist -lMathCore -lCint -lGpad
}
