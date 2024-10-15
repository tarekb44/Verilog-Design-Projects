Overview

This is a design of a Read-Only Memory (ROM) module with parity checking implemented in Verilog. The ROM module is designed to store 4-bit wide data across 16 addresses, with each data entry accompanied by a parity bit for error detection.

Features
	•	Parity Checking: Implements even parity checking for error detection. Each data entry has an associated parity bit calculated using an XOR operation over the data bits.
	•	Asynchronous Reset: Supports an asynchronous reset signal to initialize the ROM’s output and parity error flag to known states.
	•	Enable Signal: Includes an enable signal to control when the ROM outputs valid data.
	•	Parity Error Flag: Outputs a parity error flag that indicates when a parity mismatch is detected during a read operation.

Testbench Highlights
	•	Clock Generation: Simulates a clock signal with a 10-time unit period to drive the ROM module.
	•	Reset Testing: Verifies the ROM’s behavior upon activation and deactivation of the reset signal.
	•	Functional Verification: Reads data from various addresses to ensure correct data output when the ROM is enabled.
	•	Parity Error Injection: Forces incorrect parity bits at specific addresses to test the ROM’s ability to detect and flag parity errors.
	•	Comprehensive Output Checking: Compares the ROM’s outputs against expected values for both data and parity error flags, reporting successes and discrepancies.

Verification Strategy
	1.	Initialization Check: Confirms that the ROM outputs zeroed data and a cleared parity error flag after a reset.
	2.	Normal Operation: Reads from multiple addresses with correct parity to ensure the ROM outputs the correct data and indicates no parity error.
	3.	Disable Functionality: Disables the ROM to verify that it outputs invalid data and an undefined parity error flag.
	4.	Parity Error Detection: Forces incorrect parity bits and reads from the affected addresses to ensure the ROM detects and flags the parity errors appropriately.

Simulation Results
	•	Successful Data Reads: The ROM correctly outputs the expected data for all addresses when enabled and no parity errors are present.
	•	Parity Error Detection: The ROM successfully detects and flags parity errors when the parity bits are intentionally corrupted.
	•	Reset Behavior: Upon reset, the ROM outputs are correctly initialized, and normal operation resumes after deactivation of the reset signal.
	•	Enable Control: The ROM outputs invalid data and an undefined parity error flag when the enable signal is deasserted, as expected.

Tools Used
	•	Verilog HDL
	•	Riviera-PRO Simulator