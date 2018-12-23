#include "table.h"
#define CXMAX 1000
#define LOOPMAX 50

int cx,cx1,cx2;
int err;

enum fct{lit,opr,lod,sto,cal,ini,jmp,jpc,ext};
enum inloop{brk,ctn};
char *mnemonic[9]={"lit","opr","lod","sto","cal","ini","jmp","jpc", "ext"};

FILE *fa;
FILE *fa1,*fa2;
FILE *fin,*fout;
char fname[AL];

enum listswitcher{false,true};
enum listswitcher listswitch;

struct instruction{
	enum fct f;
	int l;
	int a;
	int isd;
	double d;
};
struct instruction code[CXMAX+1];

struct loop{
	int cx;
	enum inloop type;
	int level;
};
struct loop loopReg[LOOPMAX];
int loop_pos=0;
int loop_level=0;

int become_level=0;
int pop_stack=0;

struct stack{
	int vi;
	double vd;
	enum type_e type;
};

void error(int n){
	printf("***");
	fputs("***",fa1);
	printf("error%d",n);
	fprintf(fa1,"error%d",n);
}

void code_error(char * s)
{
	printf("%s\n", s);
	exit(1);
}
void _gen(enum fct x,int y,int z,int isd,double d)
{
	if(cx>CXMAX)
		printf("program too long!");
	code[cx].f=x;
	code[cx].l=y;
	code[cx].a=z;
	code[cx].isd=isd;
	code[cx].d=d;
	cx++;
}

void gen(enum fct x,int y,int z)
{
	_gen(x,y,z,0,0.0);
}

void listcode( )
{
	int i;
	if(listswitch==true){
		printf("****************************************************************************************************************************************************\n");
		printf("pcode:\n");
		printf("%15s %15s %15s %15s %15s %15s\n","id","f","l","a","isd","d");
		for(i=0;i<=cx-1;i++){
			printf("%15d %15s %15d %15d %15d %15lf\n",i,mnemonic[(int)code[i].f],code[i].l,code[i].a,code[i].isd,code[i].d);
			//fprintf(fa,"%2d	%5s	%3d	%5d\n",i,mnemonic[(int)code[i].f],code[i].l,code[i].a);
			}
		printf("****************************************************************************************************************************************************\n");
	}
}


int base(int l,int b,struct stack s[STACKSIZE])
{
	int b1;
	b1=b;
	while(l>0){
		b1=s[b1].vi;
		l=l-1;
	}
	return b1;
}

void interpret()
{
	int p=0;
	int b=0;
	int t=0;
	struct instruction i;
	/*int s[STACKSIZE];*/
	struct stack s[STACKSIZE];
	printf("********Start X0*********\n");
 	//fprintf(fa1,"********Start PL/0*********\n");
	s[0].vi=0;s[0].vd=0.0;s[0].type=int_t;
	s[1].vi=0;s[1].vd=0.0;s[1].type=int_t;
	s[2].vi=0;s[2].vd=0.0;s[2].type=int_t;
	s[3].vi=0;s[3].vd=0.0;s[3].type=int_t;
	int ti=tx;
	while(ti>=0){
		if(table[ti].kind==variable){
			if(table[ti].array){
				int len = array_len(table[tx].array_size);
				int tj;
				if(table[ti].type==double_tt){
					for(tj=table[ti].adr;tj<(table[ti].adr+len);tj++){
						s[tj].type=double_tt;
					}
					
				}else{
					for(tj=table[ti].adr;tj<(table[ti].adr+len);tj++){
						s[tj].type=int_t;
					}
				}

			}else{
				if(table[ti].type==double_tt){
					s[table[ti].adr].type=double_tt;
				}else{
					s[table[ti].adr].type=int_t;
				}
			}
		}
		ti--;
	}
	do{
		i=code[p];
		p=p+1;
		switch(i.f){
			case lit:
				t=t+1;
				if(i.isd){
					s[t].type=double_tt;
					s[t].vd=i.d;
				}else{
					s[t].type=int_t;
					s[t].vi=i.a;
				}
				break;
			case opr:
				switch(i.a){
					case 0:
						p=0;
						break;
					case 1:
						if(i.isd){
							s[t].type=double_tt;
							s[t].vd=-s[t].vd;
						}else{
							s[t].type=int_t;
							s[t].vi=-s[t].vi;
						}
						break;
					case 2:
						t=t-1;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vd+s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].type=double_tt;
							s[t].vd=s[t].vd+s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vi+s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].type=int_t;
							s[t].vi=s[t].vi+s[t+1].vi;
						}
						break;
					case 3:
						t=t-1;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vd-s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].type=double_tt;
							s[t].vd=s[t].vd-s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vi-s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].type=int_t;
							s[t].vi=s[t].vi-s[t+1].vi;
						}
						break;
					case 4:
						t=t-1;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vd*s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].type=double_tt;
							s[t].vd=s[t].vd*s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vi*s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].type=int_t;
							s[t].vi=s[t].vi*s[t+1].vi;
						}
						break;
					case 5:
						t=t-1;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vd/s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].type=double_tt;
							s[t].vd=s[t].vd/s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].type=double_tt;
							s[t].vd=s[t].vi/s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].type=int_t;
							s[t].vi=s[t].vi/s[t+1].vi;
						}
						break;
					case 6:
						if(s[t].type==double_tt){
							code_error("top of the stack is a double so that we do not know if it is odd.");
						}
						if((s[t].vi)%2==0)
							s[t].vi=0;
						else
							s[t].vi=1;
						break;
					case 8:
						t=t-1;
						if(s[t].type==double_tt||s[t+1].type==double_tt){
							code_error("tops of the stack are doubles so that we do not know if one is equals to another.");
						}
						if(s[t].vi==s[t+1].vi)
							s[t].vi=1;
						else
							s[t].vi=0;
						break;
					case 9:
						t=t-1;
						if(s[t].type==double_tt||s[t+1].type==double_tt){
							code_error("tops of the stack are doubles so that we do not know if one is equals to another.");
						}
						if(s[t].vi!=s[t+1].vi)
							s[t].vi=1;
						else
							s[t].vi=0;
						break;
					case 10:
						t--;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].vi=s[t].vd<s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].vi=s[t].vd<s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].vi=s[t].vi<s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].vi=s[t].vi<s[t+1].vi;
						}
						s[t].type=int_t;
						break;
					case 11:
						t--;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].vi=s[t].vd>=s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].vi=s[t].vd>=s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].vi=s[t].vi>=s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].vi=s[t].vi>=s[t+1].vi;
						}
						s[t].type=int_t;
						break;
					case 12:
						t=t-1;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].vi=s[t].vd>s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].vi=s[t].vd>s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].vi=s[t].vi>s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].vi=s[t].vi>s[t+1].vi;
						}
						s[t].type=int_t;
						break;
					case 13:
						t=t-1;
						if(s[t].type==double_tt&&s[t+1].type==double_tt){
							s[t].vi=s[t].vd<=s[t+1].vd;
						}else if(s[t].type==double_tt&&s[t+1].type==int_t){
							s[t].vi=s[t].vd<=s[t+1].vi;
						}else if(s[t].type==int_t&&s[t+1].type==double_tt){
							s[t].vi=s[t].vi<=s[t+1].vd;
						}else if(s[t].type==int_t&&s[t+1].type==int_t){
							s[t].vi=s[t].vi<=s[t+1].vi;
						}
						s[t].type=int_t;
						break;
					case 14:
						if(s[t].type==double_tt){
							printf("%lf",s[t].vd);
							fprintf(fa2,"%lf",s[t].vd);
						}else{
							printf("%d",s[t].vi);
							fprintf(fa2,"%d",s[t].vi);
						}
						t=t-1;
						break;
					case 15:
						printf("\n");
						fprintf(fa2,"\n");
						break;
					case 16:
						t=t+1;
						s[t].type=int_t;
						printf("?");
						fprintf(fa2,"?");
						if(i.isd){
							scanf("%lf",&s[t].vd);
							fprintf(fa2,"%lf",s[t].vd);
						}else{
							scanf("%d",&s[t].vi);
							fprintf(fa2,"%d",s[t].vi);
						}
						break;
					case 17:	/*写字符*/
						if(s[t].type==double_tt){
							code_error("top of the stack is a double so that we cannot write a charater.");
						}
						printf("%c",s[t].vi);
						fprintf(fa2,"%c",s[t].vi);
						t=t-1;
						break;
					case 18:	/*写栈顶值所在的数据单元int*/
						if(s[t].type==double_tt){
							code_error("top of the stack is a double so that we cannot write from a double address.");
						}
						if(s[s[t].vi].type==double_tt){
							printf("%lf",s[s[t].vi].vd);
							fprintf(fa2,"%lf",s[s[t].vi].vd);
						}else{
							printf("%d",s[s[t].vi].vi);
							fprintf(fa2,"%d",s[s[t].vi].vi);
						}
						t=t-1;
						break;
					case 19:	/*写栈顶值所在的数据单元char*/
						if(s[t].type==double_tt){
							code_error("top of the stack is a double so that we cannot write a charater to an address.");
						}
						if(s[s[t].vi].type==double_tt){
							code_error("adr of the stack is a double so that we cannot write a charater.");
						}
						printf("%c",s[s[t].vi].vi);
						fprintf(fa2,"%c",s[s[t].vi].vi);
						t=t-1;
						break;
					case 20:	/*MOD*/
						t=t-1;
						if(s[t].type==double_tt||s[t+1].type==double_tt){
							code_error("tops of the stack are doubles so that one cannot mod another.");
						}
						s[t].vi=s[t].vi%s[t+1].vi;
						break;
					case 21:	/*xor*/
						t=t-1;
						if(s[t].type==double_tt||s[t+1].type==double_tt){
							code_error("tops of the stack are doubles so that one cannot xor another.");
						}
						s[t].vi=s[t].vi^s[t+1].vi;
						break;
					case 22:	/*and*/
						t=t-1;
						if(s[t].type==double_tt||s[t+1].type==double_tt){
							code_error("tops of the stack are doubles so that one cannot and another.");
						}
						s[t].vi=s[t].vi&&s[t+1].vi;
						break;
					case 23:	/*or*/
						t=t-1;
						if(s[t].type==double_tt||s[t+1].type==double_tt){
							code_error("tops of the stack are doubles so that one cannot or another.");
						}
						s[t].vi=s[t].vi||s[t+1].vi;
						break;
					case 24:	/*not*/
						if(s[t].type==double_tt){
							code_error("top of the stack is double so that one cannot do |not|.");
						}
						s[t].vi=!s[t].vi;
						break;
					case 25:	/*写bool*/
						if(s[t].type==double_tt){
							code_error("tops of the stack are doubles so that one cannot be writen.");
						}
						printf("%s",s[t].vi==0?"false":"true");
						fprintf(fa2,"%s",s[t].vi==0?"false":"true");
						t=t-1;
						break;
					case 26: /*pop stack*/
						t=t-1;
						break;
				}
				break;	
			case lod:
				if(i.a==0)/*lod栈顶值所在的数据单元*/
				{
					if(s[t].type==double_tt){
							code_error("top of the stack is a double so that we cannot lod from a double address.");
					}
					if(s[base(i.l,b,s)+s[t].vi].type==double_tt){
						s[t].type=double_tt;
						s[t].vd=s[base(i.l,b,s)+s[t].vi].vd;
					}else{
						s[t].type=int_t;
						s[t].vi=s[base(i.l,b,s)+s[t].vi].vi;
					}
				}
				else
				{
					t=t+1;
					if(s[base(i.l,b,s)+i.a].type==double_tt){
						s[t].type=double_tt;
						s[t].vd=s[base(i.l,b,s)+i.a].vd;
					}else{
						s[t].type=int_t;
						s[t].vi=s[base(i.l,b,s)+i.a].vi;
					}
				}
				break;
			case sto:
				if(i.a==0)/*sto到次栈顶值所在的数据单元，数据源为栈顶*/
				{
					if(s[t-1].type==double_tt){
							code_error("top of the stack is a double so that we cannot lod from a double address.");
					}
					if(s[base(i.l,b,s)+s[t-1].vi].type==double_tt){
						if(s[t].type==double_tt){
							s[base(i.l,b,s)+s[t-1].vi].vd=s[t].vd;
							s[t-1].vd=s[t].vd;
							s[t-1].type=s[t].type;
						}else{
							s[base(i.l,b,s)+s[t-1].vi].vd=s[t].vi;
							s[t-1].vd=s[t].vi;
							s[t-1].type=s[t].type;
						}
					}else{
						if(s[t].type==double_tt){
							s[base(i.l,b,s)+s[t-1].vi].vi=(int)s[t].vd;
							s[t-1].vi=(int)s[t].vd;
							s[t-1].type=s[t].type;
						}else{
							s[base(i.l,b,s)+s[t-1].vi].vi=s[t].vi;
							s[t-1].vi=s[t].vi;
							s[t-1].type=s[t].type;
						}
					}
					t=t-1;
				}
				else
				{
					if(s[base(i.l,b,s)+i.a].type==double_tt){
						if(s[t].type==double_tt){
							s[base(i.l,b,s)+i.a].vd=s[t].vd;
						}else{
							s[base(i.l,b,s)+i.a].vd=s[t].vi;
						}
					}else{
						if(s[t].type==double_tt){
							s[base(i.l,b,s)+i.a].vi=(int)s[t].vd;
						}else{
							s[base(i.l,b,s)+i.a].vi=s[t].vi;
						}
					}
					t=t-1;
				}
				break;
			case cal:
			/*
				s[t+1]=base(i.l,b,s);
				s[t+2]=b;
				s[t+3]=p;
				b=t+1;
				p=i.a;
			*/
				break;
			case ini:
				t=t+i.a;
				break;
			case jmp:
				p=i.a;
				break;
			case jpc:
				if(s[t].type==double_tt){
					code_error("top of the stack is a double so that we do not know if it is equals to zero.");
				}
				if(s[t].vi==0)
					p=i.a;
				t=t-1;
				break;
			case ext:						/* exit */
				p=0;
				break;
			}
		}while(p!=0);
		printf("\n********End X0***********\n");
		fclose(fa2);
}