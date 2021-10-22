-- Average cost of taxi trip by number of passengers --
SELECT passenger_count,
       avg(total_amount)
FROM test.trips_dist
GROUP BY passenger_count
ORDER BY passenger_count

-- Average Distance of taxi ride --
SELECT avg(trip_distance)
FROM test.trips_dist
