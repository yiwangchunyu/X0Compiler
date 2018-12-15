#include "stdio.h"
#include "string.h"

#define TXMAX 100
#define AL 10
#define LEVMAX 3
#define AMAX 2047
#define STACKSIZE 500

int lev=0;
int tx=0;
int dx=0;
int num;
int size;
int array;
int* array_size;
int array_dim;
char id[AL];

enum object{constant,variable,procedur};
enum type_e{int_t,char_t};
enum object kind;
enum type_e type;

void error(int);

struct table1{
	char name[AL];
	enum object kind;
	enum type_e type;
	int val,adr,size,array,array_dim;
	int *array_size;
	};
struct table1 table[TXMAX+1];

struct procReg1{
int dx0;
int tx0;
int cx0;
};
struct procReg1 procReg;

void enter(enum object k){
	tx=tx+1;
	strcpy(table[tx].name,id);
	table[tx].kind=k;
	switch(k)
		{
		case constant:
			if(num>AMAX){
				error(31);
				num=0;
				}
			table[tx].val=num;
			break;
			
		case variable:		
			table[tx].adr=dx;
			table[tx].type=type;
			if(array){
				table[tx].array=array;
				table[tx].array_dim=array_dim;
				table[tx].array_size=array_size;
				int len = 1, i = 0;
				for(i=0;i<array_dim;i++)
				{
					len*=array_size[i];
				}
				dx = dx+len;
			}else{
				dx++;
			}
			break;
		case procedur:
			break;

		}
}


int position(char id[10])
{
	int i;
	strcpy(table[0].name,id);
	i=tx;
	while(strcmp(table[i].name,id)!=0)
		i--;
	return i;
}

void printTable(int tofile)
{
	int i;
	char kind[15];
	char type[15];
	int array_size0=0;
	printf("****************************************************************************************************************************************************\n");
	printf("table:\n");
	printf("%15s%15s%15s%15s%15s%15s%15s%15s%15s\n", "name", "kind", "val", "type", "adr", "size", "array", "array_dim", "array_size");
	for(i=0;i<=tx;i++)
	{
		switch(table[i].kind)
		{
			case constant:
				strcpy(kind, "constant");
				break;
			case variable:
				strcpy(kind, "variable");
				break;
			case procedur:
				strcpy(kind, "procedur");
				break;
		}
		switch(table[i].type)
		{
			case int_t:
				strcpy(type, "int");
				break;
			case char_t:
				strcpy(type, "char");
				break;
		}
		if(table[i].array)
		{
			array_size0 = table[i].array_size[0];
		}
		printf("%15s%15s%15d%15s%15d%15d%15d%15d%15d\n", table[i].name, kind, table[i].val, type, table[i].adr, table[i].size, table[i].array, table[i].array_dim, array_size0);
	}
	printf("****************************************************************************************************************************************************\n");
}