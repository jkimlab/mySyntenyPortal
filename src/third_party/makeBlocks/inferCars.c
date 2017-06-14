#include "util.h"
#include "species.h"

#define BUFSZ		5000
#define STACKSZ	500
#define X				(sizeof(unsigned char))
#define YES			0x01
#define NO			0x00
#define HI			0xFF

struct chrom {
	int elenum;
	int eleorder[MAXORDER];
	struct chrom *next;
};

struct tree_node {
	struct tree_node *father, *rchild, *lchild;
	int chromnum;
	double dist;
	char name[20];
	struct chrom *genome;
	unsigned char *S;
};

struct node_list {
	struct tree_node *addr;
	struct node_list *next;
};

struct edge_list {
	int i, j;
	double wei;
	struct edge_list *next;
};

struct wei_mat {
  int x;
	double val;
	struct wei_mat *next;
};

/////////////////////////////////////////

static struct tree_node *Ancestor, *Phylotree;
static int A, T, N, Z, K;
static unsigned char *G, *PP, *SS;
static struct edge_list *Edgelist;
static struct wei_mat W[MAXORDER];
static struct node_list *Leaf, *Allnode;

/////////////////////////////////////////

int map(int i) {
	if (i == A)
		return Z;
	if (i == Z)
		return A;
	return (i <= T) ? (i + T) : (i - T);
}

int pam(int i) {
	if (i >= N)
		fatalf("pam - illegal i %d", i);
	if (i == Z)
		return A;
	return (i <= T) ? i : -(i - T);
}

unsigned char Val(unsigned char *H, int i, int j) {
	int a, b;
	if (i > Z)
		fatalf("Val - illegal i %d", i);
	if (j > Z)
		fatalf("Val - illegal j %d", j);
	
	a = i * (N/X + 1) + j/X;
	b = j % X;

	return (H[a] >> b) & 0x1;
}
																									
void Set(unsigned char *H, int i, int j, unsigned char value) {
	unsigned char g;
	int a, b;

	if (i < 0)
		i = map(-i);
	if (j < 0)
		j = map(-j);
	if (j == 0)
		j = Z;
	
	a = i * (N/X + 1) + j/X;
	b = j % X;
	
	if (value == YES) {
		g = 0x01 << b;
		H[a] = (H[a] | g);
	}
	else {
		g = 0x01 << b;
		g = HI - g;
		H[a] = (H[a] & g);
	}
}

double WVal(int i, int j) {
	struct wei_mat *pt;
	if (i > Z)
		fatalf("Val - illegal i %d", i);
	if (j > Z)
		fatalf("Val - illegal j %d", j);
	for (pt = &(W[i]); pt != NULL; pt = pt->next)
		if (pt->x == j)
			break;
	if (pt != NULL)
		return pt->val;
	else
		return 0;
}

void WSet(int i, int j, double value) {
	struct wei_mat *pt, *lst;
	if (i < 0)
		i = map(-i);
	if (j < 0)
		j = map(-j);
	if (j == A)
		j = Z;
	for (pt = lst = &(W[i]); pt != NULL; ) {
		if (pt->x == j)
			break;
		else {
			lst = pt;
			pt = pt->next;
		}
	}
	if (pt == NULL) {
		pt = (struct wei_mat *)ckalloc(sizeof(struct wei_mat));
		pt->next = NULL;
		lst->next = pt;
		pt->x = j;
		pt->val = value;
	}
	else 
		pt->val = value;
}

struct tree_node *locate_tree_node(char *spe) {
	struct tree_node *p;
	struct node_list *lf;
	p = NULL;
	for (lf = Leaf; lf != NULL; lf = lf->next) {
		if (same_string(lf->addr->name, spe)) {
			p = lf->addr;
			break;
		}
	}
	return p;
}

struct tree_node *allocate_new_tnode() {
	struct tree_node *p;
	p = (struct tree_node *)ckalloc(sizeof(struct tree_node));
	p->dist = 0;
	p->lchild = p->rchild = p->father = NULL;
	p->chromnum = 0;
	p->genome = NULL;
	return p;
}

struct tree_node *get_phylo_tree(char *treestr) {
	struct tree_node *stack[STACKSZ];
	struct tree_node *p, *q;
	char buf[500];
	char *pt;
	int top, bb, dd, count;
	double dc = 0.0;
	struct node_list *head, *last, *lf;
	struct node_list *head2, *last2, *an;

	p = NULL;
	head = head2 = last = last2 = NULL;
	top = bb = dd = count = 0;

	pt = treestr;

	while (*pt != '\0' && *pt != ';') {
		if (isalpha(*pt)) {
			p = allocate_new_tnode();
			if (sscanf(pt, "%[^:]:%*s", buf) != 1)
				fatalf("cannot parse: %s", pt);
			strcpy(p->name, buf);
			lf = (struct node_list *)ckalloc(sizeof(struct node_list));
			lf->next = NULL;
			lf->addr = p;
			if (head == NULL)
				head = last = lf;
			else {
				last->next = lf;
				last = lf;
			}
			an = (struct node_list *)ckalloc(sizeof(struct node_list));
			an->next = NULL;
			an->addr = p;
			if (head2 == NULL)
				head2 = last2 = an;
			else {
				last2->next = an;
				last2 = an;
			}
			pt = strchr(pt, ':');
			if (pt == NULL)
				fatalf("DIE: missing branch length: %s", buf);
		}
		if (*pt == ':') {
			pt++;
			if (sscanf(pt, "%lf", &dc) != 1)
				fatalf("cannot parse: %s", pt);
			while(*pt != ',' && *pt != ')')
				pt++;
		}
		switch(*pt) {
			case '(': {
				p = allocate_new_tnode();
				sprintf(buf, "N%d", ++count);
				strcpy(p->name, buf);
				stack[top++] = p;
				an = (struct node_list *)ckalloc(sizeof(struct node_list));
				an->next = NULL;
				an->addr = p;
				if (head2 == NULL)
					head2 = last2 = an;
				else {
					last2->next = an;
					last2 = an;
				}
				break;
			}
			case ',': {
				q = stack[top - 1];
				q->lchild = p;
				p->father = q;
				p->dist = dc;
				break;
			}
			case ')': {
				q = stack[--top];
				q->rchild = p;
				p->father = q;
				p->dist = dc;
				p = q;
				if ( *(pt+1) == '@') {
					Ancestor = q;
					pt++;
				}
				break;
			}
			default: ;
		}
		pt++;
	}

	Leaf = head;
	Allnode = head2;
	
	return p;
}
/*
void print_tree(struct tree_node *tt) {
	if (tt == NULL)
		return;
	fprintf(stderr, "%s %lf", tt->name, tt->dist);
	if (tt->father != NULL)
		fprintf(stderr, " [%s]", tt->father->name);
	fprintf(stderr, "\n");
	print_tree(tt->lchild);
	print_tree(tt->rchild);
}
*/

void read_genomes(char *genomefile) {
	FILE *fp;
	char buf[BUFSZ], spe[20];
	char *pt;
	int i, num;
	struct tree_node *tt;
	struct chrom *cp, *cnew;
	
	fp = ckopen(genomefile, "r");
	while(fgets(buf, BUFSZ, fp)) {
		if (buf[0] == '#' || buf[0] == '\n')
			continue;
		if (buf[0] == '>') {
			if (sscanf(buf, ">%s", spe) != 1)
				fatalf("cannot parse: %s", buf);
			if ((tt = locate_tree_node(spe)) == NULL)
				fatalf("DIE: species %s not exist", spe);
			for (;;) {
				fgets(buf, BUFSZ, fp);
				if (buf[0] == '\n')
					break;
				cnew = (struct chrom *)ckalloc(sizeof(struct chrom));
				cnew->next = NULL;
				if (tt->genome == NULL) 
					tt->genome = cnew;
				else {
					for (cp = tt->genome; cp->next != NULL; cp = cp->next)
						;
					cp->next = cnew;
				}
				if (buf[0] == '#')
					continue;
				pt = buf;
				for (i = 0; i < MAXORDER; i++) {
					if (*pt == '$')
						break;
					if (sscanf(pt, "%d", &num) != 1)
						fatalf("cannot parse: %s", pt);
					cnew->eleorder[i] = num;
					pt = strchr(pt, ' ');
					pt++;
				}
				if (i == MAXORDER)
					fatalf("DIE: MAXORDER %d is too small", MAXORDER);
				cnew->elenum = i;
			}
		}
	}
	fclose(fp);
}

void check_leaf_node() {
	struct node_list *lf;
	struct chrom *g;
	int count, i;
	for (lf = Leaf; lf != NULL; lf = lf->next) {
		i = spe_idx(lf->addr->name);
		if (Spetag[i] == 2)
			continue;
		if (lf->addr->genome == NULL)
			fatalf("DIE: no genome for %s", lf->addr->name);
		count = 0;
		for (g = lf->addr->genome; g != NULL; g = g->next)
			count += g->elenum;
		if (count > T)
			T = count;
	}
	fprintf(stderr, "- total conserved segments = %d\n", T);
}

void init_all_nodes() {
	int i;
	struct node_list *b;
	struct tree_node *node;

  for (b = Allnode; b != NULL; b = b->next) {
		node = b->addr;
		node->S = (unsigned char *)ckalloc(K);
		for (i = 0; i < K; i++)
			node->S[i] = 0x00;
	}

	G = (unsigned char *)ckalloc(K);
	PP = (unsigned char *)ckalloc(K);
	for (i = 0; i < K; i++)
		G[i] = PP[i] = 0x00;
}

void init_descendent(char *spe) {
	struct tree_node *node;
	struct chrom *chr;
	int i;
	node = locate_tree_node(spe);
  for (chr = node->genome; chr != NULL; chr = chr->next) {
		i = 0;
		Set(node->S, A, chr->eleorder[i], YES);
		Set(node->S, -chr->eleorder[i], Z, YES);
		for (++i; i < chr->elenum; ++i) {
			Set(node->S, chr->eleorder[i-1], chr->eleorder[i], YES);
			Set(node->S, -chr->eleorder[i], -chr->eleorder[i-1], YES);
		}
		Set(node->S, chr->eleorder[i-1], Z, YES);
		Set(node->S, A, -chr->eleorder[i-1], YES);
	}
}

void init_outgroup(char *spe) {
	struct tree_node *node;
	char tmp[50], buf[500];
	int a, b;
	FILE *fp;
	
	node = locate_tree_node(spe);
	
	sprintf(tmp, "%s.joins", spe);
	fp = ckopen(tmp, "r");
	while(fgets(buf, 500, fp)) {
		if (buf[0] == '#')
			continue;
		if (sscanf(buf, "%d %d", &a, &b) != 2)
			fatalf("cannot parse %s: %s", tmp, buf);
		Set(node->S, a, b, YES);
		Set(node->S, -b, -a, YES);
	}
	fclose(fp);
}

void modify_successor(struct tree_node *node) {
	int n, beg, end, i, sum;

	if (node->lchild == NULL && node->rchild == NULL)
		return;

	modify_successor(node->lchild);
	modify_successor(node->rchild);
	
	for (n = A+1; n <= Z-1; n++) {
		beg = n * (N/X + 1);
		end = (n+1) * (N/X + 1);
		sum = 0;
		for (i = beg; i < end; i++)
			sum += (node->lchild->S[i] & node->rchild->S[i]);
		if (sum == 0) {
			for (i = beg; i < end; i++)
				node->S[i] = (node->lchild->S[i] | node->rchild->S[i]);
		}
		else {
			for (i = beg; i < end; i++)
				node->S[i] = (node->lchild->S[i] & node->rchild->S[i]);
		}
	}
}

void adjust_ancestor(struct tree_node *node) {
	struct tree_node *dad;
	int n, beg, end, i, sum;
	
	if (node->father == NULL)
		return;
	
	dad = node->father;
	adjust_ancestor(dad);
	
	for (n = A+1; n <= Z-1; n++) {
		beg = n * (N/X + 1);
		end = (n+1) * (N/X + 1);
		sum = 0;
		for (i = beg; i < end; i++)
			sum += (node->S[i] & dad->S[i]);
		if (sum != 0) {
			for (i = beg; i < end; i++)
				node->S[i] = (node->S[i] & dad->S[i]);
		}
	}
}

int get_indegree(unsigned char *P, int element) {
	int i, sum;
	for (sum = 0, i = A; i <= Z; i++)
		sum += Val(P, i, element);
	return sum;
}

int get_outdegree(unsigned char *P, int element) {
	int i, sum;
	for (sum = 0, i = A; i <= Z; i++)
		sum += Val(P, element, i);
	return sum;
}

double calculate_edge_weight(struct tree_node *node, int i, int j) {
	double weight, leftw, rightw;

	if (node->lchild == NULL && node->rchild == NULL) {
		weight = (double)Val(node->S, i, j);
		return weight;
	}
	
	leftw = calculate_edge_weight(node->lchild, i, j);
	rightw = calculate_edge_weight(node->rchild, i, j);
	weight = (leftw * node->rchild->dist + rightw * node->lchild->dist)
					/ (node->lchild->dist + node->rchild->dist);
	
	return weight;
}

void sort_edges() {
  struct edge_list *q, *p;
	int i, j;
	double val;
	for (i = A; i <= Z; i++) {
		for (j = A; j <= Z; j++) {
			if ((val = WVal(i, j)) > 0) {
				p = (struct edge_list *)ckalloc(sizeof(struct edge_list));
				p->next = NULL;
				p->i = i;
				p->j = j;
				p->wei = val;
				if (Edgelist == NULL)
					Edgelist = p;
				else if (p->wei > Edgelist->wei) {
					p->next = Edgelist;
					Edgelist = p;
				}
				else {
					for (q = Edgelist; q->next != NULL; q = q->next) {
						if (p->wei > q->next->wei || (q->i == map(p->j) && q->j == map(p->i)))
							break;
					}
					p->next = q->next;
					q->next = p;
				}
			}
		}
	}
}

void create_aux_graph() {
	int i;
	struct edge_list *p;
	int start[N], end[N];
	
	for (i = A; i <= Z; i++)
		start[i] = end[i] = 0;
	
	for (p = Edgelist; p != NULL; p = p->next) {
		if (start[p->i] == 0 && end[p->j] == 0) {
			Set(G, p->i, p->j, YES);
			Set(G, map(p->j), map(p->i), YES);
			if (p->i != A) {
				start[p->i] = 1;
				end[map(p->i)] = 1;
			}
			if (p->j != Z) {
				end[p->j] = 1;
				start[map(p->j)] = 1;
			}
		}
	}
}

void remove_cycles() {
	int i, j, s, starti, total;
	int mini, minj;
	double minwei = 2.0;
	int used[N], buf[N];
	
	mini = minj = 0;
	for (i = A; i <= Z; i++)
		used[i] = 0;
	for (;;) {
		for (i = A+1; i < Z; i++)
			if (used[i] == 0)
				break;
		if (i == Z)
			break;
		starti = i;
		total = 0;
		for (;;) {
			buf[total++] = i;
			used[i] = 1;
			for (j = A+1; j < Z; j++)
				if (Val(G, i, j) && used[j] == 0)
					break;
			if (j == Z) {
				if (Val(G, i, starti)) {
					for (s = 0; s < total; s++) {
						if (WVal(buf[s], buf[(s+1)%total]) < minwei) {
							mini = buf[s];
							minj = buf[(s+1)%total];
							minwei = WVal(buf[s], buf[(s+1)%total]);
						}
					}
					Set(G, mini, minj, NO);
					mini = minj = 0;
					minwei = 2.0;
				}
				break;
			}
			else
				i = j;
		}
	}
}

double get_state(int i, int j) {
	/*
	if (WVal(i, j) == 1.0)
		return 0;
	else
		return 1; 
		*/
	return WVal(i, j);
}

void print_support(FILE *fp, int i, int j) {
	int s;
	struct tree_node *tt;
	for (s = 0; s < Spesz; s++) {
		tt = locate_tree_node(Spename[s]);
		if (Val(tt->S, i, j))
			fprintf(fp, "\t%s", Spename[s]);
	}
	fprintf(fp, "\n");
}

void find_cars(struct tree_node *anc) {
	int i, j, beg, end, n, count, total, minus;
	double weight;
	int used[N], buf[N];
	FILE *carfile, *joinfile;

	SS = anc->S;

	// generate the corresponding predecessor graph
 	for (i = A+1; i <= Z-1; i++)
		Set(SS, A, i, Val(SS, map(i), Z));
	for (i = A; i <= Z; i++)
		Set(PP, A, i, Val(SS, A, i));
	for (i = A; i <= Z; i++)
		Set(PP, i, Z, Val(SS, i, Z));
	for (i = A+1; i <= Z-1; i++)
		for (j = A+1; j <= Z-1; j++)
			Set(PP, i, j, Val(SS, map(j), map(i)));

	for (i = A; i <= Z; i++) {
		printf("S %*d:", 5, pam(i));
		for (j = A+1; j <= Z; j++) {
			if (Val(SS, i, j) == YES)
				printf(" %*d", 5, pam(j));
		}
		printf("\n");
	}
	printf("===================================\n");

	for (i = A; i <= Z; i++) {
		printf("P %*d:", 5, pam(i));
		for (j = A+1; j <= Z; j++) {
			if (Val(PP, i, j) == YES)
				printf(" %*d", 5, pam(j));
		}
		printf("\n");
	}
	printf("===================================\n");
	
	// intersect predecessor and successor graph
	
	for (n = A; n <= Z; n++) {
		beg = n * (N/X + 1);
		end = (n + 1) * (N/X + 1);
		for (i = beg; i < end; i++)
			SS[i] = (SS[i] & PP[i]);
	}
	
	for (i = A; i <= Z; i++) {
		printf("X %*d:", 5, pam(i));
		for (j = A+1; j <= Z; j++) {
			if (Val(SS, i, j) == YES)
				printf(" %*d", 5, pam(j));
		}
		printf("\n");
	}
	
  for (i = A; i <= Z; i++) {
		for (j = A; j <= Z; j++) {
			if (Val(SS, i, j)) {
				if (get_outdegree(SS, i) == 1 && get_indegree(SS, j) == 1)
					WSet(i, j, 1.0);
				else if (i == A && get_indegree(SS, j) == 1) {
					WSet(A, j, 1.0);
					WSet(map(j), Z, 1.0);
				}
				else if (j == Z && get_outdegree(SS, i) == 1) {
					WSet(i, Z, 1.0);
					WSet(A, map(i), 1.0);
				}
				else {
					weight = calculate_edge_weight(anc, i, j);
					WSet(i, j, weight);
					WSet(map(j), map(i), weight);
				}
			}
		}
	}
	sort_edges();
	create_aux_graph();
	remove_cycles();
	
	carfile = ckopen("Ancestor.car", "w");
	joinfile = ckopen("Ancestor.joins", "w");
	fprintf(carfile, ">ANCESTOR\t%d\n", T);
	fprintf(joinfile, "#%d\n", T);
	count = 0;
	for (i = A; i <= Z; i++)
		used[i] = 0;
	for (;;) {
		for (i = A+1; i <= Z-1; i++)
			if (used[abs(pam(i))] == 0)
				break;
		if (i == Z)
			break; 
		for (;;) { //find the first one
			for (j = A; j < Z; j++)
				if (Val(G, j, i))
					break;
			if (j == Z || j == A)
				break;
			i = j;
		}
		fprintf(carfile, "# CAR %d\n", ++count);
		total = minus = 0;

    for (;;) {
			if (i != Z && i != A)
				used[abs(pam(i))] = 1;
			buf[total] = i;
			++total;
			if (pam(i) < 0)
				++minus;
			for (j = A; j <= Z; j++)
				if (Val(G, i, j))
					break;
			if (j > Z)
				break;
			else {
				if (j != Z) {
					fprintf(joinfile, "%*d\t%*d\t%lf", 5, pam(i), 5, pam(j), get_state(i, j));
					print_support(joinfile, i, j);
					i = j;
				}
				else
					break;
			}
   	}
		if (minus <= total/2) {
						
			fprintf(joinfile, "%*d\t%*d\t%lf", 5, 0, 5, pam(buf[0]), get_state(A, buf[0]));
			print_support(joinfile, A, buf[0]);

			for (i = 0; i < total; i++)
				fprintf(carfile, "%d ", pam(buf[i]));
			fprintf(carfile, "$\n");
			
			fprintf(joinfile, "%*d\t%*d\t%lf", 5, pam(buf[total-1]), 5, 0, get_state(buf[total-1], Z));
			print_support(joinfile, buf[total-1], Z);
		}
		else {
			fprintf(joinfile, "%*d\t%*d\t%lf", 5, 0, 5, -pam(buf[total-1]), get_state(A, map(buf[total-1])));
			print_support(joinfile, A, map(buf[total-1]));
			
			for (i = total-1; i >= 0; i--)
				fprintf(carfile, "%d ", -pam(buf[i]));
			fprintf(carfile, "$\n");
			
			fprintf(joinfile, "%*d\t%*d\t%lf", 5, -pam(buf[0]), 5, 0, get_state(map(buf[0]), Z));
			print_support(joinfile, map(buf[0]), Z);
		}
	}
	fprintf(stderr, "- %d CARs found.\n", count);
	fclose(joinfile);
	fclose(carfile);
}

void free_tree_space(struct tree_node *node) {
	struct chrom *p, *q;
	if (node == NULL)
		return;
	free_tree_space(node->lchild);
	free_tree_space(node->rchild);
	free(node->S);
	if (node->genome != NULL) {
		p = node->genome;
		for (;;) {
			q = p->next;
			free(p);
			if (q == NULL)
				break;
			else
				p = q;
		}
	}
	free(node);
}

void free_nlist(struct node_list *nlist) {
	struct node_list *p, *q;
	if (nlist == NULL)
		return;
	p = nlist;
	for (;;) {
		q = p->next;
		free(p);
		if (q == NULL)
			break;
		else
			p = q;
	}
}

int main (int argc, char* argv[]) {
	int i;
	
	if (argc != 3)
		fatalf("args: config.file genomes-file");

	get_spename(argv[1]);
	get_treestr(argv[1]);

	// initialization
	Phylotree = Ancestor = NULL;
	Edgelist = NULL;
	Leaf = Allnode = NULL;
	A = T = N = Z = 0;
	
	Phylotree = get_phylo_tree(Treestr);
	//print_tree(phylotree);
	read_genomes(argv[2]);
	check_leaf_node();

	if (Ancestor == NULL)
		Ancestor = Phylotree;
	fprintf(stderr, "- target ancestor is node %s, left child %s, right child %s\n", 
				Ancestor->name, Ancestor->lchild->name, Ancestor->rchild->name);

	Z = 2 * T + 1;
	N = Z + 1;
	K = N * (N/X + 1);

	init_all_nodes();
	for (i = 0; i < Spesz; i++) {
		if (Spetag[i] != 2)
			init_descendent(Spename[i]);
		else
			init_outgroup(Spename[i]);
	}
	
	// infer successor sets in each node
	modify_successor(Phylotree);
	// adjust the successor sets in the target ancestor 
	// using outgroup information
	adjust_ancestor(Ancestor);
	// looking for CARs
	find_cars(Ancestor);
	
	//free space
	free_tree_space(Phylotree);
	free_nlist(Leaf);
	free_nlist(Allnode);
	free(G);
	free(PP);

	return 0;
}	
