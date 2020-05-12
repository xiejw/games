import hparams

print(hparams)

pd = {
    'training_total_loops': 10,
    'training_games_per_loop': 600,
    'training_samples_per_game': 50,
}
hparams.set_hparams(pd)
new_pd = hparams.get_hparams()

print((new_pd['training_total_loops']))
print((new_pd['training_games_per_loop']))

