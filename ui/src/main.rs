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
    siv.add_layer(
        Dialog::new()
            .title("Select difficulty")
            .content(
                SelectView::new()
                    .item(
                        "Easy:      15x15,   10 mines",
                        game::Options {
                            size: Vec2::new(15, 15),
                            mines: 10,
                        },
                    )
                    .item(
                        "Medium:    16x16, 40 mines",
                        game::Options {
                            size: Vec2::new(16, 16),
                            mines: 40,
                        },
                    )
                    .on_submit(|s, option| {
                        s.pop_layer();
                        new_game(s, *option);
                    }),
            )
            .dismiss_button("Back"),
    );
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

    siv.add_layer(Dialog::info(
        "Controls:
Reveal cell:                  left click
Mark as mine:                 right-click
Reveal nearby unmarked cells: middle-click",
    ));
}
