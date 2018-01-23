# Prepare Referece Panel 
This document will guide you through preparing your reference panel VCF (variant call format) files for input into PopInf. In this tutorial, we will use a subset of the 1000 Genomes Release 3 whole genome sequence data. However, PopInf can take any VCF files with individuals from any population or any data set. If you would like to use different populations in your reference panel, you can do so. If you are making your own reference panel, you do not need to follow this readme. Just make sure your vcf files are separated by chromosome. 

## What you need to prepare the reference panel 
You will need the following to prepare the reference panel:
1. High performance computer (the reference files will likely be very large if you are analyzing sites across the entire genome).
2. VCF files of the reference populations separated by chromosome.
3. 1000 genomes selected individuals sample list (We provide the list in this folder).

## Step 1: Set up your enviroment 
popInf and the refecence panel set up use a variety of programs. We will set up a conda environment to manage all necessary packages and programs. 

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

## Step 2: Download 1000 Genomes VCF files
We will use a subset of the 1000 Genomes Release 3 whole genome sequence data (vcf files). We chose individuals that represent populations in Africa, Asia, and Europe.

To download vcfs (they will be separated by chromosome): \
`wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20130502/ `

NOTE: These files are very large and will take quite a bit of time to download. I would suggest submitting this command as a job. 

## Step 3: Run snakemake
There is a snakefile in this folder with the commands to prepare the reference panel for input into popInf. Before running the snakefile see the step below.

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

### Run snakemake
You can submit the snakefile as a job on your cluster. See the "Cluster execution" section of snakemake documentation (https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html)

NOTE: The configuration file and Snakefile must be in the same directory.

```
cd /path/to/snakefile/directory/
source activate popInf
snakemake -j 15 --cluster "sbatch -n 2 -t 96:00:00"
```

After snakemake has completed, you can move onto running popInf. Make sure the vcf file for the samples with unknown ancestry are also separated by chromosome. 


