using Pkg
pkg"activate ."
pkg"instantiate"
using DataFrames
using GLM
x1 = rand(100); x2 = rand(100); eps = rand(100)
y = 2x1 .+ 3x2 .+ eps
df = DataFrame(y = y, x1 = x1, x2 = x2, eps = eps)
ols = lm(@formula(y ~ x1 + x2), df)
