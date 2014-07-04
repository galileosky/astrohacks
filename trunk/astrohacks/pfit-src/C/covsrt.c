/* covsrt.f -- translated by f2c (version 20100827).
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
/* 	This subroutine is derived from a subroutine of the same */
/* 	name in Numerical Recipes in C */
/* Subroutine */ int covsrt_(doublereal * covar, integer * npc,
			     integer * ma,
			     integer * ai, integer * mfit)
{
    /* System generated locals */
    integer covar_dim1, covar_offset, i__1, i__2;

    /* Local variables */
    static integer i__, j, k;
    static doublereal swap;

    /* Parameter adjustments */
    covar_dim1 = *npc;
    covar_offset = 1 + covar_dim1;
    covar -= covar_offset;
    --ai;

    /* Function Body */
    i__1 = *ma;
    for (i__ = *mfit + 1; i__ <= i__1; ++i__) {
	i__2 = i__;
	for (j = 1; j <= i__2; ++j) {
	    covar[i__ + j * covar_dim1] = 0.f;
	    covar[j + i__ * covar_dim1] = 0.f;
	}
    }
    k = *mfit;
    for (j = *ma; j >= 1; --j) {
	if (ai[j] != 0) {
	    i__1 = *ma;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		swap = covar[i__ + k * covar_dim1];
		covar[i__ + k * covar_dim1] = covar[i__ + j * covar_dim1];
		covar[i__ + j * covar_dim1] = swap;
	    }
	    i__1 = *ma;
	    for (i__ = 1; i__ <= i__1; ++i__) {
		swap = covar[k + i__ * covar_dim1];
		covar[k + i__ * covar_dim1] = covar[j + i__ * covar_dim1];
		covar[j + i__ * covar_dim1] = swap;
	    }
	    --k;
	}
    }
    return 0;
}				/* covsrt_ */
