import copy
import tkinter as tk

class Board(object):

    def __init__(self, size, root):
        self._frame = self._init_frame(size, root)
        self._bg_colors = self._init_bg_colors(size)
        self._colors = copy.deepcopy(self._bg_colors)
        self._widgets = self._init_widgets(size, self._frame)
        self._history = []
        self._size = size

    def _init_frame(self, size, root):
        frame = tk.Frame(root)
        root.columnconfigure(0, weight=1)
        root.rowconfigure(0, weight=1)
        frame.grid(row=0, column=0, sticky=tk.N+tk.S+tk.W+tk.E)

        for i in range(size):
            frame.columnconfigure(i, pad=3, weight=1)
            frame.rowconfigure(i, pad=3, weight=1)
        return frame

    def _init_bg_colors(self, size):
        def color_fn(i, j):
            return 'lightyellow2' if (i + j) % 2 == 0 else 'light grey'
        return [[color_fn(i, j) for j in range(size) ] for i in range(size)]

    def _init_widgets(self, size, frame):
        widgets = [[None for _ in range(size)] for _ in range(size)]
        for i in range(size):
            for j in range(size):
                bg_color = self._bg_colors[i][j]
                L = tk.Label(frame, text='    ', bg=bg_color)
                L.grid(row=i, column=j, sticky=tk.N+tk.S+tk.W+tk.E)

                L.bind('<Button-1>',lambda e,i=i,j=j: self.on_click(i,j,e))
                L.bind('<Key>', self.on_key)
                widgets[i][j] = L
        return widgets

    def on_click(self, i, j, event):
        del event
        self._flip_one_spot(i, j)
        self._history.append((i,j))

    def _flip_one_spot(self, i, j):
        pairs = [(i,j), (i-1,j), (i+1,j), (i,j-1), (i,j+1)]

        size = self._size
        for p in pairs:
            x, y = p
            if x < 0 or x >= size or y < 0 or y>= size:
                continue

            c = self._colors[x][y]
            c = self._bg_colors[x][y] if c == 'black' else 'black'
            self._colors[x][y] = c

            self._widgets[x][y].config(bg=c)
            self._widgets[x][y].focus_set()  # to recv key

    # Label must get focus_set()
    def on_key(self, e):
        if e.char != ' ':
            return
        if not self._history:
            return

        i, j = self._history[-1]
        self._flip_one_spot(i, j)
        self._history.pop(-1)

root = tk.Tk()
root.geometry("400x400")
Board(size=8, root=root)
print('Press `space` to revert one step.')
root.mainloop()
