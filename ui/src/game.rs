use cursive::Vec2;

#[derive(Clone, Copy)]
pub struct Options {
    pub size: Vec2,
}

#[derive(Clone, Copy)]
pub enum Stone {
    White,
    Black,
}

pub struct Board {
    pub size: Vec2,
    pub stones: Vec<Option<Stone>>,
}

pub enum BoardError {
    Occupied,
}

impl Board {
    pub fn new(options: Options) -> Self {
        let n_cells = options.size.x * options.size.y;
        Board {
            size: options.size,
            stones: vec![None; n_cells],
        }
    }

    pub fn place(&mut self, pos: &Vec2) -> Result<Stone, BoardError> {
        Ok(Stone::Black)
    }
}
