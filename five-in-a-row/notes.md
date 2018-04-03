# 2018-04-03

I think the issue is the State is not remembered correctly. It remebers the path
not the board state.

However, after impoving the hash funciton of State, the result is still bad. It
is not random and puts the stones to corners anymore. But the AI level is low.
See `result/2018-04-03_2.md`.

# 2018-04-03

Things to try:
1. Use stats rather than randomness
2. Remember stats over runs

Pure random. Start the game from empy stats table each run.

    let numberToWin = 5
    let size = 15
    let maxMoves = 30
    let calculationTime = 60.0

The result is particully bad. 

    try board.newMove(Move(x:8, y:8))
    try board.newMove(Move(x:7, y:9))

    Played 9063 games with search depth 30.
    BlackWins: 7 -- 0.00077237117952113
    WhiteWins: 3 -- 0.00033101621979477
    bestMove Move(x: 13, y: 6)
    All results:
     -> 0.03125: Move(x: 13, y: 6)
     -> 0.0277777777777778: Move(x: 5, y: 7)
     -> 0.0263157894736842: Move(x: 11, y: 7)
     -> 0.024390243902439: Move(x: 13, y: 8)

According to the summary, the simulation cannot finish the game.

Try 

    let numberToWin = 5
    let size = 15
    let maxMoves = 100
    let calculationTime = 90.0

Get 

    try board.newMove(Move(x:8, y:8))
    try board.newMove(Move(x:7, y:9))
    try board.newMove(Move(x:8, y:9))   <- 0.58 
    try board.newMove(Move(x:8, y:10))
    
output 

    End simulation at 90.005686044693
    Played 3272 games with search depth 100.
    BlackWins: 698 -- 0.213325183374083
    WhiteWins: 714 -- 0.218215158924205
    bestMove Move(x: 1, y: 13)
    All results:
     -> 0.470588235294118: Move(x: 1, y: 13)
     -> 0.466666666666667: Move(x: 3, y: 3)

This is bad as it does not make sense. I think I will try to use stats table,
instead of pure randomness to run simulation
