import pandas as pd
import plotly.express as px

df = pd.read_csv('results/benchmark-facts.csv')

fig = px.line(df, x = 'foo', y='bar')
fig.show()
