/* gaussj.f -- translated by f2c (version 20100827).
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

/* 	Copyright Eric Fuller, 2001-2007 */
/* 	This subroutine was derived from a subroutine of the same */
/* 	name in Numerical Recipes in C */
/* Subroutine */ int gaussj_(doublereal *a, integer *n, integer *np, 
	doublereal *beta)
{
    /* System generated locals */
    integer a_dim1, a_offset, beta_dim1, beta_offset, i__1, i__2, i__3;
    doublereal d__1;

    /* Builtin functions */
    /* Subroutine */ int s_paus(char *, ftnlen);

    /* Local variables */
    static integer i__, j, k, l, ll;
    static doublereal big, dum;
    static integer icol, ipiv[1000], irow, indxc[1000], indxr[1000];
    static doublereal pivinv;

/* 	GAUSSIAN ELIMINATION WITH ROW AND COLUMN PIVOTING. */
/* 	THIS IS SIMILAR TO THE NUMERICAL RECIPES ROUTINE */
/* 	BUT IT IS NOT THE SAME ROUTINE. */
/* 	INITIALISE PIVOT TABLE */
    /* Parameter adjustments */
    beta_dim1 = *np;
    beta_offset = 1 + beta_dim1;
    beta -= beta_offset;
    a_dim1 = *np;
    a_offset = 1 + a_dim1;
    a -= a_offset;

    /* Function Body */
    i__1 = *n;
    for (j = 1; j <= i__1; ++j) {
	ipiv[j - 1] = 0;
    }
    i__1 = *n;
    for (i__ = 1; i__ <= i__1; ++i__) {
	big = 0.f;
	i__2 = *n;
	for (j = 1; j <= i__2; ++j) {
	    if (ipiv[j - 1] != 1) {
		i__3 = *n;
		for (k = 1; k <= i__3; ++k) {
		    if (ipiv[k - 1] == 0) {
			if ((d__1 = a[j + k * a_dim1], abs(d__1)) >= big) {
			    big = (d__1 = a[j + k * a_dim1], abs(d__1));
			    irow = j;
			    icol = k;
			}
		    } else if (ipiv[k - 1] > 1) {
			s_paus("Singular matrix in gaussj.", (ftnlen)26);
		    }
		}
	    }
	}
	++ipiv[icol - 1];
	if (irow != icol) {
	    i__2 = *n;
	    for (l = 1; l <= i__2; ++l) {
		dum = a[irow + l * a_dim1];
		a[irow + l * a_dim1] = a[icol + l * a_dim1];
		a[icol + l * a_dim1] = dum;
	    }
	    for (l = 1; l <= 1; ++l) {
		dum = beta[irow + l * beta_dim1];
		beta[irow + l * beta_dim1] = beta[icol + l * beta_dim1];
		beta[icol + l * beta_dim1] = dum;
	    }
	}
	indxr[i__ - 1] = irow;
	indxc[i__ - 1] = icol;
	if (a[icol + icol * a_dim1] == 0.f) {
	    s_paus("Singular matrix in gaussj.", (ftnlen)26);
	}
	pivinv = 1.f / a[icol + icol * a_dim1];
	a[icol + icol * a_dim1] = 1.f;
	i__2 = *n;
	for (l = 1; l <= i__2; ++l) {
	    a[icol + l * a_dim1] *= pivinv;
	}
	for (l = 1; l <= 1; ++l) {
	    beta[icol + l * beta_dim1] *= pivinv;
	}
	i__2 = *n;
	for (ll = 1; ll <= i__2; ++ll) {
	    if (ll != icol) {
		dum = a[ll + icol * a_dim1];
		a[ll + icol * a_dim1] = 0.f;
		i__3 = *n;
		for (l = 1; l <= i__3; ++l) {
		    a[ll + l * a_dim1] -= a[icol + l * a_dim1] * dum;
		}
		for (l = 1; l <= 1; ++l) {
		    beta[ll + l * beta_dim1] -= beta[icol + l * beta_dim1] * 
			    dum;
		}
	    }
	}
    }
    for (l = *n; l >= 1; --l) {
	if (indxr[l - 1] != indxc[l - 1]) {
	    i__1 = *n;
	    for (k = 1; k <= i__1; ++k) {
		dum = a[k + indxr[l - 1] * a_dim1];
		a[k + indxr[l - 1] * a_dim1] = a[k + indxc[l - 1] * a_dim1];
		a[k + indxc[l - 1] * a_dim1] = dum;
	    }
	}
    }
    return 0;
} /* gaussj_ */

