import java.io.BufferedReader;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;

public class matrix{    
    // 定义矩阵类的变量
    int row;
    int col;
    int[][] value;

    public static void main(String[] args) throws IOException {
        System.out.printf("Matrix multiplication implemented by Java.\n");
        FileReader fr = new FileReader("data.txt");
        BufferedReader bf = new BufferedReader(fr);
        matrix A = new matrix(bf);
        matrix B = new matrix(bf);
        if (A.col != B.row) {
            System.out.print("Input Error");
            return;
        }
        // PrintArr(A.value);
        // PrintArr(B.value);
        long t = System.currentTimeMillis();
        matrix ans = A.Comput(B);
        t = System.currentTimeMillis() - t;
        System.out.printf("Matrix %d×%d and %d×%d cost %d ms.\n",A.row,A.col,B.row,B.col,t);
        // PrintArr(ans.value);
        write2file(ans);
        fr.close();
        bf.close();
    }
    // 读取矩阵
    public matrix(BufferedReader bf) throws IOException {
        // 按行读取
        String str;
        // 读取行列
        str = bf.readLine();
        String[] temp = str.split(" ");
        row = Integer.parseInt(temp[0]);
        col = Integer.parseInt(temp[1]);
        value = new int[row][col];
        for (int i = 0; i < row; i++) {
            str = bf.readLine();
            temp = str.split(" ");
            for (int j = 0; j < col; j++)
                value[i][j] = Integer.parseInt(temp[j]);
        }
        // PrintArr(value);
    }

    public static void write2file(matrix temp) throws IOException
    {
        FileOutputStream outputStream = new FileOutputStream("result.txt");
        String str;
        str = Integer.toString(temp.row)+" " + Integer.toString(temp.col) + "\n";
        for(int i = 0 ; i < temp.row ; i++)
        {
            for(int j = 0 ; j < temp.col ; j++)
            {
                str += Integer.toString(temp.value[i][j])+" ";
            }
            str += "\n";
        }
        byte[] strToBytes = str.getBytes();
        outputStream.write(strToBytes);
        outputStream.close();
    }

    public static void PrintArr(int[][] temp)
    {
        for(int i = 0 ; i < temp.length; i++)
        {
           for(int j = 0 ; j < temp[i].length ;j++)
           {
               System.out.print(temp[i][j]+" ");
           }
           System.out.print('\n');
        }
    }
    
    public matrix(int row,int col)
    {
        this.row = row;
        this.col = col;
        this.value = new int[row][col];
    }
    // 计算结果
    public matrix Comput(matrix B)
    {
        matrix Ans = new matrix(this.row,B.col);
        for(int i = 0 ; i < this.row ; i++)
        {
            for(int j = 0 ; j < B.col ; j++)
            {
                for(int times = 0 ; times < this.col ; times++)
                    Ans.value[i][j] += this.value[i][times]*B.value[times][j];
            }
        }
        return Ans;
    }
}