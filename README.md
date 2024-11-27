##**Traffic Signal Optimization Simulation**

This project simulates and optimizes traffic light durations at a 4-lane intersection using MATLAB. The goal is to manage vehicle queues and minimize congestion dynamically.

**Features**
- Dynamically allocated green light durations based on traffic conditions.
- Prioritization of congested lanes using a queue threshold that essentially keeps a cap on the queue length.
- Visualization of real-time traffic queues and average queue size trends.

**Simulation Details**
- Number of Lanes: 4
- Traffic Arrival Rates: Randomized using Poisson distribution.
- Green Light Optimization: Adjusted dynamically with priority for congested lanes.

**Output**
1. Real-time queue sizes for each lane.
2. Average queue size trends over time.
3. Final statistics on total vehicles processed.


**How to Run**
1. Clone the Repository:
   Use the following command to clone the repository to your local machine:

   **git clone https://github.com/<your-username>/traffic-simulation.git**
   
2. Navigate to the Project Directory:
   Change into the project directory ->
   
   **cd traffic-simulation**
   
3. Open the simulation.m file in MATLAB.
  Run the file by pressing the Run button or typing ->

  **run('simulation.m')**

