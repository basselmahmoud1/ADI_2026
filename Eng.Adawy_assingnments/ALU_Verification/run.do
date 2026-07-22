vlib work
vlog ALU_pkg.sv interface.sv pack.sv -l sim.log
vlog ALU.sv +cover=sbfec -coveropt 3 -l sim.log
vlog Top.sv -l sim.log
vsim -coverage -voptargs=+acc work.top
view wave
do wave.do
run -all

# Generate Coverage Reports
coverage report -html -output covhtmlreport -details
coverage report -output coverage_report.txt -details -all