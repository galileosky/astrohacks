/* setup.f -- translated by f2c (version 20100827).
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

static integer c__1 = 1;

/* 	Copyright Eric Fuller, 2001-2007 */
/* 	This subroutine was derived from an example in */
/* 	Numerical Recipes in C */
/* Subroutine */ int sort_(integer * mfit, integer * ma, integer * ai,
			   doublereal * covar, doublereal * beta)
{
    /* Format strings */
    static char fmt_10[] = "(\002Fitted Parameters : \002,i5)";

    /* System generated locals */
    integer i__1, i__2;

    /* Builtin functions */
    integer s_wsfe(cilist *), do_fio(integer *, char *, ftnlen),
	e_wsfe(void);
    /* Subroutine */ int s_paus(char *, ftnlen);

    /* Local variables */
    static integer j, k;

    /* Fortran I/O blocks */
    static cilist io___2 = { 0, 6, 0, fmt_10, 0 };


/* 	SORT PARAMETERS */
    /* Parameter adjustments */
    --beta;
    covar -= 21;
    --ai;

    /* Function Body */
    *mfit = 0;
    i__1 = *ma;
    for (j = 1; j <= i__1; ++j) {
	if (ai[j] != 0) {
	    ++(*mfit);
	}
    }
    s_wsfe(&io___2);
    do_fio(&c__1, (char *) &(*mfit), (ftnlen) sizeof(integer));
    e_wsfe();
    if (*mfit == 0) {
	s_paus("No Parameters to be fitted.", (ftnlen) 27);
    }
    i__1 = *mfit;
    for (j = 1; j <= i__1; ++j) {
	i__2 = *mfit;
	for (k = 1; k <= i__2; ++k) {
	    covar[j + k * 20] = 0.f;
	}
	beta[j] = 0.f;
    }
    return 0;
}				/* sort_ */

/* Subroutine */ int build_(integer * ndat, integer * mfit,
			    doublereal * x1,
			    doublereal * x2, doublereal * afunc1,
			    doublereal * afunc2, integer * ma,
			    doublereal * phi, doublereal * y1,
			    doublereal * y2, doublereal * sig1,
			    doublereal * sig2, doublereal * covar,
			    doublereal * beta, doublereal * a,
			    integer * ai)
{
    /* System generated locals */
    integer i__1, i__2, i__3;
    doublereal d__1;

    /* Local variables */
    static integer i__, j, k, l, m;
    static doublereal ym1, ym2, wt1, wt2, sig2i1, sig2i2;
    extern /* Subroutine */ int funcs_(doublereal *, doublereal *, doublereal
				       *, doublereal *, integer *,
				       doublereal *);

/* 	BUILD MATRIX */
    /* Parameter adjustments */
    --ai;
    --a;
    --beta;
    covar -= 21;
    --sig2;
    --sig1;
    --y2;
    --y1;
    --afunc2;
    --afunc1;
    --x2;
    --x1;

    /* Function Body */
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
	funcs_(&x1[i__], &x2[i__], &afunc1[1], &afunc2[1], ma, phi);
	ym1 = y1[i__];
	ym2 = y2[i__];
	if (*mfit < *ma) {
	    i__2 = *ma;
	    for (j = 1; j <= i__2; ++j) {
		if (ai[j] == 0) {
		    ym1 -= a[j] * afunc1[j];
		    ym2 -= a[j] * afunc2[j];
		}
	    }
	}
/* Computing 2nd power */
	d__1 = sig1[i__];
	sig2i1 = 1.f / (d__1 * d__1);
/* Computing 2nd power */
	d__1 = sig2[i__];
	sig2i2 = 1.f / (d__1 * d__1);
	j = 0;
	i__2 = *ma;
	for (l = 1; l <= i__2; ++l) {
	    if (ai[l] != 0) {
		++j;
		wt1 = afunc1[l] * sig2i1;
		wt2 = afunc2[l] * sig2i2;
		k = 0;
		i__3 = l;
		for (m = 1; m <= i__3; ++m) {
		    if (ai[m] != 0) {
			++k;
			covar[j + k * 20] =
			    covar[j + k * 20] + wt1 * afunc1[m] +
			    wt2 * afunc2[m];
		    }
		}
		beta[j] = beta[j] + ym1 * wt1 + ym2 * wt2;
	    }
	}
    }
    i__1 = *mfit;
    for (j = 2; j <= i__1; ++j) {
	i__2 = j - 1;
	for (k = 1; k <= i__2; ++k) {
	    covar[k + j * 20] = covar[j + k * 20];
	}
    }
    return 0;
}				/* build_ */
