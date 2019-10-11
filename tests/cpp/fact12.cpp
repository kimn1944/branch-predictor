#include <iostream>
using namespace std;
int main() {
	int a=12;
	long result=1;
	cout << "Compute factorial 12:" << endl;
	for ( int i=1; i<=a; i++) {
		result = result * i;
		cout << result << endl;
	} 
}
