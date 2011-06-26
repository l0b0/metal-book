#! /usr/bin/env python
# -*- coding: utf-8 -*-
"""
Test conversion of ISO 216 A series paper sizes to ISO 269 C series
"""

from math import sqrt

__copyright__ = 'Copyright (C) 2011 Victor Engmark'
__license__ = 'GPLv3'

A_SERIES = [
    [841, 1189],
    [594, 841],
    [420, 594],
    [297, 420],
    [210, 297],
    [148, 210],
    [105, 148],
    [74, 105],
    [52, 74],
    [37, 52],
    [26, 37]]

C_SERIES = [
    [917, 1297],
    [648, 917],
    [458, 648],
    [324, 458],
    [229, 324],
    [162, 229],
    [114, 162],
    [81, 114],
    [57, 81],
    [40, 57],
    [28, 40]]

def a_to_c(dimension):
    return dimension * pow(2, 1.0 / 8)

def main():
    for a_values, c_values in zip(A_SERIES, C_SERIES):
        a_to_c_values = [
            int(round(a_to_c(a_values[0]))),
            int(round(a_to_c(a_values[1])))]
        if a_to_c_values != c_values:
            print str([a_to_c(a_values[0]), a_to_c(a_values[1])]) + ' != ' + str(c_values)

if __name__ == '__main__':
    main()
