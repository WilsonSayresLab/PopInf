# PopInf
PopInf is a method to infer the major population (or populations) ancestry of a sample or set of samples.

# Running PopInf 
Below are steps for running PopInf. PopInf is incorporated into the workflow system snakemake. All necessary files and scripts are in this directory. There are instructions on preparing the reference panel in a folder called "`Reference_Panel`". There are also instructions on preparing the unknown samples in a folder called "`Unknown_Samples`".

## What you need to run PopInf
 1. Variants for a reference panel in VCF file format separated by chromosome.
 2. Variants for sample(s) of individuals with unknown or self-reported ancestry in VCF file format separated by chromosome.
 3. Sample information file for the reference panel. This file must contain 3 tab-delimited columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unknown) and 3) population information for the corresponding individual. Our example for this file is provided in this folder and is called `ThousandGenomesSamples_AdmxRm_SHORT.txt`.
 4. Sample information file for the unknown samples. This file must contain 3 tab-delimited columns: 1) the individual's sample name, and 2) sex information (i.e. male, female, unknown) and 3) population information for the corresponding individual (this column can be labeled "unknown" for this file). Our example for this file is provided in this folder and is called `gtex_samples_SHORT.txt`.
 5. Reference Genome file (.fa) used for mapping variants. Make sure there are accompanying index (.fai) and dictionary (.dict) files.

## Step 1: Set up your environment 
PopInf uses a variety of programs. We will set up a conda environment to manage all necessary packages and programs. 

### Install Anaconda or Miniconda
First, you will have to install Anaconda or Miniconda. Please refer to Conda's documentation for steps on how to install conda. See: https://conda.io/docs/index.html

### Create the environment
You can name your environment whatever you would like. We named this environment 'PopInf' and we will use this environment for all analyses. 

Create conda environment called `PopInf`: \
`conda env create --name PopInf --file popInf_environment.yaml`

The `popInf_environment.yaml` environment file is located in this folder.

You will need to activate the environment when running scripts or commands and deactivate the environment when you are done. 

To activate the `PopInf` environment: \
`source activate PopInf` 

To deactivate the `PopInf` environment: \
`source deactivate PopInf`

### Add additional programs to the environment
To use GATK in the conda environment, you must register it. After activating the environment, type the following into the command line: \
`gatk-register <path and name of gatk jar file>`

Please note that "`<path and name of gatk jar file>`" is just the path and file name for the gatk.jar file.

Additional packages within R must be installed into this environment as well. After activating the environment, type the following into the command line: 
```
conda install -c bioconda r-plotrix
conda install -c r r-car
conda install -c bioconda r-viridis 
```

## Step 2: Prepare the reference panel
See the readme file in the folder called "`Reference_Panel`".


## Step 3: Prepare the unknown samples
See the readme file in the folder called "`Unknown_Samples`".


## Step 4: Edit the configuration file
Associated with the Snakefile is a configuration file in json format. This file has 16 pieces of information needed to run the Snakefile. To run PopInf, go through all lines in the configuration file and make sure to change the content as specified.
The config file is named `popInf.config.json` and is located in this folder. See below for details. We also provide an example our configuration file below:

`popInf.config.json:`
```
{
  "_comment_sample_info": "This section of the .json file asks for sample information",
  "ref_panel_pop_info_path": "/PopInf/Sample_Information/ThousandGenomesSamples_AdmxRm.txt",
  "unkn_panel_pop_info_path": "/PopInf/Sample_Information/GTExSamples.txt",
  
  "_comment_general_options": "This section of the .json file asks for information needed to run popInf regardelss of what chromosomes you choose to analyze",
  "Autosomes_Yes_or_No": "N",
  "ref_path": "/mnt/storage/SAYRES/REFERENCE_GENOMES/hs37d5/hs37d5.fa",
  "genotype_call_rate_threshold": "0.98",
  
  "_comment_autosomes": "This section of the .json file asks for information needed for the autosomes if they are to be analyzed",
  "vcf_ref_panel_path": "/PopInf/Reference_Panel/",
  "vcf_ref_panel_prefix": "chr",
  "vcf_ref_panel_suffix": "_10000genomes_selected_individuals.vcf",
  "vcf_unknown_set_path": "/PopInf/Unknown_Samples/",
  "vcf_unknown_set_prefix": "chr",
  "vcf_unknown_set_suffix": "_unknown_panel.recode.vcf",
  "chromosome": ["1", "2", "3", "4", "5", "6", "7", 
                 "8", "9", "10", "11", "12", "13", "14", 
                 "15", "16", "17", "18", "19", "20", "21", "22"],
  
  "_comment_chrX": "This section of the .json file asks for information needed for the analysis of the X chromosome",
  "vcf_ref_panel_path_X": "/PopInf/Reference_Panel/",
  "vcf_ref_panel_file": "chrX_10000genomes_selected_individuals.vcf",
  "vcf_unknown_set_path_X": "/PopInf/Unknown_Samples/",
  "vcf_unknown_set_file": "chrX_unknown_panel.recode.vcf",
  "X_chr_coordinates": "/PopInf/X_chromosome_regions_XTR_hg19.bed"
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

### Specify the call rate threshold
`"genotype_call_rate_threshold": ` Removes sites with a user specified call rate. For example, if you want to remove sites with any missing data (call rate of 100%) set `"genotype_call_rate_threshold": ` to `"1.0"`. If you don't want to implements a call rate threshold, set `"genotype_call_rate_threshold": ` to `"0"`. 

### Additional information to provide if analyzing the autosomes
`"vcf_ref_panel_path": ` Add the full path to the zipped reference panel VCF files that are separated by chromosome. Make sure the path has "/" at the end.

`"vcf_ref_panel_prefix": ` Add the part of the name of the reference VCF files that comes before the chr number. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"chr"` to this part of the config file. 

`"vcf_ref_panel_suffix": ` Add the part of the name of the reference VCF files that comes after the chromosome number. For example, if the reference VCF file for chromosome 1 is named `chr1_reference_panel.vcf.gz` then you would add `"_reference_panel.vcf.gz"` to this the config file.

`"vcf_unknown_set_path": ` Add the full path to the zipped unknown sample(s) VCF files that are separated by chromosome. Make sure the path has "/" at the end.

`"vcf_unknown_set_prefix": ` Add the part of the name of the unknown VCF files that comes before the chromosome number. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"chr"` to this part of the config file. 

`"vcf_unknown_set_suffix": ` Add the part of the name of the unknown VCF files that comes after the chr number. For example, if the unknown VCF file for chromosome 1 is named `chr1_unknown_panel.vcf.gz` then you would add `"_unknown_panel.vcf.gz"` to the config file.

`"chromosome": ` You may leave it as is, unless you do not want to analyze chromosomes 1-22. PopInf has an option to analyze the X chromosome (separately from the autosomes) so the X chromosome is not added here. If you are interested in analyzing the X chromosome, see below.

### Additional information to provide if analyzing the X chromosome
`"vcf_ref_panel_path_X": ` Add the full path to the zipped reference panel VCF file for the X chromosome. Make sure the path has "/" at the end.

`"vcf_ref_panel_file": ` Add the full name of the zipped reference panel VCF file for the X chromosome.

`"vcf_unknown_set_path_X": ` Add the full path to the zipped unknown sample(s) VCF file for the X chromosome. Make sure the path has "/" at the.

`"vcf_unknown_set_file": ` Add the full name of the zipped unknown sample(s) VCF file for the X chromosome. 

`"X_chr_coordinates": ` Add the full path to and name of the file containing the X chromosome PAR and XTR coordinates. The coordinates are provided in the file named `X_chromosome_regions_XTR_hg19.bed` and this file is located in this folder.

## Step 5: Run PopInf
This step will provide instructions on how to run PopInf. With our server, we chose to use an sbatch script to run PopInf. This script is provided in this folder if your wish to use this. However, depending on your server, you might need to run PopInf differently. All the necessary scripts are provided in this folder.

### Edit the .sh script
Before running the sbatch script, some necessary edits are needed. These edits are specified both at the top of the script and here:

#### 1. Path to the location of the Snakefile and corresponding scripts (Line 25)
`SPATH=/full/path/to/PopInf/directory/`

#### 2. Name of the environment you created (Line 27)
`ENV=popInf`

#### 3. Email you want the notifications to be sent to. If running on a cluster. This is the email address you wish to send slurm logs to (Line 30)
`EMAIL=youremail@email.com`

#### 4. The path to and file name of the reference panel samples list (Line 32)
`POPFILEREF=/full/path/to/reference_panel/Sample_Information/file.txt`

#### 5. The path to and file name of the unknown panel samples list (Line 34)
`POPFILEUNK=/full/path/to/unknown_sets/Sample_Information/file.txt`

NOTE: If you are not running this shell script on a cluster, remove lines 2-7 and replace the snakemake command on line 65 with just `snakemake`

### Run the PopInf
The following section discusses how the run the sbatch script to run PopInf. The script can be run differently depending on whether the autosomes or X chromosome is to be analyzed.

NOTE: Make sure you edit `snakemake_PopInf_slurm.sh` before running PopInf

#### Use the following command to run the sbatch script on automsomes:
```
sbatch snakemake_PopInf_slurm.sh A
```
#### Use the following command to run the sbatch script on the X chromosome:
```
sbatch snakemake_PopInf_slurm.sh X
```

## The results of running PopInf
After submitting `snakemake_PopInf_slurm.sh` PopInf will run. PopInf will output PCA plots as well as an inferred population report for each automsome separately and all autosomes merged and the X chromosome. The PCA plots will provide a visual representation of how the unknown sample(s) compare(s) to the reference panel. For each unknown sample, the inferred population reports will provide distances to each reference population's centroid, and inferred ancestry based on how close the sample is to each population.

We ran PopInf using 986 unrelated individuals from the 1000 Genomes consortium as our reference panel and 148 GTEx samples as our unknown panel. Our sample lists are provided in this folder, and our configuration file can be seen above. Additionally, we have provided the PCA plot and inferred population report that PopInf generated for the merged autosomes in this folder.
