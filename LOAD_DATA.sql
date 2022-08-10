-- Create database in server 
CREATE SCHEMA maven_airlines;


-- Change active schema
USE maven_airlines;


-- Create table into which input data will be loaded 
DROP TABLE IF EXISTS passenger_satisfaction;
CREATE TABLE passenger_satisfaction (
ID	INT,
Gender	ENUM('Male', 'Female'),
Age	INT,
Customer_Type	TEXT,
Type_of_Travel	ENUM('Business', 'Personal'),
Class	ENUM('Business', 'Economy', 'Economy Plus'),
Flight_Distance	INT,
Departure_Delay	INT,
Arrival_Delay	INT,
Departure_and_Arrival_Time_Convenience	INT,
Ease_of_Online_Booking	INT,
Check_in_Service	INT,
Online_Boarding	INT,
Gate_Location	INT,
Onboard_Service	INT,
Seat_Comfort	INT,
Leg_Room_Service	INT,
Cleanliness	INT,
Food_and_Drink	INT,
In_flight_Service	INT,
In_flight_Wifi_Service	INT,
In_flight_Entertainment	INT,
Baggage_Handling	INT,
Overall_Satisfaction	TEXT)
;


-- Confirm table structure 
DESC passenger_satisfaction;


-- Check server-side load local data capability. If OFF, turn ON 
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;


-- Load data from local input file into passenger_satisfaction table
-- Perform transformations to replace any empty input cells with NULLs 
LOAD DATA LOCAL INFILE '/Users/mubeen/Documents/Projects/SQL/Maven Airlines/airline_passenger_satisfactionED.csv' INTO TABLE passenger_satisfaction
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES

(ID,Gender,Age,Customer_Type,Type_of_Travel,Class,Flight_Distance,Departure_Delay,@Arrival_Delay,Departure_and_Arrival_Time_Convenience,
Ease_of_Online_Booking,Check_in_Service,Online_Boarding,Gate_Location,Onboard_Service,Seat_Comfort,Leg_Room_Service,Cleanliness,
Food_and_Drink,In_flight_Service,In_flight_Wifi_Service,In_flight_Entertainment,Baggage_Handling,Overall_Satisfaction)

SET 
	Arrival_Delay = NULLIF(@Arrival_Delay, '')
;


-- Confirm all data properly loaded into table 
SELECT*
FROM passenger_satisfaction;




