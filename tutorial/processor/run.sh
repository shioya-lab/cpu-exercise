make
cd asm
pwd
cargo run -- ./asm.txt ./out.txt
cd ..
cp asm/out.txt IMem.dat
