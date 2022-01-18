--[[ 
Define the SIMION geometry file for a linear accelerator 
using LUA based on the repetitive nature of the setup. 
The linac is surrounded by a closed vacuum chamber. 
A front electrode should mimic the exit from an ion trap. 
A back electrode forms the target for the accelerated ions. 
Dr. N. Hendrik Nahler -- Heriot-Watt University 
Heather Blatchford -- Heriot-Watt University 
March 2021 
--]] 
-- Functions 
local function write_file(filename, data) 
  local fh = assert(io.open(filename, 'wb')) 
  fh:write(data) 
  fh:close() 
  end 
 -- End of Functions 
  
-- Name of gem output file 
filebase = 'L1Test' 
gemfile = filebase ..'.gem' 
pafile = filebase ..'.pa#' 

-- Convergence for the PA 
convergence = 1e-5 

-- Store all variables in a single table with identifiers. Dimension: mm  
dim = {} 
dim.NumberOfElectrodes = 12 -- number of repeating linac electrodes  
dim.ElectrodeRadius = 30 -- outside radius of the linac electrodes  
dim.ElectrodeBoreRadius = 10 -- radius of the centre bore of the linac
dim.ElectrodeLength = 20 -- width of the repetitive linac electrodes  
dim.ElectrodeSpacing = 2 -- Space between linac electrodes 
dim.VacuumSpacing = 10 -- spacing between outside of electrodes and wall  on ground 
dim.FrontThickness = 5 -- Thickness of front entrance plate  
dim.FrontSpacing = 2 -- Space between front plate and first Electrode  
dim.BackThickness = 5 -- Thickness of back plate / target  
dim.BackSpacing = 10 -- Space between linac and target  
dim.OutsideThickness = 5 -- Thickness of the outside wall   
-- Calculated dimensions 
-- Overall length of the setup 
dim.Length = 2*dim.VacuumSpacing + dim.FrontThickness + dim.FrontSpacing +  dim.NumberOfElectrodes*(dim.ElectrodeLength + dim.ElectrodeSpacing) -  dim.ElectrodeSpacing + dim.BackSpacing + dim.BackThickness + 
2*dim.OutsideThickness 
-- Overall radius of the setup 
dim.Radius = dim.ElectrodeRadius + dim.VacuumSpacing + dim.OutsideThickness  -- Dimensions finished 

-- Test Output 
-- print("Length = ",dim.Length) 
-- print("Radius = ",dim.Radius) 
-- End test output 

-- Assemble string for SIMION GEM file 
j = 1 -- increment variable for the electrodes 
-- Vacuum chamber 
local gem = "pa_define(" .. dim.Length .. "," .. dim.Radius ..  
",1,cyl,y,elect,surface=fractional)\n" 
gem = gem .. "e(" .. j .. ") { fill { within { box(0,0," .. dim.Length .. "," .. dim.Radius ..") }\n notin { box(" .. dim.OutsideThickness .. ",0," .. (dim.Length - dim.OutsideThickness) .. "," .. (dim.Radius - dim.OutsideThickness) ..") } } }\n" 
j = j+1 

-- Repelling electrode simulating exit from ion trap 
x_offset = dim.OutsideThickness + dim.VacuumSpacing + dim.FrontThickness 
gem = gem .. "e(" .. j .. ") { fill { within { box(" .. (x_offset - dim.FrontThickness) ..  ",0," .. x_offset .. "," .. dim.ElectrodeRadius .. ") } } }\n" 
j = j+1 
-- Stack of repeating electrodes in the linac
x_offset = x_offset + dim.FrontSpacing 
for i=1,dim.NumberOfElectrodes do 
x_start = x_offset + ((i-1) * (dim.ElectrodeSpacing + dim.ElectrodeLength))  x_stop = x_start + dim.ElectrodeLength 
gem = gem .. "e(" .. j .. ") { fill { within { box(" .. x_start .. "," ..  dim.ElectrodeBoreRadius .. "," .. x_stop .. "," .. dim.ElectrodeRadius .. ") } } }\n" 
j = j+1 
end 

-- End electrode and target 
gem = gem .. "e(" .. j .. ") { fill { within { box(" .. (dim.Length - dim.OutsideThickness - dim.VacuumSpacing - dim.BackThickness) .. ",0," .. (dim.Length - dim.OutsideThickness - dim.VacuumSpacing) .. "," .. dim.ElectrodeRadius .. ") } } }\n" 

-- GEM file string finalised. --> Write output to file 
write_file(gemfile, gem) 

-- Print gem file to command prompt 
-- print(gem) 

-- load gem file to PA 
local pa = simion.open_gem(gemfile):to_pa() 
pa:refine{convergence=convergence} 
pa:save(pafile) 
