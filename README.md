# Branch Predictor
This project is a multistage processor pipeline with a hybrid branch predictor.  
  
The branch predictor module implements:  
* Global branch predictor with 12 bit global history register
* Local branch predictor with 1024 entry branch history table, where each entry in BHT is a 10 bit history
* Meta predictor with 1024 entries
* Branch target buffer is a two way set associative table with 512 entries
* Return address stack with 32 entries

## Running the simulator
In order to run the simulator you must download, extract and compile the files with the provided make file.  
The extracted directory will have the following structure:
* verilog/  
this contains the verilog design files for the processor
* sim_main/  
this contains the c++ source files necessary to run the simulator
* tests/  
this contains the test files for the simulator  
  
In order to test the simulator you will have to call the executable and provide it with one of the test files like so:  
>./VMIPS -f tests/cpp/hello -d X  

where hello is the test file and X is the number of cycles you want the processor to run for. In our case 150000.  

## Predictor files
Files created by the authors:
* BRANCH_PREDICTOR.v
* META.v
* GBP.v
* LBP.v
* BTB.v
* RAS.v
* STACK.v
* FSM.v
