/*============================================================*/
/* mrf_writetofile_boost.h                                    */
/* Write data container to file with boost serializer         */
/*                                                 S. U. Esch */
/*============================================================*/

#ifndef MRF_WRITETOFILE_BOOST_H
#define MRF_WRITETOFILE_BOOST_H

#include <time.h>
#include <string>
#include <fstream>
#include "mrfdata_8b.h"
#include "boost/archive/binary_oarchive.hpp"
#include "boost/archive/binary_iarchive.hpp"
#include "boost/serialization/binary_object.hpp"

#include <QString>

/* To write a data container with this class, the data container
 * class needs to be adjusted.
 *
 */



class TMrf_WriteToFile_Boost
{
public:
    TMrf_WriteToFile_Boost();

    u_int32_t getMaxFilesize_MB() const;
    void setMaxFilesize_MB(const u_int32_t &value);
    void writeData(TMrfData_8b *data);
    void setPathName(std::string path);
    void closeFile();
    bool openFile(int mark);

private:
    u_int32_t max_filesize_MB;      // Maximum Filesize in MB
    time_t timestamp;
    struct tm *nun;
    std::ofstream ofs;
    std::string createFileName(int mark);
    QString filename;
    std::string pathname;
    u_int32_t filecounter;

};

#endif // MRF_WRITETOFILE_BOOST_H
