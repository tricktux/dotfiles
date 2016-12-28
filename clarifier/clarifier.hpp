#ifndef _CLARIFER_H_
#define _CLARIFER_H_

#include <cstdlib>
#include <cstring>
#include <iostream>
#include <iomanip>
#include <libconfig.h++>

#define OPT_MILLBALANCE "MillMaterialBalance"

class MaterialBalance
{
public:
	int iGrindingRateTmCaneDay;
	double dPolCane;
	double dFiberCane;
	double dMillPollExtraction;
	double dImbibitionCane;
	double dMoistureBagasse;
	double dMixedJuicePurity;
	double dLastRollJuice_Brix;
	double dLastRollJuice_Purity;
};

class ConfigFile
{
	libconfig::Config filecfg;
public:
	ConfigFile(const char *pConfigFileName)
	{
		if ((pConfigFileName == 0) || (pConfigFileName[0] == 0))
			throw "ConfigFile(): Bad Config File Name";
		filecfg.readFile(pConfigFileName);
	}

};

#endif
