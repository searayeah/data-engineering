CREATE TABLE cities (
    city_id INT PRIMARY KEY,
    city_name TEXT NOT NULL
);

CREATE TABLE stations (
    station_id INT PRIMARY KEY,
    station_name TEXT NOT NULL,
    city_id INT NOT NULL,
    FOREIGN KEY (city_id) REFERENCES cities (city_id)
);

CREATE TABLE trains (
    train_id INT PRIMARY KEY,
    train_number TEXT NOT NULL UNIQUE,
    train_type TEXT NOT NULL
);


CREATE TABLE routes (
    route_id INT PRIMARY KEY,
    route_name TEXT NOT NULL,
    departure_station_id INT NOT NULL,
    arrival_station_id INT NOT NULL,
    FOREIGN KEY (departure_station_id) REFERENCES stations (station_id),
    FOREIGN KEY (arrival_station_id) REFERENCES stations (station_id)
);


CREATE TABLE schedules (
    schedule_id INT PRIMARY KEY,
    train_id INT NOT NULL,
    route_id INT NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    FOREIGN KEY (train_id) REFERENCES trains (train_id),
    FOREIGN KEY (route_id) REFERENCES routes (route_id)
);


CREATE TABLE route_stations (
    route_id INT NOT NULL,
    station_id INT NOT NULL,
    stop_order INT NOT NULL,
    PRIMARY KEY (route_id, station_id),
    FOREIGN KEY (route_id) REFERENCES routes (route_id),
    FOREIGN KEY (station_id) REFERENCES stations (station_id)
);


INSERT INTO cities (city_id, city_name) VALUES
(1, 'New York'),
(2, 'Los Angeles'),
(3, 'Chicago');

INSERT INTO stations (station_id, station_name, city_id) VALUES
(1, 'Penn Station', 1),
(2, 'Union Station', 2),
(3, 'Grand Central Terminal', 1),
(4, 'Chicago Union Station', 3);

INSERT INTO trains (train_id, train_number, train_type) VALUES
(1, 'A123', 'Express'),
(2, 'B456', 'Freight'),
(3, 'C789', 'Regional');

INSERT INTO routes (
    route_id, route_name, departure_station_id, arrival_station_id
) VALUES
(1, 'NYC to LA Express', 1, 2),
(2, 'LA to Chicago Freight', 2, 4),
(3, 'NYC to Chicago Regional', 3, 4);

INSERT INTO schedules (
    schedule_id, train_id, route_id, departure_time, arrival_time
) VALUES
(1, 1, 1, '2024-12-01 08:00:00', '2024-12-02 20:00:00'),
(2, 2, 2, '2024-12-01 09:00:00', '2024-12-02 18:00:00'),
(3, 3, 3, '2024-12-01 10:00:00', '2024-12-01 22:00:00');


INSERT INTO route_stations (route_id, station_id, stop_order) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 2, 1),
(2, 4, 2),
(3, 3, 1),
(3, 4, 2);
