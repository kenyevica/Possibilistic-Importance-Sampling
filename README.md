# Possibilistic-Importance-Sampling
The improved version of the Importance Sampling (IS) algorithm that is able to utilize possibilistic reference data.  It has been tested on a case study about parameter estimation based on uncertain expert knowledge. This repository also contains the files that relates to this research.

The folder contains the following codes:
<ul>
<li>main_IS_v4.m: analysis and testing the possibilistic IS algorithm (without and with outer iteration circle)</li>
<li> func_possibilistic_is.m: possibilistic IS algorithm with fixed iteration number</li>
<li> func_possibilistic_is_kstest.m: possibilistic IS algorithm with Kolmogorov-Smirnov test to define stopping criterion </li>
  <li> func_fuzzyfunction.m: gaining aggregated discretized function values from linguistic responses </li>
  <li> func_possibfunction_intpair.m: gaining aggregated discretized function values from interval pair responses</li>
  <li> func_intfunction.m: gaining aggregated discretized function values from single-interval estimates </li><li>func_weighting_experts.m: function for weighting expert judgments in the outer circle <em>(Sol-2 has been used in the final solution)</em> </li>
</ul>


Supplementary materials:
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.17310641.svg)](https://doi.org/10.5281/zenodo.17310641)
<ul>
<li>Questionnaire_videos.pptx: the slides that was projected during the questionnaire (in the original Hungarian language), containing the videos that should be watched 
</li>
</ul>




