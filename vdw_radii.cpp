/*Build up a checkout table of van der waals radii for residue types*/
#include "defines.h"

int vdw_radii(vector<double>& radii, vector<double>& param_p, const vector<string>& resi_type, int size){
   string types[20] = {"ALA","ARG","ASN","ASP","CYS","GLN","GLU","GLY","HSD","ILE",
                       "LEU","LYS","MET","PHE","PRO","SER","THR","TRP","TYR","VAL"};
//   double values[20] = {5.5491, 10.1201, 7.3412, 7.3823, 6.3746, 8.4633, 8.4108, 4.5417, 8.6180, 7.7378,
//                        8.0562, 9.0014, 8.4121, 9.1289, 6.6179, 6.2183, 6.8406, 9.9918, 9.7016, 7.0256}; 
//   double values[20] = {5.5, 7.35, 6.4, 6.3, 5.9, 6.7, 6.7, 5.0, 6.8, 6.9,
//                        6.9, 6.9, 6.8, 7.35, 6.3, 5.7, 6.3, 7.4, 7.7, 6.5};
   double values[20] = {4.01256, 4.62059, 4.28348, 4.27733, 3.74826, 4.35527, 4.29564, 3.86518, 4.32923, 4.57110,\
                        4.55731, 4.16101, 4.49251, 4.69671, 4.51078, 4.12788, 4.15639, 5.05033, 4.51586, 4.28142}; 
   double p_list[20] = {0.99042, 0.71552, 0.87896, 0.88912, 0.95123, 0.79978, 0.77849, 1.05203, 0.79982, 1.04589,\
                        1.02160, 0.65241, 0.97725, 1.02315, 0.98890, 0.98230, 0.89542, 1.01999, 0.86185, 0.98227}; 

  map<string, double> radii_map; 
  map<string, double> param_p_map; 

  for (int k=0; k<20; k++){
     radii_map.insert(std::pair<string,double>(types[k],values[k]));
     param_p_map.insert(std::pair<string,double>(types[k],p_list[k]));
  }
 
  for (int i=0; i < size; i++){
     radii[i] = radii_map.find(resi_type[i].c_str())->second;
     param_p[i] = param_p_map.find(resi_type[i].c_str())->second;
  }

/*
   for (int i= 0; i < size; i++){
      for (int j = 0; j < 20; j++){
         if (strcmp(resi_type[i].c_str(), types[j].c_str())==0){
            radii[i] = values[j];
            break;
            }
      }
   }
*/
  return 0;
}

