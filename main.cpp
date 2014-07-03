/**********************************************************************************************************/
/*This is a program to calculate solvent accessible surface area for Karanicolas and Brooks Go-like model.*/
/*Reference paper: Shoshana J. Wodak and Joel Janin, Analytical approximation to the accessible surface   */
/*area of proteins, PNAS, 77, 1980                                                                        */
/*Authorized by Shuai Wei 6/13/2014                                                                       */
/**********************************************************************************************************/

#define MAIN
#include "defines.h"

int vdw_radii(vector<double>&, const vector<string>&, int);

int main(int argc, char** argv)
{
   if (argc != 3) {
      cout << "argv[1] is the file type: either \"crd\" or \"pdb\"." <<endl;
      cout << "argv[2] is the file name of an all-atom <pdb_id>.pdb or a Go-like <pdb_id>.crd." <<endl;
      exit(EXIT_FAILURE);
   }
  /*Open a pdb or crd file for inputs*/  
   string file_type = argv[1];
   string file_input =  argv[2];
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
   //     cout << "check point line 27" << endl; 
         fp >> num_resi;
//         resi_type = new string[num_resi];
//         string resi_type[num_resi];
         resi_type.resize(num_resi);
         coords.resize(num_resi, vector<double>(3));
         cout << "number of residues is "<< num_resi << endl;
         getline(fp,junk);
  /*Read in residue types and coords*/ 
        // cout << "check point line 36" << endl; 
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
   int found = vdw_radii(radii, resi_type, num_resi);
   if (found != 1) {
      cout <<  "Residue not found when checking radii table." << endl;
      return 2;
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
/*I suspect the read in radii are diameters, so devide them by 2*/
   for (int i =0; i < num_resi; i++) radii[i] /= 2;


   for (int i = 0; i < num_resi; i++){
      S[i] = 4.0 * pi * (radii[i] + r_w) * (radii[i] + r_w);
//      cout << "S["<< i <<"]"<< S[i] << endl;
      multiplier[i] = 1.0;  
//      cout << "x : " << coords[i][0] << "\t y : " << coords[i][1] << "\t z : " << coords[i][2] << endl;
      for (int j = 0; j < num_resi; j++){
         if (j != i){
            double d = sqrt((coords[i][0] - coords[j][0])*(coords[i][0] - coords[j][0]) +  
                            (coords[i][1] - coords[j][1])*(coords[i][1] - coords[j][1]) + 
                            (coords[i][2] - coords[j][2])*(coords[i][2] - coords[j][2]));
//            if (d< (radii[i]+ radii[j]) && d > 4.0) d = (radii[i] + radii[j]);
//            if (d<= 6.0) d = (radii[i] + radii[j])* 0.9;
            if (d< (radii[i]+ radii[j])) d = (radii[i] + radii[j]);
//            if (d > (radii[i] + radii[j]) && d < (radii[i] + radii[j]+ 2*r_w)) d /= 1.03;
            if (d > (radii[i] + radii[j])) d /= 1.048;
//      cout << "d = "<< d << endl;
            double b = pi*(radii[i] + r_w)*(radii[i] + radii[j] + 2.0 * r_w - d)*(1.0 + (radii[j] -radii[i])/d);
            if (b < 0.0) b = 0.0; // b_p could not be negative.
            double b_p = pi*(radii[i] + r_w)*(radii[i] + radii[j] + 2.0 * r_w - s - d)*(1.0 + (radii[j] - s -radii[i])/d);
            if (b_p < 0.0) b_p = 0.0; // b_p could not be negative.
//            cout << "radii are " << radii[i] << " and "<< radii[j] << " and d = "<< d 
//                 << " and r_w =" << r_w <<" and b_p = " << b_p << endl;
            multiplier[i] *=  (1.0 - (b - b_p)/S[i]);
            if (i == 0) 
             // cout << "multiplier[0] = "<< multiplier[0] << endl;
            B[i] += b_p; 
         } //if j != i
      }
      A[i] = S[i]*multiplier[i]; 
//      cout << "multiplier " << i << " equals to " << multiplier[i] <<endl;
//      cout << "A[i] = " << A[i] << ";\t" << "B[i] =" << B[i] << endl;
      if (A[i] > B[i]) {
         A_c += (A[i] -B[i]);  // A_c == 0 if A[i] < B[i]
//         fp_out_resi
//         cout <<"Residue number "<< i <<"\t"<<  (A[i] -B[i]) <<endl;       
         fp_out_resi << i <<"\t"<<  (A[i] -B[i]) <<endl;       
//         cout << "A_c = " << A_c <<endl; 
      }else {
         fp_out_resi << i <<"\t"<<  0.0 <<endl;
      }      
   }// for
//   A_c = (A_c +1304.85) / 1.1436;
//   cout << "checkpoint 107" << endl;
   fp_out_resi.close();
   fp_out.open(file_output.c_str());
//   cout << pdb_id << "\t" << A_c;
   fp_out << pdb_id << "\t" << A_c;
   
   fp.close();
   fp_out.close();
//     cout << "check point line 94" << endl; 
   } // if fp.is_open
  
   return 0;
}

