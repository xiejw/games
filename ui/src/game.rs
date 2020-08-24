use cursive::Vec2;

#[derive(Clone, Copy)]
pub struct Options {
    pub size: Vec2,
}

#[derive(Clone, Copy)]
pub enum Cell {
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
}
