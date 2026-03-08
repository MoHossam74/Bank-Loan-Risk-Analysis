SELECT COUNT(*) 
FROM Loan_default
-------------------------------------------------------------------------
SELECT 
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) AS Defaulted,
    CAST(
        SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS DefaultRate_Percentage
FROM Loan_default
---------------------------------------------------------------------------

SELECT 
    CreditScore,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) AS Defaulted,
    CAST(
        SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS DefaultRate_Percentage
FROM Loan_default
GROUP BY CreditScore
ORDER BY DefaultRate_Percentage DESC;
--------------------------------------------------------
SELECT 
    CASE 
        WHEN CreditScore < 500 THEN 'Poor'
        WHEN CreditScore < 650 THEN 'Fair'
        WHEN CreditScore < 750 THEN 'Good'
        ELSE 'Excellent'
    END AS CreditCategory,
    
    COUNT(*) AS TotalCustomers,
    
    SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) AS Defaulted,
    
    CAST(
        SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS DefaultRate_Percentage

FROM Loan_default
GROUP BY 
    CASE 
        WHEN CreditScore < 500 THEN 'Poor'
        WHEN CreditScore < 650 THEN 'Fair'
        WHEN CreditScore < 750 THEN 'Good'
        ELSE 'Excellent'
    END
ORDER BY DefaultRate_Percentage DESC;
----------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN DTIRatio < 0.2 THEN 'Low DTI'
        WHEN DTIRatio < 0.4 THEN 'Medium DTI'
        ELSE 'High DTI'
    END AS DTI_Category,
    
    COUNT(*) AS TotalCustomers,
    
    SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) AS Defaulted,
    
    CAST(
        SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*) 
        AS DECIMAL(5,2)
    ) AS DefaultRate_Percentage

FROM Loan_default
GROUP BY 
    CASE 
        WHEN DTIRatio < 0.2 THEN 'Low DTI'
        WHEN DTIRatio < 0.4 THEN 'Medium DTI'
        ELSE 'High DTI'
    END
ORDER BY DefaultRate_Percentage DESC;
-----------------------------------------------------------------
WITH Segments AS (
    SELECT
        CASE 
            WHEN CreditScore < 500 THEN 'Poor'
            WHEN CreditScore < 650 THEN 'Fair'
            WHEN CreditScore < 750 THEN 'Good'
            ELSE 'Excellent'
        END AS CreditCategory,

        CASE 
            WHEN DTIRatio < 0.2 THEN 'Low DTI'
            WHEN DTIRatio < 0.4 THEN 'Medium DTI'
            ELSE 'High DTI'
        END AS DTI_Category,

        DefaultStatus
    FROM Loan_default
)
SELECT
    CreditCategory,
    DTI_Category,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) AS Defaulted,
    CAST(SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS DefaultRate_Percentage
FROM Segments
GROUP BY CreditCategory, DTI_Category
ORDER BY DefaultRate_Percentage DESC;
----------------------------------------------------------------------------
WITH Segments AS (
    SELECT
        CASE 
            WHEN CreditScore < 500 THEN 'Poor'
            WHEN CreditScore < 650 THEN 'Fair'
            WHEN CreditScore < 750 THEN 'Good'
            ELSE 'Excellent'
        END AS CreditCategory,

        CASE 
            WHEN DTIRatio < 0.2 THEN 'Low DTI'
            WHEN DTIRatio < 0.4 THEN 'Medium DTI'
            ELSE 'High DTI'
        END AS DTI_Category,

        DefaultStatus
    FROM Loan_default
),
Agg AS (
    SELECT
        CreditCategory,
        DTI_Category,
        COUNT(*) AS TotalCustomers,
        SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) AS Defaulted,
        CAST(SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS DefaultRate
    FROM Segments
    GROUP BY CreditCategory, DTI_Category
)
SELECT *,
       RANK() OVER (ORDER BY DefaultRate DESC) AS RiskRank
FROM Agg;
------------------------------------------------------------------------------------------------------------------------------
SELECT
    LoanID,

    CASE 
        WHEN CreditScore < 500 THEN 3
        WHEN CreditScore < 650 THEN 2
        WHEN CreditScore < 750 THEN 1
        ELSE 0
    END

    +

    CASE 
        WHEN DTIRatio < 0.2 THEN 0
        WHEN DTIRatio < 0.4 THEN 1
        ELSE 2
    END

    AS RiskScore

FROM Loan_default
------------------------------------------------------------------
WITH RiskCalculation AS (
    SELECT
        LoanID,

        (
            CASE 
                WHEN CreditScore < 500 THEN 3
                WHEN CreditScore < 650 THEN 2
                WHEN CreditScore < 750 THEN 1
                ELSE 0
            END

            +

            CASE 
                WHEN DTIRatio < 0.2 THEN 0
                WHEN DTIRatio < 0.4 THEN 1
                ELSE 2
            END
        ) AS RiskScore,

        DefaultStatus

    FROM Loan_default
)

SELECT
    RiskScore,
    COUNT(*) AS TotalCustomers,
    SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) AS Defaulted,
    CAST(
        SUM(CASE WHEN DefaultStatus = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(*) AS DECIMAL(5,2)
    ) AS DefaultRate_Percentage
FROM RiskCalculation
GROUP BY RiskScore
ORDER BY RiskScore DESC;
----------------------------------------------------------
WITH RiskCalculation AS (
    SELECT
        LoanID,
        Age,
        Income,
        LoanAmount,
        CreditScore,
        DTIRatio,
        InterestRate,
        LoanTerm,
        DefaultStatus,
        (
            CASE 
                WHEN CreditScore < 500 THEN 3
                WHEN CreditScore < 650 THEN 2
                WHEN CreditScore < 750 THEN 1
                ELSE 0
            END
            +
            CASE 
                WHEN DTIRatio < 0.2 THEN 0
                WHEN DTIRatio < 0.4 THEN 1
                ELSE 2
            END
        ) AS RiskScore
    FROM Loan_default
)
SELECT TOP 20
    LoanID, RiskScore, CreditScore, DTIRatio, Income, LoanAmount, InterestRate, LoanTerm, DefaultStatus
FROM RiskCalculation
ORDER BY RiskScore DESC, DTIRatio DESC, CreditScore ASC;
------------------------------------------------------------------------
CREATE VIEW BankLoanAnalysis AS
WITH RiskCalculation AS (
    SELECT
        LoanID,
        Age,
        Income,
        LoanAmount,
        CreditScore,
        MonthsEmployed,
        NumCreditLines,
        InterestRate,
        LoanTerm,
        DTIRatio,
        Education,
        EmploymentType,
        MaritalStatus,
        HasMortgage,
        HasDependents,
        LoanPurpose,
        HasCoSigner,
        DefaultStatus,

        CASE 
            WHEN CreditScore < 500 THEN 'Poor'
            WHEN CreditScore < 650 THEN 'Fair'
            WHEN CreditScore < 750 THEN 'Good'
            ELSE 'Excellent'
        END AS CreditCategory,

        CASE 
            WHEN DTIRatio < 0.2 THEN 'Low DTI'
            WHEN DTIRatio < 0.4 THEN 'Medium DTI'
            ELSE 'High DTI'
        END AS DTI_Category,

        (
            CASE 
                WHEN CreditScore < 500 THEN 3
                WHEN CreditScore < 650 THEN 2
                WHEN CreditScore < 750 THEN 1
                ELSE 0
            END
            +
            CASE 
                WHEN DTIRatio < 0.2 THEN 0
                WHEN DTIRatio < 0.4 THEN 1
                ELSE 2
            END
        ) AS RiskScore

    FROM Loan_default
)
SELECT * FROM RiskCalculation;
--------------------------------------------
SELECT TOP 10 *

FROM Loan_default;
USE BankLoanAnalysis;
GO

SELECT name 
FROM sys.views;