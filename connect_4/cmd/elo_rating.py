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
RESULTS[ 1] = {'win': 27, 'lost': 11, 'tie':  2}
RESULTS[ 2] = {'win': 38, 'lost':  2, 'tie':  0}
RESULTS[ 3] = {'win': 27, 'lost':  6, 'tie':  7}
RESULTS[ 4] = {'win': 23, 'lost':  7, 'tie': 10}
RESULTS[ 5] = {'win': 30, 'lost':  8, 'tie':  2}
RESULTS[ 6] = {'win': 25, 'lost':  7, 'tie':  8}
RESULTS[ 7] = {'win': 22, 'lost':  4, 'tie': 14}
RESULTS[ 8] = {'win': 12, 'lost':  7, 'tie': 21}
RESULTS[ 9] = {'win': 14, 'lost':  8, 'tie': 18}
RESULTS[10] = {'win': 12, 'lost':  7, 'tie': 21}
RESULTS[11] = {'win':  8, 'lost':  8, 'tie': 24}
RESULTS[12] = {'win': 17, 'lost':  6, 'tie': 17}
RESULTS[13] = {'win': 11, 'lost': 13, 'tie': 16}
RESULTS[14] = {'win': 27, 'lost':  3, 'tie': 10}
RESULTS[15] = {'win': 20, 'lost':  2, 'tie': 18}
RESULTS[16] = {'win': 23, 'lost': 10, 'tie':  7}
RESULTS[17] = {'win': 30, 'lost':  8, 'tie':  2}
RESULTS[18] = {'win': 22, 'lost':  7, 'tie': 11}
RESULTS[19] = {'win': 24, 'lost': 11, 'tie':  5}
RESULTS[20] = {'win': 18, 'lost':  8, 'tie': 14}
RESULTS[21] = {'win': 16, 'lost': 12, 'tie': 12}

assert len(RESULTS) == 21

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
