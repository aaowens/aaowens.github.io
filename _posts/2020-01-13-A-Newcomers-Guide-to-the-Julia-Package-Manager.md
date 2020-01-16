---
categories: [julia]
---
NOTE: Some of this code, specifically the `pkg"..."` strings, is only compatible with Julia 1.3 and later. I recommend upgrading to Julia
1.3.1 if you haven't already; it's quite a bit faster at some things.

## What are Julia packages?
Unlike software packages like MATLAB and Stata, much of Julia's functionality
is found in external packages. For example, you need the DataFrames.jl package to
work with tabular data, you need the CSV.jl package to read tabular data, and you need
the Optim.jl package to solve nonlinear optimization problems. None of these packages are
installed by default. You need to add them using the Julia package manager. Let's add the
DataFrames and CSV packages to our new Julia installation.


````julia
using Pkg
pkg"add DataFrames CSV"
````


````
Resolving package versions...
  Updating `~/.julia/environments/v1.3/Project.toml`
  [336ed68f] + CSV v0.5.22
  [a93c6f00] + DataFrames v0.20.0
  Updating `~/.julia/environments/v1.3/Manifest.toml`
  [336ed68f] + CSV v0.5.22
  [324d7699] + CategoricalArrays v0.7.6
  [a93c6f00] + DataFrames v0.20.0
  [48062228] + FilePathsBase v0.7.0
  [41ab1584] + InvertedIndices v1.0.0
  [2dfb63ee] + PooledArrays v0.5.3
  [ea10d353] + WeakRefStrings v0.6.2
  [9fa8497b] + Future
````





There are many important concepts in the above output. Let's discuss them briefly:
1.  ```Updating `~/.julia/environments/v1.3/Project.toml` ``` means we are permanently adding packages to our default package environment, which lives in the file `Project.toml` stored on the computer at the path above. We'll talk more about environments later.

2. ```[336ed68f] - CSV v0.5.22``` says we added the CSV package at the version 0.5.22, which is the latest feasible version. Why do I say "feasible"? More on that later.
3. A version is a snapshot of the package code taken at a particular time. Packages change over time as they are updated by their maintainers. New features may be added, and bugs will be fixed (and introduced!). Importantly, code that works fine on version 0.5.22 of CSV may not work on a future version, like 0.6.1. This is why it's important to understand versions. Julia's package manager provides tools to make sure your code won't break in the future because of a package update.

4. ```Updating `~/.julia/environments/v1.3/Manifest.toml` ``` says we are updating the file Manifest.toml. The Manifest is more detailed than the Project file. It contains a list of every package installed, those packages' dependencies, and their precise versions. Given a Manifest.toml, you can exactly recreate the set of packages used by the code it came with, ensuring the code will work as expected.
5. ```[324d7699] - CategoricalArrays v0.7.6``` says we added the CategoricalArrays package to the Manifest. Where did this package come from? It is a dependency of DataFrames, meaning the DataFrames package uses CategoricalArrays internally.

## How do I make sure that some Julia code I found somewhere will work?

As mentioned above, packages may change their functionality in future versions. For example,
they might change the name of a function to something else. A piece of code which used the old name would break,
meaning it would not work in the future. If we are sharing some code with someone else, or we just want to ensure
our code won't break after we update our packages, we need a way to attach the desired package versions to our code. We do this by using environments.

To motivate the need for environments, let's try running this block of code

````julia
using DataFrames
using GLM
x1 = rand(100); x2 = rand(100); eps = rand(100)
y = 2x1 .+ 3x2 .+ eps
df = DataFrame(y = y, x1 = x1, x2 = x2, eps = eps)
ols = lm(@formula(y ~ x1 + x2), df)
````


````
Error: ArgumentError: Package GLM not found in current path:
- Run `import Pkg; Pkg.add("GLM")` to install the GLM package.

Error: LoadError: UndefVarError: @formula not defined
in expression starting at none:1
````





It doesn't work! This is because we never installed the GLM package.

We could add it, but how will
we know we'll have the same version the code above was written for? The safe solution is to activate
the environment associated with this code.

Let's try activating a project. Download this zip file [here](https://github.com/aaowens/aaowens.github.io/blob/master/_misc/ExampleProject.zip), which contains a Julia script,
a Project.toml, and a Manifest.toml. Unzip it and change the working directory in Julia to that folder,
then run this code.


````julia
using Pkg
pkg"activate ."
pkg"instantiate"
````


````
Activating environment at `~/Documents/data/myblog/aaowens.github.io/_posts
_content/ExampleProject/Project.toml`
````





It's important to note the file path. Projects are associated with file directories.  This code activates the environment specified by the Project.toml file in the current directory,
then instantiates the packages at the versions specified in the Manifest.toml file. Let's check what those
are by checking the package environment status.

````julia
pkg"status"
````


````
Status `~/Documents/data/myblog/aaowens.github.io/_posts_content/Exampl
eProject/Project.toml`
  [a93c6f00] DataFrames v0.20.0
  [38e38edf] GLM v1.3.5
````





At this point, the package environment is exactly as it was when the project's author wrote this code, so we can
trust that the code will work.

````julia
using DataFrames
using GLM
x1 = rand(100); x2 = rand(100); eps = rand(100)
y = 2x1 .+ 3x2 .+ eps
df = DataFrame(y = y, x1 = x1, x2 = x2, eps = eps)
ols = lm(@formula(y ~ x1 + x2), df)
````


````
StatsModels.TableRegressionModel{GLM.LinearModel{GLM.LmResp{Array{Float64,1
}},GLM.DensePredChol{Float64,LinearAlgebra.Cholesky{Float64,Array{Float64,2
}}}},Array{Float64,2}}

y ~ 1 + x1 + x2

Coefficients:
──────────────────────────────────────────────────────────────────────────
             Estimate  Std. Error  t value  Pr(>|t|)  Lower 95%  Upper 95%
──────────────────────────────────────────────────────────────────────────
(Intercept)  0.602334    0.075256   8.0038    <1e-11   0.452972   0.751696
x1           1.95099     0.107514  18.1463    <1e-32   1.7376     2.16438 
x2           2.96151     0.104047  28.4633    <1e-48   2.75501    3.16801 
──────────────────────────────────────────────────────────────────────────
````





Again, we could have just added the GLM package to our default environment and not bothered with this
separate project environment. The code would probably still work. However, this approach is safer
and guarantees that if the DataFrames or GLM interface changes in a few years, our code won't break. It also
allows us to share our code with others, and it will just work.

## Making your own project environment

In addition to using environments built by others, we would like to use them for our own
projects. Let's make a new project now. Projects in Julia are associated with file directories. To make
a new project, we just make a new directory, here called NewProject.


````julia
mkdir("NewProject")
cd("NewProject")
pkg"activate ."
pkg"instantiate"
pkg"status"
````


````
Activating new environment at `~/Documents/data/myblog/aaowens.github.io/_p
osts_content/NewProject/Project.toml`
  Updating registry at `~/.julia/registries/General`
  Updating git-repo `https://github.com/JuliaRegistries/General.git`
[?25l[2K[?25h Resolving package versions...
    Status `~/Documents/data/myblog/aaowens.github.io/_posts_content/NewPro
ject/Project.toml`
  (empty environment)
````





This is a completely empty environment, which means we can't use DataFrames right now. Let's add DataFrames
to our environment, along with BenchmarkTools.

````julia
pkg"add DataFrames BenchmarkTools"
````


````
Resolving package versions...
  Updating `~/Documents/data/myblog/aaowens.github.io/_posts_content/NewPro
ject/Project.toml`
  [6e4b80f9] + BenchmarkTools v0.4.3
  [a93c6f00] + DataFrames v0.20.0
  Updating `~/Documents/data/myblog/aaowens.github.io/_posts_content/NewPro
ject/Manifest.toml`
  [6e4b80f9] + BenchmarkTools v0.4.3
  [324d7699] + CategoricalArrays v0.7.6
  [34da2185] + Compat v3.2.0
  [9a962f9c] + DataAPI v1.1.0
  [a93c6f00] + DataFrames v0.20.0
  [864edb3b] + DataStructures v0.17.9
  [e2d170a0] + DataValueInterfaces v1.0.0
  [41ab1584] + InvertedIndices v1.0.0
  [82899510] + IteratorInterfaceExtensions v1.0.0
  [682c06a0] + JSON v0.21.0
  [e1d29d7a] + Missings v0.4.3
  [bac558e1] + OrderedCollections v1.1.0
  [69de0a69] + Parsers v0.3.10
  [2dfb63ee] + PooledArrays v0.5.3
  [189a3867] + Reexport v0.2.0
  [a2af1166] + SortingAlgorithms v0.3.1
  [3783bdb8] + TableTraits v1.0.0
  [bd369af6] + Tables v0.2.11
  [2a0f44e3] + Base64 
  [ade2ca70] + Dates 
  [8bb1440f] + DelimitedFiles 
  [8ba89e20] + Distributed 
  [9fa8497b] + Future 
  [b77e0a4c] + InteractiveUtils 
  [76f85450] + LibGit2 
  [8f399da3] + Libdl 
  [37e2e46d] + LinearAlgebra 
  [56ddb016] + Logging 
  [d6f4376e] + Markdown 
  [a63ad114] + Mmap 
  [44cfe95a] + Pkg 
  [de0858da] + Printf 
  [3fa0cd96] + REPL 
  [9a3f8284] + Random 
  [ea8e919c] + SHA 
  [9e88b42a] + Serialization 
  [1a1011a3] + SharedArrays 
  [6462fe0b] + Sockets 
  [2f01184e] + SparseArrays 
  [10745b16] + Statistics 
  [8dfed614] + Test 
  [cf7118a7] + UUIDs 
  [4ec0a83e] + Unicode
````



````julia
readdir()
````


````
2-element Array{String,1}:
 "Manifest.toml"
 "Project.toml"
````





We see that there is now a Project.toml and Manifest.toml in the NewProject directory. Julia
created these files automatically and stores the environment information there.

At this point, we can write code for our new project and store the code in .jl files or
Jupyter notebooks inside this directory. Remember to activate the environment in your code. The
first lines in the script you use to run the code should be
````julia

using Pkg
pkg"activate ."
pkg"instantiate"
````



which activates and instantiates the local (current directory) environment.

## How to distribute or archive your Julia project

Suppose you have been working on a project, whether it is a homework assignment, some research,
or a solution for a client. You want to send your code to someone else. The way to do this is simply to
zip your project folder into a file. For example, we could zip the NewProject folder we just made
into a NewProject.zip file and email the file to someone. The user then unzips the file on their computer, starts
Julia in that folder, and runs your code. The lines of code above will cause Julia to activate the project and instantiate the Manifest.toml,
guaranteeing they are using exactly the same package versions as you were.

## Updating packages

Packages are updated frequently, and you should generally try to use the latest version in order to
get performance improvements, bug fixes, and new features. Updating is easy, just do

````julia
pkg"update"
````


````
Updating registry at `~/.julia/registries/General`
  Updating git-repo `https://github.com/JuliaRegistries/General.git`
[?25l[2K[?25h Resolving package versions...
  Updating `~/Documents/data/myblog/aaowens.github.io/_posts_content/NewPro
ject/Project.toml`
 [no changes]
  Updating `~/Documents/data/myblog/aaowens.github.io/_posts_content/NewPro
ject/Manifest.toml`
 [no changes]
````





Unsurprisingly, no updates are available, since we just installed these packages. Notice that
the changes were written to `NewProject/Project.toml`, which is our current local environment. Nothing has
changed in our default environment. It's fine to have different environments using different versions of packages.

You may want to keep your default environment up to date, but avoid updating a local environment because you don't want to
break your existing code. In fact, it's a good idea to have a backup zip file of your project (including the Manifest.toml)
so that if an update breaks your code, you can instantly return to a good working version.

Earlier I mentioned that the CSV package we added was installed at the latest feasible version. Packages come with their
own list of dependencies and the acceptable versions of those dependencies. If, for example, the DataFrames package were only
compatible with version 0.4 of CSV (this is not actually true), then the latest version of CSV would not be installed. This could lead to some unexpected behavior. For example,
if you started with an empty environment and added CSV, it would install the latest version (0.5). If you then added DataFrames, CSV
would actually be downgraded to version 0.4 for compatibility reasons. Dealing with package dependencies can be
[complicated](https://en.wikipedia.org/wiki/Dependency_hell), but you will probably not have to worry about this much
if you stick to well-maintained packages and heed the following advice.

## Avoid putting all packages in your default environment

It can be tempting to not bother with activating and instantiating and just add packages
as needed to your default environment. This often works and is fairly common practice, but I recommend against it for 2 reasons.

1. It makes it harder to share your project. Your colleague probably has different packages installed. Using project specific Project.toml and Manifest.toml solves this problem.
2. Version conflicts may make it impossible to use certain packages. For example, suppose package A requires a feature introduced in version 0.20 of DataFrames, but package B only works on version 0.19 of DataFrames. It will be impossible to install package A and B at the same time because you can only have one version of a package per environment. In contrast, if you have two projects with their own local environments, the first will just use 0.20, and the second will use 0.19.

## Final thoughts

There are other ways of managing package environments. The QuantEcon ecosystem uses the package
InstantiateFromURL.jl to load the environment from the internet, so you can just execute a line of code instead
of distributing a Project.toml and Manifest.toml. This works well for them, but for individual projects it's simpler
just to zip your code along with the .toml files.

This post doesn't cover package development. For that, I recommend Chris Rackauckas's [video](https://www.youtube.com/watch?v=QVmU29rCjaA&t=2309s).
The official Pkg [documentation](https://julialang.github.io/Pkg.jl/v1/) covers package management in exhaustive detail.


