#!/usr/bin/env python3

import pandas as pd
import numpy as np
import sys


def main():
    in_path = sys.argv[1]
    index = sys.argv[2]
    df = pd.read_csv(in_path)
    df = pd.pivot_table(df, index=index.split(","), values=["Duration"],
                        aggfunc=np.sum)
    df = df.sort_values('Duration', ascending=False)
    print(df)


if __name__ == "__main__":
    main()
