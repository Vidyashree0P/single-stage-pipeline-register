# Single Stage Pipeline Register

This project implements a single-stage pipeline register in SystemVerilog using a valid/ready handshake.

The pipeline register is placed between a producer and a consumer. It can store one data value at a time. The main purpose of the design is to handle backpressure correctly without losing or duplicating data.

## Basic idea

The data flow is:

Producer -> Pipeline Register -> Consumer

The input side contains:

- `in_data`
- `in_valid`
- `in_ready`

The output side contains:

- `out_data`
- `out_valid`
- `out_ready`

A transfer happens only when both valid and ready are high.

For the input side:

`in_valid && in_ready`

For the output side:

`out_valid && out_ready`

## Backpressure

Backpressure happens when the pipeline contains valid data but the consumer is not ready.

For example:

`out_valid = 1`

`out_ready = 0`

In this condition, the pipeline must hold the current data until the consumer becomes ready. The stored value should not be overwritten.

## Ready logic

The main handshake logic used in the design is:

`in_ready = !valid_reg || out_ready`

This means the pipeline can accept new data when:

1. The register is empty.
2. The current output data is being consumed.

This also allows the pipeline to consume the old data and accept new data in the same clock cycle.

## Internal registers

The design uses two registers:

- `data_reg` stores the actual data.
- `valid_reg` indicates whether the stored data is valid.

During reset, `valid_reg` is cleared so that the pipeline starts in an empty state.

## Testbench

The testbench checks the following cases:

- Normal data transfer
- Data consumption
- Backpressure
- Holding data while the consumer is not ready
- Releasing backpressure
- Consuming old data and accepting new data in the same cycle

## Simulation results
<img width="877" height="525" alt="Screenshot 2026-07-03 225529" src="https://github.com/user-attachments/assets/3769d538-9316-4a67-b98d-573b0bb49fbc" />


