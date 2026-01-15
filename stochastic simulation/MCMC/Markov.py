import statistics
import matplotlib.pyplot as plt
import numpy as np
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


p_a = np.array(results)
plt.plot(k, p_a, 'bo')
#plt.axis((0, 30, 0, 1))
plt.xlabel('k, number of balls')
plt.ylabel('1/p')
plt.title('1/p vs. k')
plt.show()

# Power regression
# Returns the best guess for a, b assuming y = b * x^a.
# Set plot=False if you don't want to draw the plot.
def powregression(x, y, plot=True):
    log_x = np.log(x)
    log_y = np.log(y)
    a, b = np.polyfit(log_x,log_y,1)

    if plot:
        line = [a*x0 + b for x0 in log_x]
        plt.scatter(log_x,log_y)
        plt.plot(log_x,line)
        plt.title("Power regression")
        plt.show()

    return a, np.exp(b)

m=9
k_sample = np.array(k_sample)
k_sample = 2 + k_sample
a, exp_b = powregression(k_sample[:m], results[:m])
print(a)
print(exp_b)
