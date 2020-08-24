use cursive::Vec2;

#[derive(Clone, Copy)]
pub struct Options {
    pub size: Vec2,
}

#[derive(Clone, Copy)]
pub enum Color {
    White,
    Black,
}

pub struct Board {
    pub size: Vec2,
    pub stones: Vec<Option<Color>>,

    next_color: Color,
}

#[derive(Debug)]
pub enum Error {
    Occupied,
}

impl Board {
    pub fn new(options: Options) -> Self {
        let n_cells = options.size.x * options.size.y;
        Board {
            size: options.size,
            stones: vec![None; n_cells],
            next_color: Color::Black,
        }
    }

    pub fn place(&mut self, pos: &Vec2) -> Result<Color, Error> {
        let id = pos.x + pos.y * self.size.x;

        match self.next_color {
            Color::Black => {
                self.stones[id] = Some(Color::Black);
                self.next_color = Color::White;
                return Ok(Color::Black);
            }
            Color::White => {
                self.stones[id] = Some(Color::White);
                self.next_color = Color::Black;
                return Ok(Color::White);
            }
        };
    }
}
