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

INCLUDEPATH += ../../MRF/source/ /home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/include/ /private/esch/external_packages/FairSoft_build/include/

exists($(ROOTSYS))
{
INCLUDEPATH += $(ROOTSYS)/include/root/
}

LIBS += -L/private/esch/external_packages/FairSoft_build/lib -lzmq -lboost_thread -lboost_timer -lboost_system
LIBS += -L/home/ikp1/esch/fairsoft/FairRoot_Mohammad_build/lib -lFairMQ

exists($(ROOTSYS))
{
LIBS += -L $(ROOTSYS)/lib/root/ -lCore -lGraf -lHist -lMathCore -lCint -lGpad
}
