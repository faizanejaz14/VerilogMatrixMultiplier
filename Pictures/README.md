These are the images we took as proof of our Matrix Multiplier working.

3x3 Inconsistent image shows that our output had one bug where when we were writing to Matrixs A and B, the first element of both Matrix was always 0. This was due to the multiple read/write ports we had taken out of memory to implement the parallel architecture. This was fixed by increasing memory to provide a garbage location to write data on.

The 3x3 Matrix are all computed in parallel, whereas the 10x10 are done serially.
