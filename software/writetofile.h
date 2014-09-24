#ifndef WRITETOFILE_H
#define WRITETOFILE_H

#include <QString>
#include <QFile>
#include <QTextStream>
#include "mrfdataadv1d.h"
#include "mrfdataadv2d.h"
//#include "mrfdata_tpx3data.h"
//#include "mrfdata_chain2ltc2604.h"
#include <iostream>
#include <fstream>
#include <time.h>

class WriteToFile
{
public:
    WriteToFile();
    bool OpenFile();
    bool OpenFile(int mark);
    bool Close();
    bool isDataFileOpen();
    void ConfigHeader(QString);
    void AppendToConfig(QString data);
    void AppendToConfig(int data);
    void AppendToConfig(TMrfDataAdv1D &data);
//    void AppendToConfig(TMrfData_Chain2LTC2604 &data);
    void AppendToConfigEndl();
    void AppendToData(QString data);
    void AppendToData(int data);
    //void AppendToData(TMrfDataAdv1D &data);
    void AppendToDataEndl();
    void AppendToData(TMrfDataAdv1D::itemMap &data);
//    void AppendToData(TMrfData_Chain2LTC2604 &data);
//    void AppendToData(TMrfData_Tpx3Data &data);
    void AppendToData(TMrfDataAdv1D &data);
    bool CheckFileSizeForNewFile();
    void SetFileSize(int byte);
    int GetFileSize();
    void SetPathName(QString path);
    QString GetDataFileName();
    QString GetPathName();
    void SetIntegerBase(int base);
    u_int32_t graytobin(u_int32_t gray);


private:
    struct tm *nun;
    //std::ofstream configstream;
    //std::ofstream datastream;

    int i;
    int filesize; // byte
    QFile datafile;
    QFile configfile;
    QTextStream configstream;
    QTextStream datastream;
    time_t _timeStamp;
    QString filename;
    QString filename_datastream;
    QString filename_configstream;
    QString pathname;

};

#endif // WRITETOFILE_H
