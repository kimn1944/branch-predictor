#include <iostream>
using namespace std;
int main() {
	int opCTR = 0;
	int result = 0;
	for(int i=0; i<=10000; i++) {
		opCTR++;
		if ( opCTR==0 ) result+=i;
		else if ( opCTR==1 ) result-=i;
		else if ( opCTR==2 ) result=result*i;
		else {
			result=result|i;
			opCTR=0;
		}
	}
        cout << "Result is: " << result << endl;
	return 0;	
}
