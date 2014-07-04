/* pfit.f -- translated by f2c (version 20100827).
   You must link the resulting object file with libf2c:
	on Microsoft Windows system, link with libf2c.lib;
	on Linux or Unix systems, link with .../path/to/libf2c.a -lm
	or, if you install libf2c.a in a standard place, with -lf2c -lm
	-- in that order, at the end of the command line, as in
		cc *.o -lf2c -lm
	Source for libf2c is in /netlib/f2c/libf2c.zip, e.g.,

		http://www.netlib.org/f2c/libf2c.zip
*/

#include "f2c.h"

/* Table of constant values */

static integer c__20 = 20;
static integer c__1 = 1;

/* 	Copyright Eric Fuller, 2001-2007 */
/* 	This program was derived from an example in */
/* 	Numerical Recipes in C. Eric Fuller extended */
/* 	the example program to 2 dimensions. */
/* Main program */ int MAIN__(void)
{
    /* Format strings */
    static char fmt_53[] = "(\002 I         A           SigA\002)";
    static char fmt_52[] = "(i2,4x,f14.6,2x,f14.6)";

    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Builtin functions */
    double sqrt(doublereal);
    integer s_wsfe(cilist *), e_wsfe(void), do_fio(integer *, char *,
						   ftnlen);
    /* Subroutine */ int s_stop(char *, ftnlen);

    /* Local variables */
    extern /* Subroutine */ int getparam_(integer *, doublereal *,
					  integer *);
    static doublereal a[20];
    static integer i__, j, l;
    static doublereal x1[1000], y1[1000], x2[1000], y2[1000], z1[1000],
	z2[1000];
    static integer ai[20], ma;
    static doublereal phi, rho, sig1[1000], sig2[1000], beta[20],
	siga[1000];
    static integer ndat, mfit;
    extern /* Subroutine */ int sort_(integer *, integer *, integer *,
				      doublereal *, doublereal *),
	build_(integer *, integer *, doublereal *, doublereal *,
	       doublereal *, doublereal *, integer *, doublereal *,
	       doublereal *, doublereal *, doublereal *, doublereal *,
	       doublereal *, doublereal *, doublereal *, integer *)
    , model_(integer *, doublereal *, doublereal *);
    static doublereal chisq, covar[400] /* was [20][20] */ ;
    extern /* Subroutine */ int stats_(integer *, integer *, doublereal *,
				       doublereal *, doublereal *,
				       doublereal *, doublereal *,
				       doublereal *);
    static doublereal afunc1[20], afunc2[20];
    extern /* Subroutine */ int gaussj_(doublereal *, integer *, integer *,
					doublereal *),
	covsrt_(doublereal *, integer *, integer *, integer *, integer *),
	calcchi_(doublereal *, integer *, doublereal *, doublereal *,
		 doublereal *, doublereal *, integer *, doublereal *,
		 doublereal *, doublereal *, doublereal *, doublereal *,
		 doublereal *, doublereal *, doublereal *),
	getdata_(doublereal *, doublereal *, doublereal *, doublereal *,
		 doublereal *, doublereal *, doublereal *, doublereal *,
		 integer *);

    /* Fortran I/O blocks */
    static cilist io___25 = { 0, 6, 0, fmt_53, 0 };
    static cilist io___26 = { 0, 6, 0, fmt_52, 0 };


    ma = 18;
    getparam_(&ma, a, ai);
    sort_(&mfit, &ma, ai, covar, beta);
    getdata_(&phi, &rho, x1, x2, y1, y2, sig1, sig2, &ndat);
    build_(&ndat, &mfit, x1, x2, afunc1, afunc2, &ma, &phi, y1, y2, sig1,
	   sig2, covar, beta, a, ai);
/* 	SOLVE MATRIX */
    gaussj_(covar, &mfit, &c__20, beta);
    j = 0;
    i__1 = ma;
    for (l = 1; l <= i__1; ++l) {
	if (ai[l - 1] != 0) {
	    ++j;
	    a[l - 1] = beta[j - 1];
	}
    }
/* 	RECOVER THE PARAMETERS AND CALCULATE THEIR UNCERTAINTIES */
    covsrt_(covar, &c__20, &ma, ai, &mfit);
    i__1 = ma;
    for (i__ = 1; i__ <= i__1; ++i__) {
	siga[i__ - 1] =
	    sqrt((d__1 = covar[i__ + i__ * 20 - 21], abs(d__1)));
    }
    calcchi_(&chisq, &ndat, x1, x2, afunc1, afunc2, &ma, &phi, a, z1, z2,
	     y1, y2, sig1, sig2);
    stats_(&ndat, &mfit, x1, x2, y1, y2, z1, z2);
/* 	SHOW RESULTS */
    s_wsfe(&io___25);
    e_wsfe();
    i__1 = ma;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_wsfe(&io___26);
	do_fio(&c__1, (char *) &i__, (ftnlen) sizeof(integer));
	do_fio(&c__1, (char *) &a[i__ - 1], (ftnlen) sizeof(doublereal));
	do_fio(&c__1, (char *) &siga[i__ - 1],
	       (ftnlen) sizeof(doublereal));
	e_wsfe();
    }
    model_(&ma, a, siga);
    s_stop("", (ftnlen) 0);
    return 0;
}				/* MAIN__ */

/* Main program alias */ int pfit_()
{
    MAIN__();
    return 0;
}
