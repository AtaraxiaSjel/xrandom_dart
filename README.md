![Generic badge](https://img.shields.io/badge/status-draft-red.svg)
[![Actions Status](https://github.com/rtmigo/xorshift/workflows/unittest/badge.svg?branch=master)](https://github.com/rtmigo/xorshift/actions)
![Generic badge](https://img.shields.io/badge/tested_on-Windows_|_MacOS_|_Ubuntu-blue.svg)

This library implements Xorshift random number generators in native Dart.

Xorshift algorithms are known as the **fastest random number generators**, requiring very small code
and state.

The library has been thoroughly tested to match reference numbers generated by C algorithms. The
sources in C are taken directly from scientific articles by George Marsaglia and Sebastiano Vigna,
the inventors of the algorithms. The Xorshift128+ results are also matched to reference values from
JavaScript [xorshift](https://github.com/AndreasMadsen/xorshift) library, that tested the 128+ similarly. 

