import Tkinter as tk

dim = 8

board = [ [None]* dim for _ in range(dim) ]
widgets = [[None]*dim for _ in range(dim) ]
default_colors = [
        [
    'lightyellow2' if (i + j) % 2 == 0 else 'light grey' for j in range(dim)] for i in range(dim)]


root = tk.Tk()
root.geometry("400x400")

history = []

def on_click(i,j,event):
    del event
    pairs = [(i,j), (i-1,j), (i+1,j), (i,j-1), (i,j+1)]

    history.append((i,j))

    for p in pairs:
        x, y = p
        if x < 0 or x >= dim or y < 0 or y>= dim:
            continue


        c = board[x][y]
        default_c = default_colors[x][y]
        c = default_c if c == 'black' else 'black'
        widgets[x][y].config(bg=c)
        widgets[x][y].focus_set()  # to recv key
        board[x][y] = c

frame = tk.Frame(root)
root.columnconfigure(0, weight=1)
root.rowconfigure(0, weight=1)

frame.grid(row=0, column=0, sticky= tk.N + tk.S + tk.W + tk.E)

def key(e):
    if e.char != ' ':
        return
    # Label must get focus_set()
    if not history:
        return

    i, j = history[-1]
    on_click(i,j, None)
    history.pop(-1)
    history.pop(-1)  # twice


frame.bind('<Key>' , key)

for i in range(dim):
    frame.columnconfigure(i, pad=3, weight=1)
    frame.rowconfigure(i, pad=3, weight=1)

for i,row in enumerate(board):
    for j,column in enumerate(row):
        args = {}
        args['sticky'] = tk.N + tk.S + tk.W + tk.E

        L = tk.Label(frame,text='    ',bg='grey')
        L.grid(row=i,column=j, **args)
        L.bind('<Button-1>',lambda e,i=i,j=j: on_click(i,j,e))
        L.bind('<Key>', key)

        c = default_colors[i][j]
        L.config(bg=c)
        widgets[i][j] = L
        board[i][j] =c

root.mainloop()
