using Weave
function weave2(path)
weave(path, doctype = "github")
outfile = splitext(path)
outname = outfile[1]
cstring = `sed -i 's/figures\//\/figures\//g' $outname.md`
run(cstring)
end
