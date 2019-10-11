#include <iostream>
using namespace std;
unsigned int fib (unsigned int n) {
	if(n==0||n==1) return n;
	else return fib(n-1)+fib(n-2);
}
int main() {
	unsigned int n = 18;
	cout << "Fibonacci 18 is: "<< fib(n) << endl;
	return 0;
}
