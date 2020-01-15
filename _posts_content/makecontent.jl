## Run this file to generate the blog posts 

using Pipe
include("weave2.jl")

files = readdir()
jmd = @pipe splitext.(files) |> filter(x -> x[2] == ".jmd", _)
jmdfiles = reduce.(*, jmd)
#jmdfiles = filter(x -> splitext(x)[2] == ".jmd", files)
weave2.(jmdfiles)
mdfiles = [x[1] * ".md" for x in jmd]
for f in mdfiles
    mv(f, "../_posts/$f", force = true)
end

for f in readdir("figures")
    mv("figures/$f", "../figures/$f", force = true)
end
