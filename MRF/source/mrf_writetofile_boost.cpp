#include "mrf_writetofile_boost.h"
#include <iostream>



TMrf_WriteToFile_Boost::TMrf_WriteToFile_Boost(): max_filesize_MB(200),filecounter(1)
{
    pathname="data/";
}

u_int32_t TMrf_WriteToFile_Boost::getMaxFilesize_MB() const
{
    return max_filesize_MB;
}

void TMrf_WriteToFile_Boost::setMaxFilesize_MB(const u_int32_t &value)
{
    max_filesize_MB = value;
}

void TMrf_WriteToFile_Boost::writeData(TMrfData_8b* data)
{
    boost::archive::binary_oarchive oa(ofs);
    oa << data;
}

void TMrf_WriteToFile_Boost::createFileName(int mark)
{
    // filecounter=1;
    time (&timestamp);
    nun = localtime(&timestamp);
    filename.clear();
    filename.append(QString::fromStdString(pathname));
    if(!filename.endsWith("/"))
    {
        filename.append("/");
    }

    filename.append(QString("%1").arg(nun->tm_year+1900,4,10,QChar('0')));
    filename.append("-");
    filename.append(QString("%1").arg(nun->tm_mon+1,2,10,QChar('0')));
    filename.append("-");
    filename.append(QString("%1").arg(nun->tm_mday,2,10,QChar('0')));
    filename.append("-");
    filename.append(QString("%1").arg(nun->tm_hour,2,10,QChar('0')));
    filename.append("-");
    filename.append(QString("%1").arg(nun->tm_min,2,10,QChar('0')));
    filename.append("-");
    filename.append(QString("%1").arg(nun->tm_sec,2,10,QChar('0')));

    filename.append("--");
    filename.append(QString::number(mark));
    //filename.append("-data--0.txt");
    filename.append("-data--");
    filename.append(QString::number(filecounter));
    filename.append(".txt");


    filecounter++;

//    filename_datastream.clear();
//    filename_configstream.clear();
//    filename_datastream.append(filename);
//    filename_configstream.append(filename);
//    filename_datastream.append("--");
//    filename_configstream.append("--");
//    filename_datastream.append(QString::number(mark));
//    filename_configstream.append(QString::number(mark));
//    filename_datastream.append("-data--0.txt");
//    filename_configstream.append("-config.txt");
}

void TMrf_WriteToFile_Boost::setPathName(std::string path)
{
    pathname=path;
}

void TMrf_WriteToFile_Boost::closeFile()
{
    ofs.close();
}

bool TMrf_WriteToFile_Boost::openFile(int _mark)
{
    createFileName(_mark);
    ofs.open(filename.toLocal8Bit().data(),std::ios::binary);
    return ofs.is_open();
}

bool TMrf_WriteToFile_Boost::CheckFileSizeForNewFile()
{
    ofs.flush();
    if(ofs.tellp() > (max_filesize_MB*1000000))
    {
        ofs.close();
        createFileName(mark);
        ofs.open(filename.toLocal8Bit().data(),std::ios::binary);
    }
    return ofs.is_open();
}
