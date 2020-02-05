exe             := scu
compiler        := g++
ld_libs         := -lcurl

$(exe): ./lex.yy.cc
	$(compiler) -o $(exe) $(ld_libs) lex.yy.cc
