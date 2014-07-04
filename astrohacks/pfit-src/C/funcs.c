/* funcs.f -- translated by f2c (version 20100827).
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
/* Subroutine */ int funcs_(doublereal * x1, doublereal * x2,
			    doublereal * p1,
			    doublereal * p2, integer * np,
			    doublereal * phi)
{
    /* Builtin functions */
    double cos(doublereal), tan(doublereal), sin(doublereal);

    /* Parameter adjustments */
    --p2;
    --p1;

    /* Function Body */
    p1[1] = 1.f;
    p1[2] = *x1;
    p1[3] = 0.f;
    p1[4] = 0.f;
    p1[5] = 1.f / cos(*x2 * .01745329252);
    p1[6] = tan(*x2 * .01745329252);
    p1[7] = -cos(*x1 * .01745329252) * tan(*x2 * .01745329252);
    p1[8] = sin(*x1 * .01745329252) * tan(*x2 * .01745329252);
    p1[9] = cos(*phi * .01745329252) * sin(*x1 * .01745329252) / cos(*x2 *
								     .01745329252);
    p1[10] = 0.f;
    p1[11] =
	-(cos(*phi * .01745329252) * cos(*x1 * .01745329252) +
	  sin(*phi * .01745329252) * tan(*x2 * .01745329252));
    p1[12] = sin(*x1 * .01745329252);
    p1[13] = cos(*x1 * .01745329252);
    p1[14] = 0.f;
    p1[15] = 0.f;
    p1[16] = tan(*x2 * .01745329252) * sin(*x1 * .01745329252);
    p1[17] = -cos(*x1 * .01745329252) * tan(*x2 * .01745329252) * sin(*x1 *
								      .01745329252);
    p1[18] = -cos(*x1 * .01745329252) * tan(*x2 * .01745329252) * cos(*x1 *
								      .01745329252);
    p2[1] = 0.f;
    p2[2] = 0.f;
    p2[3] = 1.f;
    p2[4] = *x2;
    p2[5] = 0.f;
    p2[6] = 0.f;
    p2[7] = sin(*x1 * .01745329252);
    p2[8] = cos(*x1 * .01745329252);
    p2[9] = cos(*phi * .01745329252) * cos(*x1 * .01745329252) * sin(*x2 *
								     .01745329252)
	- sin(*phi * .01745329252) * cos(*x2 * .01745329252);
    p2[10] = cos(*x1 * .01745329252);
    p2[11] = 0.f;
    p2[12] = 0.f;
    p2[13] = 0.f;
    p2[14] = sin(*x2 * .01745329252);
    p2[15] = cos(*x2 * .01745329252);
    p2[16] = 0.f;
    p2[17] = sin(*x1 * .01745329252) * sin(*x1 * .01745329252);
    p2[18] = sin(*x1 * .01745329252) * cos(*x1 * .01745329252);
    return 0;
}				/* funcs_ */
