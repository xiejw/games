import math
import collections

# Function to calculate the prob_winning.
def prob_winning(rating1, rating2):
    return 1.0 * 1.0 / (1 + 1.0 * math.pow(10, 1.0 * (rating1 - rating2) / 400))


# Function to calculate Elo rating after updating.
#
# - K is a constant.
# - d determines whether Player A wins or Player B.
#     1.0 means A wins.
#     0.5 means tie.
#     0.0 means B wins.
def update_elo_rating(Ra, Rb, K, d):
    Pa = prob_winning(Rb, Ra)
    Pb = prob_winning(Ra, Rb)

    Ra = Ra + K * (d - Pa)
    Rb = Rb + K * ((1 - d) - Pb)
    return Ra, Rb

K = 30

# For key i, it is the result the Iter i against Iter (i-1).
RESULTS = collections.OrderedDict()
RESULTS[ 1] = {'win': 29, 'lost':  8, 'tie':  3}
RESULTS[ 2] = {'win': 24, 'lost': 15, 'tie':  1}
RESULTS[ 3] = {'win': 28, 'lost': 10, 'tie':  2}
RESULTS[ 4] = {'win': 29, 'lost':  8, 'tie':  3}

assert len(RESULTS) == 4

elo_r = collections.OrderedDict()
elo_r[0] = 1000.  # Anchored.

for (k, v) in RESULTS.items():
    assert k >= 1
    assert k not in elo_r

    # Anchor elo_r[k] to elo_r[k-1] first
    elo_r[k] = elo_r[k - 1]

    result = RESULTS[k]

    # The algorithrm is simple and partially deterministic.
    # We go over the loop, and in each iteration, one win, lost and tie are
    # updated in the deterministic order. If the wins have reach the cap,
    # specified by the `RESULTS`, it is skipped. Same applies to lost and tie.
    win = 0
    lost = 0
    tie = 0

    while True:
        changed = False

        # We do not update elo rating for k-1.
        if win < result['win']:
            changed = True
            win += 1
            elo_r[k], _ = update_elo_rating(elo_r[k], elo_r[k-1], K, 1.0)

        if lost < result['lost']:
            changed = True
            lost += 1
            elo_r[k], _ = update_elo_rating(elo_r[k], elo_r[k-1], K, 0.0)

        if tie < result['tie']:
            changed = True
            tie += 1
            elo_r[k], _ = update_elo_rating(elo_r[k], elo_r[k-1], K, 0.5)

        if not changed:
            break

    if k == 1:
      print("Elo rating for model {}: {:.2f} (anchored)".format(0, elo_r[0]))

    print("Elo rating for model {}: {:.2f}".format(k, elo_r[k]))


def plot_elo_ratings(elo_r):
    import numpy as np
    try:
        import PyGnuplot as gp
    except:
        print("Skip plotting the graph as PyGnuplot is not installed.")
        return
    import tempfile
    assert isinstance(elo_r, collections.OrderedDict)

    X = np.arange(len(elo_r))
    Y = np.array([r for r in elo_r.values()])

    with tempfile.NamedTemporaryFile() as fp:
        gp.s([X,Y], filename=fp.name)
        gp.c('plot "{}" u 1:2 notitle w lp'.format(fp.name))
        input('press any key to continue')

plot_elo_ratings(elo_r)
