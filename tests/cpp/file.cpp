#include <iostream>
#include <fstream>
#include <istream>
using namespace std;
int main() {
	ofstream outputFile("out.txt");
	outputFile << "##########################################\n";
	outputFile << "##		ECE201/401		##\n";
	outputFile << "##########################################";
	return 0;
}
