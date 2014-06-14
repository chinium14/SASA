/*Build up a checkout table of van der waals radii for residue types*/
#include "defines.h"

int vdw_radii(vector<double>& radii, string * resi_type, int size){
   string types[20] = {"ALA","ARG","ASN","ASP","CYS","GLN","GLU","GLY","HIS","ILE",
                       "LEU","LYS","MET","PHE","PRO","SER","THR","TRP","TYR","VAL"};
   double values[20] = {5.5491, 10.1201, 7.3412, 7.3823, 6.3746, 8.4633, 8.4108, 4.5417, 8.6180, 7.7378,
                        8.0562, 9.0014, 8.4121, 9.1289, 6.6179, 6.2183, 6.8406, 9.9918, 9.7016, 7.0256}; 
//   double values[20] = {5.5, 7.35, 6.4, 6.3, 5.9, 6.7, 6.7, 5.0, 6.8, 6.9,
//                        6.9, 6.9, 6.8, 7.35, 6.3, 5.7, 6.3, 7.4, 7.7, 6.5};
   for (int i= 0; i < size; i++){
      for (int j = 0; j < 20; j++){
         if (strcmp(resi_type[i].c_str(), types[j].c_str())==0){
            radii[i] = values[j];
            break;
            }
      }
   }
   return 1;
}

