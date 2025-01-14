      SUBROUTINE iau_NUT80 ( DATE1, DATE2, DPSI, DEPS )
*+
*  - - - - - - - - - -
*   i a u _ N U T 8 0
*  - - - - - - - - - -
*
*  Nutation, IAU 1980 model.
*
*  This routine is part of the International Astronomical Union's
*  SOFA (Standards of Fundamental Astronomy) software collection.
*
*  Status:  canonical model.
*
*  Given:
*     DATE1,DATE2     d      TT as a 2-part Julian Date (Note 1)
*
*  Returned:
*     DPSI            d      nutation in longitude (radians)
*     DEPS            d      nutation in obliquity (radians)
*
*  Notes:
*
*  1) The DATE DATE1+DATE2 is a Julian Date, apportioned in any
*     convenient way between the two arguments.  For example,
*     JD(TDB)=2450123.7 could be expressed in any of these ways,
*     among others:
*
*            DATE1          DATE2
*
*         2450123.7D0        0D0        (JD method)
*          2451545D0      -1421.3D0     (J2000 method)
*         2400000.5D0     50123.2D0     (MJD method)
*         2450123.5D0       0.2D0       (date & time method)
*
*     The JD method is the most natural and convenient to use in
*     cases where the loss of several decimal digits of resolution
*     is acceptable.  The J2000 method is best matched to the way
*     the argument is handled internally and will deliver the
*     optimum resolution.  The MJD method and the date & time methods
*     are both good compromises between resolution and convenience.
*
*  2) The nutation components are with respect to the ecliptic of
*     date.
*
*  Called:
*     iau_ANPM     normalize angle into range +/- pi
*
*  Reference:
*
*     Explanatory Supplement to the Astronomical Almanac,
*     P. Kenneth Seidelmann (ed), University Science Books (1992),
*     Section 3.222 (p111).
*
*  This revision:  2009 December 15
*
*  SOFA release 2016-05-03
*
*  Copyright (C) 2016 IAU SOFA Board.  See notes at end.
*
*-----------------------------------------------------------------------

      IMPLICIT NONE

      DOUBLE PRECISION DATE1, DATE2, DPSI, DEPS

*  Arcseconds to radians
      DOUBLE PRECISION DAS2R
      PARAMETER ( DAS2R = 4.848136811095359935899141D-6 )

*  2Pi
      DOUBLE PRECISION D2PI
      PARAMETER ( D2PI = 6.283185307179586476925287D0 )

*  Units of 0.1 milliarcsecond to radians
      DOUBLE PRECISION U2R
      PARAMETER ( U2R = DAS2R/1D4 )

*  Reference epoch (J2000.0), JD
      DOUBLE PRECISION DJ00
      PARAMETER ( DJ00 = 2451545D0 )

*  Days per Julian century
      DOUBLE PRECISION DJC
      PARAMETER ( DJC = 36525D0 )

      DOUBLE PRECISION T, EL, ELP, F, D, OM, DP, DE, ARG, S, C
      INTEGER I, J

      DOUBLE PRECISION iau_ANPM


*  ------------------------------------------------
*  Table of multiples of arguments and coefficients
*  ------------------------------------------------
*
*  The coefficient values are in 0.1 mas units and the rates of change
*  are in mas per Julian millennium.

      REAL X(9,106)

*                Multiple of            Longitude        Obliquity
*           L    L'   F    D  Omega   coeff. of sin    coeff. of cos
*                                         1       t        1     t

      DATA ((X(I,J),I=1,9),J=1,10) /
     :      0.,  0.,  0.,  0.,  1., -171996., -1742.,  92025.,  89.,
     :      0.,  0.,  0.,  0.,  2.,    2062.,     2.,   -895.,   5.,
     :     -2.,  0.,  2.,  0.,  1.,      46.,     0.,    -24.,   0.,
     :      2.,  0., -2.,  0.,  0.,      11.,     0.,      0.,   0.,
     :     -2.,  0.,  2.,  0.,  2.,      -3.,     0.,      1.,   0.,
     :      1., -1.,  0., -1.,  0.,      -3.,     0.,      0.,   0.,
     :      0., -2.,  2., -2.,  1.,      -2.,     0.,      1.,   0.,
     :      2.,  0., -2.,  0.,  1.,       1.,     0.,      0.,   0.,
     :      0.,  0.,  2., -2.,  2.,  -13187.,   -16.,   5736., -31.,
     :      0.,  1.,  0.,  0.,  0.,    1426.,   -34.,     54.,  -1. /
      DATA ((X(I,J),I=1,9),J=11,20) /
     :      0.,  1.,  2., -2.,  2.,    -517.,    12.,    224.,  -6.,
     :      0., -1.,  2., -2.,  2.,     217.,    -5.,    -95.,   3.,
     :      0.,  0.,  2., -2.,  1.,     129.,     1.,    -70.,   0.,
     :      2.,  0.,  0., -2.,  0.,      48.,     0.,      1.,   0.,
     :      0.,  0.,  2., -2.,  0.,     -22.,     0.,      0.,   0.,
     :      0.,  2.,  0.,  0.,  0.,      17.,    -1.,      0.,   0.,
     :      0.,  1.,  0.,  0.,  1.,     -15.,     0.,      9.,   0.,
     :      0.,  2.,  2., -2.,  2.,     -16.,     1.,      7.,   0.,
     :      0., -1.,  0.,  0.,  1.,     -12.,     0.,      6.,   0.,
     :     -2.,  0.,  0.,  2.,  1.,      -6.,     0.,      3.,   0. /
      DATA ((X(I,J),I=1,9),J=21,30) /
     :      0., -1.,  2., -2.,  1.,      -5.,     0.,      3.,   0.,
     :      2.,  0.,  0., -2.,  1.,       4.,     0.,     -2.,   0.,
     :      0.,  1.,  2., -2.,  1.,       4.,     0.,     -2.,   0.,
     :      1.,  0.,  0., -1.,  0.,      -4.,     0.,      0.,   0.,
     :      2.,  1.,  0., -2.,  0.,       1.,     0.,      0.,   0.,
     :      0.,  0., -2.,  2.,  1.,       1.,     0.,      0.,   0.,
     :      0.,  1., -2.,  2.,  0.,      -1.,     0.,      0.,   0.,
     :      0.,  1.,  0.,  0.,  2.,       1.,     0.,      0.,   0.,
     :     -1.,  0.,  0.,  1.,  1.,       1.,     0.,      0.,   0.,
     :      0.,  1.,  2., -2.,  0.,      -1.,     0.,      0.,   0. /
      DATA ((X(I,J),I=1,9),J=31,40) /
     :      0.,  0.,  2.,  0.,  2.,   -2274.,    -2.,    977.,  -5.,
     :      1.,  0.,  0.,  0.,  0.,     712.,     1.,     -7.,   0.,
     :      0.,  0.,  2.,  0.,  1.,    -386.,    -4.,    200.,   0.,
     :      1.,  0.,  2.,  0.,  2.,    -301.,     0.,    129.,  -1.,
     :      1.,  0.,  0., -2.,  0.,    -158.,     0.,     -1.,   0.,
     :     -1.,  0.,  2.,  0.,  2.,     123.,     0.,    -53.,   0.,
     :      0.,  0.,  0.,  2.,  0.,      63.,     0.,     -2.,   0.,
     :      1.,  0.,  0.,  0.,  1.,      63.,     1.,    -33.,   0.,
     :     -1.,  0.,  0.,  0.,  1.,     -58.,    -1.,     32.,   0.,
     :     -1.,  0.,  2.,  2.,  2.,     -59.,     0.,     26.,   0./
      DATA ((X(I,J),I=1,9),J=41,50) /
     :      1.,  0.,  2.,  0.,  1.,     -51.,     0.,     27.,   0.,
     :      0.,  0.,  2.,  2.,  2.,     -38.,     0.,     16.,   0.,
     :      2.,  0.,  0.,  0.,  0.,      29.,     0.,     -1.,   0.,
     :      1.,  0.,  2., -2.,  2.,      29.,     0.,    -12.,   0.,
     :      2.,  0.,  2.,  0.,  2.,     -31.,     0.,     13.,   0.,
     :      0.,  0.,  2.,  0.,  0.,      26.,     0.,     -1.,   0.,
     :     -1.,  0.,  2.,  0.,  1.,      21.,     0.,    -10.,   0.,
     :     -1.,  0.,  0.,  2.,  1.,      16.,     0.,     -8.,   0.,
     :      1.,  0.,  0., -2.,  1.,     -13.,     0.,      7.,   0.,
     :     -1.,  0.,  2.,  2.,  1.,     -10.,     0.,      5.,   0. /
      DATA ((X(I,J),I=1,9),J=51,60) /
     :      1.,  1.,  0., -2.,  0.,      -7.,     0.,      0.,   0.,
     :      0.,  1.,  2.,  0.,  2.,       7.,     0.,     -3.,   0.,
     :      0., -1.,  2.,  0.,  2.,      -7.,     0.,      3.,   0.,
     :      1.,  0.,  2.,  2.,  2.,      -8.,     0.,      3.,   0.,
     :      1.,  0.,  0.,  2.,  0.,       6.,     0.,      0.,   0.,
     :      2.,  0.,  2., -2.,  2.,       6.,     0.,     -3.,   0.,
     :      0.,  0.,  0.,  2.,  1.,      -6.,     0.,      3.,   0.,
     :      0.,  0.,  2.,  2.,  1.,      -7.,     0.,      3.,   0.,
     :      1.,  0.,  2., -2.,  1.,       6.,     0.,     -3.,   0.,
     :      0.,  0.,  0., -2.,  1.,      -5.,     0.,      3.,   0. /
      DATA ((X(I,J),I=1,9),J=61,70) /
     :      1., -1.,  0.,  0.,  0.,       5.,     0.,      0.,   0.,
     :      2.,  0.,  2.,  0.,  1.,      -5.,     0.,      3.,   0.,
     :      0.,  1.,  0., -2.,  0.,      -4.,     0.,      0.,   0.,
     :      1.,  0., -2.,  0.,  0.,       4.,     0.,      0.,   0.,
     :      0.,  0.,  0.,  1.,  0.,      -4.,     0.,      0.,   0.,
     :      1.,  1.,  0.,  0.,  0.,      -3.,     0.,      0.,   0.,
     :      1.,  0.,  2.,  0.,  0.,       3.,     0.,      0.,   0.,
     :      1., -1.,  2.,  0.,  2.,      -3.,     0.,      1.,   0.,
     :     -1., -1.,  2.,  2.,  2.,      -3.,     0.,      1.,   0.,
     :     -2.,  0.,  0.,  0.,  1.,      -2.,     0.,      1.,   0. /
      DATA ((X(I,J),I=1,9),J=71,80) /
     :      3.,  0.,  2.,  0.,  2.,      -3.,     0.,      1.,   0.,
     :      0., -1.,  2.,  2.,  2.,      -3.,     0.,      1.,   0.,
     :      1.,  1.,  2.,  0.,  2.,       2.,     0.,     -1.,   0.,
     :     -1.,  0.,  2., -2.,  1.,      -2.,     0.,      1.,   0.,
     :      2.,  0.,  0.,  0.,  1.,       2.,     0.,     -1.,   0.,
     :      1.,  0.,  0.,  0.,  2.,      -2.,     0.,      1.,   0.,
     :      3.,  0.,  0.,  0.,  0.,       2.,     0.,      0.,   0.,
     :      0.,  0.,  2.,  1.,  2.,       2.,     0.,     -1.,   0.,
     :     -1.,  0.,  0.,  0.,  2.,       1.,     0.,     -1.,   0.,
     :      1.,  0.,  0., -4.,  0.,      -1.,     0.,      0.,   0. /
      DATA ((X(I,J),I=1,9),J=81,90) /
     :     -2.,  0.,  2.,  2.,  2.,       1.,     0.,     -1.,   0.,
     :     -1.,  0.,  2.,  4.,  2.,      -2.,     0.,      1.,   0.,
     :      2.,  0.,  0., -4.,  0.,      -1.,     0.,      0.,   0.,
     :      1.,  1.,  2., -2.,  2.,       1.,     0.,     -1.,   0.,
     :      1.,  0.,  2.,  2.,  1.,      -1.,     0.,      1.,   0.,
     :     -2.,  0.,  2.,  4.,  2.,      -1.,     0.,      1.,   0.,
     :     -1.,  0.,  4.,  0.,  2.,       1.,     0.,      0.,   0.,
     :      1., -1.,  0., -2.,  0.,       1.,     0.,      0.,   0.,
     :      2.,  0.,  2., -2.,  1.,       1.,     0.,     -1.,   0.,
     :      2.,  0.,  2.,  2.,  2.,      -1.,     0.,      0.,   0. /
      DATA ((X(I,J),I=1,9),J=91,100) /
     :      1.,  0.,  0.,  2.,  1.,      -1.,     0.,      0.,   0.,
     :      0.,  0.,  4., -2.,  2.,       1.,     0.,      0.,   0.,
     :      3.,  0.,  2., -2.,  2.,       1.,     0.,      0.,   0.,
     :      1.,  0.,  2., -2.,  0.,      -1.,     0.,      0.,   0.,
     :      0.,  1.,  2.,  0.,  1.,       1.,     0.,      0.,   0.,
     :     -1., -1.,  0.,  2.,  1.,       1.,     0.,      0.,   0.,
     :      0.,  0., -2.,  0.,  1.,      -1.,     0.,      0.,   0.,
     :      0.,  0.,  2., -1.,  2.,      -1.,     0.,      0.,   0.,
     :      0.,  1.,  0.,  2.,  0.,      -1.,     0.,      0.,   0.,
     :      1.,  0., -2., -2.,  0.,      -1.,     0.,      0.,   0. /
      DATA ((X(I,J),I=1,9),J=101,106) /
     :      0., -1.,  2.,  0.,  1.,      -1.,     0.,      0.,   0.,
     :      1.,  1.,  0., -2.,  1.,      -1.,     0.,      0.,   0.,
     :      1.,  0., -2.,  2.,  0.,      -1.,     0.,      0.,   0.,
     :      2.,  0.,  0.,  2.,  0.,       1.,     0.,      0.,   0.,
     :      0.,  0.,  2.,  4.,  2.,      -1.,     0.,      0.,   0.,
     :      0.,  1.,  0.,  1.,  0.,       1.,     0.,      0.,   0. /

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

*  Interval between fundamental epoch J2000.0 and given date (JC).
      T = ( ( DATE1-DJ00 ) + DATE2 ) / DJC

*
*  FUNDAMENTAL ARGUMENTS in the FK5 reference system
*

*  Mean longitude of the Moon minus mean longitude of the Moon's
*  perigee.
      EL = iau_ANPM ( ( 485866.733D0 + ( 715922.633D0 +
     :                  ( 31.310D0 + 0.064D0 * T ) * T ) * T ) * DAS2R
     :                + MOD(1325D0*T, 1D0) * D2PI )

*  Mean longitude of the Sun minus mean longitude of the Sun's perigee.
      ELP = iau_ANPM ( ( 1287099.804D0 + ( 1292581.224D0 +
     :                   ( -0.577D0 -0.012D0 * T ) * T ) * T ) * DAS2R
     :                 + MOD(99D0*T, 1D0) * D2PI )

*  Mean longitude of the Moon minus mean longitude of the Moon's node.
      F = iau_ANPM ( ( 335778.877D0 + ( 295263.137D0 +
     :                 ( -13.257D0 + 0.011D0 * T ) * T ) * T ) * DAS2R
     :               + MOD(1342D0*T, 1D0) * D2PI )

*  Mean elongation of the Moon from the Sun.
      D = iau_ANPM ( ( 1072261.307D0 + ( 1105601.328D0 +
     :                 ( -6.891D0 + 0.019D0 * T ) * T ) * T ) * DAS2R
     :               + MOD(1236D0*T, 1D0) * D2PI )

*  Longitude of the mean ascending node of the lunar orbit on the
*  ecliptic, measured from the mean equinox of date.
      OM = iau_ANPM( ( 450160.280D0 + ( -482890.539D0 +
     :                 ( 7.455D0 + 0.008D0 * T ) * T ) * T ) * DAS2R
     :               + MOD( -5D0*T, 1D0) * D2PI )

*  ---------------
*  Nutation series
*  ---------------

*  Change time argument from centuries to millennia.
      T = T / 10D0

*  Initialize nutation components.
      DP = 0D0
      DE = 0D0

*  Sum the nutation terms, ending with the biggest.
      DO 1 J=106,1,-1

*     Form argument for current term.
         ARG = DBLE(X(1,J)) * EL
     :       + DBLE(X(2,J)) * ELP
     :       + DBLE(X(3,J)) * F
     :       + DBLE(X(4,J)) * D
     :       + DBLE(X(5,J)) * OM

*     Accumulate current nutation term.
         S = DBLE(X(6,J)) + DBLE(X(7,J)) * T
         C = DBLE(X(8,J)) + DBLE(X(9,J)) * T
         IF ( S .NE. 0D0 ) DP = DP + S * SIN(ARG)
         IF ( C .NE. 0D0 ) DE = DE + C * COS(ARG)

*     Next term.
 1    CONTINUE

*  Convert results from 0.1 mas units to radians.
      DPSI = DP * U2R
      DEPS = DE * U2R

*  Finished.

*+----------------------------------------------------------------------
*
*  Copyright (C) 2016
*  Standards Of Fundamental Astronomy Board
*  of the International Astronomical Union.
*
*  =====================
*  SOFA Software License
*  =====================
*
*  NOTICE TO USER:
*
*  BY USING THIS SOFTWARE YOU ACCEPT THE FOLLOWING SIX TERMS AND
*  CONDITIONS WHICH APPLY TO ITS USE.
*
*  1. The Software is owned by the IAU SOFA Board ("SOFA").
*
*  2. Permission is granted to anyone to use the SOFA software for any
*     purpose, including commercial applications, free of charge and
*     without payment of royalties, subject to the conditions and
*     restrictions listed below.
*
*  3. You (the user) may copy and distribute SOFA source code to others,
*     and use and adapt its code and algorithms in your own software,
*     on a world-wide, royalty-free basis.  That portion of your
*     distribution that does not consist of intact and unchanged copies
*     of SOFA source code files is a "derived work" that must comply
*     with the following requirements:
*
*     a) Your work shall be marked or carry a statement that it
*        (i) uses routines and computations derived by you from
*        software provided by SOFA under license to you; and
*        (ii) does not itself constitute software provided by and/or
*        endorsed by SOFA.
*
*     b) The source code of your derived work must contain descriptions
*        of how the derived work is based upon, contains and/or differs
*        from the original SOFA software.
*
*     c) The names of all routines in your derived work shall not
*        include the prefix "iau" or "sofa" or trivial modifications
*        thereof such as changes of case.
*
*     d) The origin of the SOFA components of your derived work must
*        not be misrepresented;  you must not claim that you wrote the
*        original software, nor file a patent application for SOFA
*        software or algorithms embedded in the SOFA software.
*
*     e) These requirements must be reproduced intact in any source
*        distribution and shall apply to anyone to whom you have
*        granted a further right to modify the source code of your
*        derived work.
*
*     Note that, as originally distributed, the SOFA software is
*     intended to be a definitive implementation of the IAU standards,
*     and consequently third-party modifications are discouraged.  All
*     variations, no matter how minor, must be explicitly marked as
*     such, as explained above.
*
*  4. You shall not cause the SOFA software to be brought into
*     disrepute, either by misuse, or use for inappropriate tasks, or
*     by inappropriate modification.
*
*  5. The SOFA software is provided "as is" and SOFA makes no warranty
*     as to its use or performance.   SOFA does not and cannot warrant
*     the performance or results which the user may obtain by using the
*     SOFA software.  SOFA makes no warranties, express or implied, as
*     to non-infringement of third party rights, merchantability, or
*     fitness for any particular purpose.  In no event will SOFA be
*     liable to the user for any consequential, incidental, or special
*     damages, including any lost profits or lost savings, even if a
*     SOFA representative has been advised of such damages, or for any
*     claim by any third party.
*
*  6. The provision of any version of the SOFA software under the terms
*     and conditions specified herein does not imply that future
*     versions will also be made available under the same terms and
*     conditions.
*
*  In any published work or commercial product which uses the SOFA
*  software directly, acknowledgement (see www.iausofa.org) is
*  appreciated.
*
*  Correspondence concerning SOFA software should be addressed as
*  follows:
*
*      By email:  sofa@ukho.gov.uk
*      By post:   IAU SOFA Center
*                 HM Nautical Almanac Office
*                 UK Hydrographic Office
*                 Admiralty Way, Taunton
*                 Somerset, TA1 2DN
*                 United Kingdom
*
*-----------------------------------------------------------------------

      END
