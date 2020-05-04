set dir [pwd]
puts "Here I am: $dir"

set fp [open "./src/rtl/params.vh" r]
set file_data [read $fp]
close $fp

set lines [split $file_data "\n"]
set stripped [string map {" " ""} $lines]
# set pattern \=(.*?)\;
set pattern parameterTX_SIZE\=(.*?)\;
set matches [regexp -inline $pattern $stripped]
set tx_wdith [lindex $matches 1]

puts $tx_wdith

if {$tx_wdith == 512} {
    puts "Configuring the interface for 512-bit data transfers"
    startgroup
    set_property -dict [list CONFIG.M_TDATA_NUM_BYTES {64}] [get_bd_cells Interface_Cell/axis_dwidth_converter_0]
    set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {64}] [get_bd_cells Interface_Cell/axis_dwidth_converter_1]
    endgroup
} elseif {$tx_wdith == 1024} {
    puts "Configuring the interface for 1024-bit data transfers"
    startgroup
    set_property -dict [list CONFIG.M_TDATA_NUM_BYTES {128}] [get_bd_cells Interface_Cell/axis_dwidth_converter_0]
    set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {128}] [get_bd_cells Interface_Cell/axis_dwidth_converter_1]
    endgroup
} else {
    puts "ERROR: TX_SIZE parameter (in params.vh) must be set to either 512 or 1024!"
}

validate_bd_design -force
