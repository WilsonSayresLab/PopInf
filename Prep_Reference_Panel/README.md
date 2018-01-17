# Prepare Referece Panel 
This document will guide you through preparing your reference panel VCF (variant call format) files for input into PopInf. In this tutorial, we will use a subset of the 1000 Genomes Release 3 whole genome sequence data. However, PopInf can take any VCF files with individuals from any population. If you would like to use different populations in your reference panel, you can do so. Just follow these steps and replace the VCF files we use with your VCF.

## What you need to prepare the reference panel 
You will need the following to prepare the reference panel:
1. High performance computer (the reference file will likely be very large if you are analyzing sites across the entire genome).
2. VCF files of the reference populations separated by chromosome.
3. 1000 genomes sample list (only if you are using the 1000 genomes samples we use in this tutorial. We provide that list in this folder).

## Step 1: Set up your enviroment 
This tutorial will use a variety of programs. We will set up a conda environment to manage all necessary packages and programs. 

### Install Anaconda or Miniconda
First, you will have to install Anaconda or Miniconda. Please refer to Conda's documentation for steps on how to install conda. See: https://conda.io/docs/index.html

### Create the enviroment
You can name your environment what ever you would like. We named this environment 'popInf' and we will use this environment for all analyses. 

Create conda environment called `popInf`: \
`conda env create --name popInf --file popInf_environment.yaml`

The `popInf_environment.yaml` environment file is located in this folder.

You will need to activate the environment when running scripts/commands and deactivate the environment when you are done. 

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
There is a snakefile in this folder with the commands to prepare the reference panel for input into popInf.

### Edit configuration file
Associated with the `snakefile` is a configuration file in json format. This file has all important informaiton to run the snakefile.
