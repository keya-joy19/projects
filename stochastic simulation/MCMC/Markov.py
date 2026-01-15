import statistics
# Simulates a game until a player has no balls left
# Returns 1 if player 1 lost, 0 otherwise
def simulate2(n, k):
    ball_count = np.ones(n) # 1 ball for each player
    ball_count[0] = k # Player 1 now gets k balls to start
    steps = 0

    while np.all(ball_count > 0):
        i = np.random.randint(n) # 0 to n - 1
        j = np.random.randint(n - 1) # 0 to n - 2
        if j >= i: # shift j to avoid picking i again or never picking nth player
            j += 1

        ball_count[i] -= 1 # player i gives j one ball
        ball_count[j] += 1
        steps += 1

    if (ball_count[0] == 0): # checking if player 1 lost their balls
      return 1

    return 0

# Estimate probability p
n = 4
k_sample = [1, 2, 3, 5, 7, 10, 12, 15, 20, 25, 30]
trials = 200000
p = 0
results = []

for i in k_sample:
  for t in range(trials):
    p += simulate2(n, i)

  p /= trials
  results.append(p)
  p = 0

print("Probability p for various k: ", results)


n = 3
k = 3
trials = 15000
var1 = 0 # Calculated using sample std formula
mean = 0

results = [simulate(n, k) for i in range(trials)]
mean = statistics.mean(results)

for i in range(trials):
  var1 += (results[i]-mean)**2

var1 *= 1/(trials-1)
print("Sample variance calculated manually: ", var1)
var2 = statistics.variance(results)
print("Estimated variance using built-in function: ", var2)
stdev = statistics.stdev(results)
print("Estimated standard deviation: ", stdev)
