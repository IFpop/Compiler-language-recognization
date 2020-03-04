#coding = utf-8
#owner: IFpop

from time import *

'''
# 设置文件数据格式为  n1 n2  行数 列数
#                   .....  n1行数据
# 共两个矩阵
# 返回值为： 矩阵，矩阵行列list
'''
def read_matrix(f):
    temp = []
    num =  [int(x) for x in (f.readline()).split(' ')]
    # print("矩阵n×n行数:")
    # print(num)
    # 按行读取
    for i in range(num[0]):
        temp_list = [int(x) for x in (f.readline()).split(' ')[:-1]]
        # print(temp_list)
        temp.append(temp_list)
    return temp,num

def Comput(A,A_num,B,B_num):
    Ans = [[0 for j in range(B_num[1])] for i in range(A_num[0])]
    for i in range(A_num[0]):
        for j in range(B_num[1]):
            for time in range(A_num[1]): # 前一个矩阵的列与后一个矩阵的行是相等的
                Ans[i][j] += A[i][time]*B[time][j]
    return Ans

get_now_milli_time = lambda: int(time() * 1000)

if __name__ == '__main__':
    print("Matrix multiplication implemented by Python.")
    with open('data.txt','r') as f:
        # 读取A矩阵
        A,A_num = read_matrix(f)
        # 读取B矩阵
        B,B_num = read_matrix(f)
        f.close()
    if(A_num[1] == B_num[0]):
        begin_time = get_now_milli_time()
        ans = Comput(A,A_num,B,B_num)
        end_time = get_now_milli_time()
        run_time = end_time-begin_time
        # 将ans写入文件
        with open('result.txt','w') as f:
            f.write(str(A_num[0])+" "+str(B_num[1])+"\n")
            for i in range(A_num[0]):
                for j in range(B_num[1]):
                    f.write(str(ans[i][j])+" ")
                f.write('\n')
        print(f'Matrix {A_num[0]} × {A_num[1]} and {B_num[0]} × {B_num[1]} cost time: {run_time} ms.\n')
    else:
        print("Row and column mismatch")
    