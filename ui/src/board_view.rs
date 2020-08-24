use super::game;

use cursive::direction::Direction;
use cursive::event::{Event, EventResult, Key};
use cursive::theme::{BaseColor, Color, ColorStyle};
use cursive::Printer;
use cursive::Vec2;

#[derive(Clone, Copy, PartialEq)]
enum Cell {
    Unknown,
}

pub struct BoardView {
    board: game::Board, // Actual board, unknown to the player.
    overlay: Vec<Cell>, // Visible board
    selected: Vec2,
    focused: bool,
}

impl BoardView {
    const LEFT_MARGIN: usize = 2;
    const TOP_MARGIN: usize = 1;

    pub fn new(options: game::Options) -> Self {
        let overlay = vec![Cell::Unknown; options.size.x * options.size.y];
        let board = game::Board::new(options);
        BoardView {
            board,
            overlay,
            selected: Vec2::new(7, 7),
            focused: false,
        }
    }
}

impl cursive::view::View for BoardView {
    fn required_size(&mut self, _: Vec2) -> Vec2 {
        // For each cell, used 2 pixel to print.
        self.board
            .size
            .map_x(|x| 2 * x + BoardView::LEFT_MARGIN)
            .map_y(|y| y + BoardView::TOP_MARGIN)
    }

    fn draw(&self, printer: &Printer) {
        for (i, cell) in self.overlay.iter().enumerate() {
            let x = (i % self.board.size.x) * 2 + BoardView::LEFT_MARGIN; // Print two chars per cell.
            let y = i / self.board.size.x + BoardView::TOP_MARGIN;

            let text = match *cell {
                Cell::Unknown => "  ",
            };

            let mut color = match *cell {
                Cell::Unknown => Color::RgbLowRes(3, 3, 3),
            };

            let default_bg = Color::Dark(BaseColor::Black);
            if self.focused {
                let vec2 = &self.selected;
                if (x - BoardView::LEFT_MARGIN) / 2 == vec2.x && y - BoardView::TOP_MARGIN == vec2.y
                {
                    color = Color::Dark(BaseColor::Red);
                }
            }

            printer.with_color(ColorStyle::new(default_bg, color), |printer| {
                printer.print((x, y), text)
            });
        }

        // Print row title.
        for y in 0..self.board.size.y {
            let x = 0;
            let text = match y {
                10 => "a ",
                11 => "b ",
                12 => "c ",
                13 => "d ",
                14 => "e ",
                15 => "f ",
                _ => ["0 ", "1 ", "2 ", "3 ", "4 ", "5 ", "6 ", "7 ", "8 ", "9 "][y],
            };
            printer.print((x * 2, y + BoardView::TOP_MARGIN), text);
        }

        // Print column title.
        for x in 0..self.board.size.x {
            let y = 0;
            let text = match x {
                10 => "a ",
                11 => "b ",
                12 => "c ",
                13 => "d ",
                14 => "e ",
                15 => "f ",
                _ => ["0 ", "1 ", "2 ", "3 ", "4 ", "5 ", "6 ", "7 ", "8 ", "9 "][x],
            };
            printer.print((x * 2 + BoardView::LEFT_MARGIN, y), text);
        }
    }

    fn take_focus(&mut self, _: Direction) -> bool {
        self.focused = true;
        true
    }

    fn on_event(&mut self, event: Event) -> EventResult {
        match event {
            Event::Key(v) => {
                if v != Key::Tab {
                    let current_pos = &mut self.selected;
                    match v {
                        Key::Down => current_pos.y += 1,
                        Key::Up => current_pos.y -= 1,
                        Key::Right => current_pos.x += 1,
                        Key::Left => current_pos.x -= 1,
                        _ => {}
                    };

                    return EventResult::Consumed(None);
                } else {
                    self.focused = false;
                }
            }
            _ => (),
        }

        EventResult::Ignored
    }
}
