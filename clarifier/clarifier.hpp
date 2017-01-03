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
public:
	libconfig::Config filecfg;

	ConfigFile(const char *pConfigFileName)
	{
		if ((pConfigFileName == 0) || (pConfigFileName[0] == 0))
			throw "ConfigFile(): Bad Config File Name";
		try{ filecfg.readFile(pConfigFileName); }
		catch (const libconfig::FileIOException &fioex)
		{
			std::cerr << "ConfigFile(): I/O error while reading file.\n";
			throw fioex;
		}
		catch (const libconfig::ParseException &pex)
		{
			std::cerr << "ConfigFile(): Parse error at " << pex.getFile() << ":" << pex.getLine() << " - " << pex.getError() << std::endl;
			throw pex;
		}
	}

	void GetMainOptions()
	{
		const libconfig::Setting &settRoot = filecfg.getRoot();
		for (auto &&setting : settRoot)
		{
			std::cout << setting.getPath() << std::endl;
			if (setting.isGroup())
			{
				for (auto &&sett : setting)
				{
					std::cout << sett.getPath() << std::endl;
					if (sett.isGroup())
					{
						for (auto &&s : sett)
							std::cout << s.getPath() << std::endl;
					}
				}
			}
		}
	}

};

#endif
