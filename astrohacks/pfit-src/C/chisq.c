/* chisq.f -- translated by f2c (version 20100827).
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
/* Subroutine */ int calcchi_(doublereal * chisq, integer * ndat,
			      doublereal *
			      x1, doublereal * x2, doublereal * afunc1,
			      doublereal * afunc2, integer * ma,
			      doublereal * phi, doublereal * a,
			      doublereal * z1, doublereal * z2,
			      doublereal * y1, doublereal * y2,
			      doublereal * sig1, doublereal * sig2)
{
    /* Format strings */
    static char fmt_50[] = "(\002Chi Squared       : \002,f6.1)";

    /* System generated locals */
    integer i__1, i__2;
    doublereal d__1, d__2;

    /* Builtin functions */
    integer s_wsfe(cilist *), do_fio(integer *, char *, ftnlen),
	e_wsfe(void);

    /* Local variables */
    static integer i__, j;
    static doublereal sum1, sum2;
    extern /* Subroutine */ int funcs_(doublereal *, doublereal *, doublereal
				       *, doublereal *, integer *,
				       doublereal *);

    /* Fortran I/O blocks */
    static cilist io___5 = { 0, 6, 0, fmt_50, 0 };


/* 	CALCULATE CHI SQUARED FOR THE CURRENT FIT PARAMETERS */
    /* Parameter adjustments */
    --sig2;
    --sig1;
    --y2;
    --y1;
    --z2;
    --z1;
    --a;
    --afunc2;
    --afunc1;
    --x2;
    --x1;

    /* Function Body */
    *chisq = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
	funcs_(&x1[i__], &x2[i__], &afunc1[1], &afunc2[1], ma, phi);
	sum1 = 0.f;
	sum2 = 0.f;
	i__2 = *ma;
	for (j = 1; j <= i__2; ++j) {
	    sum1 += a[j] * afunc1[j];
	    sum2 += a[j] * afunc2[j];
	}
	z1[i__] = sum1;
	z2[i__] = sum2;
/* Computing 2nd power */
	d__1 = (y1[i__] - z1[i__]) / sig1[i__];
/* Computing 2nd power */
	d__2 = (y2[i__] - z2[i__]) / sig2[i__];
	*chisq = *chisq + d__1 * d__1 + d__2 * d__2;
    }
    s_wsfe(&io___5);
    do_fio(&c__1, (char *) &(*chisq), (ftnlen) sizeof(doublereal));
    e_wsfe();
    return 0;
}				/* calcchi_ */
