import java.util.Arrays;
import java.util.ArrayList;
import java.util.PriorityQueue;
import java.util.BitSet;
import java.util.Comparator;

int dim = 9;
float w;
int[][] board;
int[][] lockedBoard;
int[] selectedCell = {-1, -1};
int[] lastUpdatedCell = {-1, -1};
String inp = "";
ArrayList<int[]> steps = new ArrayList<int[]>();

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
    if(steps.isEmpty()){
        drawBoard();
        drawGrid(color(25));
        return;
    }

    if(frameCount % 30 != 0)
        return;

    if(!steps.isEmpty()){
        int[] currStep = steps.remove(0);
        board[currStep[1]][currStep[2]] = currStep[0];
        lastUpdatedCell[0] = currStep[1];
        lastUpdatedCell[1] = currStep[2];

        drawBoard();
        drawGrid(color(25));
    }
}

void drawGrid(color col){
    float sw = 5;
    stroke(col);
    for(int r = 0; r < dim+1; r++){
        strokeWeight(sw);
        if(r % sqrt(dim) == 0)
            strokeWeight(sw * 2);
        line(0, r * w, width, r * w);
    }
    for(int c = 0; c < dim+1; c++){
        strokeWeight(sw);
        if(c % sqrt(dim) == 0)
            strokeWeight(sw * 2);
        line(c * w, 0, c * w, height);
    }

    strokeWeight(sw);
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
                fill(31);
                rect(c * w, r * w, w, w);
                fill(255);
            }
            if(lastUpdatedCell[0]!= -1){
                fill(102);
                rect(lastUpdatedCell[1] * w, lastUpdatedCell[0] * w, w, w);
                fill(255);
            }
            if(board[r][c] != 0)
                text(board[r][c], c * w + w/2, r * w + w/2);
        }
}

void resetBoard(){
    for(int r = 0; r < dim; r++)
        for(int c = 0; c < dim; c++)
            if(lockedBoard[r][c] == 0)
                board[r][c] = 0;
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

    if(mouseButton == RIGHT)
        stepSolve();
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

    //New board
    if(key == 'n'){
        board = new int[dim][dim];
        unlockBoard();
        lastUpdatedCell = new int[]{-1, -1};
    }

    //Reset board
    if(key == 'r'){
        resetBoard();
        lastUpdatedCell = new int[]{-1, -1};
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
        steps = new ArrayList<int[]>();
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

BitSet freeNumsRow(int r){
    BitSet freeNums = new BitSet(dim);

    for(int c = 0; c < dim; c++)
        if(board[r][c] != 0)
            freeNums.set(board[r][c] - 1);
            
    freeNums.flip(0, dim);

    return freeNums;
}

BitSet freeNumsCol(int c){
    BitSet freeNums = new BitSet(dim);

    for(int r = 0; r < dim; r++)
        if(board[r][c] != 0)
            freeNums.set(board[r][c] - 1);
            
    freeNums.flip(0, dim);

    return freeNums;
}

BitSet freeNumsSqr(int r, int c){
    BitSet freeNums = new BitSet(dim); //<>//
    int d = floor(sqrt(dim));
    r /= d;
    c /= d;

    for(int sr = r * d; sr < (r + 1) * d; sr++)
        for(int sc = c * d; sc < (c + 1) * d; sc++)
            if(board[sr][sc] != 0)
                freeNums.set(board[sr][sc] - 1);
            
    freeNums.flip(0, dim);

    return freeNums;
}

BitSet getCellFreeNums(int r, int c){
    BitSet freeNums = freeNumsRow(r);
    freeNums.and(freeNumsCol(c));
    freeNums.and(freeNumsSqr(r, c));

    println("[" + r + " " + c + "] Free nums: " + freeNums.toString());

    return freeNums;
}

int[][] calcBoardEntropy(){
    int[][] boardEntropy = new int[dim][dim]; 
    BitSet freeNums; 

    for(int r = 0; r < dim; r++){
        for(int c = 0; c < dim; c++){ 
            freeNums = new BitSet(dim);
            if(board[r][c] == 0 && lockedBoard[r][c] == 0)
                freeNums = getCellFreeNums(r, c);

                int cellEntropy = 0;
                for(int i = 0; i < dim; i++)
                    if(freeNums.get(i))
                        cellEntropy++;
                
                boardEntropy[r][c] = cellEntropy;
        }
    }

    return boardEntropy;
}

void printEntropy(int[][] boardEntropy){
    for(int r = 0; r < dim; r++){
        for(int c = 0; c < dim; c++)
            print(boardEntropy[r][c] + " ");
        println();
    }
}

boolean solve(){
    int[][] boardEntropy;
    boardEntropy = calcBoardEntropy();
    printEntropy(boardEntropy);
    println("-------");

    PriorityQueue<int[]> entropyPQ = new PriorityQueue<>(entropyComparator);
    for(int r = 0; r < dim; r++){
        for(int c = 0; c < dim; c++){
            if(board[r][c] == 0){
                int[] entropyPos = new int[3];
                entropyPos[0] = boardEntropy[r][c];
                entropyPos[1] = r;
                entropyPos[2] = c;

                entropyPQ.add(entropyPos);
            }
        }
    }

    if(entropyPQ.isEmpty())
        return true;

    int[] currEntropyPos = entropyPQ.poll();
    BitSet availNums = getCellFreeNums(currEntropyPos[1], currEntropyPos[2]);

    for(int i = 0; i < dim; i++){
        if(availNums.get(i)){
            board[currEntropyPos[1]][currEntropyPos[2]] = i + 1;

            int[] stepArr = new int[3];
            stepArr[0] = i + 1;
            stepArr[1] = currEntropyPos[1];
            stepArr[2] = currEntropyPos[2];
            steps.add(stepArr);
            
            if(solve())
                return true;
        }
    }

    board[currEntropyPos[1]][currEntropyPos[2]] = 0;
    return false;
}

void stepSolve(){
    int[][] boardEntropy;
    boardEntropy = calcBoardEntropy();
    printEntropy(boardEntropy);
    println("-------");

    PriorityQueue<int[]> entropyPQ = new PriorityQueue<>(entropyComparator);
    for(int r = 0; r < dim; r++){
        for(int c = 0; c < dim; c++){
            if(board[r][c] == 0){
                int[] entropyPos = new int[3];
                entropyPos[0] = boardEntropy[r][c];
                entropyPos[1] = r;
                entropyPos[2] = c;

                entropyPQ.add(entropyPos);
            }
        }
    }

    if(entropyPQ.isEmpty())
        return;

    int[] currEntropyPos = entropyPQ.poll();
    BitSet availNums = getCellFreeNums(currEntropyPos[1], currEntropyPos[2]);

    for(int i = 0; i < dim; i++){
        if(availNums.get(i)){
            board[currEntropyPos[1]][currEntropyPos[2]] = i + 1;
            drawBoard();
            break;
        }
    }
}