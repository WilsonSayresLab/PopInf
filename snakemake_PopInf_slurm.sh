#!/bin/bash
#SBATCH --job-name=popInf_master # Job name
#SBATCH --mem-per-cpu=16000
#SBATCH -o slurm.%j.out                # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err                # STDERR (%j = JobId)
#SBATCH --mail-type=END,FAIL           # notifications for job done & fail
#SBATCH --mail-user= email@email.com   # send-to address
#SBATCH -n 16
#SBATCH -t 96:00:00

# CHANGES NEEDED FOR EXECUTION:
#	1. change the path to the location of the Snakefile and corresponding scripts
#	2. change the name of the environment to the one you created
cd /path/to/Snakefile
source activate environment

echo "Checking whether the autosomes or the X chromosome are to be analyzed."
echo ""
date
echo ""
if [[ $1 = "A" ]]; then
	echo "The autosomes will now be analyzed."
	echo ""
	echo "Each individual chromosome's data is now being prepped for analysis."
	echo ""
		
	# Run snakemake to prep each chromosome. The snakemake will: (1) keep only SNPs for the reference and unknown
	# files, (2) merge the reference and unknown files, (3) remove any missing data, (4) convert the vcf files into
	# plink format, and (5) LD prune the data
	# CHANGES NEEDED FOR EXECUTION:
	#	1. change the email to the email you want the notifications to be sent to
	date
	snakemake -j 20 --nolock --cluster "sbatch -n 16 -t 96:00:00 --mail-type=END,FAIL --mail-user=email@email.com"
	date
	echo ""
		
	echo "The individual chromosome files are now being merged for analysis."
	echo ""
		
	# Create the merge list
	date
	python make_merge_list.py --path autosomes/merge/ --stem _reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune --out merge_list
	date
	echo ""
	
	# Merge the files
	date
	plink --file autosomes/merge/chr1_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune --merge-list merge_list.txt --recode --out autosomes/merge/merge_all_chr_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune
	date
	echo ""
	
	# Edit the 6th column of the ped files
	date
	awk '{{$6 = "1"; print}}' autosomes/merge/merge_all_chr_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune.ped > autosomes/merge/merge_all_chr_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune_editColumn6.ped
	date
	echo ""
	
	echo "The autosomes are now being analyzed."
	echo ""
		
	# Make par file
	date
	python make_par.py --map autosomes/merge/merge_all_chr_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune.map --ped autosomes/merge/merge_all_chr_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune_editColumn6.ped --ev merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune --par merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_par
	date
	
	# Run smartpca
	date
	smartpca -p merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_par_PCA.par
	date
	echo ""
	
	# Edit the evec files
	date
	awk '{{if($1 == "\t" ) {{print $2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t",$13,"\t"}} else {{print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t"}}}}' merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune.evec > merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix.evec
	awk '{gsub(/\.variant2/,""); gsub(/\.variant/,""); print}' merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix.evec > merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix2.evec
	date
	echo ""

	echo "The analysis results are now being plotted."
	echo ""
		
	# Plot results and get inferred population report
	# CHANGES NEEDED FOR EXECUTION:
	#	1. Change the path to and file name of the reference panel samples list
	#	2. Change the path to and file name of the unknown panel samples list
	date
	Rscript pca_inferred_ancestry_report.R merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix2.evec merge_all_chr_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune.eval /path/to/reference_panel_sample_list.txt /path/to/unknown_panel_sample_list.txt PCA_plots_all_autosomes autosomes_inferred_pop_report
	date
	
	echo "Analysis of the autosomes is complete."
		
else
	echo "The X chromosome will now be analyzed."
	echo ""
		
	# For the X chromosome, the snakemake will: (1) separate males from females, (2) keep only SNPs for the combined sex, 
	# male, and female files, (3) merge the combined sex, male, and female files, (4) remove the PARS and X transposed 
	# regions for the combined sex, male, and female files, (5) remove any missing data, (6) convert the vcf files into 
	# plink format, and (5) LD prune the data using a specific X chromosome pruning filter
	# CHANGES NEEDED FOR EXECUTION:
	#	1. change the email to the email you want the notifications to be sent to
	date
	snakemake -j 20 --nolock --cluster "sbatch -n 16 -t 96:00:00 --mail-type=END,FAIL --mail-user=email@email.com"
	date
	echo ""
	
	# Make par file
	date
	python make_par.py --map chrX/merge/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune.map --ped chrX/merge/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_editColumn6.ped --ev chrX/pca/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune --par chrX/pca/par/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_par
	date
	echo ""
	
	# Run smartpca
	date
	smartpca -p chrX/pca/par/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_par_PCA.par
	date
	echo ""
	
	# Edit the evec files
	date
	awk '{{if($1 == "\t" ) {{print $2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t",$13,"\t"}} else {{print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t"}}}}' chrX/pca/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune.evec > chrX/pca/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix.evec
	awk '{gsub(/\.variant2/,""); gsub(/\.variant/,""); print}' chrX/pca/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix.evec > chrX/pca/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix2.evec
	date
	echo ""
	
	# Plot results and get inferred population report
	# CHANGES NEEDED FOR EXECUTION:
	#	1. Change the path to and file name of the reference panel samples list
	#	2. Change the path to and file name of the unknown panel samples list
	date
	Rscript pca_inferred_ancestry_report.R chrX/pca/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix2.evec chrX/pca/chrX_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune.eval /path/to/reference_panel_sample_list.txt /path/to/unknown_panel_sample_list.txt chrX/PCA_plots_chrX chrX/chrX_inferred_pop_report
	date
	
	echo ""	
	echo "The X chromosome has been analyzed."
	echo ""	
fi
