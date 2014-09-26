#ifndef MRFDATA_TOPIX4CONFIG_H
#define MRFDATA_TOPIX4CONFIG_H

#include "mrfdataadv1d.h"
#include <stdint.h>

namespace topix4_command {
        static const u_int32_t nooperation = 0;
        static const u_int32_t normaloperation = 1;
        static const u_int32_t configmodeoperation = 2;
        static const u_int32_t columnselection = 3;
        static const u_int32_t writepixelconfiguration = 4;
        static const u_int32_t readpixelconfiguration = 5;
        static const u_int32_t movetonextpixel = 7;
        static const u_int32_t storedataccr0 = 32;
        static const u_int32_t readdataccr0 = 48;
        static const u_int32_t storedataccr1 = 33;
        static const u_int32_t readdataccr1 = 49;
        static const u_int32_t storedataccr2 = 34;
        static const u_int32_t readdataccr2 = 50;
        static const u_int32_t storedataccr3 = 35;
        static const u_int32_t readdataccr3 = 51;
}

namespace topix4_ccrnumber {
        static const std::string ccr0 = "CommandCCR0";
        static const std::string ccr1 = "CommandCCR1";
        static const std::string ccr2 = "CommandCCR2";
}

class TMrfData_Topix4Config : public TMrfDataAdv1D
{
public:
      TMrfData_Topix4Config(const u_int32_t& blocklength = bitsinablock, const u_int32_t& defaultindex = 0, const u_int32_t& defaultstreamoffset = 0, const u_int32_t& defaultvalueoffset = 0, const bool& defaultreverse = false, const bool& defaultstreamreverse = false);

      //From TMrfDataAdvBase
      virtual void initMaps();
      virtual void assemble();

      virtual void setCommand(std::string ccr, u_int32_t command);

      uint32_t getCounterMode();

};

#endif // MRFDATA_TOPIX4CONFIG_H
