use super::game;

use cursive::direction::Direction;
use cursive::event::{Event, EventResult, Key, MouseButton, MouseEvent};
use cursive::theme::{BaseColor, Color, ColorStyle};
// use cursive::views::{Button, Dialog};
use cursive::views::Dialog;
use cursive::Printer;
use cursive::Vec2;

#[derive(Clone, Copy, PartialEq)]
enum Cell {
    Visible(usize),
    Flag,
    Unknown,
}

pub struct BoardView {
    // Actual board, unknown to the player.
    board: game::Board,

    // Visible board
    overlay: Vec<Cell>,

    focused: Option<Vec2>,
    selected: Option<Vec2>,
}

impl BoardView {
    pub fn new(options: game::Options) -> Self {
        let overlay = vec![Cell::Unknown; options.size.x * options.size.y];
        let board = game::Board::new(options);
        BoardView {
            board,
            overlay,
            focused: None,
            selected: None,
        }
    }

    fn get_cell(&self, mouse_pos: Vec2, offset: Vec2) -> Option<Vec2> {
        mouse_pos
            .checked_sub(offset)
            .map(|pos| pos.map_x(|x| x / 2))
            .and_then(|pos| {
                if pos.fits_in(self.board.size) {
                    Some(pos)
                } else {
                    None
                }
            })
    }
}

impl cursive::view::View for BoardView {
    fn draw(&self, printer: &Printer) {
        for (i, cell) in self.overlay.iter().enumerate() {
            let x = (i % self.board.size.x) * 2;
            let y = i / self.board.size.x;

            let text = match *cell {
                Cell::Unknown => "  ",
                Cell::Flag => "()",
                Cell::Visible(n) => ["  ", " 1", " 2", " 3", " 4", " 5", " 6", " 7", " 8"][n],
            };

            let mut color = match *cell {
                Cell::Unknown => Color::RgbLowRes(3, 3, 3),
                Cell::Flag => Color::RgbLowRes(4, 4, 2),
                Cell::Visible(1) => Color::RgbLowRes(3, 5, 3),
                Cell::Visible(2) => Color::RgbLowRes(5, 5, 3),
                Cell::Visible(3) => Color::RgbLowRes(5, 4, 3),
                Cell::Visible(4) => Color::RgbLowRes(5, 3, 3),
                Cell::Visible(5) => Color::RgbLowRes(5, 2, 2),
                Cell::Visible(6) => Color::RgbLowRes(5, 0, 1),
                Cell::Visible(7) => Color::RgbLowRes(5, 0, 2),
                Cell::Visible(8) => Color::RgbLowRes(5, 0, 3),
                _ => Color::Dark(BaseColor::White),
            };

            let default_bg = Color::Dark(BaseColor::Black);
            match &self.selected {
                Some(vec2) => {
                    if x / 2 == vec2.x && y == vec2.y {
                        color = Color::Dark(BaseColor::Red);
                    }
                }
                None => {}
            };

            printer.with_color(ColorStyle::new(default_bg, color), |printer| {
                printer.print((x, y), text)
            });
        }
    }

    fn take_focus(&mut self, _: Direction) -> bool {
        true
    }

    fn on_event(&mut self, event: Event) -> EventResult {
        match event {
            Event::Key(v) => {
                if v != Key::Tab {
                    let mut current_pos = self.selected.unwrap_or(Vec2::new(7, 7));
                    match v {
                        Key::Down => current_pos.y += 1,
                        Key::Up => current_pos.y -= 1,
                        Key::Right => current_pos.x += 1,
                        Key::Left => current_pos.x -= 1,
                        _ => {}
                    };
                    self.selected = Some(current_pos);

                    return EventResult::Consumed(None);
                }
            }
            Event::Mouse {
                offset,
                position,
                event: MouseEvent::Press(_btn),
            } => {
                // Get cell for position
                if let Some(pos) = self.get_cell(position, offset) {
                    self.focused = Some(pos);
                    return EventResult::Consumed(None);
                }
            }
            Event::Mouse {
                offset,
                position,
                event: MouseEvent::Release(btn),
            } => {
                // Get cell for position
                if let Some(pos) = self.get_cell(position, offset) {
                    // if self.focused == Some(pos) {
                    //     // We got a click here!
                    //     match btn {
                    //         MouseButton::Left => return self.reveal(pos),
                    //         MouseButton::Right => {
                    //             self.flag(pos);
                    //             return EventResult::Consumed(None);
                    //         }
                    //         MouseButton::Middle => {
                    //             return self.auto_reveal(pos);
                    //         }
                    //         _ => (),
                    //     }
                    // }

                    self.focused = None;
                }
            }
            _ => (),
        }

        EventResult::Ignored
    }

    fn required_size(&mut self, _: Vec2) -> Vec2 {
        self.board.size.map_x(|x| 2 * x)
    }
}
