# PopInf
PopInf is a method to infer the major population (or populations) ancestry of a sample or set of samples.

# Running PopInf 
Below are steps for running PopInf. PopInf is incorporated into the workflow system snakemake. All necessary files and scripts are in this directory. There are instructions on preparing the reference panel in a folder called "`Prep_Reference_Panel`"

## What you need to run PopInf
 - Variants for a reference panel in VCF file format separated by chromosome.
 - Variants for sample(s) of individuals with unknown or self-reported ancestry in VCF file format separated by chromosome.
 - Tab delimited file for the reference panel. This file must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual.
 - Tab delemited file for the individuals with unknown or self-reported ancestry. This file must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual (this column can be labeled "unknown" for this file).
 - Reference Genome file (.fa) used for mapping variants. Make sure there are accompanying index (.fai) and dictionary (.dict) files. 

## Step 1: Set up your enviroment 
PopInf uses a variety of programs. We will set up a conda environment to manage all necessary packages and programs. 

### Install Anaconda or Miniconda
First, you will have to install Anaconda or Miniconda. Please refer to Conda's documentation for steps on how to install conda. See: https://conda.io/docs/index.html

### Create the enviroment
You can name your environment what ever you would like. We named this environment 'popInf' and we will use this environment for all analyses. 

Create conda environment called `popInf`: \
`conda env create --name popInf --file popInf_environment.yaml`

The `popInf_environment.yaml` environment file is located in this folder.

You will need to activate the environment when running scripts or commands and deactivate the environment when you are done. 

To activate `popInf` environment: \
`source activate popInf` 

To deactivate `popInf` environment: \
`source deactivate popInf`

### Add additional programs to the environment
To use GATK in the conda environment, you must register it. After activating the environment, type the following into the command line: \
`gatk-register <path and name of gatk jar file>`

Please note that "`<path and name of gatk jar file>`" is just the path and file name for the gatk.jar file.

Additional packages within R must be installed into this environment as well. After activating the environment, type the following into the command line: 
```
conda istall -c bioconda r-plotrix
conda install -c r r-car
```

## Step 2: Prepare the reference panel
See the readme file in the folder called "`Prep_Reference_Panel`" 

## Step 3: Separate reference panel and unknown panel by biological sex
If you would like to analyze the biological sexes separately, see the readme file in the folder called "`Separate_Biological_Sex`"




