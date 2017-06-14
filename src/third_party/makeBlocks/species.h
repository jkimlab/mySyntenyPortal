/* ****************************************
 * a configuration file is needed
 * ***************************************/

#ifndef _SPE_H_
#define _SPE_H_

#define MAXSPE		29		// maximum number of species
#define MAXCHR		50000		// maximum number of chrom in one species
#define MAXORDER	100000	// maximum number of order of signed permutation

#define MINOVL		0.4
#define AFEW			0.3
#define MINOUTSEG	0.02
#define MINDESSEG	0.05
#define MAXNUM		500000000

#define ORT(x) ((x == '+') ? '-' : '+')

///////////////////////////////////////////////

enum segstate {FIRST = 0, LAST, BOTH, MIDDLE};

struct seg_list {
	int id, beg, end, subid, chid, chnum;
	int *cidlist;
	char chr[50];
	char orient;
	enum segstate state;
	struct seg_list *next;
};

struct block_list {
	int id, isdup;
	int left, right;
	struct seg_list *speseg[MAXSPE];
	struct block_list *next;
};

///////////////////////////////////////////////

extern int Spesz;	// total number of species
extern char Spename[MAXSPE][100];	// names of species
extern int Spetag[MAXSPE];	// tags of species, 0 - reference, 1 - descendent, 2 - outgroup
extern int Chrassmz;	// total number of clades 
extern int Spechrassm[MAXSPE]; // clade number
extern char Treestr[200];	// string of the phylogentic tree
extern char Treestr2[200];
extern char Netdir[200];	// dir of pairwise nets files
extern char Chaindir[200];	// dir of pairwise chains files
extern int MINLEN;
extern int HSACHR;

///////////////////////////////////////////////

int spe_idx(char *sname);	// return the index of species
int ref_spe_idx();	// return the index of reference species
int des_spe_idx();	// JK: return the index of descendent species
void get_spename(char *configfile);	// read species names from config file
void get_treestr(char *configfile);	// read tree string from config file
void get_treestr2(char *configfile);
void get_chaindir(char *configfile);	// read chain dir from config file
void get_netdir(char *configfile);	// read net dir from config file
void get_minlen(char *configfile);	// read the minimum length of a block
void get_numchr(char *configfile);	// read the minimum length of a block

///////////////////////////////////////////////

struct block_list *get_block_list(char *block_file);
struct block_list *allocate_newblock();
void assign_states(struct block_list *blk);
void assign_orders(struct block_list *blk);
void merge_chlist(struct block_list *blk);
void free_seg_list(struct seg_list *sg);
void free_block_list(struct block_list *blk);

#endif
