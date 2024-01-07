#!/usr/bin/env bash
cat << EOF > ./clq.py
import pandas as pd
import numpy as np
import heapq
import networkx as nx

# read citation graph
cit_G = nx.read_gexf("citation_graph.gexf")

# important "connector" between the different parts of the graph
btw_centrality = nx.betweenness_centrality(cit_G, normalized=True)
keys_of_largest = heapq.nlargest(3, btw_centrality, key=btw_centrality.get)


btw_centrality_values = list(dict(btw_centrality).values())
q1c = np.percentile(btw_centrality_values, 25)
q3c = np.percentile(btw_centrality_values, 75)
iqr = q3c - q1c
upper_bound = q3c + 1.5 * iqr

print("The node(s)")
print([(k,btw_centrality[k]) for k in keys_of_largest if float(btw_centrality[k]) > upper_bound])
print("can be considered as important connector(s) as their betweenness-centrality lies over the upper bound of", upper_bound)


# how degree of citation varies among the graph nodes
print("\n\nhow does the degree vary?")

in_degrees = list(dict(cit_G.in_degree).values())
range = [max(in_degrees), min(in_degrees)]
q1 = np.percentile(in_degrees, 25)
q3 = np.percentile(in_degrees, 75)
iqr = q3 - q1
std = np.std(in_degrees)

print("range: ", range)
print("interquartile Range: ", iqr)
print("standard deviation: ", std)


# average length of the shortest path among nodes
print("\n\nwhat is the average length of the shortest path among nodes")
print("concentrating only on the graph's connected compoenents with more than 1 node")
components = nx.strongly_connected_components(cit_G)
sum = 0
number_of_nodes = 0
for C in (cit_G.subgraph(c).copy() for c in components):
  if C.number_of_nodes() > 1:
    number_of_nodes += C.number_of_nodes()
    sum += nx.average_shortest_path_length(C)*C.number_of_nodes()
mean = sum / number_of_nodes
print("The average path length is:", mean)


EOF

python3  clq.py
