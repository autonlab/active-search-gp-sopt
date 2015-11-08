This is an organized version of the software for paper

Yifei Ma, Tzu-Kuo Huang, Jeff Schneider. "Active Search and Bandits on Graphs Using Sigma-Optimality". UAI 2015.
Paper available at http://www.autonlab.org/autonweb/23145.html and ID 307 in http://auai.org/uai2015/proceedings.shtml

The code partially repreduces **Figure 2** and **Figure 3**; could also be used for **general** active search/bandit problems as long as either 

* matrix **A** is given as the adjacency matrix of k-nearest-neighbour graph, A_{ij} = [node_i is neighbor of node_j] + [node_j is neighbor of node_i],

* or,

* matrix **C** given as kernel matrix of examples, C_{ij} = k(x_i,x_j).

---

## HOW TO USE

1. Load and run demo for Figure 2(b).

		```
		git clone this/repository/from/right/of/the/page
		matlab >> cd code; run_as
		```

2. Specify **dataset** and **algorithm** to run other experiments. `code/configure_param_choices.m` will then pick the other parameters accordingly.

3. `code/run_as_par.m` for an example of parallel execution.

4. For your own experiments, assign adjacency matrix **A** or kernel matrix **C** (or both) to any of the `code/as_{algorithm_name}.m` function, tell it **labels** because it is *active*, give some extra **options** or use an empty **struct()** for default choices, and wait for the results.

5. Some simple adaptation is possible to make use of an **oracle** instead of **labels** for real active search problems.

## DEMO EXECUTION RESULTS

By simply specifying **dataset** and **algorithm** without anything else, you should get results identical what we have provided:

* **exp/{data}_{algorithm}.mat**, variables generated at the end of `code/run_as*.m`.

* **exp/{data}_{algorithm}_selected.txt**, list of selected node ids stored as a matrix of size `[time step] x [parameter choice]`.

In any case, if the plots generated from `plot(hits_top15percent ./ sum(y))` or `plot(hits ./ sum(y))` seem reasonably close to our figures, you have most-likely done it right.

## TEMPORARY FILES

Running the codes will create two directories at `$HOME/tmp/as_logs/` and `$HOME/tmp/as_cache/`, unless otherwise specified at beginning of `code/run_as*.m`. 
(Centralized paths are great if your codes run across different machines on a cluster.)
Temporary file sizes are usually minimal; you could also turn off cache file generation by setting variable `save_cache` to false.

## ALGORITHMS IMPLEMENTED (`code/as_{algorithm}.m`)

### as_sopt_vanilla.m

* Implementation of Algorithm 1 **GP-SOPT(vanilla)**, eq (9.a).

### as_sopt_tt.m

* Implementation of Algorithm 1 **GP-SOPT.TT(threshold total covariance)**, eq (9.b)

### as_gp_select.m

* Baseline algorithm, Hastagiri P. Vanchinathan, Andreas Marfurt, Charles-Antoine Robelin, Donald Kossmann, Andreas Krause. "Discovering Valuable Items from Massive Data". SIGKDD 2015.

* Also could be thought as non-repeated selection of Michal Valko, Rémi Munos, Branislav Kveton Tomáš Kocák. "Spectral Bandits for Smooth Graph Functions". ICML 2014.

## DATASET INCLUDED

* `data/toy` --- graph for Figure 2

* `data/populated_places_5000` -- Figure 3(a)

* `data/wikipedia_data` --- Figure 3(b)

* `data/new_nips` --- Fiure 3(c)

* Not included: `enron_graph`, because of its large size. --- Please contact us.

## TODO

* include Xuezhi Wang, Roman Garnett, Jeff Schneider. "Active Search on Graphs". SIGKDD 2013.
