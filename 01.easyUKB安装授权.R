
# 1. 安装并加载easyUKBhelp
install.packages("easyUKBhelp_1.0.0.zip", repos = NULL, type = "binary")
library(easyUKBhelp)

# 2. 获取机器码 发给作者
easyUKBhelp:::guide_activation()

# 3. 待作者操作授权后
easyUKBhelp:::install_easyUKB(github_token = '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', 
                              server_url = 'http://8.155.15.248:8503')

# 4. 安装成功后尝试加载
library(easyUKB)

# 5. UKB数据准备
# 将下载好的 包括eid列和其他字段的csv文件放入该路径中
set_data_path("XXX/XXX/XXX/UKB_rawdata")
ukb_data_prepare(remove_csv = TRUE,#自己选择是否删除原始 csv 文件
                 chunk_size = 80)  #每多少列变量为一组储存

