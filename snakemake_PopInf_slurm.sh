#!/bin/bash
#SBATCH --job-name=popInf_master # Job name
#SBATCH --mem-per-cpu=16000
#SBATCH -o slurm.%j.out                # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err                # STDERR (%j = JobId)
#SBATCH --mail-type=END,FAIL           # notifications for job done & fail
#SBATCH --mail-user= email@email.com   # send-to address
#SBATCH -n 16
#SBATCH -t 96:00:00

cd /path/to/Snakefile
source activate PopInf

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
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the stem name matches the one in the .json file
	#	2. make sure the biological sex in the merge list name also matches the one in the .json file
	date
	python mak_merge_list.py --path autosomes/merge/ --stem _[biological_sex]_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune --out merge_list_[biological_sex]
	date
	echo ""
	
	# Merge the files
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	plink --file autosomes/merge/chr1_[biological_sex]_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune --merge-list merge_list_[biological_sex].txt --recode --out autosomes/merge/merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune
	date
	echo ""
	
	# Edit the 6th column of the ped files
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	awk '{{$6 = "1"; print}}' autosomes/merge/merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune.ped > autosomes/merge/merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune_editColumn6.ped
	date
	echo ""
	
	echo "The autosomes are now being analyzed."
	echo ""
		
	# Make par file
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	python make_par.py --map autosomes/merge/merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune.map --ped autosomes/merge/merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_merge_no_missing_plink_LDprune_editColumn6.ped --ev merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune --par merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_par
	date
	
	# Run smartpca
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	smartpca -p merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_par_PCA.par
	date
	echo ""
	
	# Edit the evec files
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	awk '{{if($1 == "\t" ) {{print $2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t",$13,"\t"}} else {{print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t"}}}}' merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune.evec > merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix.evec
	awk '{gsub(/\.variant2/,""); gsub(/\.variant/,""); print}' merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix.evec > merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix2.evec
	date
	echo ""

	echo "The analysis results are now being plotted."
	echo ""
		
	# Plot results and get inferred population report
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	Rscript pca_inferred_ancestry_report.R merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune_Fix2.evec merge_all_chr_[biological_sex]_reference_panel_unknown_set_SNPs_no_missing_plink_LDprune.eval ThousandGenomesSamples_AdmxRm_SHORT.txt gtex_samples_SHORT.txt PCA_plots_all_autosomes_[biological_sex] autosomes_[biological_sex]_inferred_pop_report
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
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	python make_par.py --map chrX/merge/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune.map --ped chrX/merge/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_editColumn6.ped --ev chrX/pca/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune --par chrX/pca/par/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_par
	date
	echo ""
	
	# Run smartpca
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	smartpca -p chrX/pca/par/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_par_PCA.par
	date
	echo ""
	
	# Edit the evec files
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	awk '{{if($1 == "\t" ) {{print $2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t",$13,"\t"}} else {{print $1,"\t",$2,"\t",$3,"\t",$4,"\t",$5,"\t",$6,"\t",$7,"\t",$8,"\t",$9,"\t",$10,"\t",$11,"\t",$12,"\t"}}}}' chrX/pca/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune.evec > chrX/pca/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix.evec
	awk '{gsub(/\.variant2/,""); gsub(/\.variant/,""); print}' chrX/pca/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix.evec > chrX/pca/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix2.evec
	date
	echo ""
	
	# Plot results and get inferred population report
	# CHANGES NEEDED FOR EXECUTION:
	# 	1. make sure the biological sex in the file names match the one in the .json file
	date
	Rscript pca_inferred_ancestry_report.R chrX/pca/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune_Fix2.evec chrX/pca/chrX_[biological_sex]_reference_panel_unknown_set_SNPs_merge_noPARS_noXTR_noMissing_plink_LDprune.eval ThousandGenomesSamples_AdmxRm_SHORT.txt gtex_samples_SHORT.txt chrX/PCA_plots_chrX_[biological_sex] chrX/chrX_[biological_sex]_inferred_pop_report
	date
	
	echo ""	
	echo "The X chromosome has been analyzed."
	echo ""	
fi
