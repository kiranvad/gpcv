Active Search Toolbox for MATLAB
================================

This repository contains MATLAB code for performing _active search,_
as described in the following paper:
> Garnett, R., Krishnamurthy, Y., Xiong, X., Schneider, J., and Mann,
> R. Bayesian Optimal Active Search and Surveying. (2012).
> International Conference on Machine Learning (ICML 2012).

This code is designed for use with the
[Active Learning Toolbox for MATLAB](https://github.com/rmgarnett/active_learning).

Note
----

All code here assumes that the positive/sought class is encoded by
"1"; all other classes are treated as uninteresting.

Contents
--------

The following files are provided.

### Utilities

* `search_expected_utility`: a score function implementing the
  (one-step) active search expected utility, for use directly in
  `argmax` (for one-step lookahead) or with
  `expected_utility_lookahead` (for multiple-step lookahead).
* `search_utility`: a utility function implementing the active search
  utility.

### Pruning

The following files enable pruning the search space as described in
the above paper. The pruning method relies on a bound on the maximum
probability of being positive after observing a given additional
number of positive observations. An interface is specified in
`expected_search_utility_bound`, and one implementation is provided,
corresponding to `knn_model` in the Active Learning Toolbox. To use
pruning with a different model, you should write a probability bound
corresponding to this interface and pass it to
`active_search_bound_selector`.

* `active_search_bound_selector`: a selector implementing the pruning
  method; only potentially optimal unlabeled points are selected
* `expected_search_utility_bound`: a generic implementation of the
  required bound on expected utility to enable pruning, used by
  `active_search_bound_selector`
* `knn_probability_bound`: an implementation of the probability bound
  required by `expected_search_utility_bound` for `knn_model` in the
  Active Learning Toolbox
