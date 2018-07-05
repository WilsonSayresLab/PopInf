# Separating Files by Biological Sex
This document will guide you through separating your reference panel and unknown panel files by biological sex if you wish to analyze each biological sex separately.

## What you need to separate the files by biological sex
1. High performance computer (the reference files will likely be very large if you are analyzing sites across the entire genome).
2. VCF files for the reference panel separated by chromosome that are zipped (see below if needed).
3. VCF files for the unknown panel separated by chromosome zipped (see below if needed).
3. Reference panel sample list with biological sexes specified (If using 1000 Genomes, we provide the list in this folder).
4. Unknown panel sample list with biological sexes specified.

## How to zip VCF files
If you need to zip your VCF files, use the following commands:
```
bgzip -c file.vcf > file.vcf.gz
tabix -p vcf file.vcf.gz
```


### Separate the reference and unknown panel files by biological sex
First, edit the sbatch script to include your directories and file names. Make sure that your reference panel and unknown panel are files. To zip the vcf files, use the follow command:

You can submit the sbatch script as a job on your cluster.


'''

## Step 1: Set up your environment 
popInf and the reference panel set up use a variety of programs. We will set up a conda environment to manage all necessary packages and programs. 

### Install Anaconda or Miniconda
First, you will have to install Anaconda or Miniconda. Please refer to Conda's documentation for steps on how to install conda. See: https://conda.io/docs/index.html

### Create the enviroment
You can name your environment whatever you would like. We named this environment 'popInf' and we will use this environment for all analyses. 

Create conda environment called `popInf`: \
`conda env create --name popInf --file popInf_environment.yaml`

The `popInf_environment.yaml` environment file is located in this folder.

You will need to activate the environment when running scripts or commands and deactivate the environment when you are done. 

To activate `popInf` environment: \
`source activate popInf` 

To deactivate `popInf` environment: \
`source deactivate popInf`

## Step 2: Create the biological sex sample lists
First for the reference panel, create two tab delimited text files for males and females. The files must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual.

Then for the unknown panel, create two tab delimited text files for males and females. The files must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual.

## Step 3: Make sure reference and unknown VCF files are zipped

## Step 4: Run Snakemake
There is a Snakefile in this folder with the commands to separate the reference and unknown panel files by biological sex. Before running the Snakefile see the step below.

### Edit configuration file
Associated with the `snakefile` is a configuration file in json format. This file has 3 pieces of informaiton needed to run the snakefile.
The config file is named `prep_ref.config.json` and is located in this folder. \
`prep_ref.config.json`:

```
{
	"vcf_1000g_path": "/your_path_to_1000_genomes_vcfs_here/",
	
	"pop_list_1000g": "1000genomes_selected_individuals_noAdmix_ind.txt",
	
	"chromosome": [
	"1", "2", "3", "4", "5", "6", 
	"7", "8", "9", "10", "11", "12", 
	"13", "14", "15", "16", "17", "18", 
	"19", "20", "21", "22", "X"
	]
}

```
Add the full path to the downloaed 1000 genomes after `"vcf_1000g_path": `. Make sure the path has "/" at the end and is in quotes (like in the above example).

Add the name (and full path) of the individuals you want to have in your reference panel after `"pop_list_1000g_path": ` 

You may leave `"chromosome": ` as is, unless you do not want to analyze all chromosomes. popInf has an option to analyze the X chromosome (separately from the autosomes) so the X chromosome is added here. If you are not interested in analyzing the X chromosome, just remove "X"

