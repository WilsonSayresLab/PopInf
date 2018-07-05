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

## Step 1: Set up your environment 
popInf and the reference panel set up use a variety of programs. We will set up a conda environment to manage all necessary packages and programs. 

### Install Anaconda or Miniconda
First, you will have to install Anaconda or Miniconda. Please refer to Conda's documentation for steps on how to install conda. See: https://conda.io/docs/index.html

### Create the environment
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
First for the reference panel, create two tab delimited text files for males and females. The files must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unknown) and 3) population information for the corresponding individual.

Then for the unknown panel, create two tab delimited text files for males and females. The files must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unknown) and 3) population information for the corresponding individual.

## Step 3: Run Snakemake
There is a Snakefile in this folder with the commands to separate the reference and unknown panel files by biological sex. Before running the Snakefile see the step below.

### Edit configuration file
Associated with the `Snakefile` is a configuration file in json format. This file has 11 pieces of information needed to run the Snakefile.
The config file is named `popInf_separateBiologicalSex.config.json` and is located in this folder. \
`popInf_separateBiologicalSex.config.json`:

```
{
	"vcf_ref_panel_path": "/your_path_to_zipped_reference_panel_vcfs_here/",
	"vcf_ref_panel_prefix": "reference_panel_file_prefix",
	"vcf_ref_panel_suffix": "reference_panel_file_suffix.vcf.gz",
	"vcf_unknown_set_path": "/your_path_to_zipped_unknown_panel_vcfs_here/",
	"vcf_unknown_set_prefix": "unknown_panel_file_prefix",
	"vcf_unknown_set_suffix": "unknown_panel_file_suffix.vcf.gz",
	"chromosome": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", 	                 "19", "20", "21", "22", "X"],
	"ref_males_sample_list": "/your_path_to_reference_panel_male_list/males_list.txt",
	"ref_females_sample_list": "/your_path_to_reference_panel_male_list/females_list.txt",
	"unk_males_sample_list": "/your_path_to_unknown_panel_male_list/males_list.txt",
	"unk_females_sample_list": "/your_path_to_unknown_panel_female_list/females_list.txt",
}

```
Add the full path to the zipped reference panel VCF files that are separated by chromosome after `"vcf_ref_panel_path": `. Make sure the path has "/" at the end and is in quotes (like in the above example).

Add the part of the name of the reference VCF files that comes before the chr number after `"vcf_ref_panel_prefix": `. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"chr"` to this part of the config file. Make sure that this is in quotes (like in the above example).

Add the part of the name of the reference VCF files that comes after the chr number after `"vcf_ref_panel_suffix": `. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"_reference_panel.vcf.gz"` to this part of the config file. Make sure that this is in quotes (like in the above example).

Add the full path to the zipped unknown panel VCF files that are separated by chromosome after `"vcf_unknown_set_path": `. Make sure the path has "/" at the end and is in quotes (like in the above example).

Add the part of the name of the unknown VCF files that comes before the chr number after `"vcf_unknown_set_prefix": `. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"chr"` to this part of the config file. Make sure that this is in quotes (like in the above example).

Add the part of the name of the unknown VCF files that comes after the chr number after `"vcf_unknown_set_suffix": `. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"_unknown_panel.vcf.gz"` to this part of the config file. Make sure that this is in quotes (like in the above example).

You may leave `"chromosome": ` as is, unless you do not want to analyze all chromosomes. popInf has an option to analyze the X chromosome (separately from the autosomes) so the X chromosome is added here. If you are not interested in analyzing the X chromosome, just remove "X".

Add the full path to and the file names of the tab delimited text files for the reference panel males and females and unknown panel males and females after `"ref_males_sample_list": `, `"ref_females_sample_list": `, `"unk_males_sample_list": `, and `"unk_females_sample_list": `.

### Run snakemake
You can submit the Snakefile as a job on your cluster. See the "Cluster execution" section of snakemake documentation (https://snakemake.readthedocs.io/en/stable/tutorial/additional_features.html)

NOTE: The configuration file and Snakefile must be in the same directory.

```
cd /path/to/snakefile/directory/
source activate popInf
snakemake -j 15 --cluster "sbatch -n 2 -t 96:00:00"
```
After snakemake has completed, you can move onto running popInf and analyzing each biological sex separately.

