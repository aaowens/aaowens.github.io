## Run this file to generate the blog posts

using Pipe
include("weave2.jl")

RUNALL = false

if RUNALL
	files = readdir()
else
	files = ["2020-02-11-Using-the-Panel-Study-of-Income-Dynamics.jmd"] # Put new posts to run here
end
jmd = @pipe splitext.(files) |> filter(x -> x[2] == ".jmd", _)
jmdfiles = reduce.(*, jmd)
#jmdfiles = filter(x -> splitext(x)[2] == ".jmd", files)
weave2.(jmdfiles)
mdfiles = [x[1] * ".md" for x in jmd]
reads(x) = read(x, String)
for f in mdfiles
    write(f, reads("header.txt")* reads(f))
    mv(f, "../_posts/$f", force = true)
end

for f in readdir("figures")
    mv("figures/$f", "../figures/$f", force = true)
end
