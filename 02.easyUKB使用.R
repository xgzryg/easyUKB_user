################加载R包、数据库储存路径################
rm(list = ls());gc()
library(easyUKB)
library(openxlsx)
library(stringr)
library(stringi)
library(tidyr)
library(dplyr)
library(data.table)
path='K:/easyUKB包开发/UKB_rawdata'
set_data_path(path)
################定义xx疾病需要提取的id
# id=read.xlsx("心脏病诊断ID.xlsx")
# colnames(id)[1]='ID'
# data <- batch_merge_data_optimized(id_list = id$ID)

################提取时间################
# p34	Year of birth
# p52	Month of birth
# 抽血时间 p3166_
# 死亡时间 40000	死亡日期  40007	去世时的年龄  40001	主要死因：ICD10
# 失访时间基线时间 p191	Date lost to follow-up 
# p200  p53_i0	基线时间 p21022 基线年龄
time=time_Extract()
# write.csv(time,'time.csv',row.names=F)

################糖尿病综合诊断################
Diabetes=Diabetes_Comprehensive_diagnosis()
write.csv(Diabetes, "Diabetes诊断.csv", row.names = FALSE)
Diabetes_duration=Diabetes_duration()
write.csv(Diabetes_duration, "Diabetes_duration.csv", row.names = FALSE)

################诊断1 触摸屏 报告################
# p6150_i0,p3894_i0,p3627_i0,p4056_i0,p2966_i0 
# 医生诊断的心血管疾病和糖尿病
Self_report_diagnosis=Self_report_diagnosis_p6150()

# p5901_i0 p5901_i1 p5901_i2 p5901_i3	
# Age when diabetes-related eye disease diagnosed
# 诊断出糖尿病相关眼病的年龄
Self_report_DR_diagnosis=Self_report_DR_diagnosis()

################诊断1 触摸屏 药物################
# 6177	胆固醇、血压或糖尿病的药物
# 6153	胆固醇、血压、糖尿病的药物，或者服用外源性激素
Self_report_drug=Self_report_drug_p6177_p6153()

# pain_meds止痛药包括c("Aspirin", "Ibuprofen (e.g. Nurofen)", "Paracetamol", "Codeine")
# stomach_meds胃药包括c("Ranitidine (e.g. Zantac)","Omeprazole (e.g. Zanprol)","Laxatives (e.g. Dulcolax, Senokot)")
# nsaid_meds NSAIDs (非甾体抗炎药)包括c("Aspirin", "Ibuprofen (e.g. Nurofen)")
#######样本量够的变量
# Aspirin_use 
# Ibuprofen_use 
# Paracetamol_use 
# Ranitidine_use 
# Omeprazole_use 
# Laxatives_use 
# Pain_medication_use 
# Stomach_medication_use 
# NSAID_medication_use
Self_report_drug_p6154_p10004_p10005=merge_col(Self_report_drug_p6154_p10004(),
                                               Self_report_drug_p10005())

################诊断2 访谈 Verbal interview诊断 20002非癌症################
# 1. 准备疾病列表
disease_list <- list(
  # 糖尿病视网膜病变
  Diabetic_retinopathy = c("1276"),
  # 糖尿病神经病变
  Diabetic_neuropathy = c("1254", "1255", "1256", "1258", "1468"),
  # 糖尿病肾病
  Diabetic_kidney_disease = c("1192", "1193", "1194", "1519", "1607"),
  # 冠心病
  Coronary_heart_disease = c("1074", "1075"),
  # 中风
  Stroke = c("1081", "1583"),
  # 糖尿病相关外周动脉疾病
  Peripheral_artery_disease = c("1067", "1087")
)
# 批量处理所有疾病
# 48种慢性疾病的Field Code列表（参考PDF文档）
disease_list <- list(
  # 1. 高血压
  Hypertension = c("1065", "1072"),
  # 2. 抑郁症
  Depression = c("1072", "1531"),
  # 3. 哮喘
  Asthma = c("1111"),
  # 4. 心房颤动
  Atrial_fibrillation = c("1471", "1075"),
  # 5. 冠心病
  Coronary_heart_disease = c("1074", "1138", "1139"),
  # 6. 消化不良
  Dyspepsia = c("1142", "1143", "1457", "1510", "1474", "1442"),
  # 7. 糖尿病
  Diabetes = c("1607", "1468", "1220", "1222", "1223", "1276"),
  # 8. 甲状腺疾病
  Thyroid_disorders = c("1224", "1225", "1226", "1522", "1610", "1428"),
  # 9. 慢性阻塞性肺病
  COPD = c("1112", "1113", "1472"),
  # 10. 焦虑症
  Anxiety = c("1287", "1288", "1469", "1615", "1614", "1616", "1243"),
  # 11. 肠易激综合征
  Irritable_bowel_syndrome = c("1154", "1408"),
  # 12. 酒精使用障碍
  Alcohol_use_disorder = c("1408", "1604"),
  # 13. 其他精神活性物质滥用
  Other_psychoactive_substance_abuse = c("1409", "1410"),
  # 14. 治疗性便秘
  Treated_constipation = c("1599"),
  # 15. 中风/短暂性脑缺血发作
  Stroke_TIA = c("1081", "1082", "1083", "1086", "1583"),
  # 16. 慢性肾病
  Chronic_kidney_disease = c("1427", "1607", "1192", "1193", "1194", "1519", "1520"),
  # 17. 憩室病
  Diverticular_disease = c("1458", "1458"),
  # 18. 外周血管疾病
  Peripheral_vascular_disease = c("1067", "1087"),
  # 19. 心力衰竭
  Heart_failure = c("1079", "1588", "1076"),
  # 20. 前列腺疾病
  Prostate_disorders = c("1207", "1396", "1516"),
  # 21. 癫痫
  Epilepsy = c("1264"),
  # 22. 痴呆
  Dementia = c("1263"),
  # 23. 精神分裂症/双相情感障碍
  Schizophrenia_bipolar_disorder = c("1289", "1291"),
  # 24. 银屑病/湿疹
  Psoriasis_eczema = c("1452", "1453"),
  # 25. 炎症性肠病
  Inflammatory_Bowel_Disease = c("1461", "1462", "1463"),
  # 26. 偏头痛
  Migraine = c("1265"),
  # 27. 支气管扩张
  Bronchiectasis = c("1114"),
  # 28. 帕金森病
  Parkinsons_disease = c("1262"),
  # 29. 多发性硬化症
  Multiple_Sclerosis = c("1261"),
  # 30. 骨质疏松症
  Osteoporosis = c("1465"),
  # 31. 慢性肝病
  Chronic_liver_disease = c("1141", "1157", "1158", "1506"),
  # 32. 梅尼埃病
  Menieres_disease = c("1421"),
  # 33. 恶性贫血
  Pernicious_Anaemia = c("1331"),
  # 34. 其他心脏问题
  Other_heart_cardiac_problem = c("1066"),
  # 35. 骨折
  Fracture = c("1647", "1648", "1650"),
  # 36. 青光眼
  Glaucoma = c("1277"),
  # 37. 白内障
  Cataract = c("1278"),
  # 38. 年龄相关性黄斑变性
  AMD = c("1528"))

verbal_interview_diagnosis <- easyUKB:::p20002_verbal_interview_diagnosis(path=path,disease_list,instances=0)

################诊断2 访谈 Verbal interview诊断 20001癌症################
# disease_list <- list(
#   # 39. 肺癌
#   Lung_Cancer = c("1001"),
#   # 40. 非黑色素瘤皮肤癌
#   Non_melanoma_skin_cancer = c("1060"),
#   # 41. 黑色素瘤
#   Melanoma = c("1059"),
#   # 42. 胃癌
#   Stomach_Cancer = c("1018"),
#   # 43. 食管癌
#   Oesophageal_cancer = c("1017"),
#   # 44. 结肠癌
#   Colon_cancer = c("1022"),
#   # 45. 前列腺癌
#   Prostate_cancer = c("1044"),
#   # 46. 卵巢癌
#   Ovarian_cancer = c("1039"),
#   # 47. 乳腺癌
#   Breast_cancer = c("1002"),
#   # 48. 其他癌症
#   Other_cancers = c("1004", "1005", "1006", "1007", "1008", "1009", "1010", "1011", "1012", 
#                     "1015", "1016", "1019", "1020", "1021", "1024", "1025", "1026", "1027", 
#                     "1028", "1029", "1030", "1031", "1032", "1033", "1034", "1035", "1036", 
#                     "1037", "1038", "1041", "1042", "1043", "1045", "1046", "1047", "1048", 
#                     "1050", "1051", "1052", "1053", "1055", "1056", "1058", "1061", "1062", 
#                     "1063", "1064", "1065", "1066", "1067", "1068", "1070", "1071", "1072", 
#                     "1073", "1074", "1075", "1076", "1077", "1078", "1079", "1080", "1081", 
#                     "1082", "1084", "1085", "1086", "1087", "1088")
# )
# cancer_verbal_interview_diagnosis=p20001_verbal_interview_diagnosis(path=path,disease_list,instances=0)

# 1. 首先定义所有癌症编码
all_cancer_codes <- c(
  "1001", "1002", "1003", "1004", "1005", "1006", "1007", "1008", "1009", "1010",
  "1011", "1012", "1015", "1016", "1017", "1018", "1019", "1020", "1021", "1022",
  "1023", "1024", "1025", "1026", "1027", "1028", "1029", "1030", "1031", "1032",
  "1033", "1034", "1035", "1036", "1037", "1038", "1039", "1040", "1041", "1042",
  "1043", "1044", "1045", "1046", "1047", "1048", "1050", "1051", "1052", "1053",
  "1055", "1056", "1058", "1059", "1060", "1061", "1062", "1063", "1064", "1065",
  "1066", "1067", "1068", "1070", "1071", "1072", "1073", "1074", "1075", "1076",
  "1077", "1078", "1079", "1080", "1081", "1082", "1084", "1085", "1086", "1087",
  "1088"
)
# 2. 定义特定癌症组（包含其所有子类型）
specific_groups <- list(
  # 肺癌（包含小细胞、非小细胞）
  Lung_Cancer = c("1001", "1027", "1028"),
  # 非黑色素瘤皮肤癌（包含基底细胞癌、鳞状细胞癌、啮齿性溃疡）
  Non_melanoma_skin_cancer = c("1060", "1061", "1062", "1073"),
  # 黑色素瘤
  Melanoma = "1059",
  # 胃癌
  Stomach_Cancer = "1018",
  # 食管癌
  Oesophageal_cancer = "1017",
  # 结肠癌
  Colon_cancer = c("1020","1022","1023","1086"),
  # 前列腺癌
  Prostate_cancer = "1044",
  # 卵巢癌
  Ovarian_cancer = "1039",
  # 乳腺癌
  Breast_cancer = "1002"
)
# 3. 其他癌症 = 所有编码 - 特定组中已包含的编码
used_codes <- unique(unlist(specific_groups))
Other_cancers <- setdiff(all_cancer_codes, used_codes)
# 4. 最终 disease_list
disease_list <- c(specific_groups, list(Other_cancers = Other_cancers))
# 5. 提取所有癌症数据
cancer_verbal_interview_diagnosis=easyUKB:::p20001_verbal_interview_diagnosis(path=path,disease_list,instances=0)

################诊断2 访谈 Verbal interview手术################
# 准备手术列表
operation_list <- list(
  # 糖尿病视网膜病变
  Diabetic_retinopathy = c("1437"),
  # 糖尿病神经病变
  Diabetic_neuropathy = c("1471"),
  # 糖尿病肾病
  Diabetic_kidney_disease = c("1195", "1580", "1581", "1582"),
  # 冠心病
  Coronary_heart_disease = c("1070", "1095", "1523"),
  # 中风
  Stroke = c("1468"),
  # 糖尿病相关外周动脉疾病
  Peripheral_artery_disease = c("1104","1108","1110","1440","1441","1442")
)
# 批量处理所有手术
verbal_interview_operation_diagnosis <- easyUKB:::p20004_verbal_interview_batch(operation_list,instances = 0)

################诊断2 访谈 Verbal interview药物################
# 提取数据
p20003=p20003_Extract_Convert( instances=0)

# ACE抑制剂（特异性最高）
ace_inhibitors = c(
  "1140860696", "1140860706", "1140860714", "1140860728", "1140860750",
  "1140860752", "1140860758", "1140860776", "1140860802", "1140860806",
  "1140860878", "1140860892", "1140860912")
# 二氢吡啶类钙通道阻滞剂（特异性高）
dihydropyridine_ccbs = c(
  "1140861088", "1140861090", "1140861190", "1140861194", "1140861202",
  "1140861276", "1140861282")
# 中枢性降压药（特异性高）
central_agents = c(
  "1140860454", "1140860470", "1140860478", "1140861984", "1140861986")
# 血管扩张剂（特异性高）
vasodilators = c("1140860520")
# α-受体阻滞剂（特异性较高）
alpha_blockers = c(
  "1140860580", "1140860610", "1140860690")
# 复方降压药（特异性高）
combination_antihypertensives = c(
  "1140860308", "1140860312", "1140860316", "1140860320", "1140860322",
  "1140860324", "1140860328", "1140860330", "1140860332", "1140860334",
  "1140860336", "1140860338", "1140860340", "1140860342", "1140860348",
  "1140860352", "1140860356", "1140860358", "1140860736", "1140860738")
# 所有高血压特异性药物（去重）
all_hypertension_drugs = unique(c(
  ace_inhibitors, dihydropyridine_ccbs, central_agents, vasodilators,
  alpha_blockers, combination_antihypertensives))
# 高血压
hypertension_codes = all_hypertension_drugs
p20003_hypertension = easyUKB:::p20003_disease_medicine(p20003,hypertension_codes, 
                                                        disease_name="hypertension")

################诊断3 测量指标诊断################
# 提取数据 诊断高血压
blood_pressure=diagnose_hypertension_byBP(instances=0)
# 提取数据 诊断血脂异常 包括高脂血症和低hdl
# 1. 美国国家胆固醇教育计划（NCEP）ATP III标准
# 总胆固醇（TC）：≥5.2 mmol/L (200 mg/dL)
# 甘油三酯（TG）：≥1.7 mmol/L (150 mg/dL)
# 低密度脂蛋白胆固醇（LDL-C）：≥3.4 mmol/L (130 mg/dL)
# 高密度脂蛋白胆固醇（HDL-C）：<1.0 mmol/L (40 mg/dL)（男性）；<1.3 mmol/L (50 mg/dL)（女性）
# 2. 中国成人血脂异常防治指南（2016修订版）
# 总胆固醇（TC）：≥5.2 mmol/L
# 甘油三酯（TG）：≥1.7 mmol/L
# 低密度脂蛋白胆固醇（LDL-C）：
# 低危人群：≥3.4 mmol/L
# 中危人群：≥2.6 mmol/L
# 高危人群：≥1.8 mmol/L
# 高密度脂蛋白胆固醇（HDL-C）：<1.0 mmol/L
# 3. 欧洲心脏病学会（ESC）指南
# 极高危人群：LDL-C ≥1.8 mmol/L
# 高危人群：LDL-C ≥2.6 mmol/L
# 中危人群：LDL-C ≥3.0 mmol/L
# diag_dyslipidemia()
# diag_hyperlipidemia()

################诊断4 算法定义的结局################
# Myocardial_infarction,Stroke,End_stage_renal_disease,STEMI,NSTEMI, 诊断
# Ischaemic_stroke,Intracerebral_haemorrhage,Subarachnoid_haemorrhage, 诊断
# COPD,Asthma,Motor_neurone_disease 诊断
# p42018	Dementia
# p42020	`Alzheimer's_disease`
# p42022	Vascular_dementia
# p42024	Frontotemporal_dementia
# Parkinsonism（帕金森综合征）是一个广义术语，指具有类似帕金森病症状的一组疾病
# 主要特征：震颤、僵硬、运动迟缓、姿势不稳
# 包括： 原发性帕金森病（Parkinson's disease）
# 继发性帕金森综合征（药物性、血管性、中毒性等）
# 帕金森叠加综合征（如多系统萎缩、进行性核上性麻痹等）
# p42030	Parkinsonism
# p42032	`Parkinson's disease`
# p42034  Progressive supranuclear palsy
# p42036	Multiple system atrophy
Algorithmically_defined_outcomes=Algorithmically_defined_outcomes()

################输入ICD10编码list################
ICD10_code_list <- list(
  # Heart_failure = c("I50","I500","I501","I509"),
  # MACE = c("I20","I200", "I201", "I208", "I209",
  #          "I21","I210","I211","I212","I213","I214","I219",
  #          "I22","I220","I221","I228","I229",
  #          "I23","I230","I231","I232","I233","I234","I235","I236","I238",
  #          "I24","I240", "I241", "I248", "I249", 
  #          "I25","I250", "I251", "I252", "I255", "I256", "I258", "I259",
  #          "I50","I500","I501","I509",
  #          "I60", "I600", "I601", "I602", "I603", "I604", "I605", "I606", "I607", "I608", "I609",
  #          "I61", "I610", "I611", "I612", "I613", "I614", "I615", "I616", "I618", "I619",
  #          "I63", "I630", "I631", "I632", "I633", "I634", "I635", "I636", "I638", "I639",
  #          "I64", 
  #          "I62","I620","I621","I629",
  #          "I70", "I700", "I7000", "I7001", "I701", "I7010", "I7011", "I702", 
  #          "I708", "I7080", "I7081", "I709", "I7090", "I7091", "I7020", "I7021", 
  #          "I71", "I710", "I711", "I712", "I713", "I714", "I715", "I716", "I718", "I719", 
  #          "I72", "I720", "I721", "I722", "I723", "I724", "I725", "I726", "I728", "I729",
  #          "I73", "I730", "I731", "I738", "I739",
  #          "I74", "I740", "I741", "I742", "I743", "I744", "I745", "I748", "I749"),
  Coronary_heart_disease = c("I20","I200", "I201", "I208", #"I209",
                             "I21","I210","I211","I212","I213","I214","I219",
                             "I22","I220","I221","I228","I229",
                             "I23","I230","I231","I232","I233","I234","I235","I236","I238",
                             "I24","I240", "I241", "I248", "I249", 
                             "I25","I250", "I251", "I252", "I255", "I256", "I258", "I259"),
  Stroke = c("I60", "I600", "I601", "I602", "I603", "I604", "I605", "I606", "I607", "I608", "I609",
             "I61", "I610", "I611", "I612", "I613", "I614", "I615", "I616", "I618", "I619",
             "I63", "I630", "I631", "I632", "I633", "I634", "I635", "I636", "I638", "I639",
             "I64"),
  Peripheral_artery_disease = c('E105', 'E115', 'E145',
                                "I70", "I700", "I7000", "I7001", "I701", "I7010", "I7011", "I702", 
                                "I708", "I7080", "I7081", "I709", "I7090", "I7091", "I7020", "I7021", 
                                "I71", "I710", "I711", "I712", "I713", "I714", "I715", "I716", "I718", "I719", 
                                "I72", "I720", "I721", "I722", "I723", "I724", "I725", "I726", "I728", "I729",
                                "I738", "I739"),
  Diabetic_kidney_disease = c("E102","E112", "E142", "N083",
                              "N18","N180", "N181", "N182","N183", "N184", "N185","N188", "N189"),
  Diabetic_neuropathy   = c("E104","E114","E144","G590",
                            "G629","G632", "G990"),
  Diabetic_retinopathy  = c("E103","E113","E143","H280","H360")
) 

# ICD10_code_list <- list(
#   gestational_diabetes = c("O244"),
#   congenital_heart_disease = c("Q20", "Q200", "Q201", "Q202", "Q203", "Q204", "Q205", "Q206", "Q208","Q209",
#                                "Q21", "Q210", "Q211", "Q212", "Q213", "Q214", "Q218", "Q219",
#                                "Q22", "Q220", "Q221", "Q222", "Q223", "Q224", "Q225", "Q226", "Q228",
#                                "Q229", "Q23", "Q230", "Q231", "Q232", "Q233", "Q234", "Q238", "Q239",
#                                "Q24", "Q240", "Q241", "Q242", "Q243", "Q244", "Q245", "Q246", "Q248",
#                                "Q249", "Q25", "Q250", "Q251", "Q252", "Q253", "Q254", "Q255", "Q256",
#                                "Q257", "Q258", "Q259", "Q26", "Q260", "Q261", "Q262", "Q263", "Q264",
#                                "Q265", "Q266", "Q268", "Q269"),
#   Atrial_fibrillation = c("I48"),
#   hypertension = c("I10", "I11", "I110", "I119", "I12", "I120", "I129", "I13", "I130", 
#                    "I131","I132", "I139", "I15", "I150", "I151", "I152", "I158", "I159"),
#   dyslipidemia = c("E780", "E781", "E782", "E784", "E785"),
#   diabetes_mellitus = c("E10", "E100", "E101", "E102", "E103", "E104", "E105", "E106", 
#                         "E107", "E108", "E109", "E11", "E110", "E111", "E112", "E113",
#                         "E114", "E115", "E116", "E117", "E118", "E119", "E14", "E140", 
#                         "E141", "E142", "E143", "E144", "E145", "E146", "E147", "E148", "E149"),
#   peripheral_arterial_disease = c("I70", "I700", "I7000", "I7001", "I702", "I7020", "I7021",
#                                   "I708", "I7080", "I709", "I7090", "I738", "I739"),
#   aortic_stenosis = c("I060", "I062", "I350", "I352"),
#   mitral_regurgitation = c("I051", "I052", "I340"),
#   atrial_fibrillation_or_flutter = c("I48", "I480", "I481", "I482", "I483", "I484", "I489"),
#   venous_thromboembolism = c("I26", "I260", "I269", "I80", "I800", "I801", "I802", "I803", 
#                              "I808", "I809", "I81", "I820", "I822", "D68", "D680", "D681", 
#                              "D682", "D683", "D684", "D685", "D686", "D688", "D689")
# )

# 48种慢性疾病的ICD-10编码列表
ICD10_code_list <- list(
  # 1. 高血压
  Hypertension = c("I10", "I110", "I119", "I12", "I120", "I129", "I13", "I130", 
                   "I131", "I132", "I139", "I15", "I150", "I151", "I152", 
                   "I158", "I159"),
  # 2 抑郁症
  Depression = c("F32", "F33", "F34", "F38", "F204"),
  # 3 哮喘
  Asthma = c("J45", "J450", "J451", "J458", "J459"),
  # 4 心房颤动
  Atrial_fibrillation = c("J48", "J480", "J481", "J482", "J489"),
  # 5 冠心病
  Coronary_heart_disease = c("I20", "I21", "I22", "I23", "I24", "I25"),
  # 6 消化不良
  Dyspepsia = c("K21", "K210", "K227", "K228", "K229", "K23", "K25", 
                "K29", "K26", "K30", "Q401", "B980"),
  # 7 糖尿病
  Diabetes = c("G632", "G590", "H360", "H280", "E10", "E11", "E12", 
               "E13", "E14", "E00"),
  # 8 甲状腺疾病
  Thyroid_disorders = c("E05", "E03", "E04", "E01", "E06", "E07", "E02"),
  # 9 慢性阻塞性肺病
  COPD = c("J41", "J42", "J43", "J44"),
  # 10 焦虑症
  Anxiety = c("F40", "F41", "F43", "F431", "F42", "Z733", "G470", "F99"),
  # 11 肠易激综合征
  Irritable_bowel_syndrome = c("K58", "F102"),
  # 12 酒精使用障碍
  Alcohol_use_disorder = c("K70", "F101"),
  # 13 其他精神活性物质滥用
  Other_psychoactive_substance_abuse = c("F111", "F100", "F112", "F119"),
  # 14 治疗性便秘
  Treated_constipation = c("K590"),
  # 15 中风/短暂性脑缺血发作
  Stroke_TIA = c("I64", "I65", "I60", "I61", "I62", "I66", "I63", "436", "437"),
  # 16 慢性肾病
  Chronic_kidney_disease = c("Q611", "Q612", "Q613", "N17", "N18", "N19", 
                             "E112", "N028"),
  # 17 憩室病
  Diverticular_disease = c("K57"),
  # 18 外周血管疾病
  Peripheral_vascular_disease = c("I72", "I73", "444"),
  # 19 心力衰竭
  Heart_failure = c("I42", "I50"),
  # 20 前列腺疾病
  Prostate_disorders = c("N40", "N41", "N42", "N510"),
  # 21 癫痫
  Epilepsy = c("G40"),
  # 22 痴呆
  Dementia = c("A810", "F00", "F01", "F03", "F051", "F106", "G30", "G31"),
  # 23 精神分裂症/双相情感障碍
  Schizophrenia_bipolar_disorder = c("F20", "F21", "F30", "F31"),
  # 24 银屑病/湿疹
  Psoriasis_eczema = c("L20", "L21", "L22", "L23", "L24", "L25", "L26", "L27", 
                       "L30", "L40", "L41"),
  # 25 炎症性肠病
  Inflammatory_Bowel_Disease = c("K50", "K51"),
  # 26 偏头痛
  Migraine = c("G43"),
  # 27 支气管扩张
  Bronchiectasis = c("J47"),
  # 28 帕金森病
  Parkinsons_disease = c("G20", "G21", "G22", "G23", "G259", "G26", "G903"),
  # 29 多发性硬化症
  Multiple_Sclerosis = c("G35"),
  # 30 骨质疏松症
  Osteoporosis = c("M15", "M150", "M1500", "M151", "M16", "M17"),
  # 31 慢性肝病
  Chronic_liver_disease = c("185", "B581", "K701", "K712", "K713", "K714", 
                            "K715", "K716", "K74", "K743"),
  # 32 梅尼埃病
  Menieres_disease = c("H810"),
  # 33 恶性贫血
  Pernicious_Anaemia = c("D51"),
  # 34 其他心脏问题
  Other_heart_cardiac_problem = c("146", "149", "151", "152", "167", "168", 
                                  "169", "170", "420", "421", "422", "423", 
                                  "424", "426", "427", "429"),
  # 35 骨折
  Fracture = c("S327", "S3270", "S72", "S820", "S8200"),
  # 36 青光眼
  Glaucoma = c("H40"),
  # 37 白内障
  Cataract = c("H25", "H26", "H28"),
  # 38 年龄相关性黄斑变性
  AMD = c("H353")
)

ICD10_code_list <- list(
  # 39 肺癌
  Lung_Cancer = "C34",
  # 40 非黑色素瘤皮肤癌
  Non_melanoma_skin_cancer = c("C44", "C45"),
  # 41 黑色素瘤
  Melanoma = "C43",
  # 42 胃癌
  Stomach_Cancer = "C16",
  # 43 食管癌
  Oesophageal_cancer = "C15",
  # 44. 结肠癌
  Colon_cancer = "C18",
  # 45. 前列腺癌
  Prostate_cancer = "C61",
  # 46. 卵巢癌
  Ovarian_cancer = "C56",
  # 47. 乳腺癌
  Breast_cancer = "C50",
  # 48. 其他癌症
  Other_cancers = c("C00", "C01", "C02", "C03", "C65", "C66", "C67", "C68", 
                    "C69", "C70", "C71", "C72", "C73", "C74", "C75", "C76", 
                    "C77", "C78", "C79", "C80", "C81", "C82", "C83", "C84", 
                    "C85", "C86", "C88", "C90", "C91", "C92", "C93", "C94", 
                    "C95", "C96", "C97")
)
# 单行代码扩展
ICD10_code_list <- lapply(ICD10_code_list, function(codes) {
  unique(unlist(lapply(codes, function(code) {
    if (nchar(code) == 3) c(code, paste0(code, 0:9)) else code
  })))
})

################诊断5 First occurrences首次出现################
# 首次出现（ICD10编码只有字母+前两位数字）
First_occurrences_diag_date=First_occurrences_multiple_disease_diagnosis(path=path,ICD10_code_list) 

################诊断6 死亡原因和日期年龄################
# 创建诊断列
Death <- death_diagnosis(time, ICD10_code_list)

################诊断7 住院诊断和首次住院日期################
# 一次性处理所有非癌症疾病 这里只有最细的诊断
Hospital_Diag = Hospital_inpatient_Diagnoses_date_ICD10(path=path,ICD10_code_list)
# 一次性处理所有癌症 这里只有最细的诊断
Cancer_Diag = Hospital_cancer_Diagnoses_date_ICD10(path=path,ICD10_code_list)

################输入ICD9编码list################
ICD9_code_list <- list(
  Diabetic_kidney_disease = c("8421","E90501", "3009", "E90503",
                              "E90504","E90506", "E90505"),
  Diabetic_neuropathy   = c("V501","V744","V740","V749",
                            "V745","V75", "V750"),
  Diabetic_retinopathy  = c("1389","5522","2534","E9051","E90510")
) 
################诊断7 住院诊断和首次住院日期################
Hospital_Diag = Hospital_inpatient_Diagnoses_date_ICD9(path=path,disease_list=ICD9_code_list)

################输入手术编码list################
operative_list = list(
  # 糖尿病视网膜病变
  Diabetic_retinopathy = c("C791", "C792", "C811", "C812", "C818", "C819", "C85"),
  # 糖尿病神经病变
  Diabetic_neuropathy = c("A733"),
  # 糖尿病肾病
  Diabetic_kidney_disease = c("M01", "X40"),
  # 冠心病
  Coronary_heart_disease = c("K40", "K41", "K42", "K43", "K44", "K45", "K46", "K47", "K48", "K49", "K50", "K75"),
  # 中风
  Stroke = c("L34", "L351", "L353", "L354", "L358", "L359"),
  # 糖尿病相关外周动脉疾病
  Peripheral_artery_disease = c(
    "L19", "L261", "L262", "L265", "L266", "L267", 
    "L27", "L28", "L431", "L435", "L521", "L522", 
    "L541", "L544", "L601", "L602", "L603", "L604",
    "L631", "L635", "X092", "X093", "X094", "X095", 
    "X098", "X099", "X101", "X104", "X108", "X109", 
    "X111", "X112", "X118", "X119")
)
################诊断8 医院手术和手术日期################
Hospital_operative_Diag = Hospital_operative_Diagnoses_date_ICD10(operative_list)

################使用患病时date计算单一疾病随访时间################
# 1. Diabetic_retinopathy (糖尿病视网膜病变)
diabetic_retinopathy_result <- combine_diseases_and_date(
  date_columns = list(
    Death$Diabetic_retinopathy_date,
    Hospital_Diag$Diabetic_retinopathy_date,
    Hospital_operative_Diag$Diabetic_retinopathy_date
  ),
  disease_columns = list(
    Death$Diabetic_retinopathy_diagnosis,
    Hospital_Diag$Diabetic_retinopathy_diagnosis,
    Hospital_operative_Diag$Diabetic_retinopathy_diagnosis
  ),
  new_name = "Diabetic_retinopathy"
)

# 2. Diabetic_neuropathy (糖尿病神经病变)
diabetic_neuropathy_result <- combine_diseases_and_date(
  date_columns = list(
    Death$Diabetic_neuropathy_date,
    Hospital_Diag$Diabetic_neuropathy_date,
    Hospital_operative_Diag$Diabetic_neuropathy_date
  ),
  disease_columns = list(
    Death$Diabetic_neuropathy_diagnosis,
    Hospital_Diag$Diabetic_neuropathy_diagnosis,
    Hospital_operative_Diag$Diabetic_neuropathy_diagnosis
  ),
  new_name = "Diabetic_neuropathy"
)

# 3. Diabetic_kidney_disease (糖尿病肾病)
# 注意：这里包括了 Algorithmically_defined_outcomes 中的 End_stage_renal_disease
diabetic_kidney_disease_result <- combine_diseases_and_date(
  date_columns = list(
    First_occurrences_diag_date$Diabetic_kidney_disease_date,
    Death$Diabetic_kidney_disease_date,
    Hospital_Diag$Diabetic_kidney_disease_date,
    Hospital_operative_Diag$Diabetic_kidney_disease_date,
    Algorithmically_defined_outcomes$End_stage_renal_disease_date
  ),
  disease_columns = list(
    First_occurrences_diag_date$Diabetic_kidney_disease_diagnosis,
    Death$Diabetic_kidney_disease_diagnosis,
    Hospital_Diag$Diabetic_kidney_disease_diagnosis,
    Hospital_operative_Diag$Diabetic_kidney_disease_diagnosis,
    Algorithmically_defined_outcomes$End_stage_renal_disease_diagnosis
  ),
  new_name = "Diabetic_kidney_disease"
)

# 4. Coronary_heart_disease (冠心病)
# 注意：这里包括了 Algorithmically_defined_outcomes 中的 Myocardial_infarction
coronary_heart_disease_result <- combine_diseases_and_date(
  date_columns = list(
    First_occurrences_diag_date$Coronary_heart_disease_date,
    Death$Coronary_heart_disease_date,
    Hospital_Diag$Coronary_heart_disease_date,
    Hospital_operative_Diag$Coronary_heart_disease_date,
    Algorithmically_defined_outcomes$Myocardial_infarction_date
  ),
  disease_columns = list(
    First_occurrences_diag_date$Coronary_heart_disease_diagnosis,
    Death$Coronary_heart_disease_diagnosis,
    Hospital_Diag$Coronary_heart_disease_diagnosis,
    Hospital_operative_Diag$Coronary_heart_disease_diagnosis,
    Algorithmically_defined_outcomes$Myocardial_infarction_diagnosis
  ),
  new_name = "Coronary_heart_disease"
)

# 5. Stroke (卒中)
# 注意：这里包括了 Algorithmically_defined_outcomes 中的 Stroke
stroke_result <- combine_diseases_and_date(
  date_columns = list(
    First_occurrences_diag_date$Stroke_date,
    Death$Stroke_date,
    Hospital_Diag$Stroke_date,
    Hospital_operative_Diag$Stroke_date,
    Algorithmically_defined_outcomes$Stroke_date
  ),
  disease_columns = list(
    First_occurrences_diag_date$Stroke_diagnosis,
    Death$Stroke_diagnosis,
    Hospital_Diag$Stroke_diagnosis,
    Hospital_operative_Diag$Stroke_diagnosis,
    Algorithmically_defined_outcomes$Stroke_diagnosis
  ),
  new_name = "Stroke"
)

# 6. Peripheral_artery_disease (外周动脉疾病)
peripheral_artery_disease_result <- combine_diseases_and_date(
  date_columns = list(
    First_occurrences_diag_date$Peripheral_artery_disease_date,
    Death$Peripheral_artery_disease_date,
    Hospital_Diag$Peripheral_artery_disease_date,
    Hospital_operative_Diag$Peripheral_artery_disease_date
  ),
  disease_columns = list(
    First_occurrences_diag_date$Peripheral_artery_disease_diagnosis,
    Death$Peripheral_artery_disease_diagnosis,
    Hospital_Diag$Peripheral_artery_disease_diagnosis,
    Hospital_operative_Diag$Peripheral_artery_disease_diagnosis
  ),
  new_name = "Peripheral_artery_disease"
)

final_combined_date <- combine_disease_dates(time,
                                             diabetic_retinopathy_result,
                                             diabetic_neuropathy_result,
                                             diabetic_kidney_disease_result,
                                             coronary_heart_disease_result,
                                             stroke_result,
                                             peripheral_artery_disease_result
)
# 保存到CSV文件
write.csv(final_combined_date, "combined_diseases_date_data.csv", row.names = FALSE)

################使用患病时age计算单一疾病随访时间################
# 1. Diabetic_retinopathy (糖尿病视网膜病变)
diabetic_retinopathy_age_result <- combine_diseases_and_age(
  age_columns = list(
    verbal_interview_diagnosis$Diabetic_retinopathy_age,
    verbal_interview_operation_diagnosis$Diabetic_retinopathy_age,
    Self_report_DR_diagnosis$Diabetic_eye_disease_age
  ),
  disease_columns = list(
    verbal_interview_diagnosis$Diabetic_retinopathy_diagnosis,
    verbal_interview_operation_diagnosis$Diabetic_retinopathy_diagnosis,
    Self_report_DR_diagnosis$Diabetic_eye_disease_diagnosis
  ),
  new_name = "Diabetic_retinopathy"
)

# 2. Diabetic_neuropathy (糖尿病神经病变)
diabetic_neuropathy_age_result <- combine_diseases_and_age(
  age_columns = list(
    verbal_interview_diagnosis$Diabetic_neuropathy_age,
    verbal_interview_operation_diagnosis$Diabetic_neuropathy_age
  ),
  disease_columns = list(
    verbal_interview_diagnosis$Diabetic_neuropathy_diagnosis,
    verbal_interview_operation_diagnosis$Diabetic_neuropathy_diagnosis
  ),
  new_name = "Diabetic_neuropathy"
)

# 3. Diabetic_kidney_disease (糖尿病肾病)
diabetic_kidney_disease_age_result <- combine_diseases_and_age(
  age_columns = list(
    verbal_interview_diagnosis$Diabetic_kidney_disease_age,
    verbal_interview_operation_diagnosis$Diabetic_kidney_disease_age
  ),
  disease_columns = list(
    verbal_interview_diagnosis$Diabetic_kidney_disease_diagnosis,
    verbal_interview_operation_diagnosis$Diabetic_kidney_disease_diagnosis
  ),
  new_name = "Diabetic_kidney_disease"
)

# 4. Coronary_heart_disease (冠心病)
# 注意：Self_report_diagnosis中有heart_attack和angina，需要合并
# 首先创建合并的冠心病诊断列
heart_attack_diagnosis <- ifelse(is.na(Self_report_diagnosis$heart_attack), 0, Self_report_diagnosis$heart_attack)
angina_diagnosis <- ifelse(is.na(Self_report_diagnosis$angina), 0, Self_report_diagnosis$angina)
self_report_chd_diagnosis <- as.integer(heart_attack_diagnosis == 1 | angina_diagnosis == 1)

# 获取最小年龄
self_report_chd_age <- pmin(
  Self_report_diagnosis$heart_attack_age,
  Self_report_diagnosis$angina_age,
  na.rm = TRUE
)
self_report_chd_age[self_report_chd_diagnosis == 0] <- NA

coronary_heart_disease_age_result <- combine_diseases_and_age(
  age_columns = list(
    verbal_interview_diagnosis$Coronary_heart_disease_age,
    verbal_interview_operation_diagnosis$Coronary_heart_disease_age,
    self_report_chd_age
  ),
  disease_columns = list(
    verbal_interview_diagnosis$Coronary_heart_disease_diagnosis,
    verbal_interview_operation_diagnosis$Coronary_heart_disease_diagnosis,
    self_report_chd_diagnosis
  ),
  new_name = "Coronary_heart_disease"
)

# 5. Stroke (卒中)
stroke_age_result <- combine_diseases_and_age(
  age_columns = list(
    verbal_interview_diagnosis$Stroke_age,
    verbal_interview_operation_diagnosis$Stroke_age,
    Self_report_diagnosis$stroke_age
  ),
  disease_columns = list(
    verbal_interview_diagnosis$Stroke_diagnosis,
    verbal_interview_operation_diagnosis$Stroke_diagnosis,
    Self_report_diagnosis$stroke
  ),
  new_name = "Stroke"
)

# 6. Peripheral_artery_disease (外周动脉疾病)
peripheral_artery_disease_age_result <- combine_diseases_and_age(
  age_columns = list(
    verbal_interview_diagnosis$Peripheral_artery_disease_age,
    verbal_interview_operation_diagnosis$Peripheral_artery_disease_age
  ),
  disease_columns = list(
    verbal_interview_diagnosis$Peripheral_artery_disease_diagnosis,
    verbal_interview_operation_diagnosis$Peripheral_artery_disease_diagnosis
  ),
  new_name = "Peripheral_artery_disease"
)

final_combined_age <- combine_disease_ages(time,
                                           diabetic_retinopathy_age_result,
                                           diabetic_neuropathy_age_result,
                                           diabetic_kidney_disease_age_result,
                                           coronary_heart_disease_age_result,
                                           stroke_age_result,
                                           peripheral_artery_disease_age_result
)
write.csv(final_combined_age, "combined_diseases_age_data.csv", row.names = FALSE)

################合并age随访时间和date随访时间################
combined_result <- merge_disease_dataframes(final_combined_date, final_combined_age)
write.csv(combined_result, "combined_result.csv", row.names = FALSE)

################批量合并age随访时间和date随访时间################
# 将数据源放入一个列表中
diag_date_list <- list(
  Death = Death,
  Hospital_Diag = Hospital_Diag,
  verbal_interview_diagnosis = verbal_interview_diagnosis,
  First_occurrences_diag_date = First_occurrences_diag_date
)
# 使用函数自动合并所有疾病
all_disease_date_results <- combine_all_diseases_date(diag_date_list)
all_disease_date_results <- cbind(all_disease_date_results, time[, c(
  "baseline_age", "baseline_date", "blood_time0", 
  "blood_time_age", "outcome_age", "outcome_time")]) %>% 
  dplyr::rename(blood_time = blood_time0)
all_disease_date_results <- process_date_dataframe(all_disease_date_results)
# 保存到CSV文件
write.csv(all_disease_date_results, "48种慢性疾病随访_diseases_date.csv", row.names = FALSE)

all_disease_age_results <- combine_all_diseases_age(diag_date_list)
all_disease_age_results <- cbind(all_disease_age_results, time[, c(
  "baseline_age", "baseline_date", "blood_time0", 
  "blood_time_age", "outcome_age", "outcome_time")])
all_disease_age_results <- process_age_dataframe(all_disease_age_results)
write.csv(all_disease_age_results, "48种慢性疾病随访_diseases_age.csv", row.names = FALSE)

combined_result <- merge_disease_dataframes(all_disease_date_results, all_disease_age_results)
write.csv(combined_result, "48种慢性疾病随访_combined_result.csv", row.names = FALSE)

################人口学&血检&协变量################
demo=list(age_sex_income(),
          ethnicity(),
          Townsend_deprivation_index(),
          employment(),
          education(),
          UKB_Assessment_Centre(),
          obesity(),
          SBP_DBP(),
          Hand_grip_strength_kg(),
          Smoking_status(),
          Alcohol_status(),
          Alcohol_intake_frequency(),
          Sleep(),
          Healthy_sleep_score(),
          Vitamin_and_mineral_supplements(),
          dex_eGFR(),
          calc_uacr(),
          Physical_activity(),
          IPAQ_activity_group(),
          blood_count(),
          blood_biochemistry()
) %>% purrr::reduce(full_join,by="eid")
write.csv(demo, "demo.csv", row.names = FALSE)

################CKM综合征0-3期基线诊断################
CKM_stage=calculate_CKM_stage(path = NULL,instance = 0,
                              uacr_col = "uacr_mg_g",
                              abdominal_obesity_criteria = "AHA_metabolic",
                              ckd_method = "ckm_categories")

################CKD################
CKD_stage=easyUKB::calculate_CKD_stage(path=path,instance=0,
                                       egfr_col="eGFR_EPI_2021_scr", 
                                       uacr_col="uacr_mg_g",
                                       method=c("kdigo_risk"))　# kdigo指南

################腹型肥胖################
abdominal_obesity=easyUKB::calculate_abdominal_obesity(path=path,
                                                       instance=0,
                                                       criteria="AHA_metabolic")

################基线高血压################
baseline_hypertension=diagnose_baseline_hypertension(instance=0)

################7种胰岛素抵抗指标################
IR_indices=calculate_IR_indices(instance=0)

################9种肥胖相关体型指标################
obesity_indices=calculate_obesity_indices(instance=0)

################AHA Prevent方程10年心血管风险################
Prevent_CVD_Risk=easyUKB::calculate_Prevent_CVD_Risk(instances=0)

################血脂异常################
Dyslipidemia=easyUKB::calculate_Dyslipidemia()

################呼吸功能################
FEV1=extract_FEV1_Best(path = NULL, instance = 0) 

################肾功能################
# eGFR和UACR（尿白蛋白肌酐比）
kidney_function=list(dex_eGFR(),
                     calc_uacr()
) %>% purrr::reduce(full_join,by="eid")
# 在基线或基线前有CKD[eGFR<60mL/min/1.73m2 或
# 尿白蛋白肌酐比（urine albumin-to-creatinine ratio，UACR）≥30mg/g
kidney_function_poor=subset(kidney_function,
                            eGFR_EPI_2021_scr<60 |
                              uacr_mg_g>=30)
kidney_function_healthy=subset(kidney_function,!(eid%in%kidney_function_poor$eid))

################计算 GOLD ProtAge################
GOLD_ProtAge=calculate_GOLD_ProtAge(path = NULL)

################计算 GOLD MetAge################
GOLD_MetAge=calculate_GOLD_MetAge(path = NULL)

################计算 GOLD Light BioAge################
# 是GOLD BioAge的精简版
Light_BioAge_UKB=calculate_Light_BioAge_UKB(path = NULL, instance = 0) 

################计算 GOLD BioAge################
GOLD_BioAge_UKB=calculate_GOLD_BioAge_UKB(path = NULL, instance = 0) 

################计算 表型年龄################
PhenotypicAge=calculate_PhenotypicAge(path=NULL, instance = 0)

################BioAge包计算KDM-BA、表型年龄、HD################
# 基于NHANESIII训练
BioAges=calculate_BioAges(path=NULL)

################计算生物年龄加速################
# extreme_threshold:Z 分数阈值
# 默认 1.5，用于定义极端衰老和极端年轻的样本
# method:计算方法
# "linear"：线性回归残差（默认）
# "lowess"：局部加权回归残差（LOWESS/LOESS）
# 使用 loess 函数，参数 span = 2/3、degree = 2、family = "symmetric"
# "direct"：直接差值（生物学年龄 - 实际年龄）
BioAge_Acceleration <- calculate_BioAge_Acceleration(data=df, 
                                                     chronological_age="Age",
                                                     biological_age="phenoage", 
                                                     sex = "Sex", #注释掉就不按性别分层回归
                                                     extreme_threshold = 1.5,
                                                     method="linear",
                                                     id = "eid")

################环境污染################
#####水质
# Field ID	Description
# 21104	Ca concentration 钙浓度
# 21103	CaCO3 concentration 碳酸钙浓度
# 21105	Mg concentration 镁浓度
# 21100	Water hardness (USGS classification) 水的硬度（根据美国地质调查局的分类标准）
# 21101	Water hardness (WHO classification) 水的硬度（世界卫生组织的分类标准）
# 21102	Year of survey 调查年份
Water_quality_assessment=Water_quality_assessment()

#####噪音
# Field ID	Description
# 24024	Average 24-hour sound level of noise pollution
# 24023	Average 16-hour sound level of noise pollution
# 24022	Average night-time sound level of noise pollution
# 24021	Average evening sound level of noise pollution
# 24020	Average daytime sound level of noise pollution
residential_noise_pollution=residential_noise_pollution()

#####空气污染
# ID	name	units
# p24003	Nitrogen dioxide air pollution; 2010	micro-g/m3
# p24004	Nitrogen oxides air pollution; 2010	micro-g/m3
# p24005	Particulate matter air pollution (pm10); 2010	micro-g/m3
# p24006	Particulate matter air pollution (pm2.5); 2010	micro-g/m3
# p24007	Particulate matter air pollution (pm2.5) absorbance; 2010	per-metre
# p24008	Particulate matter air pollution 2.5-10um; 2010	micro-g/m3
# p24009	Traffic intensity on the nearest road	vehicles/day
# p24010	Inverse distance to the nearest road	1/metres
# p24011	Traffic intensity on the nearest major road	vehicles/day
# p24012	Inverse distance to the nearest major road	1/metres
# p24013	Total traffic load on major roads	vehicles/day
# p24014	Close to major road	
# p24015	Sum of road length of major roads within 100m	metres
# p24016	Nitrogen dioxide air pollution; 2005	micro-g/m3
# p24017	Nitrogen dioxide air pollution; 2006	micro-g/m3
# p24018	Nitrogen dioxide air pollution; 2007	micro-g/m3
# p24019	Particulate matter air pollution (pm10); 2007	micro-g/m3
air_pollution=air_pollution()

#####绿地面积和海岸距离
# Greenspace and coastal proximity
# ID	name	units
# p24500_i0	Greenspace percentage, buffer 1000m	percent
# p24500_i1	Greenspace percentage, buffer 1000m	percent
# p24501_i0	Domestic garden percentage, buffer 1000m	percent
# p24501_i1	Domestic garden percentage, buffer 1000m	percent
# p24502_i0	Water percentage, buffer 1000m	percent
# p24502_i1	Water percentage, buffer 1000m	percent
# p24503_i0	Greenspace percentage, buffer 300m	percent
# p24503_i1	Greenspace percentage, buffer 300m	percent
# p24504_i0	Domestic garden percentage, buffer 300m	percent
# p24504_i1	Domestic garden percentage, buffer 300m	percent
# p24505_i0	Water percentage, buffer 300m	percent
# p24505_i1	Water percentage, buffer 300m	percent
# p24506_i0	Natural environment percentage, buffer 1000m	percent
# p24506_i1	Natural environment percentage, buffer 1000m	percent
# p24507_i0	Natural environment percentage, buffer 300m	percent
# p24507_i1	Natural environment percentage, buffer 300m	percent
# p24508_i0	Distance (Euclidean) to coast	Kilometres
# p24508_i1	Distance (Euclidean) to coast	Kilometres
greenspace=greenspace()
################电子设备使用################
# electronic_device_use
# Field ID	Description
# p1110_i0	Length_of_mobile_phone_use
# p1120_i0	Weekly_usage_of_mobile_phone_in_last_3_months
# p1130_i0	Hands-free_device/speakerphone_use_with_mobile_phone_in_last_3_month
# p1140_i0	Difference_in_mobile_phone_use_compared_to_two_years_previously
# p1150_i0	Usual_side_of_head_for_mobile_phone_use
# p2237_i0	Plays_computer_games
# 不用：
# 10749	Time using mobile phone in last 3 months (pilot)
# 10016	Regular use of hands-free device/speakerphone with mobile phone (pilot)
# 10886	Difference in mobile phone use compared to one year previously (pilot)
# 10105	Internet user (pilot)
# 10114	Willing to be contacted by email (pilot)
# 应用处理函数
electronic_device_use <- electronic_device_use()

################家族史和家庭人员生存状态和年龄################
#### 家庭人员生存状态和年龄
# Field ID	Description   history
# p1797_i0	Father still alive
# p2946_i0	Father's age
# p1807_i0	Father's age at death
# p1835_i0	Mother still alive
# p1845_i0	Mother's age
# p3526_i0	Mother's age at death
# p4501_i0	Non-accidental death in close genetic family
family_survival_status <- family_survival_status()

#### 家族史
# p20107_i0	Illnesses of father
# p20110_i0	Illnesses of mother
# p20111_i0	Illnesses of siblings
family_illnesses <- family_illnesses()
Family_history=family_illnesses[["Family_history"]]
Father_history=family_illnesses[["Father"]]
Mother_history=family_illnesses[["Mother"]]

################处理日晒相关变量################
# Field ID	描述	Description
# p1050_i0	夏季在户外的时间	Time_spend_outdoors_in_summer
# p1060_i0	冬季在户外的时间	Time_spent_outdoors_in_winter
# p1717_i0	肤色	Skin_colour
# p1727_i0	皮肤晒黑的容易程度	Ease_of_skin_tanning
# p1737_i0	儿童时期被晒伤的次数	Childhood_sunburn_occasions
# p1747_i0	头发颜色（自然色，未变灰之前）	Hair_colour
# p1757_i0	面部老化	Facial_ageing
# p2267_i0	使用防晒产品	Sun/UV_protection_use
# p2277_i0	使用日光浴床/太阳灯的频率	Frequency_of_solarium/sunlamp_use
# 处理日晒相关变量
processed_data <- sun_exposure_data(data)

################40个遗传主成分################
# Genetic principal components 遗传主成分（共40个，一般纳入前20个做协变量）
GPC=Genetic_principal_components(n=20)

################读取处理蛋白组数据################
protein_data=extract_protein_data(path = NULL, 
                                  instance = 0,
                                  threshold_protein = 20,
                                  threshold_sample = 50,
                                  impute = c("median"))
# 提取list里的蛋白统计数据
proteins_stats=as.data.frame(protein_data$stats)
# 提取list里的蛋白数据
proteins=protein_data$filtered_data

################提取蛋白组学的技术因素协变量和常见人口、生活协变量################
olink_covariates=Proteomics_covariate()
write.csv(olink_covariates,'olink_covariates.csv',row.names = F)

################提取需要的特定协变量################
data=fread("K:/UKB文章/UKB变量计算/48种慢性疾病随访_combined_result.csv")

# 糖尿病病程和糖化血红蛋白
Diabetes_duration=Diabetes_duration()
Diabetes_duration=Diabetes_duration%>%select(-Baseline_age,-Diagnosis_age)

demo=list(age_sex_income(),
          ethnicity(),
          education(),
          Townsend_deprivation_index(),
          obesity(),
          SBP_DBP(),
          Smoking_status(),
          Alcohol_status(),
          Sleep(),
          Healthy_sleep_score(),
          dex_eGFR(),
          Physical_activity(),
          blood_count(),
          blood_biochemistry()
) %>% purrr::reduce(full_join,by="eid")

# 提取所有推荐变量
selected_vars <- c(
  # 人口统计学和基本特征
  "eid", "Age", "Sex", "Income", "Education", "Townsend_deprivation_index", "Ethnicity",
  # 体格测量
  "BMI", "Obesity_state", "SBP", "DBP", "Mean_arterial_pressure", "Pulse_pressure",
  # 生活方式
  "Smoking_status", "Alcohol_status", 
  "Sleep_duration", "Insomnia", "Snoring", "Daytime_dozing/sleeping", "Healthy_sleep_score",
  "Physical_activity(MET,min/week)", "Moderate_and_vigorous_physical_activity(MVPA)",
  # 血常规
  "WBC(10^9 cells/Litre)", "RBC(10^12 cells/Litre)", "Hb(grams/decilitre)", "PLT(10^9 cells/Litre)",
  "Lym#(10^9 cells/Litre)", "Lym%(percent)", "Mono#(10^9 cells/Litre)", "Mono%(percent)", 
  "Neu#(10^9 cells/Litre)", "Neu%(percent)",
  # 生化和代谢
  "eGFR_EPI_2021_scr","Glu(mmol/L)", "HbA1c(mmol/mol)", "Cr(umol/L)", "Cys C(mg/L)", "UA(umol/L)",
  "Alb(g/L)", "TC(mmol/L)", "TG(mmol/L)", "HDL-C(mmol/L)", "LDL-C(mmol/L)", 
  "Apo A(g/L)", "Apo B(g/L)", "CRP(mg/L)","Lp(a)(nmol/L)",
  "ALT(U/L)", "AST(U/L)", "GGT(U/L)", "ALP(U/L)", "TBIL(umol/L)", "DBIL(umol/L)"
)
# 提取数据子集
demo_selected <- demo[, ..selected_vars]  # 使用data.table语法
demo_selected=merge(demo_selected,Diabetes_duration,by='eid')

write.csv(demo_selected, "糖尿病大血管病变临床预测模型指标.csv", row.names = FALSE)

