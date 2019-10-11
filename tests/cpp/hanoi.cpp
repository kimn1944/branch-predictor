#include <iostream>
using namespace std;
void Hanoi(int numberOfBlocks, int startPole, int destPole, int openPole){
      if( numberOfBlocks > 0 ){
             Hanoi(numberOfBlocks - 1, startPole, openPole, destPole);
             cout << "Moving " << numberOfBlocks << " from " << startPole;
             cout << " to " << destPole << endl;
             Hanoi(numberOfBlocks - 1, openPole, destPole, startPole);
      }
}
int main () {
	Hanoi(5,1,3,2);
	return 0;
}
