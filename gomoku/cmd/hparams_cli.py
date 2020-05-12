import hparams

print(hparams)

pd = {'training_total_loops': 10}
hparams.set_hparams(pd)
new_pd = hparams.get_hparams()

print(type(new_pd['training_total_loops']))

