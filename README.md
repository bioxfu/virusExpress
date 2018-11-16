# virusExpress Workflow Tutorial

### 1. Run RNA-Seq workflow

### 2. Clone the repository
```
git clone https://github.com/bioxfu/virusExpress
cd virusExpress
```

### 3. Create *config.yaml* and *Snakefile* based on the examples
```
cp example/example.config.yaml config.yaml
cp example/example.Snakefile Snakefile
# edit config.yaml
```

### 4. Initiate the project
```
source init.sh
```

### 5. Dry run the workflow to check any mistakes
```
./dry_run.sh
```

### 6. Run the workflow
```
# if you are working on the HPC
./run_HPC.sh

# if you are working on the local machine
./run.sh

# check the workflow progress in nohup.out file
tail nohup.log 

# check the jobs on HPC
qstat

# if you get the error: Directory cannot be locked.
snakemake --unlock 
```

### 7. Remove the temporary files
```
./clean.sh
```

### 8. Draw CGView figures
```
# install CGView
# wget http://wishart.biology.ualberta.ca/cgview/application/cgview.zip
unzip cgview.zip

cp example/CGView.sh CGView.sh
# edit CGView.sh and run
```