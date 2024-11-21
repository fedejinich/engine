rm -rf zig-out &&\
zig build -Dlog=true &&\
cp /Users/fedejinich/Projects/BitVMX/pokemon-bitvmx/engine/examples/zig/pkmn_guess/zig-out/bin/pkmn_guess ../../../../../fork/BitVMX-CPU/pkmn_guess.elf &&\
cd ../../../../../fork/BitVMX-CPU/ &&\
cargo run --release --bin emulator -- execute --elf pkmn_guess.elf --debug

