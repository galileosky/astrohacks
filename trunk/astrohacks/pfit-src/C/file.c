/* file.f -- translated by f2c (version 20100827).
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

static integer c__5 = 5;
static integer c__1 = 1;
static integer c__3 = 3;

/* 	Copyright Eric Fuller, 2001-2007 */
/* Subroutine */ int getparam_(integer *ma, doublereal *a, integer *ai)
{
    /* System generated locals */
    integer i__1;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer f_open(olist *), s_rsle(cilist *), do_lio(integer *, integer *, 
	    char *, ftnlen), e_rsle(void), f_clos(cllist *);

    /* Local variables */
    static integer i__;

    /* Fortran I/O blocks */
    static cilist io___2 = { 0, 8, 0, 0, 0 };


/* 	GET PARAMETERS */
    /* Parameter adjustments */
    --ai;
    --a;

    /* Function Body */
    o__1.oerr = 0;
    o__1.ounit = 8;
    o__1.ofnmlen = 11;
    o__1.ofnm = "control.dat";
    o__1.orl = 0;
    o__1.osta = "OLD";
    o__1.oacc = 0;
    o__1.ofm = 0;
    o__1.oblnk = 0;
    f_open(&o__1);
    i__1 = *ma;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_rsle(&io___2);
	do_lio(&c__5, &c__1, (char *)&a[i__], (ftnlen)sizeof(doublereal));
	do_lio(&c__3, &c__1, (char *)&ai[i__], (ftnlen)sizeof(integer));
	e_rsle();
    }
    cl__1.cerr = 0;
    cl__1.cunit = 8;
    cl__1.csta = 0;
    f_clos(&cl__1);
    return 0;
} /* getparam_ */

/* Subroutine */ int getdata_(doublereal *phi, doublereal *rho, doublereal *
	x1, doublereal *x2, doublereal *y1, doublereal *y2, doublereal *sig1, 
	doublereal *sig2, integer *ndat)
{
    /* Format strings */
    static char fmt_32[] = "(f12.6,4x,f12.6)";
    static char fmt_34[] = "(f8.6,4x,f8.6)";
    static char fmt_30[] = "(\002Stars             : \002,i5)";

    /* System generated locals */
    integer i__1;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer f_open(olist *), s_rsfe(cilist *), do_fio(integer *, char *, 
	    ftnlen), e_rsfe(void), s_rsle(cilist *), do_lio(integer *, 
	    integer *, char *, ftnlen), e_rsle(void);
    double sqrt(doublereal), cos(doublereal);
    integer f_clos(cllist *), s_wsfe(cilist *), e_wsfe(void);

    /* Local variables */
    static integer i__;
    static doublereal xticks, yticks;

    /* Fortran I/O blocks */
    static cilist io___3 = { 0, 8, 0, fmt_32, 0 };
    static cilist io___4 = { 0, 8, 0, fmt_34, 0 };
    static cilist io___8 = { 0, 8, 1, 0, 0 };
    static cilist io___9 = { 0, 0, 0, fmt_30, 0 };


/* 	GET DATA */
    /* Parameter adjustments */
    --sig2;
    --sig1;
    --y2;
    --y1;
    --x2;
    --x1;

    /* Function Body */
    o__1.oerr = 0;
    o__1.ounit = 8;
    o__1.ofnmlen = 9;
    o__1.ofnm = "input.dat";
    o__1.orl = 0;
    o__1.osta = "OLD";
    o__1.oacc = 0;
    o__1.ofm = 0;
    o__1.oblnk = 0;
    f_open(&o__1);
    s_rsfe(&io___3);
    do_fio(&c__1, (char *)&(*phi), (ftnlen)sizeof(doublereal));
    do_fio(&c__1, (char *)&(*rho), (ftnlen)sizeof(doublereal));
    e_rsfe();
    s_rsfe(&io___4);
    do_fio(&c__1, (char *)&xticks, (ftnlen)sizeof(doublereal));
    do_fio(&c__1, (char *)&yticks, (ftnlen)sizeof(doublereal));
    e_rsfe();
/* 	WRITE(*,36) XTICKS,YTICKS */
    for (i__ = 1; i__ <= 1000; ++i__) {
	i__1 = s_rsle(&io___8);
	if (i__1 != 0) {
	    goto L20;
	}
	i__1 = do_lio(&c__5, &c__1, (char *)&x1[i__], (ftnlen)sizeof(
		doublereal));
	if (i__1 != 0) {
	    goto L20;
	}
	i__1 = do_lio(&c__5, &c__1, (char *)&x2[i__], (ftnlen)sizeof(
		doublereal));
	if (i__1 != 0) {
	    goto L20;
	}
	i__1 = do_lio(&c__5, &c__1, (char *)&y1[i__], (ftnlen)sizeof(
		doublereal));
	if (i__1 != 0) {
	    goto L20;
	}
	i__1 = do_lio(&c__5, &c__1, (char *)&y2[i__], (ftnlen)sizeof(
		doublereal));
	if (i__1 != 0) {
	    goto L20;
	}
	i__1 = e_rsle();
	if (i__1 != 0) {
	    goto L20;
	}
	sig1[i__] = xticks / sqrt(3.f) / cos(x2[i__] * .01745329252);
	sig2[i__] = yticks / sqrt(3.f);
/* 	  WRITE(*,*) X1(I),X2(I),Y1(I),Y2(I),SIG1(I),SIG2(I) */
    }
L20:
    *ndat = i__ - 1;
    cl__1.cerr = 0;
    cl__1.cunit = 8;
    cl__1.csta = 0;
    f_clos(&cl__1);
    s_wsfe(&io___9);
    do_fio(&c__1, (char *)&(*ndat), (ftnlen)sizeof(integer));
    e_wsfe();
/* 	WRITE(0,33) PHI */
/* 	WRITE(0,37) RHO */
/* L31: */
/* L33: */
/* L35: */
/* L36: */
/* L37: */
    return 0;
} /* getdata_ */

/* Subroutine */ int model_(integer *ma, doublereal *a, doublereal *siga)
{
    /* Format strings */
    static char fmt_60[] = "(i2,4x,f14.6,2x,f14.6)";

    /* System generated locals */
    integer i__1;
    olist o__1;
    cllist cl__1;

    /* Builtin functions */
    integer f_open(olist *), s_wsfe(cilist *), do_fio(integer *, char *, 
	    ftnlen), e_wsfe(void), f_clos(cllist *);

    /* Local variables */
    static integer i__;

    /* Fortran I/O blocks */
    static cilist io___11 = { 0, 8, 0, fmt_60, 0 };


/* 	WRITE A FILE FOR A PROGRAM TO READ THE MODEL PARAMETERS */
    /* Parameter adjustments */
    --siga;
    --a;

    /* Function Body */
    o__1.oerr = 0;
    o__1.ounit = 8;
    o__1.ofnmlen = 9;
    o__1.ofnm = "model.dat";
    o__1.orl = 0;
    o__1.osta = "UNKNOWN";
    o__1.oacc = 0;
    o__1.ofm = 0;
    o__1.oblnk = 0;
    f_open(&o__1);
    i__1 = *ma;
    for (i__ = 1; i__ <= i__1; ++i__) {
	s_wsfe(&io___11);
	do_fio(&c__1, (char *)&i__, (ftnlen)sizeof(integer));
	do_fio(&c__1, (char *)&a[i__], (ftnlen)sizeof(doublereal));
	do_fio(&c__1, (char *)&siga[i__], (ftnlen)sizeof(doublereal));
	e_wsfe();
    }
    cl__1.cerr = 0;
    cl__1.cunit = 8;
    cl__1.csta = 0;
    f_clos(&cl__1);
    return 0;
} /* model_ */

