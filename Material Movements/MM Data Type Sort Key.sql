CASE
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) = 'BI'
        THEN 0
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) = 'EI'
        THEN 100
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) = 'CI'
        THEN 98
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) = 'AD'
        THEN 99
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'PC%'
        THEN 1
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'GI%'
        THEN 5
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'IP%' OR CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'SN%'
        THEN 10
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'IC%' OR CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'SC%'
        THEN 15
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'TR%'
        THEN 20
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'RT%'
        THEN 25
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'TO%'
        THEN 30
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'TI%'
        THEN 35
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'TC%'
        THEN 40
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'CO%'
        THEN 45
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'CR%'
        THEN 50
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'CC%'
        THEN 55
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'IL%'
        THEN 60
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'IG%'
        THEN 65
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'GC%'
        THEN 70
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'TF%'
        THEN 75
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'RR%'
        THEN 80
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE 'NC%'
        THEN 85
    ELSE 90
END
+
CASE
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE '%CCPO'
        THEN 1
    WHEN CAST([Q MM R32 Comparison Union Network Base].[Data Type] AS VARCHAR(25)) LIKE '%PCCO'
        THEN 2
    ELSE 0
END
