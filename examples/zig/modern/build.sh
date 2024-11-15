rm -rf zig-out &&\
zig build -Dlog=true &&\
cp /Users/fedejinich/Projects/BitVMX/pokemon-bitvmx/engine/examples/zig/modern/zig-out/bin/pkmn_battle ../../../../../fork/BitVMX-CPU/pkmn_battle.elf &&\
cd ../../../../../fork/BitVMX-CPU/ &&\
cargo run --release --bin emulator -- execute --elf pkmn_battle.elf --debug

