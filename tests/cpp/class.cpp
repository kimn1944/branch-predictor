#include <iostream>
using namespace std;
class CRectangle {
	int x, y;
     public:
	void set_values(int,int);
	int area () {return (x*y);}
};
void CRectangle::set_values (int a, int b) {
	x = a;
	y = b;
}
int main() {
	CRectangle rect;
	rect.set_values (3,4);
	cout << "Rectangle(3,4) area is: " << rect.area() << endl;
	return 0;
}

