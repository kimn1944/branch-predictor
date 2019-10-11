#include <iostream>
#include <vector>
using namespace std;

bool func (int i, int j) { return i<j; }

int main () {
  int a[10] = {78, 23, 45, 12, 3, 101, 7, 4, 90, 17};
  vector<int> rank (a, a+10);
  vector<int>::iterator it;
  sort (rank.begin(), rank.end(), func);
  for (it=rank.begin(); it!=rank.end(); ++it) {
	cout << " " << *it;
  }
  cout << endl;
  return 0;
}
