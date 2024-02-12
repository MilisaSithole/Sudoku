import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Comparator;

int dim = 4;
float w;
int[][] board;
int[][] lockedBoard;
int[] selectedCell = {-1, -1};
String inp = "";

Comparator<int[]> entropyComparator = (a, b) -> a[0] - b[0];

void setup() {
    size(800, 800);
    background(51);

    textAlign(CENTER, CENTER);
    float textSize = map(dim, 4, 25, 50, 10);
    textSize(textSize);
    board = new int[dim][dim];
    lockedBoard = new int[dim][dim];
            
    w = width / (float)dim;
}

void draw() {
    drawBoard();
    drawGrid(color(25));
}

void drawGrid(color col){
    float sw = 10;
    stroke(col);
    for(int r = 0; r < dim+1; r++){
        strokeWeight(5);
        if(r % sqrt(dim) == 0)
            strokeWeight(sw);
        line(0, r * w, width, r * w);
    }
    for(int c = 0; c < dim+1; c++){
        strokeWeight(5);
        if(c % sqrt(dim) == 0)
            strokeWeight(sw);
        line(c * w, 0, c * w, height);
    }
}

void drawBoard(){
    background(51);
    if(selectedCell[0] != -1){
        fill(102);
        rect(selectedCell[1] * w, selectedCell[0] * w, w, w);
    }
    fill(255);
    for(int r = 0; r < dim; r++)
        for(int c = 0; c < dim; c++){
            if(lockedBoard[r][c] != 0){
                fill(0);
                rect(c * w, r * w, w, w);
                fill(255);
            }
            if(board[r][c] != 0)
                text(board[r][c], c * w + w/2, r * w + w/2);
        }
}

void lockBoard(){
    for(int r = 0; r < dim; r++)
        for(int c = 0; c < dim; c++)
            lockedBoard[r][c] = board[r][c];
}

void unlockBoard(){
    lockedBoard = new int[dim][dim];
}

void mousePressed() {
    //Entering num to cell
    if(mouseButton == LEFT){
        inp = "";
        int r = floor(mouseY / (height/dim));
        int c = floor(mouseX / (width/dim));

        //Check cell isn't locked
        if(lockedBoard[r][c] == 0){
            selectedCell[0] = r;
            selectedCell[1] = c;
        }
    }
}

void keyReleased() {
    //Entering num to cell
    if(selectedCell[0] != -1){
        if(key != ENTER && key >= '0' && key <= '9' || key == BACKSPACE){
            if(key == BACKSPACE && inp.length() > 0)
                inp = inp.substring(0, inp.length()-1);
            else
                inp += key;
            
            board[selectedCell[0]][selectedCell[1]] = int(inp);            
        }
        else {
            inp = "";
            selectedCell[0] = -1;
            selectedCell[1] = -1;
        }  
    }

    //Resetting board
    if(key == 'r'){
        board = new int[dim][dim];
        unlockBoard();
    }

    //Locking board
    if(key == 'l')
        lockBoard();

    //Unlocking board
    if(key == 'u')
        unlockBoard();

    //Validate board
    if(key == 'v')
        if(validateBoard())
            drawGrid(color(0, 255, 64));

    //Debugging
    if(key == 'd'){
        solve();
    }
}

boolean validateBoard(){
    //Rows
    for(int r = 0; r < dim; r++)
        if(!validateRow(r))
            return false;

    //Cols
    for(int c = 0; c < dim; c++)
        if(!validateCol(c))
            return false;

    //Squares
    int d = floor(sqrt(dim));
    for(int r = 0; r < dim; r += d)
        for(int c = 0; c < dim; c += d)
            if(!validateSquare(r, c))
                return false;

    return true;
}

boolean validateRow(int r){
    boolean[] usedNums = new boolean[dim];

    for(int c = 0; c < dim; c++)
        if(board[r][c] != 0)
            usedNums[board[r][c] - 1] = true;

    for(boolean rowBit: usedNums)
        if(!rowBit)
            return false;

    return true;
}

boolean validateCol(int c){
    boolean[] usedNums = new boolean[dim];

    for(int r = 0; r < dim; r++)
        if(board[r][c] != 0)
            usedNums[board[r][c] - 1] = true;

    for(boolean colBit: usedNums)
        if(!colBit)
            return false;

    return true;
}

boolean validateSquare(int r, int c){
    int d = floor(sqrt(dim));
    r /= d;
    c /= d;

    boolean[] usedNums = new boolean[dim];
    for(int sr = r * d; sr < (r + 1) * d; sr++)
        for(int sc = c * d; sc < (c + 1) * d; sc++)
            if(board[sr][sc] != 0)
                usedNums[board[sr][sc] - 1] = true;

    for(boolean sqrBit: usedNums)
        if(!sqrBit)
            return false;

    return true;
}

boolean[] freeNumsRow(int r){
    boolean[] freeNums = new boolean[dim];
    for(int i = 0; i < dim; i++)
        freeNums[i] = true;

    for(int c = 0; c < dim; c++) 
        if(board[r][c] != 0)
            freeNums[board[r][c] - 1] = false;

    return freeNums;
}

boolean[] freeNumsCol(int c){
    boolean[] freeNums = new boolean[dim];
    for(int i = 0; i < dim; i++)
        freeNums[i] = true;

    for(int r = 0; r < dim; r++)
        if(board[r][c] != 0)
            freeNums[board[r][c] - 1] = false;

    return freeNums;
}

boolean[] freeNumsSqr(int r, int c){
    boolean[] freeNums = new boolean[dim];
    for(int i = 0; i < dim; i++)
        freeNums[i] = true;

    int d = floor(sqrt(dim)); //<>//
    r /= d;
    c /= d;

    for(int sr = r * d; sr < (r + 1) * d; sr++)
        for(int sc = c * d; sc < (c + 1) * d; sc++)
            if(board[sr][sc] != 0)
                freeNums[board[sr][sc] - 1] = false;

    return freeNums;
}

boolean[] getCellFreeNums(int r, int c){ 
    boolean[] rowNums, colNums, sqrNums;
    rowNums = freeNumsRow(r);
    colNums = freeNumsCol(c);
    sqrNums = freeNumsSqr(r, c);

    boolean[] freeNums = new boolean[dim];
    for(int i = 0; i < dim; i++)
        freeNums[i] = rowNums[i] & colNums[i] & sqrNums[i];

    return freeNums;
}

int[][] calcBoardEntropy(){
    int[][] boardEntropy = new int[dim][dim];
    boolean[] freeNums;

    for(int r = 0; r < dim; r++){
        for(int c = 0; c < dim; c++){ //<>//
            freeNums = new boolean[dim];
            if(board[r][c] == 0 && lockedBoard[r][c] == 0)
                freeNums = getCellFreeNums(r, c);

                int cellEntropy = 0;
                for(boolean num: freeNums)
                    if(num)
                        cellEntropy++;
                
                boardEntropy[r][c] = cellEntropy;
        }
    }

    return boardEntropy;
}

void solve(){
    int[][] boardEntropy;
    boardEntropy = calcBoardEntropy();

    PriorityQueue<int[]> entropyPQ = new PriorityQueue<>(entropyComparator);

    for(int r = 0; r < dim; r++){
        for(int c = 0; c < dim; c++){
            if(lockedBoard[r][c] != 0 || boardEntropy[r][c] == 0)
                continue;

            int[] ePos = new int[3]; //Entropy Position [E, R, C]
            ePos[0] = boardEntropy[r][c];
            ePos[1] = r;
            ePos[2] = c;

            println("Entropy: " + Arrays.toString(ePos));

            entropyPQ.add(ePos);
        }
    }
}
