#coding = utf-8
#owner：IFpop

import random


A_row = 200  # 表示需要生成的矩阵行数
A_col = 200
B_row = 200
B_col = 200
with open('dataA.txt','w') as f1:
    with open('dataB.txt','w') as f2:
        with open('data.txt','w') as f:
            # 写入A矩阵
            f.write(str(A_row)+" "+str(A_col))
            f.write('\n')
            for i in range(A_row):
                for j in range(A_col):
                    temp = random.randint(-100,100)
                    f.write(str(temp))
                    f.write(' ')
                    f1.write(str(temp))
                    f1.write(' ')
                f.write('\n')
                f1.write('\n')
            # 写入B矩阵
            f.write(str(B_row)+" "+str(B_col))
            f.write('\n')
            for i in range(B_row):
                for j in range(B_col):
                    temp = random.randint(-100,100)
                    f.write(str(temp))
                    f.write(' ')
                    f2.write(str(temp))
                    f2.write(' ')
                f.write('\n')
                f2.write('\n')
