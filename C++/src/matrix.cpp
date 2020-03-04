#include<iostream>
#include<fstream>
#include<stdlib.h> 
#include<string.h>
#include <ctime>
using namespace std;

#define Maxnum 510
struct Matrix {
	int value[Maxnum][Maxnum];
	int row;
	int col;
};
struct Matrix* read_matrix(ifstream& fin)
{
	struct Matrix* temp = (struct Matrix*)malloc(sizeof(struct Matrix));
	fin >> temp->row;
	fin >> temp->col;

	for (int i = 0; i < temp->row; i++)
	{
		for (int j = 0; j < temp->col; j++)
		{
			fin >> temp->value[i][j];
		}
	}
	return temp;
}
void Print(struct Matrix* temp)
{
	for (int i = 0; i < temp->row; i++)
	{
		for (int j = 0; j < temp->col; j++)
		{
			printf("%d ", temp->value[i][j]);
		}
		printf("\n");
	}
}
void write2file(struct Matrix* temp)
{
	ofstream outfile("result.txt");
	outfile << temp->row << " " << temp->col << endl;
	for (int i = 0; i < temp->row; i++)
	{
		for (int j = 0; j < temp->col; j++)
		{
			outfile << temp->value[i][j] << " ";
		}
		outfile << endl;
	}
	outfile.close();
}
int main()
{
	printf("Matrix multiplication implemented by C++.\n");
	struct Matrix* ans = (struct Matrix*)malloc(sizeof(struct Matrix));
	ifstream fin("data.txt");
	struct Matrix* A = read_matrix(fin);
	struct Matrix* B = read_matrix(fin);
	fin.close();
	//	Print(A);
	//	Print(B);
	ans->row = A->row;
	ans->col = B->col;
	memset(ans->value, 0, sizeof(int));
	int t = clock();
	for (int i = 0; i < ans->row; i++)
	{
		for (int j = 0; j < ans->col; j++)
		{
			for (int times = 0; times < A->col; times++)
				ans->value[i][j] += A->value[i][times] * B->value[times][j];
		}
	}
    t = clock() - t;
    t = (double)t / CLOCKS_PER_SEC * 1000;
    cout <<"Matrix "<< A->row <<"¡Á"<<A->col<<" and "<< B->row<<"¡Á"<<B->col<<" cost: " << t << " ms." << endl;
	// Print(ans);
	write2file(ans);
	system("pause"); 
	return 0;
}
