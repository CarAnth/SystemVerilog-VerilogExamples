# SystemVerilog, Verilog & VHDL Examples

A collection of small RTL designs and simulation testbenches for practicing
digital design in SystemVerilog, Verilog, and VHDL. The examples cover counters,
finite state machines, UART, arbitration, FIFOs, ready/valid handshakes, and
clock domain crossing (CDC).

The counter and sequence detector have implementations in all three languages
for comparing coding styles and equivalent behavior. The other examples use
SystemVerilog.

## Examples

| Topic | Implementation | Language | Simulation target |
| --- | --- | --- | --- |
| Programmable counter | Enable, parallel load, programmable limit, one-cycle limit pulse | SystemVerilog / Verilog / VHDL | `counter-sv`, `counter-v`, `counter-vhdl` |
| Sequence detector | Overlapping `1011` detection with valid-gated input and registered match | SystemVerilog / Verilog / VHDL | `fsm-sv`, `fsm-v`, `fsm-vhdl` |
| UART transmitter | FSM-based serial transmission, 8 data bits, no parity, 1 stop bit | SystemVerilog | `uart-tx` |
| UART receiver | Start-bit qualification, serial reception, data-valid indication | SystemVerilog | `uart-rx` |
| Fixed-priority arbiter | Four requesters; requester 0 has highest priority | SystemVerilog | `fixed-arbiter` |
| Round-robin arbiter | Four requesters with rotating priority | SystemVerilog | `round-robin` |
| Synchronous FIFO | Parameterized width/depth, full/empty flags, registered read data | SystemVerilog | `sync-fifo` |
| Ready/valid buffer | One-entry data buffer with backpressure | SystemVerilog | `valid-handshake` |
| Two-flop synchronizer | Single-bit level synchronization | SystemVerilog | `two-ff` |
| Pulse synchronizer | Toggle-based pulse transfer; bench demonstrates missed fast pulses | SystemVerilog | `pulse-sync` |
| CDC handshake | Request/acknowledge toggles with a source busy flag | SystemVerilog | `cdc-handshake` |
| Multi-bit CDC | Held 8-bit payload with request/acknowledge handshake and per-domain reset synchronization | SystemVerilog | `multi-cdc` |
| Reset synchronizer | Asynchronous assertion and two-stage synchronous release | SystemVerilog | `reset-sync` |
| Asynchronous FIFO | Work in progress: interface and pointer declarations only | SystemVerilog | Not runnable yet |

## Repository layout

| Directory | Contents |
| --- | --- |
| [`examples/counters/`](examples/counters/) | Counter RTL and testbenches, separated by language |
| [`examples/fsm/`](examples/fsm/) | Sequence detector RTL and testbenches, separated by language |
| [`examples/uart/`](examples/uart/) | Separate transmitter and receiver examples |
| [`examples/arbiters/`](examples/arbiters/) | Fixed-priority and round-robin examples |
| [`examples/fifo/`](examples/fifo/) | Synchronous FIFO and asynchronous FIFO draft |
| [`examples/handshake/`](examples/handshake/) | Ready/valid buffer and testbench |
| [`examples/cdc/`](examples/cdc/) | Level, pulse, handshake, multi-bit, and reset synchronization |
| [`scripts/`](scripts/) | Python simulation runner and explicit source-file manifest |
| `build/` | Generated simulation executables and waveforms; ignored by Git |

RTL and its testbench are kept together in each example directory. Original
HDL filenames are retained. The multi-bit CDC example also depends on
`examples/cdc/reset/reset_synchronizer.sv`; the runner includes it automatically.

## Requirements

- Python 3.8 or later for the simulation runner; no third-party Python packages.
- Icarus Verilog (`iverilog` and `vvp`) for Verilog/SystemVerilog simulation.
- GHDL for VHDL simulation using VHDL-2008.
- GTKWave, optionally, for inspecting generated VCD waveforms.

The tools must be available on your terminal's `PATH`. On Windows, use
`python` in place of `python3` if that is the command installed on your system.
The runner works from PowerShell, Bash, or another terminal with these tools
on `PATH`.

## Quick start

```bash
git clone https://github.com/CarAnth/SystemVerilog-VerilogExamples.git
cd SystemVerilog-VerilogExamples

# List the runnable examples and their top-level testbench names.
python3 scripts/run.py --list

# Run one example.
python3 scripts/run.py counter-sv

# Run every supported testbench.
python3 scripts/run.py all
```

Each example runs in its own `build/<target>/` directory. This keeps waveforms
and compiled outputs out of the source directories and prevents collisions
between testbenches with the same module or entity name.

The runner returns a nonzero exit code on compilation errors, reported
testbench failures, missing tools, or timeouts. It also checks text output
because some existing benches use `$error` or `$display` without returning a
nonzero process exit code. The default timeout is 30 seconds per command:

```bash
python3 scripts/run.py uart-rx --timeout 60
```

### View a waveform

```bash
python3 scripts/run.py counter-sv
gtkwave build/counter-sv/tb_counter.vcd
```

Verilog/SystemVerilog waveform filenames are set by each testbench's
`$dumpfile` call. VHDL waveforms are named after the target, for example
`build/counter-vhdl/counter-vhdl.vcd`.

## Run manually

The Python runner is optional. The following commands start from the
repository root and use separate build directories.

### SystemVerilog counter

```bash
mkdir -p build/manual-counter-sv
cd build/manual-counter-sv
iverilog -g2012 -s tb_counter -o sim.vvp \
  ../../examples/counters/systemverilog/programmable_counter.sv \
  ../../examples/counters/systemverilog/tb_counter.sv
vvp sim.vvp
cd ../..
```

### Verilog counter

```bash
mkdir -p build/manual-counter-v
cd build/manual-counter-v
iverilog -g2012 -s tb_counter -o sim.vvp \
  ../../examples/counters/verilog/programmable_counter.v \
  ../../examples/counters/verilog/testbench.v
vvp sim.vvp
cd ../..
```

The runner and this command use `-g2012` for both `.v` and `.sv` benches;
some Verilog benches use SystemVerilog simulation tasks such as `$error`.

### VHDL counter

```bash
mkdir -p build/manual-counter-vhdl
cd build/manual-counter-vhdl
ghdl -a --std=08 \
  ../../examples/counters/vhdl/programmable_counter.vhd \
  ../../examples/counters/vhdl/tb_counter_vhdl.vhd
ghdl -e --std=08 tb_programmable_counter
ghdl -r --std=08 tb_programmable_counter \
  --assert-level=error --vcd=counter.vcd
cd ../..
```

These manual examples use Bash syntax. Use the Python runner for a consistent
command across Windows and Linux.

## Simulation status and current limitations

All **17 runnable testbenches** completed without reported errors using Icarus
Verilog 12.0 and GHDL 4.1.0 on Linux. This describes the existing directed
simulations; it does not establish exhaustive verification, synthesis results,
timing closure, or FPGA hardware validation.

- **Asynchronous FIFO:** `async_fifo.sv` is an unfinished draft, including
  syntax and port-direction issues. It has no implemented read/write logic or
  testbench and is excluded from the runner.
- **Pulse synchronization:** the current bench sends two pulses too close
  together for the destination clock and demonstrates that they can be lost.
  It is a demonstration, not a self-checking lossless-transfer test.
- **CDC verification:** the handshake bench only checks a limited condition;
  the multi-bit bench checks one payload. Digital simulation does not model
  analog metastability or establish CDC correctness in hardware.
- **UART parameters:** TX and RX currently use two-bit baud counters. The
  default four clocks per bit is exercised; larger divisors require widening
  these counters. The RX example samples `rx` directly and does not include an
  input synchronizer.
- **FIFO depth:** the synchronous FIFO uses natural binary pointer wrapping.
  Use a power-of-two depth of at least two; other depths are not supported by
  the current pointer logic.
- **VHDL practice bench:** `examples/fsm/vhdl/prac_tb.vhd` is a reset-only
  exercise with no automatic finish. Use `tb_fsmvhdl.vhd` for the runnable FSM
  test; the practice bench is excluded from `all`.
- **Timescales:** several original Verilog/SystemVerilog files have no explicit
  timescale. Interpret their delays according to the simulator default.

The reset bench waits for nonblocking assignments before checking reset
assertion, and the multi-bit CDC bench supplies a numeric code to `$fatal` for
Icarus compatibility.

## Adding an example

1. Create a topic directory under `examples/` and add the RTL and testbench.
2. Add its language, top-level testbench, and ordered source list to
   `scripts/examples.json`. Include any shared dependencies.
3. Make the testbench terminate and report mismatches clearly.
4. Run it with `python3 scripts/run.py <target>` and update the examples table.

Keep generated executables, simulator databases, and waveforms in `build/`.
They can be regenerated and should not be committed.
