#-------------------------------------------------
#
# Project created by QtCreator 2014-07-22T14:57:58
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = topix4_main

INCLUDEPATH += ../../MRF/source/ $(FAIRROOTPATH)/include/ $(SIMPATH)/include/


DEPENDPATH += ../helper_functions.h

#CONFIG -= qt

TEMPLATE = app

RESOURCES += \
    resources.qrc
SOURCES += main.cpp\
	mainwindow.cpp \
	topix4_fairmq_readout.cpp \
	 ../writetofile.cpp \
	 ../../MRF/source/mrfdata_chain2ltc2604.cpp \
	 ../../MRF/source/mrfdata_chainltc.cpp \
	 ../../MRF/source/mrfdataadv2d.cpp \
	 ../../MRF/source/mrfdataadvbase.cpp \
	 ../../MRF/source/mrfcal_topix4.cpp \
	 ../../MRF/source/mrfcal.cpp \
	 ../../MRF/source/mrftal_rbtopix4.cpp \
	 ../../MRF/source/mrftal_rbbase_v6.cpp \
	 ../../MRF/source/mrftal_rbbase.cpp \
	 ../../MRF/source/mrfdataregaccess.cpp \
	 ../../MRF/source/mrfdataadv1d.cpp \
	 ../../MRF/source/mrfdataadv1daddress.cpp \
	 ../../MRF/source/mrfdata_mmcmconf.cpp \
	 ../../MRF/source/mrftal_rbudp.cpp \
	 ../../MRF/source/mrfgal_udp.cpp \
	 ../../MRF/source/mrfgal.cpp \
	 ../../MRF/source/mrftal.cpp \
	 ../../MRF/source/mrftal_rb.cpp \
	 ../../MRF/source/mrfdata_8b.cpp \
	 ../../MRF/source/mrfdata.cpp \
	 ../../MRF/source/mrfdata_topix4flags.cpp \
	 ../../MRF/source/mrfcal_topix4testboard.cpp \
	 ../../MRF/source/mrfdata_topix4config.cpp \
	 ../../MRF/source/mrfdata_tpx4pixelmatrix.cpp \
	 ../../MRF/source/mrfdataadv3dmatrix.cpp \
	 ../../MRF/source/mrfdata_topix4command.cpp \
	 ../../MRF/source/mrfstrerror.cpp \
	 ../../MRF/source/mrf_confitem.cpp \
	 ../../MRF/source/mrfgal_sis1100.cpp \
	 ../../MRF/source/mrfdata_dcmconf.cpp \
	 ../../MRF/source/mrftools.cpp \
	 ../../MRF/source/qmrftools.cpp \
	 ../../MRF/source/mrfdata_afei3hits.cpp \
	 ../../MRF/source/mrfdata_afei3.cpp \
	 ../../MRF/source/stringseparator.cpp \
    ../../MRF/source/mrfdata_tpx4pixel.cpp \
    ../../MRF/source/mrfdata_tpx4data.cpp \
    ../../MRF/source/mrf_writetofile_boost.cpp

HEADERS  += mainwindow.h \
	 topix4_fairmq_readout.h \
	 ../writetofile.h \
	 ../../MRF/source/mrfdata_chain2ltc2604.h \
	 ../../MRF/source/mrfdata_chainltc.h \
	 ../../MRF/source/mrfdataadv2d.h \
	 ../../MRF/source/mrfdataadvbase.h \
	 ../../MRF/source/mrfcal_topix4.h \
	 ../../MRF/source/mrfcal.h \
	 ../../MRF/source/mrftal_rbtopix4.h \
	 ../../MRF/source/mrftal_rbbase_v6.h \
	 ../../MRF/source/mrftal_rbbase.h \
	 ../../MRF/source/mrfdataregaccess.h \
	 ../../MRF/source/mrfdataadv1d.h \
	 ../../MRF/source/mrfdataadv1daddress.h \
	 ../../MRF/source/mrfdata_mmcmconf.h \
	 ../../MRF/source/mrftal_rbudp.h \
	 ../../MRF/source/mrfgal_udp.h \
	 ../../MRF/source/mrfgal.h \
	 ../../MRF/source/mrftal.h \
	 ../../MRF/source/mrftal_rb.h \
	 ../../MRF/source/mrfdata_8b.h \
	 ../../MRF/source/mrfdata.h \
	 ../../MRF/source/mrfdata_topix4flags.h \
	 ../../MRF/source/mrfcal_topix4testboard.h \
	 ../../MRF/source/mrfdata_topix4config.h \
	 ../../MRF/source/mrfdata_tpx4pixelmatrix.h \
	 ../../MRF/source/mrfdataadv3dmatrix.h \
	 ../../MRF/source/mrfdata_topix4command.h \
	 ../../MRF/source/mrfstrerror.h \
	 ../../MRF/source/mrf_confitem.h \
	 ../../MRF/source/mrfgal_sis1100.h \
	 ../../MRF/source/mrfdata_dcmconf.h \
	 ../../MRF/source/mrftools.h \
	 ../../MRF/source/qmrftools.h \
	 ../../MRF/source/mrfdata_afei3hits.h \
	 ../../MRF/source/mrfdata_afei3.h \
	 ../../MRF/source/stringseparator.h \
    ../helper_functions.h \
    ../../MRF/source/mrfdata_tpx4pixel.h \
    ../../MRF/source/mrfdata_tpx4data.h \
    ../../MRF/source/mrf_writetofile_boost.h


QMAKE_MOC = $$QMAKE_MOC -DBOOST_TT_HAS_OPERATOR_HPP_INCLUDED

FORMS    += mainwindow.ui
OBJECTS_DIR=generated_files

#QMAKE_LFLAGS_DEBUG += /NODEFAULTLIB:boost_thread

#QMAKE_LIBDIR_FLAGS = -L/private/esch/external_packages/FairSoft_build/ -lboost_timer -lboost_system -lboost_thread

LIBS += -L$(SIMPATH)/lib -lzmq -lboost_thread -lboost_serialization -lboost_timer -lboost_system -lboost_chrono
LIBS += -L$(FAIRROOTPATH)/lib -lFairMQ

