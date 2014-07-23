/*============================================================*/
/* mrf_confitem.cpp                                           */
/* MVD Readout Framework Configuration Item                   */
/*                                               M.C. Mertens */
/*============================================================*/


#include "mrf_confitem.h"


TConfItem::TConfItem()
: value(0), position(0), length(0), min(0), max(0), flags(0)
{
}

/*
TConfItem::TConfItem(const mrf::registertype value, const u_int32_t position, const u_int32_t length)
: value(value), position(position), length(length), user1(0), user2(0)
{
}
*/

TConfItem::TConfItem(const mrf::registertype value, const u_int32_t position, const u_int32_t length)
: value(value), position(position), length(length), min(0), max((1 << length) - 1), flags(0)
{
}

TConfItem::TConfItem(const mrf::registertype value, const u_int32_t position, const u_int32_t length, const u_int32_t min, const u_int32_t max, const u_int32_t flags)
: value(value), position(position), length(length), min(min), max(max), flags(flags)
{
}



