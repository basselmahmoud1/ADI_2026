# ============================================================================
# Makefile for CFS Aligner Simulation
# UVM-based verification environment
# ============================================================================

# Tool and Options (QuestaSim)
VLIB ?= vlib
VLOG ?= vlog
VSIM ?= vsim

# Simulation directories and files
RTL_FILELIST = filelist_rtl.f
TB_FILELIST = filelist_tb.f
WORK_DIR = work
COMPILE_LOG = compile.log
SIM_LOG = sim.log

# Simulation parameters
TIMESCALE = -timescale 1ns/1ns
UVM_HOME ?= $(QUESTA_HOME)/verilog_src/uvm-1.2
DEFINES = +define+UVM_NO_DEPRECATED +define+UVM_VERSION=1200
COVER_OPTS = +cover=bcesfx
DESIGN_COVERAGE_DUS = work.FFT_WRAPPER work.FFT_Top work.BUTTERFLY work.SDF_STAGE work.Complex_MULT work.Control_unit work.Counter work.DELAY work.ROM work.Complex_pack

# DUT module name
DUT_MODULE = FFT_WRAPPER

# Top module name
TB_TOP = top

# Test to run
TEST ?= fft_test_matlab

TESTS = fft_test_all_zeros fft_test_alternating fft_test_real_ramp fft_test_deterministic_complex fft_test_impulse_n0 fft_test_impulse_n3 fft_test_dc_pos fft_test_dc_neg fft_test_cos_bin1 fft_test_complex_sinusoid_bin1 fft_test_lsb_pattern fft_test_max_positive_impulse fft_test_min_negative_impulse fft_test_maxmin_pair fft_test_mixed_corners

# Simulation run time
RUNTIME ?= 1us

# ============================================================================
# Default target
# ============================================================================
.PHONY: all
all: compile elaborate simulate

# ============================================================================
# Compilation target
# ============================================================================
.PHONY: compile
compile: $(WORK_DIR)
	@echo "=== Compiling RTL ==="
	$(VLOG) -work $(WORK_DIR) -sv -mfcu $(TIMESCALE) $(COVER_OPTS) -f $(RTL_FILELIST) -l $(COMPILE_LOG)
	@echo "=== Compiling Testbench ==="
	$(VLOG) -work $(WORK_DIR) -sv -mfcu $(TIMESCALE) $(DEFINES) $(COVER_OPTS) -L $(UVM_HOME) -f $(TB_FILELIST) -l $(COMPILE_LOG)

$(WORK_DIR):
	@echo "=== Creating library $(WORK_DIR) ==="
	$(VLIB) $(WORK_DIR)

# ============================================================================
# Elaboration target
# ============================================================================
.PHONY: elaborate
elaborate:
	@echo "=== No separate elaboration step for QuestaSim ==="

# ============================================================================
# Simulation target
# ============================================================================
.PHONY: simulate
simulate:
	@echo "=== Running Simulation (Batch Mode) ==="
	$(VSIM) -work $(WORK_DIR) -c -do "coverage save -onexit $(TEST).ucdb; run $(RUNTIME); quit" \
		-coverage -cover bcesfx -voptargs="+acc=npr+cover=bcesfx" \
		-suppress 12110 \
		+UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-l $(SIM_LOG) \
		$(TB_TOP)

.PHONY: coverage_report
coverage_report:
	@echo "=== Generating separate code coverage report (excluding functional covergroups) ==="
	powershell -NoProfile -Command "if (!(Test-Path 'reports')) { New-Item -ItemType Directory -Path 'reports' | Out-Null }; if (!(Test-Path 'reports/coverage')) { New-Item -ItemType Directory -Path 'reports/coverage' | Out-Null }"
	vcover report -code bcesfx -html -output reports/coverage/html regression.ucdb
	vcover report -code bcesfx -details -output reports/coverage/coverage_report.txt regression.ucdb
	vcover report -code bcesfx -summary -output reports/coverage/coverage_summary.txt regression.ucdb

.PHONY: design_coverage
design_coverage:
	@echo "=== Generating design-only code coverage report ==="
	powershell -NoProfile -Command "if (!(Test-Path 'reports')) { New-Item -ItemType Directory -Path 'reports' | Out-Null }; if (!(Test-Path 'reports/design')) { New-Item -ItemType Directory -Path 'reports/design' | Out-Null }"
	vcover report -code bcesfx -du=work.FFT_WRAPPER -details -output reports/design/FFT_WRAPPER_cov.txt regression.ucdb
	vcover report -code bcesfx -du=work.FFT_Top -details -output reports/design/FFT_Top_cov.txt regression.ucdb
	vcover report -code bcesfx -du=work.BUTTERFLY -details -output reports/design/BUTTERFLY_cov.txt regression.ucdb
	vcover report -code bcesfx -du=work.SDF_STAGE -details -output reports/design/SDF_STAGE_cov.txt regression.ucdb

.PHONY: final_design_report
final_design_report:
	@echo "=== Generating final RTL-only coverage summary (toggle + branch + statement) ==="
	powershell -NoProfile -Command "if (!(Test-Path 'reports')) { New-Item -ItemType Directory -Path 'reports' | Out-Null }; if (!(Test-Path 'reports/final')) { New-Item -ItemType Directory -Path 'reports/final' | Out-Null }; \
		$$duList = @('FFT_WRAPPER','FFT_Top','BUTTERFLY','SDF_STAGE'); \
		$$out = 'reports/final/design_final_coverage.txt'; \
		$$tmp = @(); \
		foreach ($$du in $$duList) { \
			$$path = \"reports/final/$$du.txt\"; \
			& vcover report -code bcesfx -du=work.$$du -details -output $$path regression.ucdb; \
			if (Test-Path $$path) { $$tmp += $$path }; \
		}; \
		if ($$tmp.Count -gt 0) { Get-Content $$tmp | Set-Content $$out; Write-Host \"Merged design coverage report: $$out\" } else { 'No design code coverage data found in regression.ucdb' | Set-Content $$out; Write-Host \"No design code coverage data found in regression.ucdb\" }"

.PHONY: regression
regression: compile
	@echo "=== Running Regression Suite ==="
	powershell -NoProfile -Command "if (!(Test-Path 'runs_outputs')) { New-Item -ItemType Directory -Path 'runs_outputs' | Out-Null }; \
		$$tests = '$(TESTS)'.Split(' '); \
		$$failed = @(); \
		foreach ($$t in $$tests) { \
			if ($$t.Trim() -ne '') { \
				Write-Host \"=== Running $$t ===\"; \
				$$log = \"runs_outputs/$$t/sim.log\"; \
				if (!(Test-Path \"runs_outputs/$$t\")) { New-Item -ItemType Directory -Path \"runs_outputs/$$t\" | Out-Null }; \
				& '$(VSIM)' -work '$(WORK_DIR)' -c -do \"coverage save -onexit runs_outputs/$$t/$$t.ucdb; run $(RUNTIME); quit -f\" -coverage -voptargs=\"+acc=npr+cover=bcesfx\" -suppress 12110 +UVM_TESTNAME=$$t +UVM_VERBOSITY=UVM_MEDIUM -l $$log $(TB_TOP); \
				if ($$LASTEXITCODE -ne 0) { $$failed += $$t }; \
				Copy-Item -Path 'fft_in.txt', 'fft_out_ref.txt', 'dut_out.txt' -Destination \"runs_outputs/$$t/\" -ErrorAction SilentlyContinue; \
			} \
		}; \
		if ($$failed.Count -gt 0) { Write-Error (\"Regression failed for: \" + ($$failed -join ', ')); } else { Write-Host \"All tests completed successfully.\" }"
	@echo "=== Merging Coverage ==="
	powershell -NoProfile -Command "& vcover merge -out regression.ucdb (Get-ChildItem -Path runs_outputs -Recurse -Filter *.ucdb | Select-Object -ExpandProperty FullName)"
	vcover report -html -output cov_report regression.ucdb
	$(MAKE) coverage_report
	@echo "=== Generating MATLAB Plots ==="
	matlab -batch "plot_regression; exit"

# ============================================================================
# GUI Simulation target
# ============================================================================
.PHONY: simulate_gui
simulate_gui:
	@echo "=== Running Simulation (GUI Mode) ==="
	$(VSIM) -work $(WORK_DIR) -gui \
		-voptargs="+acc=npr" \
		-suppress 12110 \
		+UVM_TESTNAME=$(TEST) \
		+UVM_VERBOSITY=UVM_MEDIUM \
		-l $(SIM_LOG) \
		$(TB_TOP) &

# ============================================================================
# One-step simulation (batch and GUI)
# ============================================================================
.PHONY: sim
sim: clean compile simulate

.PHONY: gui
gui: clean compile simulate_gui

# ============================================================================
# View waveforms
# ============================================================================
.PHONY: wave
wave:
	powershell -NoProfile -Command "Start-Process -FilePath '$(VSIM)' -ArgumentList @('-work','$(WORK_DIR)','-view','vsim.wlf')"

# ============================================================================
# Clean targets
# ============================================================================
.PHONY: clean
clean:
	@echo "=== Cleaning simulation artifacts ==="
	powershell -NoProfile -Command "if (Test-Path '$(WORK_DIR)') { Remove-Item -Recurse -Force '$(WORK_DIR)' }; Get-ChildItem -Path . -Include '*.log','*.wdb','*.wlf','*.history','transcript','modelsim.ini','.modelsim','*.ucdb','coverage_report.txt','coverage_summary.txt' -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue; Get-ChildItem -Path . -Recurse -Include '*.o' -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue"

.PHONY: cleanall
cleanall: clean
	@echo "=== Full cleanup ==="
	powershell -NoProfile -Command " \
		@('runs_outputs','cov_report','results','reports') | ForEach-Object { \
			if (Test-Path $$_) { Remove-Item -Recurse -Force $$_; Write-Host \"Removed: $$_\" } \
		}"

# ============================================================================
# Help target
# ============================================================================
.PHONY: help
help:
	@echo "CFS Aligner Simulation Makefile (QuestaSim)"
	@echo ""
	@echo "Available targets:"
	@echo "  make all          - Compile and simulate (batch mode)"
	@echo "  make compile      - Compile RTL and TB"
	@echo "  make simulate     - Run simulation (batch mode)"
	@echo "  make regression   - Run all FFT regression tests and generate coverage reports"
	@echo "  make coverage_report - Generate a separate coverage-only report"
	@echo "  make simulate_gui - Run simulation in QuestaSim GUI"
	@echo "  make sim          - Clean, compile, and simulate (batch mode)"
	@echo "  make gui          - Clean, compile, and simulate in GUI"
	@echo "  make wave         - View waveforms from last run"
	@echo "  make clean        - Remove compilation artifacts"
	@echo "  make cleanall     - Remove all generated files"
	@echo "  make help         - Display this help message"
	@echo ""
	@echo "Variables:"
	@echo "  VLIB=<tool>       - Library manager (default: vlib)"
	@echo "  VLOG=<tool>       - Verilog compiler (default: vlog)"
	@echo "  VSIM=<tool>       - Simulator (default: vsim)"
	@echo "  TEST=<test_name>  - Test to run (default: fft_test_matlab)"
	@echo "  RUNTIME=<time>    - Run duration for each sim (default: 1us)"
	@echo ""
	@echo "Examples:"
	@echo "  make TEST=fft_test_reg_access"
	@echo "  make regression"
	@echo "  make VLOG='vlog -O5'"
