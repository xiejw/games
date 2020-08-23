mod board_view;
mod game;

use cursive::views::{Button, Dialog, LinearLayout, Panel, SelectView};
use cursive::Cursive;
use cursive::Vec2;

use board_view::BoardView;

static G_TITLE: &str = "Gomoku";

fn main() {
    let mut siv = cursive::default();

    siv.add_layer(
        Dialog::new()
            .title(G_TITLE)
            .padding_lrtb(2, 2, 1, 1)
            .content(
                LinearLayout::vertical()
                    .child(Button::new_raw("  New game   ", show_options))
                    .child(Button::new_raw("    Exit     ", |s| s.quit())),
            ),
    );

    siv.run();
}

fn show_options(siv: &mut Cursive) {
    new_game(
        siv,
        game::Options {
            size: Vec2::new(15, 15),
            mines: 10,
        },
    )
}

fn new_game(siv: &mut Cursive, options: game::Options) {
    siv.add_layer(
        Dialog::new()
            .title(G_TITLE)
            .content(LinearLayout::horizontal().child(Panel::new(BoardView::new(options))))
            .button("Quit game", |s| {
                s.pop_layer();
            }),
    );
}
