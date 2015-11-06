This is an organized version of the software for paper

Yifei Ma, Tzu-Kuo Huang, Jeff Schneider, Active Search and Bandits on Graphs Using Sigma-Optimality, UAI 2015.

It repreduces Figure 2 and Figure 3(a) as of now.


## HOW TO USE

* $git clone this/repository/from/top/of/page

* $cd code

* Enter matlab

* Run run_as.m with no input for a demo that reproduces the nodes selected in Figure 2(b).

* Specify "dataset" and "algorithm" to run other experiments. configure_param_choices.m will then pick the other parameters accordingly.


## TEMPORARY FILES

* Running the codes will create two directories at ~/tmp/as_logs/ and ~/tmp/as_cache/, unless another directory is specified.

* For the enron experiment, the cache file will be 2.5GB. Other temporary file sizes are minimal.

* You could turn off cache file generation by setting save_cache to false.


## RESULT FILES

* Contained both in mat file in exp/data_alg.mat and text file in exp/data_alg_selected.txt. They are the expected outputs from running the codes.


## CORE FUNCTIONALITIES

### as_sopt_vanilla.m

* Implementation of Algorithm 1 GP-SOPT(vanilla), eq (9.a).

### as_sopt_tt.m

* Implementation of Algorithm 1 GP-SOPT.TT(threshold total covariance), eq (9.b)

### as_gp_select.m

* Baseline algorithm, Hastagiri P. Vanchinathan, Andreas Marfurt, Charles-Antoine Robelin, Donald Kossmann, Andreas Krause. Discovering Valuable Items from Massive Data. SIGKDD 2015.

* Also could be thought as non-repeated selection of Michal Valko, Rémi Munos, Branislav Kveton Tomáš Kocák, Spectral Bandits for Smooth Graph Functions. ICML 2014.

## TODO
* include Xuezhi Wang, Roman Garnett, Jeff Schneider. Active Search on Graphs, SIGKDD 2013.
