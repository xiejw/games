use cursive::Vec2;

#[derive(Clone, Copy)]
pub struct Options {
    pub size: Vec2,
}

#[derive(Clone, Copy)]
pub enum Cell {
    Bomb,
    Free(usize),
}

pub struct Board {
    pub size: Vec2,
    pub cells: Vec<Cell>,
}

impl Board {
    pub fn new(options: Options) -> Self {
        let n_cells = options.size.x * options.size.y;
        Board {
            size: options.size,
            cells: vec![Cell::Free(0); n_cells],
        }
    }

    fn get_mut(&mut self, pos: Vec2) -> Option<&mut Cell> {
        self.cell_id(pos).map(move |i| &mut self.cells[i])
    }

    pub fn cell_id(&self, pos: Vec2) -> Option<usize> {
        if pos < self.size {
            Some(pos.x + pos.y * self.size.x)
        } else {
            None
        }
    }

    pub fn neighbours(&self, pos: Vec2) -> Vec<Vec2> {
        let pos_min = pos.saturating_sub((1, 1));
        let pos_max = (pos + (2, 2)).or_min(self.size);
        (pos_min.x..pos_max.x)
            .flat_map(|x| (pos_min.y..pos_max.y).map(move |y| Vec2::new(x, y)))
            .filter(|&p| p != pos)
            .collect()
    }
}
