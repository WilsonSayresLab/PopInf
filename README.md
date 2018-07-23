# PopInf
PopInf is a method to infer the major population (or populations) ancestry of a sample or set of samples.

# Running PopInf 
Below are steps for running PopInf. PopInf is incorporated into the workflow system snakemake. All necessary files and scripts are in this directory. There are instructions on preparing the reference panel in a folder called "`Prep_Reference_Panel`".

## What you need to run PopInf
 1. Variants for a reference panel in VCF file format separated by chromosome.
 2. Variants for sample(s) of individuals with unknown or self-reported ancestry in VCF file format separated by chromosome.
 3. Sample information file for the reference panel. This file must contain 3 tab-delimited columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual. Our example for this file is provided in this folder and is called `ThousandGenomesSamples_AdmxRm_SHORT.txt`.
 4. Sample information file for the unknown samples. This file must contain 3 tab-delemited columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unkown) and 3) population information for the corresponding individual (this column can be labeled "unknown" for this file). Our example for this file is provided in this folder and is called `gtex_samples_SHORT.txt`.
 5. Reference Genome file (.fa) used for mapping variants. Make sure there are accompanying index (.fai) and dictionary (.dict) files.

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
conda install -c bioconda r-plotrix
conda install -c r r-car
```

## Step 2: Prepare the reference panel
See the readme file in the folder called "`Prep_Reference_Panel`".

## Step 3: Prepare the unknown samples
See the readme file in the folder called "`Prep_Unknown_Samples`".

## Step 4: Edit the configuration file
Associated with the Snakefile is a configuration file in json format. This file has 16 pieces of information needed to run the Snakefile. To run PopInf, go through all lines in the configuration file and make sure to change the content as specified.
The config file is named `popInf.config.json` and is located in this folder. See below for details. We also provide an example our configuration file below:

`popInf.config.json:`
```
{
  "_comment_sample_info": "This section of the .json file asks for sample information",
  "ref_panel_pop_info_path":"/mnt/storage/SAYRES/PCA_tutorial/snakemake/ThousandGenomesSamples_AdmxRm_SHORT.txt",
  "unkn_panel_pop_info_path":"/mnt/storage/SAYRES/PCA_tutorial/snakemake/gtex_samples_SHORT.txt",
  
  "_comment_autosomes": "This section of the .json file asks for information needed for the autosomes if they are to be analyzed",
  "Autosomes_Yes_or_No":"N",
  "ref_path":"/mnt/storage/SAYRES/REFERENCE_GENOMES/hs37d5/hs37d5.fa",
  "vcf_ref_panel_path":"/mnt/storage/SAYRES/PCA_tutorial/snakemake/autosomes/",
  "vcf_ref_panel_prefix":"chr",
  "vcf_ref_panel_suffix":"_reference_panel.recode.vcf",
  "vcf_unknown_set_path":"/mnt/storage/SAYRES/PCA_tutorial/snakemake/autosomes/",
  "vcf_unknown_set_prefix": "chr",
  "vcf_unknown_set_suffix":"_unknown_panel.recode.vcf",
  "chromosome": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22"],
  
  "_comment_chrX": "This section of the .json file asks for information needed for the analysis of the X chromosome",
  "vcf_ref_panel_path_X":"/mnt/storage/SAYRES/PCA_tutorial/snakemake/chrX/",
  "vcf_ref_panel_file":"chrX_reference_panel_females.recode.vcf",
  "vcf_unknown_set_path_X":"/mnt/storage/SAYRES/PCA_tutorial/snakemake/chrX/",
  "vcf_unknown_set_file": "chrX_unknown_panel.recode.vcf",
  "X_chr_coordinates": "/mnt/storage/SAYRES/PCA_tutorial/lists/X_chromosome_regions_XTR_hg19.bed",
}
```
After editing `popInf.config.json` make sure that this file has maintained proper json format. You can use The JSON Validator for example (https://jsonlint.com/).

Below, there are details on what to add or change in the configuration file.

### Provide the reference and unknown panel sample information
`"ref_panel_pop_info_path": ` Add the full path and file name of the sample information text file for the reference panel.

`"unkn_panel_pop_info_path": ` Add the full path and file name of the sample information text file for the unknown samples.

### Specify the type of chromosome to be analyzed
`"Autosomes_Yes_or_No": ` Specify whether analyzing the autosomes or X chromosome. If analyzing the autosomes, type `"Y"`. If analyzing the X chromosome, type `"N"`. 

### Provide information about the reference file used for mapping variants
`"ref_path": ` Add the full path to and name of the reference genome file.

### Additional information to provide if analyzing the autosomes
`"vcf_ref_panel_path": ` Add the full path to the zipped reference panel VCF files that are separated by chromosome. Make sure the path has "/" at the end.

`"vcf_ref_panel_prefix": ` Add the part of the name of the reference VCF files that comes before the chr number. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"chr"` to this part of the config file. 

`"vcf_ref_panel_suffix": ` Add the part of the name of the reference VCF files that comes after the chromosome number. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"_reference_panel.vcf.gz"` to this the config file.

`"vcf_unknown_set_path": ` Add the full path to the zipped unknown sample(s) VCF files that are separated by chromosome. Make sure the path has "/" at the end.

`"vcf_unknown_set_prefix": ` Add the part of the name of the unknown VCF files that comes before the chromosome number. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"chr"` to this part of the config file. 

`"vcf_unknown_set_suffix": ` Add the part of the name of the unknown VCF files that comes after the chr number. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"_unknown_panel.vcf.gz"` to the config file.

`"chromosome": ` You may leave it as is, unless you do not want to analyze all chromosomes. PopInf has an option to analyze the X chromosome (separately from the autosomes) so the X chromosome is not added here. If you are interested in analyzing the X chromosome, see below.

### Additional information to provide if analyzing the X chromosome
`"vcf_ref_panel_path_X": ` Add the full path to the zipped reference panel VCF file for the X chromosome. Make sure the path has "/" at the end.

`"vcf_ref_panel_file": ` Add the full name of the zipped reference panel VCF file for the X chromosome.

`"vcf_unknown_set_path_X": ` Add the full path to the zipped unknown sample(s) VCF file for the X chromosome. Make sure the path has "/" at the.

`"vcf_unknown_set_file": ` Add the full name of the zipped unknown sample(s) VCF file for the X chromosome. 

`"X_chr_coordinates": ` Add the full path to and name of the file containing the X chromosome PAR and XTR coordinates. The coordinates are provided in the file named `X_chromosome_regions_XTR_hg19.bed` and this file is located in this folder.

## Step 5: Run PopInf
This step will provide instructions on how to run PopInf. With our server, we chose to use an sbatch script to run PopInf. This script is provided in this folder if your wish to use this. However, depending on your server, you might need to run PopInf differently. All of the necessary scripts are provided in this folder.

### Edit the .sh script
Before running the sbatch script, some necessary edits are needed. These edits are specified both within the script and here by line number.

Line 7 - edit the email after `#SBATCH --mail-user= ` to be the email that you wish your slurm notification to be sent to.

Line 14 - edit the path to which all of the following scripts and files are located: (1) Snakefile, (2) snakemake_PopInf_slurm.sh, (3) popInf_environment.yaml, (4) popInf.config.json, (5) make_merge_list.py, (6) make_par.py, (7) pca_inferred_ancestry_report.R. These scripts and files are all provided in this folder. These scripts and files must all be located within the same directory.

Line 15 - edit the name of the environment you created.

Line 33, 103 - edit the email to be the email that you wish your slurm notification to be sent to.

Line 87, 131 - edit the paths to and file names of the reference panel sample list and the unknown panel sample list.

### Run the .sh script
The following section discusses how the run the sbatch script to run PopInf. The script can be run differently depending on whether the autosomes or X chromosome is to be analyzed.

#### Use the following commands to run the sbatch script:
```
sbatch snakemake_PopInf_slurm.sh A
```
NOTE: The `A` must be capitalized if analyzing the autosomes. If analyzing the X chromosome, remove the `A` and run the command as follows:
```
sbatch snakemake_PopInf_slurm.sh
```

## The results of running PopInf
After submitting `snakemake_PopInf_slurm.sh` PopInf will run. Once completed, PopInf will output PCA plots as well as an inferred population report. The PCA plots will provide a visual representation of how the unknown sample(s) compare(s) to the reference panel. For each unknown sample, the inferred population reports will provide distances to each reference population's centroid, and inferred ancestry based on how close the sample is to each population.

We ran PopInf using 986 unrelated individuals from the 1000 Genomes consortium as our reference panel and 148 GTEx samples as our unknown panel. Our sample lists are provided in this folder, and our configuration file can be seen above. Additionally, we have provided the PCA plot and inferred population report that PopInf generated for the autosomes in this folder.

