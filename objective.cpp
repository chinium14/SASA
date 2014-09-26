
/**********************************************************************************************************/
/*This is a program to calculate solvent accessible surface area for Karanicolas and Brooks Go-like model.*/
/*Reference paper: Shoshana J. Wodak and Joel Janin, Analytical approximation to the accessible surface   */
/*area of proteins, PNAS, 77, 1980                                                                        */
/*Authorized by Shuai Wei 6/13/2014                                                                       */
/**********************************************************************************************************/

#define MAIN
#include "defines.h"

int vdw_radii(vector<double>&, const vector<string>&, int);
int sasa(const string, const string, double, double);
int main(int argc, char** argv)
{  
   
   if (argc != 5) {
      cout << "argv[1] is the file type: either \"crd\" or \"pdb\"." <<endl;
      cout << "argv[2] is the file name of an all-atom <pdb_id>.pdb or a Go-like <pdb_id>.crd." <<endl;
      exit(EXIT_FAILURE);
   }
  /*Open a pdb or crd file for inputs*/  
   string file_type = argv[1];
   string file_input =  argv[2];
   double param_a = atof(argv[3]);
   double param_b = atof(argv[4]);
   int sasa_out = sasa(file_type, file_input, param_a, param_b);
}
