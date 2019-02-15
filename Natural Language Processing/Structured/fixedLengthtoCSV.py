import pandas as pd

fmt = pd.read_csv('fixed-width.txt', delimiter=' ',
                  header=None, names=['field', 'width'])
df = pd.read_fwf('input.txt', widths=fmt['width'], header=None)
