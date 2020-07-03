#!/usr/bin/env python3

"""
Massage CSV data generated via profile-parser.py.
"""

import argparse
import pandas as pd
import numpy as np
import sys


def init():
    pd.set_option('display.max_rows', None)
    pd.set_option('display.max_columns', None)
    pd.set_option('display.width', None)
    pd.set_option('display.max_colwidth', None)


def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("--index", action='append', required=True)
    parser.add_argument("--role")
    parser.add_argument("--play")
    parser.add_argument("--ok", choices=['any', 'yes', 'no'])
    parser.add_argument("--changed", choices=['any', 'yes', 'no'])
    parser.add_argument("--ok-or-changed", choices=['any', 'yes', 'no'])
    parser.add_argument("--skipped", choices=['any', 'yes', 'no'])
    parser.add_argument("--failed", choices=['any', 'yes', 'no'])
    parser.add_argument("--format")
    return parser.parse_args()


def query_state(parsed_args, df, name):
    value = getattr(parsed_args, name)
    if value == 'yes':
        df = df.query(name + ' > 0')
    elif value == 'no':
        df = df.query(name + ' == 0')
    return df


def main():
    init()
    parsed_args = parse()
    df = pd.read_csv(parsed_args.input, dtype={'ok': int, 'changed': int, 'failed': int, 'skipped': int})
    if parsed_args.role:
        df = df.query('Role == @parsed_args.role')
    if parsed_args.play:
        df = df.query('Play == @parsed_args.play')
    for name in ['ok', 'changed', 'skipped', 'failed']:
        df = query_state(parsed_args, df, name)
    if parsed_args.ok_or_changed == 'yes':
        df = df.query('ok > 0 or changed > 0')
    elif parsed_args.ok_or_changed == 'no':
        df = df.query('ok == 0 and changed == 0')
    df = df.query('Duration >= 0')
    df = pd.pivot_table(df, index=parsed_args.index, values=["Duration"],
                        aggfunc=np.sum)
    df = df.sort_values('Duration', ascending=False)
    if not parsed_args.format:
        print(df)
    else:
        func = getattr(df, 'to_' + parsed_args.format)
        print(func())
    print()
    print("Total", df['Duration'].sum())


if __name__ == "__main__":
    main()
