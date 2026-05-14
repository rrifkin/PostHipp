function RAR_PostHipp_chi2 (outcomes_csv)

	outcomes_table = readtable(outcomes_csv)
	[cont_table, chi2, p] = crosstab(outcomes_table.(1), outcomes_table.(2))

end
