
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nhppp

<!-- badges: start -->
<!-- badges: end -->

nhppp is a package for simulating events from one dimensional
nonhomogeneous Poisson point processes (NHPPPs). Its functions are based
on three algorithms that provably sample from a target NHPPP: the
time-transformation of a homogeneous Poisson process (of intensity one)
via the inverse of the integrated intensity function; the generation of
a Poisson number of order statistics from a fixed density function; and
the thinning of a majorizing NHPPP via an acceptance-rejection scheme.

## Installation

You can install the release version of nhppp from
[CRAN](https://cran.r-project.org) with:

``` r
install.packages("nhppp")
```

You can install the development version of nhppp from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("bladder-ca/nhppp-fast")
```

## Example

These examples use the generic function `draw()`, which is a wrapper for
the packages specific functions.

Consider the time varying intensity function
$\lambda(t) = e^{(0.2t)} (1 + \sin t)$, which is a sinusoidal intensity
function with an exponential amplitude. To draw samples over the
interval $(0, 6\pi]$ execute

``` r
l <- function(t) (1 + sin(t)) * exp(0.2 * t)
nhppp::draw(lambda = l, lambda_maj = l(6 * pi), range_t = c(0, 6 * pi))
#>   [1]  0.3354801  0.6505060  1.4097894  1.5676940  1.7358911  1.9131508
#>   [7]  1.9737881  2.2098840  2.5705468  2.8397478  5.3508710  6.0538141
#>  [13]  6.4877669  6.5107116  6.5354138  6.7259310  6.8036155  6.8703453
#>  [19]  6.8896877  6.9845527  7.0393689  7.1054751  7.1357530  7.3186578
#>  [25]  7.4549845  7.5184520  7.7489638  7.7885526  7.9012476  7.9493542
#>  [31]  8.0612577  8.4450296  8.5070941  8.7115539  8.7656070  9.0119827
#>  [37]  9.1444129  9.2758313  9.3538021  9.5308830  9.7138569  9.8175127
#>  [43] 11.4647933 11.7739005 12.2918744 12.3127056 12.4934561 12.5647457
#>  [49] 12.5664158 12.6675963 12.7839872 12.8051428 12.8620237 12.8667452
#>  [55] 13.1271710 13.1526868 13.1527749 13.1689267 13.2097363 13.2283006
#>  [61] 13.2336307 13.2609392 13.2910422 13.3246176 13.3441446 13.3544934
#>  [67] 13.4897336 13.5706225 13.6397087 13.6603564 13.6925110 13.7228941
#>  [73] 13.7251209 13.7589662 13.8098993 13.8146846 13.8218888 13.8230978
#>  [79] 13.8726924 13.8954428 14.0266233 14.0299753 14.0371879 14.0569433
#>  [85] 14.0816362 14.1298941 14.1442716 14.1608296 14.1907810 14.2232989
#>  [91] 14.2297653 14.2418815 14.2525792 14.2901158 14.3388520 14.3825034
#>  [97] 14.3905609 14.3931200 14.4102922 14.4171276 14.4463263 14.4496671
#> [103] 14.4588386 14.4801247 14.5267554 14.5501699 14.5507369 14.5593587
#> [109] 14.5824354 14.5825395 14.6114379 14.6350751 14.6775630 14.6885774
#> [115] 14.7251517 14.7971101 14.7985100 14.8059009 14.8248833 14.8811379
#> [121] 14.9398484 14.9714657 14.9994710 15.0966395 15.1259929 15.1412950
#> [127] 15.1897579 15.2174454 15.2270633 15.2505936 15.3914247 15.4015772
#> [133] 15.4342544 15.4383058 15.5198975 15.5611883 15.5822465 15.5891518
#> [139] 15.6018186 15.6171965 15.6503623 15.6604595 15.6664968 15.6928809
#> [145] 15.7122136 15.7287431 15.7540923 15.7830185 15.8343942 15.8506968
#> [151] 15.8543178 15.9115610 15.9334397 15.9864236 16.1026261 16.1340495
#> [157] 16.1847869 16.5541471 16.8041495 17.5921456 17.9288827 18.0103773
#> [163] 18.0810064 18.0827247 18.0841271 18.1020393 18.1382742 18.1838412
#> [169] 18.2418489 18.2822233 18.2898876 18.3667187 18.5023333 18.5493198
#> [175] 18.5531302 18.5872299 18.6505875 18.6738891 18.7247932 18.7302264
#> [181] 18.7434047 18.7562145
```

where `lambda_maj` is a majorizer constant.

When available, the integrated intensity function
$\Lambda(t) = \int_0^t \lambda(s) \ ds$ and it’s inverse
$\Lambda^{-1}(z)$ result in faster simulation times. For this example,
$\Lambda(t) = \frac{e^{0.2t}(0.2 \sin t - \cos t)+1}{1.04} + \frac{e^{0.2t} - 1}{0.2}$;
$\Lambda^{-1}(z)$ is constructed numerically upfront (or can be
calculated numerically by the function, at a computational cost).

``` r
L <- function(t) {
  exp(0.2 * t) * (0.2 * sin(t) - cos(t)) / 1.04 +
    exp(0.2 * t) / 0.2 - 4.038462
}
Li <- approxfun(x = L(seq(1, 6 * pi, 10^-3)), y = seq(1, 6 * pi, 10^-3))

nhppp::draw(Lambda = L, Lambda_inv = Li, range_t = c(0, 6 * pi))
#>   [1]        NA  1.632962  1.640155  1.721889  1.767939  2.113553  2.565825
#>   [8]  2.714186  3.798061  5.889798  5.979756  6.088280  6.884137  7.043251
#>  [15]  7.158935  7.206599  7.211111  7.226626  7.337930  7.407738  7.440669
#>  [22]  7.839326  7.928614  8.083408  8.209850  8.221786  8.275796  8.299597
#>  [29]  8.377423  8.663376  8.741127  8.868777  8.890085  8.913354  8.999144
#>  [36]  9.242002  9.680449  9.687528 10.014446 10.169445 10.234805 11.443499
#>  [43] 12.135033 12.238656 12.495400 12.534235 12.678579 12.790442 12.926655
#>  [50] 12.997778 13.022921 13.029120 13.078600 13.087348 13.106726 13.209852
#>  [57] 13.309180 13.325129 13.349460 13.374909 13.394878 13.411859 13.458509
#>  [64] 13.571011 13.719951 13.786978 13.803132 13.842302 13.853168 13.878493
#>  [71] 13.897509 13.907543 13.916104 13.927014 13.966204 13.978521 14.055814
#>  [78] 14.062522 14.062897 14.064301 14.065220 14.073883 14.082337 14.095108
#>  [85] 14.113470 14.115436 14.165635 14.174431 14.191783 14.209200 14.219398
#>  [92] 14.236415 14.280362 14.280732 14.285417 14.291834 14.345249 14.436232
#>  [99] 14.440052 14.487727 14.509201 14.522295 14.584480 14.601286 14.603546
#> [106] 14.606520 14.619099 14.664139 14.672185 14.692418 14.720232 14.807475
#> [113] 14.835971 14.884200 14.894250 15.010150 15.060233 15.074905 15.091131
#> [120] 15.092968 15.104226 15.124932 15.175594 15.204130 15.235355 15.260177
#> [127] 15.306438 15.346476 15.385195 15.393521 15.400245 15.409266 15.415258
#> [134] 15.425376 15.431110 15.450365 15.517448 15.519524 15.570211 15.570731
#> [141] 15.594144 15.616633 15.627698 15.683188 15.704957 15.795861 15.816035
#> [148] 15.933711 15.939821 16.046620 16.072435 16.239493 16.376365 18.008174
#> [155] 18.287644 18.316276 18.359368 18.403615 18.442066 18.527402 18.585253
#> [162] 18.659434 18.695921 18.733012 18.740082 18.801975 18.811325 18.818860
```
