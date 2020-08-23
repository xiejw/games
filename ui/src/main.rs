mod board_view;
mod game;

use cursive::views::{Dialog, LinearLayout, Panel};
use cursive::Cursive;
use cursive::Vec2;

use board_view::BoardView;

static G_TITLE: &str = "Gomoku";

fn main() {
    let mut siv = cursive::default();

    new_game(
        &mut siv,
        game::Options {
            size: Vec2::new(15, 15),
            mines: 10,
        },
    );

    siv.run();
}

fn show_options(siv: &mut Cursive) {}

fn new_game(siv: &mut Cursive, options: game::Options) {
    siv.add_layer(
        Dialog::new()
            .title(G_TITLE)
            .content(LinearLayout::horizontal().child(Panel::new(BoardView::new(options))))
            .button("Quit game", |s| {
                s.quit();
            }),
    );
}
