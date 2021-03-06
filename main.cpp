/**********************************************************************************************************/
/*This is a program to calculate solvent accessible surface area for Karanicolas and Brooks Go-like model.*/
/*Reference paper: Shoshana J. Wodak and Joel Janin, Analytical approximation to the accessible surface   */
/*area of proteins, PNAS, 77, 1980                                                                        */
/*Authorized by Shuai Wei 6/13/2014                                                                       */
/**********************************************************************************************************/

#define MAIN
#include "defines.h"

int vdw_radii(vector<double>&, vector<double>&, const vector<string>&, int);

int main(int argc, char** argv)
{  
   
   if (argc != 3) {
      cout << "argv[1] is the file type: either \"crd\" or \"pdb\"." <<endl;
      cout << "argv[2] is the file name of an all-atom <pdb_id>.pdb or a Go-like <pdb_id>.crd." <<endl;
/*      cout << "argv[3] is the param_a." <<endl;
      cout << "argv[4] is the param_b." <<endl;
      cout << "argv[3] is the s." <<endl;
*/
      exit(EXIT_FAILURE);
   }
  /*Open a pdb or crd file for inputs*/  
   string file_type = argv[1];
   string file_input =  argv[2];
/*   const double param_a = atof(argv[3]);
   const double param_b = atof(argv[4]);
   const double s = atof(argv[5]);
*/
   string pdb_id = file_input.substr(0,file_input.length()-4);
   string file_output = "sasa_bgo_"+ pdb_id + ".dat";
   string file_output_resi = "sasa_bgo_"+ pdb_id + "_resi.dat";
   ifstream fp; 
   ofstream fp_out;
   ofstream fp_out_resi;
   fp.open(file_input.c_str());
   fp_out_resi.open(file_output_resi.c_str());
   int num_resi = 0;
   int count = 0;
   string junk;
   vector<string> resi_type(0); 
   vector< vector<double> > coords(0, vector<double>(3));

   if (fp.is_open()){
      if (!file_type.compare("crd")){
  /*Read the number of residues and coordinates and residue type for each*/ 
         fp >> num_resi;
//         resi_type = new string[num_resi];
//         string resi_type[num_resi];
         resi_type.resize(num_resi);
         coords.resize(num_resi, vector<double>(3));
         cout << "number of residues is "<< num_resi << endl;
         getline(fp,junk);
  /*Read in residue types and coords*/ 
         string temp;
         while (!fp.eof() && num_resi != count){
           /*The first two columns are junk*/
            fp >> junk; fp >> junk;
           /*The third column is the residue type*/
            fp >> resi_type[count]; 
           /*The fourth column is junk again*/
            fp >> junk; 
           /*The 5,6,7 th columns are coords*/
            for(int i =0; i <3; i++) fp >> coords[count][i];
   //            cout << "check point line 50" << " with count= " << count << endl; 
            /*All rest columes are junk*/
            getline(fp, junk);
            ++count;
         } // while !fp.eof() && num_resi != 0
//     cout << "check point line 53" << endl; 
      } else if (!file_type.compare("pdb")){
         string temp;
         string temp_type;
         string is_ca;
         while (!fp.eof()){
            vector<double> coor_temp(3);
            fp >> temp;
            if (!temp.compare("ATOM")) {
               fp >> junk; fp >> is_ca;
               if (!is_ca.compare("CA")){
                  fp >> temp_type;
                  temp_type = temp_type.substr(temp_type.length()-3,3);
                  resi_type.push_back(temp_type); fp >> junk; fp>>junk;
       //           cout << "resi_type["<<count<<"] = " << resi_type[count] << "\t";
                  for (int j= 0; j<3; j++){ 
                     fp >> coor_temp[j];
       //              cout << coor_temp[j] << "\t";
                  }// for
       //           cout << "with count = "<< count << endl;
                  
                  coords.push_back(coor_temp);
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
  //       cout << "num_resi = " << num_resi <<endl;
      }//if crd or pdb

  /*******************/
  /*Check radii table*/ 
  /*******************/
   vector<double> radii(num_resi); 
   vector<double> param_p(num_resi); 
   vector<double> pij(num_resi-1);
   pij[0] = 1.24310;
   pij[1] = -0.15956;
   pij[2] = 0.65562;
   for (int i = 3; i < (num_resi-1); i++){
      pij[i] = 0.58720; 
   }
   int found = vdw_radii(radii, param_p, resi_type, num_resi);
   if (found != 0) {
      cout <<  "Residue not found when checking radii table." << endl;
      return 1;
   }
    // cout << "check point line 59" << endl; 
  
  /********************/
  /*Do the calculation*/
  /********************/
   vector<double> S(num_resi);
   double A[num_resi] , B[num_resi];
   double A_c = 0;
   std::fill_n(B, num_resi, 0.0);
   
   double multiplier[num_resi];

   double intercept = 0;
   double slope = 1.0;
   

   for (int i = 0; i < num_resi; i++){
//      cout << radii[i] << '\t' << param_p[i] << endl;
      S[i] = 4.0 * pi * (radii[i] + r_w) * (radii[i] + r_w);
//      cout << "S["<< i <<"]"<< S[i] << endl;
      multiplier[i] = 1.0;  
//      cout << "x : " << coords[i][0] << "\t y : " << coords[i][1] << "\t z : " << coords[i][2] << endl;
      for (int j = 0; j < num_resi; j++){
         if (j != i){
            double d = sqrt((coords[i][0] - coords[j][0])*(coords[i][0] - coords[j][0]) +  
                            (coords[i][1] - coords[j][1])*(coords[i][1] - coords[j][1]) + 
                            (coords[i][2] - coords[j][2])*(coords[i][2] - coords[j][2]));
//            if (d < 6.0) d = (radii[i] + radii[j]);
//            if (d > 9.0) d /= 1.04;
            double b = pi*(radii[i] + r_w)*(radii[i] + radii[j] + 2.0 * r_w - d)*(1.0 + (radii[j] -radii[i])/d);
            if (b < 0.0) b = 0.0; // b_p could not be negative.
            double b_p = 0;
//            b_p = pi*(radii[i] + r_w)*(radii[i] + radii[j] + 2.0 * r_w - s - d)*(1.0 + (radii[j] - s -radii[i])/d);
            if (b_p < 0.0) b_p = 0.0; // b_p could not be negative.

            int ij =  abs(i - j) -1;
            multiplier[i] *=  (1.0 - pij[ij]*param_p[i]*(b - b_p)/S[i]);
            B[i] += b_p; 
         } //if j != i
      }
      A[i] = (S[i] * multiplier[i] + intercept)/ slope; 
      if (A[i] > B[i]) {
         A_c += (A[i] -B[i]);  // A_c == 0 if A[i] < B[i]
         fp_out_resi << i <<"\t"<<  (A[i] -B[i]) <<endl;       
      }else {
         fp_out_resi << i <<"\t"<<  0.0 <<endl;
      }      
   }// for
   fp_out_resi.close();
   fp_out.open(file_output.c_str());
   fp_out << pdb_id << "\t" << A_c;
   
   fp.close();
   fp_out.close();
   } // if fp.is_open
  
   return 0;
}

