#include "writetofile.h"
#include "mrftools.h"

using mrftools::getIntBit;
using mrftools::setIntBit;
using mrftools::shiftBy;
using mrftools::getIteratorItemCount;


WriteToFile::WriteToFile():i(1),filesize(200000000)
{
    pathname="data/";
}

u_int32_t WriteToFile::graytobin(u_int32_t gray)
{
    u_int32_t result = 0;
    setIntBit(31, result, getIntBit(31, gray));
    for (unsigned int i = 30; i > 0; --i) {
        setIntBit(i, result, (getIntBit(i+1, result) && !(getIntBit(i, gray))) || (!(getIntBit(i+1, result)) && getIntBit(i, gray)));
    }
    setIntBit(0, result, (getIntBit(1, result) && !(getIntBit(0, gray))) || (!(getIntBit(1, result)) && getIntBit(0, gray)));
    return result;
}

QString WriteToFile::GetDataFileName()
{
    return filename;
}

bool WriteToFile::isDataFileOpen()
{
    return datafile.isOpen();
}

QString WriteToFile::GetPathName()
{
    return pathname;
}

void WriteToFile::SetPathName(QString path)
{
    pathname=path;
}

bool WriteToFile::OpenFile(int mark)
{
    i=1;
    time (&_timeStamp);
    nun = localtime(&_timeStamp);
    filename.clear();
    filename.append(pathname);
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

    filename_datastream.clear();
    filename_configstream.clear();
    filename_datastream.append(filename);
    filename_configstream.append(filename);
    filename_datastream.append("--");
    filename_configstream.append("--");
    filename_datastream.append(QString::number(mark));
    filename_configstream.append(QString::number(mark));
    filename_datastream.append("-data--0.txt");
    filename_configstream.append("-config.txt");
    configfile.setFileName(filename_configstream);
    datafile.setFileName(filename_datastream);
    if (!configfile.open(QIODevice::WriteOnly|QIODevice::Append))
    {
        std::cout << "ERROR: Could not open configfile " << std::endl;
        return false;
    }
    if(!datafile.open(QIODevice::WriteOnly|QIODevice::Append))
    {
        std::cout << "ERROR: Could not open datafile " << std::endl;
        return false;
    }

    configstream.setDevice(&configfile);

    datastream.setDevice(&datafile);
    return true;
}

bool WriteToFile::OpenFile()
{
    return OpenFile(0);
}

void WriteToFile::ConfigHeader(QString type)
{
    configstream<< "Date and Time "<< nun->tm_year+1900 <<"-" <<nun->tm_mon+1<<"-" <<nun->tm_mday << " " << nun->tm_hour << ":"<< nun->tm_min<< ":"<<nun->tm_sec ;
    AppendToConfigEndl();
    configstream<< "Type of Measurement: " << type ;
    AppendToConfigEndl();
    //configstream<< "DAC settings " << std::endl;
}

bool WriteToFile::Close()
{

    flush(configstream);
    flush(datastream);
    configfile.close();
    datafile.close();
    if(datafile.openMode()==0 || configfile.openMode()==0)
    {
        return true;
    }
    else
    {
    return false;
    }
}

void WriteToFile::AppendToConfig(QString data)
{
    configstream << data;
}

//void WriteToFile::AppendToConfig(TMrfData_Chain2LTC2604 &data)
//{
//   // std::map<std::string, std::map<std::string, TConfItem> >::const_iterator iter;
//   // std::map<std::string, TConfItem>::const_iterator iter2;
//   // for (iter = data.getLTCIteratorBegin(); iter != data.getLTCIteratorEnd(); ++iter) {
//   //     for (iter2 = data.getLTCIteratorBegin(iter); iter2 != data.getLTCIteratorEnd(iter); ++iter2) {
//   //         configstream << iter2->second.value << " ";
//   //     }
//   // }

//    std::map<std::string, std::map<std::string, TConfItem> >::const_iterator iter;
//    std::map<std::string, TConfItem>::const_iterator iter2;

//    for (iter = data.getLTCIteratorBegin(); iter !=  data.getLTCIteratorEnd(); ++iter) {
//        for (iter2 = iter->second.begin(); iter2 != iter->second.end(); ++iter2) {
//                configstream << iter2->second.value << " ";
//            }

//    }
//}

void WriteToFile::AppendToConfig(TMrfDataAdv1D &data)
{
        std::map<std::string, TConfItem>::const_iterator iter;
        for (iter = data.getItemIteratorBegin(); iter != data.getItemIteratorEnd(); ++iter) {
            configstream << iter->second.value << " ";
        }
         AppendToConfigEndl();
}

//void WriteToFile::AppendToData(TMrfData_Tpx3Data &data)
//{
//    std::map<std::string, TConfItem>::const_iterator iter;
//    for (iter = data.getItemIteratorBegin(); iter != data.getItemIteratorEnd(); ++iter) {
//        if(iter->first=="leadingedge" or iter->first=="trailingedge")
//        {
//            datastream << graytobin(iter->second.value) << " ";
//        }
//        else
//        {
//            datastream << iter->second.value << " ";
//        }
//        }
//}

void WriteToFile::AppendToData(TMrfDataAdv1D &data)
{
    std::map<std::string, TConfItem>::const_iterator iter;
    for (iter = data.getItemIteratorBegin(); iter != data.getItemIteratorEnd(); ++iter) {
        datastream << iter->second.value << " ";
    }
}

void WriteToFile::AppendToData(TMrfData_8b &data, bool writevector)
{
    if(writevector==false)
    {
        for(int i=0;i< data.getNumWords();i++)
        {
            datastream << data.getWord(i) << " " ;
        }
        endl(datastream);
    }
    else
    {

    }
}

void WriteToFile::AppendToData(TMrfDataAdv1D::itemMap &data)
{
    TMrfDataAdv1D::itemMap::const_iterator iter;
    for (iter = data.begin(); iter != data.end(); ++iter) {
        datastream << iter->second.value << " ";
    }
}

void WriteToFile::AppendToData(QString data)
{
    datastream << data;
}

void WriteToFile::SetIntegerBase(int base)
{
    datastream.setIntegerBase(base);

}

void WriteToFile::AppendToData(int data)
{
    datastream <<  data;
}

void WriteToFile::AppendToConfig(int data)
{
    configstream << data;
    flush(configstream);
}

void WriteToFile::AppendToDataEndl()
{
    endl(datastream);
    CheckFileSizeForNewFile();
}

void WriteToFile::AppendToConfigEndl()
{
    endl(configstream);
}

/*void WriteToFile::AppendToData(TMrfDataAdv1D &data)
{
        std::map<std::string, TConfItem>::const_iterator iter;
        for (iter = data.getItemIteratorBegin(); iter != data.getItemIteratorEnd(); ++iter) {
            datastream << iter->second.value << " ";
        }
}*/

//void WriteToFile::AppendToData(TMrfData_Chain2LTC2604 &data)
//{
//   // std::map<std::string, std::map<std::string, TConfItem> >::const_iterator iter;
//   // std::map<std::string, TConfItem>::const_iterator iter2;
//   // for (iter = data.getLTCIteratorBegin(); iter != data.getLTCIteratorEnd(); ++iter) {
//   //     for (iter2 = data.getLTCIteratorBegin(iter); iter2 != data.getLTCIteratorEnd(iter); ++iter2) {
//   //         configstream << iter2->second.value << " ";
//   //     }
//   // }

//    std::map<std::string, std::map<std::string, TConfItem> >::const_iterator iter;
//    std::map<std::string, TConfItem>::const_iterator iter2;

//    for (iter = data.getLTCIteratorBegin(); iter !=  data.getLTCIteratorEnd(); ++iter) {
//        for (iter2 = iter->second.begin(); iter2 != iter->second.end(); ++iter2) {
//                datastream << iter2->second.value << " ";
//            }

//    }
//}

bool WriteToFile::CheckFileSizeForNewFile()
{
    flush(datastream);
    //std::cout << "filesize " << filesize << " datafile.size " << datafile.size() << std::endl;
    if (datafile.size() > filesize)
    {
        datafile.close();
        QString newfilename;
        newfilename.append(filename);

        filename_datastream.clear();
        filename_datastream.append(newfilename);
        filename_datastream.append("-data");
        filename_datastream.append("--");
        filename_datastream.append(QString::number(i));
        i++;
        filename_datastream.append(".txt");
        datafile.setFileName(filename_datastream);
        if(!datafile.open(QIODevice::WriteOnly|QIODevice::Append))
        {return false;}

        datastream.setDevice(&datafile);
        return true;
    }
    return true;
}

void WriteToFile::SetFileSize(int byte)
{
    filesize = byte;
}

int WriteToFile::GetFileSize()
{
    return filesize;
}
