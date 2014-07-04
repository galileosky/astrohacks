/* stats.f -- translated by f2c (version 20100827).
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
/* Subroutine */ int stats_(integer * ndat, integer * mfit,
			    doublereal * x1,
			    doublereal * x2, doublereal * y1,
			    doublereal * y2, doublereal * z1,
			    doublereal * z2)
{
    /* Format strings */
    static char fmt_30[] =
	"(\002                      SD(X)        SD(Y)   " "     PSD\002)";
    static char fmt_40[] =
	"(\002Raw Pointing      : \002,f8.3,4x,f8.3,4x,f8" ".3)";
    static char fmt_42[] =
	"(\002Fixed Pointing    : \002,f8.3,4x,f8.3,4x,f8" ".3)";

    /* System generated locals */
    integer i__1;
    doublereal d__1, d__2, d__3, d__4, d__5;

    /* Builtin functions */
    integer s_wsfe(cilist *), e_wsfe(void);
    double sqrt(doublereal);
    integer do_fio(integer *, char *, ftnlen);

    /* Local variables */
    static integer i__;
    static doublereal sd, avg, tmp, tmq, sum;

    /* Fortran I/O blocks */
    static cilist io___1 = { 0, 6, 0, fmt_30, 0 };
    static cilist io___8 = { 0, 6, 0, fmt_40, 0 };
    static cilist io___9 = { 0, 6, 0, fmt_42, 0 };


    /* Parameter adjustments */
    --z2;
    --z1;
    --y2;
    --y1;
    --x2;
    --x1;

    /* Function Body */
    s_wsfe(&io___1);
    e_wsfe();
/* 	SHOW RAW POINTING STATISTICS */
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
	sum += y1[i__] - x1[i__];
    }
    avg = sum / *ndat;
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
/* Computing 2nd power */
	d__1 = y1[i__] - x1[i__] - avg;
	sum += d__1 * d__1;
    }
    sd = sqrt(sum / (*ndat - 1));
    tmp = sd;
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
	sum += y2[i__] - x2[i__];
    }
    avg = sum / *ndat;
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
/* Computing 2nd power */
	d__1 = y2[i__] - x2[i__] - avg;
	sum += d__1 * d__1;
    }
    sd = sqrt(sum / (*ndat - 1));
    tmq = (doublereal) (*ndat / (*ndat - *mfit));
    s_wsfe(&io___8);
    d__1 = tmp * 60.f;
    do_fio(&c__1, (char *) &d__1, (ftnlen) sizeof(doublereal));
    d__2 = sd * 60.f;
    do_fio(&c__1, (char *) &d__2, (ftnlen) sizeof(doublereal));
/* Computing 2nd power */
    d__4 = tmp;
/* Computing 2nd power */
    d__5 = sd;
    d__3 = sqrt(d__4 * d__4 + d__5 * d__5) * 60.f * sqrt(tmq);
    do_fio(&c__1, (char *) &d__3, (ftnlen) sizeof(doublereal));
    e_wsfe();
/* 	SHOW FIXED POINTING STATISTICS */
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
	sum += y1[i__] - z1[i__];
    }
    avg = sum / *ndat;
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
/* Computing 2nd power */
	d__1 = y1[i__] - z1[i__] - avg;
	sum += d__1 * d__1;
    }
    sd = sqrt(sum / (*ndat - 1));
    tmp = sd;
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
	sum += y2[i__] - z2[i__];
    }
    avg = sum / *ndat;
    sum = 0.f;
    i__1 = *ndat;
    for (i__ = 1; i__ <= i__1; ++i__) {
/* Computing 2nd power */
	d__1 = y2[i__] - z2[i__] - avg;
	sum += d__1 * d__1;
    }
    sd = sqrt(sum / (*ndat - 1));
    tmq = (doublereal) (*ndat / (*ndat - *mfit));
    s_wsfe(&io___9);
    d__1 = tmp * 60;
    do_fio(&c__1, (char *) &d__1, (ftnlen) sizeof(doublereal));
    d__2 = sd * 60.f;
    do_fio(&c__1, (char *) &d__2, (ftnlen) sizeof(doublereal));
/* Computing 2nd power */
    d__4 = tmp;
/* Computing 2nd power */
    d__5 = sd;
    d__3 = sqrt(d__4 * d__4 + d__5 * d__5) * 60.f * sqrt(tmq);
    do_fio(&c__1, (char *) &d__3, (ftnlen) sizeof(doublereal));
    e_wsfe();
    return 0;
}				/* stats_ */
