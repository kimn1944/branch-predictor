#include <iostream>
using namespace std;

int main() {
  	int m1[3][3] = {{1, 1, 1},
		  	{0, 1, 1},
		  	{0, 0, 1}};
	int m2[3][3] = {{2, 0, 3},
			{0, 1, 2},
			{1, 1, 1}};
	int i,j,k;

	cout << "M1=" << endl;
	for (i=0; i<3; i++) {
		for(j=0; j<3; j++) {
			cout << m1[i][j] << " ";
		}
		cout << endl;
	}
	cout << "M2=" << endl;
        for (i=0; i<3; i++) {
                for(j=0; j<3; j++) {
                        cout << m2[i][j] << " ";
                }
                cout << endl;
        }
	cout << "M1 + M2 =" << endl;
        for (i=0; i<3; i++) {
                for(j=0; j<3; j++) {
                        cout << m1[i][j] + m2[i][j] << " ";
                }
                cout << endl;
        }
	cout << "M1 * M2 =" << endl;
        for (i=0; i<3; i++) {
                for(j=0; j<3; j++) {
			int p = 0;
			for(k=0; k<3; k++)
				p += m1[i][k] * m2[k][j];
                        cout << p << " ";
                }
                cout << endl;
        }

}
