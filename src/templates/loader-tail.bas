1 \
ink val "7":\
paper not pi:\
border not pi:\
bright not pi:\
flash not pi:\
inverse not pi:\
cls:\
clear val "{LoaderStart}":\
let a=val "23635":\
let b=a+sgn pi:\
let c={SkipOffset}+peek a+val "256"*peek b:\
poke c,peek a:\
poke c+sgn pi,peek b:\
randomize usr (c-sgn pi)
