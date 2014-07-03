#include "defines.h"

double atom_mass(string a, string b){
   const int num_atom_type = 6;
   string atom_type[num_atom_type] = {"C", "O", "N", "S", "H", "P"};
   double mass[num_atom_type] = {12.011, 15.9994, 14.0067, 32.06, 1.0079, 30.97376};
   for (int i =0; i<num_atom_type; i++){
      if(!a.compare(atom_type[i])) {
         return mass[i];
         cout << a << endl;
         break;
      }
   }
   cout << "Atom type " << a <<" not defined in atom_mass table but found in file "<< b <<endl;
   return 1.0;
}
