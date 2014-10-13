TEMPLATE = app
CONFIG += console
CONFIG -= app_bundle
CONFIG -= qt

SOURCES += main.cpp \
    ../../MRF/source/mrfdata_8b.cpp \
	../../MRF/source/mrftools.cpp

HEADERS += \
    ../../MRF/source/mrfdata_8b.h \
    ../../MRF/source/mrftools.h

INCLUDEPATH += ../../MRF/source/  $(SIMPATH)/include/

LIBS += -L$(SIMPATH)/lib -lzmq -lboost_thread -lboost_serialization -lboost_timer -lboost_system -lboost_chrono
