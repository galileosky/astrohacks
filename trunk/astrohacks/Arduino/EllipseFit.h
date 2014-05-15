#ifndef __ELLIPSEFIT_H
#define __ELLIPSEFIT_H 1

#include	"math.h"	/* <math.h> */


#define	F0	0.0174532925	/* conversion factor */
#define	FAC	10.0		/* mixing * factor */
#define	LAB	0.01		/* start mixing parameter */
#define	LABMAX	1.0E+10		/* max. mixing parameter */
#define	LABMIN	1.0E-10		/* min. mixing parameter */
#define	PARS	5		/* number of parameters */
#define	T	50		/* max. number of iterations */
//#define	TOL	0.00001		/* tolerance */
#define	TOL	1		/* tolerance */


static int invmat(double matrix[PARS][PARS], int nfree);
static double inimat(double s[PARS][PARS],
double rl[PARS],
float *x,
float *y,
int n, float *p, float *e, int ip[PARS], int nfree);
static int inivec(double s[PARS][PARS],
double s1[PARS][PARS],
double rl[PARS],
double labda,
double *q,
float *p,
float *e,
float *x, float *y, int n, int ip[PARS], int nfree);
int ellipse1_c(int *n,		/* number of points */
float *x,	/* X coordinates */
float *y,	/* Y coordinates */
float *p);
int ellipse2_c(int *n,		/* number of coordinates */
float *x,	/* X coordinates */
float *y,	/* Y coordinates */
float *p,	/* ellipse parameters */
float *e,	/* errors in ellipse parms. */
int *m);

#endif