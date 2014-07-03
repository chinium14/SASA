/**********************************************************************************************************/
/*This is a program to calculate density distribution of residue-residue distance in the term of C-alpha  */
/*or the residue center of mass.                                                                          */
/*Authorized by Shuai Wei 6/24/2014                                                                       */
/**********************************************************************************************************/

#define MAIN
#include "defines.h"

double atom_mass(string, string);

int main(int argc, char** argv)
{
   if (argc != 2) {
      cout << "argv[1] is the pdb file name." <<endl;
      exit(EXIT_FAILURE);
   }
  /*Open a pdb file for inputs*/  
   string file_input =  argv[1];
   string pdb_id = file_input.substr(0,file_input.length()-4);
   string file_output = "Dist_Hist/dist_ca_"+ pdb_id + ".dat";
   string file_output2 = "Dist_Hist/dist_center_"+ pdb_id + ".dat";
   ifstream fp; 
   ofstream fp_out;
   ofstream fp_out2;
   fp.open(file_input.c_str());
   int num_resi = 0;
   int count = 0;
   int count_atom = 0;
   string junk;
   vector<string> resi_type(0); 
   vector< vector<double> > coords(0, vector<double>(3));
   vector< vector<double> > coords_center(0, vector<double>(3));

   if (fp.is_open()){
      string temp;
      string temp_type;
      int resi_id;
      int old_id = 1;
      string is_ca;
//      cout << "Coord of c_a" <<endl;
      while (!fp.eof()){
         vector<double> coor_temp(3);
         fp >> temp;
         if (!temp.compare("ATOM")) {
            fp >> junk; fp >> is_ca;
            if (!is_ca.compare("CA")){
               fp >> temp_type;
               temp_type = temp_type.substr(temp_type.length()-3,3);
               resi_type.push_back(temp_type); fp >> junk; fp>>junk;
//               cout << "resi_type["<<count<<"] = " << resi_type[count] << "\t";
               for (int j= 0; j<3; j++){ 
                  fp >> coor_temp[j];
       //              cout << coor_temp[j] << "\t";
               }// for
       //           cout << "with count = "<< count << endl;
                  
               coords.push_back(coor_temp);
//               for (int j = 0; j<3; j++) cout << coords[count][j] << "\t";
//               cout << endl;
               getline(fp, junk);
               ++count;
            }else{
               getline(fp,junk);
            }
         }else{
            getline(fp,junk);
         }
      }//while
      num_resi = count;
//      cout << "num_resi = " << num_resi <<endl;
      fp.clear();
      fp.seekg(0, std::ios::beg); // rewind
      string atom_type;
      vector<double> coords_resi(3);
//      cout << "Check point at line 73."<< endl;    
 
      count = 0;
      double mass_sum = 0.0;
      double atom_mass_temp = 0.0;
//      cout << "Coord of c_center" <<endl;
      while (!fp.eof()){
      //   cout << "Check point at line 75."<< endl;    
         double coor_temp;
         fp >> temp;
         if (!temp.compare("ATOM")) {
            fp >> junk; fp >> atom_type;
            atom_type =  atom_type.substr(0,1);
            atom_mass_temp = atom_mass(atom_type, file_input); 
            fp >> temp_type;
            temp_type = temp_type.substr(temp_type.length()-3,3);
 //           cout << "temp_type is " <<temp_type <<endl;
            fp >> junk; fp >> resi_id;
            if ( (resi_id != old_id)  && count_atom >0){
               old_id = resi_id;
                  // cout << "resi_type["<<count<<"] = " << resi_type[count] << "\t";
               for (int k =0; k <3; k++) coords_resi[k] /= mass_sum;
               coords_center.push_back(coords_resi);
               for (int k =0; k <3; k++) coords_resi[k] = 0;
               mass_sum =0;


//               cout<< "count = "<< count << "\t coords_center =";
//               for (int j = 0; j<3; j++) cout<< coords_center[count][j] << "\t";
//               cout << endl;
            //   cout << "Check point at line 90."<< endl;    
       
               for (int j= 0; j<3; j++){ 
                  fp >> coor_temp;
                  coords_resi[j] += coor_temp * atom_mass_temp;
               }
               getline(fp,junk);
               count_atom = 1;
               ++count;
            }       
            else{
               ++count_atom;
               mass_sum += atom_mass_temp;
                  // cout << "resi_type["<<count<<"] = " << resi_type[count] << "\t";
               for (int j= 0; j<3; j++){
                  fp >> coor_temp;
                  coords_resi[j] += coor_temp * atom_mass_temp;
               }
               getline(fp,junk);
            } // if the same residue
         }// if "ATOM"
         else if(!temp.compare("TER")){
            for (int k =0; k <3; k++) coords_resi[k] /= mass_sum;
            coords_center.push_back(coords_resi);
            for (int k =0; k <3; k++) coords_resi[k] = 0;
            mass_sum =0;
            count_atom = 0;
            ++count;   
         }// if "TER"
      }//while   
//      cout << "Check point at line 111."<< endl;    
//      cout << "Number of centers = " << coords_center.size()<<endl; 
   fp.close();
  
  /********************/
  /*Do the calculation*/
  /********************/
   fp_out.open(file_output.c_str());
   fp_out2.open(file_output2.c_str());

   vector<double> d(0);
   vector<double> d_center(0);
   int count_dist = 0;
//   cout << "num_resi = "<< num_resi << endl;    
   for (int i = 0; i < num_resi -1; i++){
      for (int j = i+1; j < num_resi; j++){
//            cout << "count_dist = " <<count_dist << "\t i = "<< i <<"\t j = " <<j <<endl; 
            d.push_back(sqrt((coords[i][0] - coords[j][0])*(coords[i][0] - coords[j][0]) +  
                            (coords[i][1] - coords[j][1])*(coords[i][1] - coords[j][1]) + 
                            (coords[i][2] - coords[j][2])*(coords[i][2] - coords[j][2])));
//            cout << d[count_dist] << "\t";
            d_center.push_back(sqrt((coords_center[i][0] - coords_center[j][0])*(coords_center[i][0] - coords_center[j][0]) +  
                            (coords_center[i][1] - coords_center[j][1])*(coords_center[i][1] - coords_center[j][1]) + 
                            (coords_center[i][2] - coords_center[j][2])*(coords_center[i][2] - coords_center[j][2]))); 
//            cout << d_center[count_dist]<< endl;
            if (d[count_dist] <10) fp_out << d[count_dist] << endl;
            if (d_center[count_dist] <10) fp_out2 << d_center[count_dist] << endl;
            ++count_dist;
      }
   }// for
//   cout << "Check point at line 133."<< endl;    
 //  plot(density(d));
//   plot(density(d_center));
   fp_out.close();
   fp_out2.close();
//     cout << "check point line 94" << endl; 
   } // if fp.is_open
  
   return 0;
}

