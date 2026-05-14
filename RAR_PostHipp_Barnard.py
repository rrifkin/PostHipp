from scipy.stats import barnard_exact
from scipy.stats.contingency import odds_ratio
import numpy as np
import pandas as pd

def RAR_PostHipp_Barnard (data_file, num_rows):

	df = pd.read_csv(data_file, dtype=str, usecols=[0, 1], nrows=num_rows)
	print (df)

	contingency_table = pd.crosstab(df['Concordant'], df['Outcome'])
	print(contingency_table)

	barnard_result = barnard_exact(contingency_table, alternative='two-sided')
	barnard_p = barnard_result.pvalue
	print("Barnard's Exact Test, p=", barnard_p)

	odds_ratio_result = odds_ratio (contingency_table)
	odds_ratio_statistic = odds_ratio_result.statistic
	odds_ratio_confidence_interval = odds_ratio_result.confidence_interval()
	print("Odds Ratio =", odds_ratio_statistic, "CI:", odds_ratio_confidence_interval)

if __name__ == "__main__":
	import sys
	RAR_PostHipp_Barnard (str(sys.argv[1]), int(sys.argv[2]))
