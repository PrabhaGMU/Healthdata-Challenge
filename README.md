# Healthdata-Challenge

Title: Exploring the Relationship Between Length of Stay and Total Bill Cost: A Linear Regression Analysis in Hospital Management

Abstract:
Efficient hospital management hinges on optimizing patient length of stay (LOS) and controlling costs. This study employs linear regression to investigate the impact of LOS on total bill costs per admission, aiming to discern the relationship while considering confounding factors. This analysis aims to elucidate the significance of Length of Stay (LOS) in healthcare expenditure. Insights from this analysis can inform strategies for resource allocation and cost containment in hospitals.

Data:
Clinical data with various parameters for a medical condition. Four tables were given and table names: 
Bill_id-/*13600*/rows 
Bill_amount-/*13600*/ rows
Demographics-/*3000*/rows 
Clinical_data-/*3400*/ rows

Results:
Descriptive Analysis
Conducted descriptive analysis considering individuals by race type.  Among patients (n=3,400) with different race type and other characteristics were displayed.

Pearson Correlation
-The CORR procedure produces Pearson correlation coefficients for continuous numeric variables. 
-The important cells we want to look at are either 2 or 3 (Cells 1 and 4 are identical, because they include information about the same pair of variables.) Cells 1 and 4 contain the correlation coefficient itself, its p-value, and the number of complete pairwise observations that the calculation was based on.
-In cell 2 (repeated in cell 3), we can see that the Pearson correlation coefficient for tot_amount and LOS is 0.009, which is not significant (p > .001 for a two-tailed test), based on 3400 complete observations.
-Correlation for other continuous variables were conducted. 


T-test statistics
-Displaying actual t-test results, and the fourth table contains the "Equality of Variances" test results:
for variables Gender (Male:0 and Female:1) against Total cost
Observation
-Since p >.0001 is greater than our chosen significance level α = 0.05 ,we conclude that males and females are not statistically significant to total cost.
-the dependent variable(total cost) -- that is, the continuous numeric variable -- to use in the test. 
-the independent variable (Gender)-- that is, the categorical variable -- to use in the test. 
-ttest was conducted for other variables and included in the analysis.

Multiple Linear Regression
Global F test (P-value < .0001) indicates that model is significant for predicting Total Bill cost based on a group of independent variables in the model.
The value of R-square is 0.286393, which means approximately 28% of the variation in Total Bill cost is explained by the independent variables.
Based on t-test with the significant level, the p-values for Race, Age, Weight, Medical_history 1 and 6. Also, all symptoms indicated sufficient evidence for predicting the total bill cost. 
Each parameter represents the mean change in the response variable for every 1-unit increase in the corresponding when all the other x’s are held fixed. For example, the total cost increases with positive values for every independent variable (observed from estimate column of results).
-Based on the p-value, Length of stay is not significantly associated with total bill cost included in the analysis.
A 95% confidence interval for Symptom_5 is (0.2210034259, 0.2699021884). This means that we are 95% confident that the total cost increases between 0.2210034259 and 0.2699021884 for every 1-symptom increase. Note: A zero in the 95% Confidence Intervals can also indicate that the independent variable is insignificant. 

Conclusion
The study findings implicated that LOS’s effect on Total Bill Cost did not have significant evidence after controlling for demographical confounders. Patients with all symptoms had a significant association to rise in total bill cost. 
Also, demographical variables Race, Age, Weight had significant relationship with rise in cost of care.
For patients included in this analysis for a medical condition, Medical_history 1 and 6 had relatively good association with total bill cost.

Future Work: Based on previous research findings and current results from the analysis there is clear path to continue further research work for this medical condition to find more drivers in cost.








