# PopInf
PopInf is a method to infer the major population (or populations) ancestry of a sample or set of samples.

# Running PopInf 
Below are steps for running PopInf. PopInf is incorporated into the workflow system snakemake. All necessary files and scripts are in this directory. There are instructions on preparing the reference panel in a folder called "`Prep_Reference_Panel`"

## What you need to run PopInf
 1. Variants for a reference panel in VCF file format separated by chromosome.
 2. Variants for sample(s) of individuals with unknown or self-reported ancestry in VCF file format separated by chromosome.
 3. Tab delimited file for the reference panel. This file must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual.
 4. Tab delemited file for the individuals with unknown or self-reported ancestry. This file must contain 3 columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual (this column can be labeled "unknown" for this file).
 5. Reference Genome file (.fa) used for mapping variants. Make sure there are accompanying index (.fai) and dictionary (.dict) files.
 6. The following files and scripts all located in the same directory:
  - Snakefile
  - snakemake_PopInf_slurm.sh
  - popInf_environment.yaml
  - popInf.config.json
  - make_merge_list.py
  - make_par.py
  - pca_inferred_ancestry_report.R


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

## Step 3: Prepare the unknown panel
See the readme file in the folder called "`Prep_Reference_Panel`" 

## Optional Step: Separate reference panel and unknown panel files by biological sex
If you would like to analyze the biological sexes separately, see the readme file in the folder called "`Separate_Biological_Sex`" for instructions on how to separate the reference and unknown files by biological sexes. These separated files can then be run with PopInf.

## Step 4: Edit the configuration file
Associated with the Snakefile is a configuration file in json format. This file has 19 pieces of information needed to run the Snakefile.
The config file is named `popInf.config.json` and is located in this folder. 

`popInf.config.json:`
```
{
  "_comment_sample_info": "This section of the .json file asks for sample information",
  "ref_panel_pop_info_path": "/path/reference_panel_samples.txt",
  "unkn_panel_pop_info_path": "/path/unknown_panel_samples.txt",
  
  "Autosomes_Yes_or_No": "Y",
  
  "_comment_autosomes": "This section of the .json file asks for information needed for the autosomes if they are to be analyzed",
  "ref_path": "/path/reference_genome_file.fa",
  "vcf_ref_panel_path": "/path_to_reference_panel_files/",
  "vcf_ref_panel_prefix": "reference_panel_file_prefix",
  "vcf_ref_panel_suffix": "reference_panel_file_suffix.recode.vcf",
  "vcf_unknown_set_path": "/path_to_unknown_panel_files/",
  "vcf_unknown_set_prefix": "unknown_panel_file_prefix",
  "vcf_unknown_set_suffix": "unknown_panel_file_suffix.recode.vcf",
  "chromosome": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"],
  "biological_sex_autosomes": "biological_sex",
  
  "_comment_chrX": "This section of the .json file asks for information needed for the analysis of the X chromosome",
  "ref_path_chrX": "/path/reference_genome_file.fa",
  "vcf_ref_panel_path_X": "/path_to_chrX_reference_panel_file/",
  "vcf_ref_panel_file": "chrX_reference_panel_file.recode.vcf",
  "vcf_unknown_set_path_X": "/path_to_chrX_unknown_panel_file/",
  "vcf_unknown_set_file": "chrX_unknown_panel_file.recode.vcf",
  "biological_sex_chrX": "biological_sex",
  "X_chr_coordinates": "/path/X_chromosome_regions_XTR_hg19.bed",
}
```
While editing the .json file, make sure that any white space or indentations are create by spaces, not tabs. If there are tabs present in this file, snakemake will run into the error of not being able to properly read the .json file. 

### Providing the reference and unknown panel sample information

Add the full path and file name of the reference panel sample information text file with the sample names, biological sex, and populations after `"ref_panel_pop_info_path": `. 

Add the full path and file name of the unknown panel sample information text file with the sample names, biological sex, and populations after `"unkn_panel_pop_info_path": `.

### Specifying the type of chromosome to be analyzed

Specify whether the analysis is to be done on the autosomes or the X chromosome after `"Autosomes_Yes_or_No": `. If the autosomes are to be analyzed, type `"Y"`. If the X chromosome is to be analyzed, type `"N"`.

### Providing the information to analyze the autosomes

Add the full path to and name of the reference genome file for the autosomes after `"ref_path": `. Make sure that this is in quotes (like in the above example).

Add the full path to the zipped reference panel VCF files that are separated by chromosome after `"vcf_ref_panel_path": `. Make sure the path has "/" at the end and is in quotes (like in the above example).

Add the part of the name of the reference VCF files that comes before the chr number after `"vcf_ref_panel_prefix": `. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"chr"` to this part of the config file. Make sure that this is in quotes (like in the above example).

Add the part of the name of the reference VCF files that comes after the chr number after `"vcf_ref_panel_suffix": `. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"_reference_panel.vcf.gz"` to this part of the config file. Make sure that this is in quotes (like in the above example).

Add the full path to the zipped unknown panel VCF files that are separated by chromosome after `"vcf_unknown_set_path": `. Make sure the path has "/" at the end and is in quotes (like in the above example).

Add the part of the name of the unknown VCF files that comes before the chr number after `"vcf_unknown_set_prefix": `. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"chr"` to this part of the config file. Make sure that this is in quotes (like in the above example).

Add the part of the name of the unknown VCF files that comes after the chr number after `"vcf_unknown_set_suffix": `. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"_unknown_panel.vcf.gz"` to this part of the config file. Make sure that this is in quotes (like in the above example).

You may leave `"chromosome": ` as is, unless you do not want to analyze all chromosomes. popInf has an option to analyze the X chromosome (separately from the autosomes) so the X chromosome is added here. If you are not interested in analyzing the X chromosome, just remove "X".

Specify the biological sex you would like to analyze after `"biological_sex_autosomes": `. The following biological sexes could be specified: `"both"`, `"male"`, or `"female"`. Make sure that this is in quotes (like in the above example).

### Providing the information to analyze the X chromosome

Add the full path to and name of the reference genome file for the X chromosome after `"ref_path_chrX": `. Make sure that this is in quotes (like in the above example).

Add the full path to the zipped reference panel VCF file for the X chromosome after `"vcf_ref_panel_path_X": `. Make sure the path has "/" at the end and is in quotes (like in the above example).

Add the full name of the zipped reference panel VCF file for the X chromosome after `"vcf_ref_panel_file": `. Make sure that this is in quotes (like in the above example).

Add the full path to the zipped unknown panel VCF file for the X chromosome after `"vcf_unknown_set_path_X": `. Make sure the path has "/" at the end and is in quotes (like in the above example).

Add the full name of the zipped unknown panel VCF file for the X chromosome after `"vcf_unknown_set_file": `. Make sure that this is in quotes (like in the above example).

Specify the biological sex you would like to analyze after `"biological_sex_chrX": `. The following biological sexes could be specified: `"both"`, `"male"`, or `"female"`. Make sure that this is in quotes (like in the above example).

Add the full path to and name of the file containing the X chromosome PARS regions coordinates and XTR region coordinates after `"X_chr_coordinates": `. The coordinates are provided in the file named `X_chromosome_regions_XTR_hg19.bed` and this file is located in this folder. Make sure that this is in quotes (like in the above example).

## Step 5: Edit the .sh script

## Step 6: Run the .sh script






