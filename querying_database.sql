/* This SQL script is used to perform an exploratory analysis of the data */


-- Display and pin entire table for reference 
SELECT* 
FROM passenger_satisfaction;


-- Use conditional aggregation to find the total percentage of people who are either Dissatisfied or Neutral with the airline 
SELECT (SUM(Overall_Satisfaction = 'Neutral or Dissatisfied')/COUNT(*))*100 percent_neutral_dissatisfied
FROM passenger_satisfaction;
-- the result (56.5537%) confirms that the total satisfaction rate dipped under 50% (43.446%)


/* The following queries analyze satisfaction rates for different classifications */ 


/* GENDER */


-- percentage of male passengers who are satisfied overall 
SELECT 'Male' Gender, (SUM(Overall_Satisfaction='Satisfied' AND Gender='Male')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Gender='Male'))*100 percent_satisfied
FROM passenger_satisfaction
UNION 
-- percentage of female passengers who are satisfied overall 
SELECT 'Female', (SUM(Overall_Satisfaction='Satisfied' AND Gender='Female')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Gender='Female'))*100 percent_satisfied
FROM passenger_satisfaction;  


/* CUSTOMER TYPE */


-- percentage of new passengers who are satisfied overall 
SELECT 'First-time' Customer_Type, (SUM(Overall_Satisfaction='Satisfied' AND Customer_Type='First-time')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Customer_Type='First-time' ))*100 percent_satisfied
FROM passenger_satisfaction
UNION
-- percentage of returning passengers who are satisfied overall 
SELECT 'Returning', (SUM(Overall_Satisfaction='Satisfied' AND Customer_Type='Returning')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Customer_Type='Returning' ))*100 percent_satisfied
FROM passenger_satisfaction; 


/* TYPE OF TRAVEL */


-- percentage of passengers that are travelling for business purposes who are satisfied overall 
SELECT 'Business' Type_of_Travel, (SUM(Overall_Satisfaction='Satisfied' AND Type_of_Travel='Business')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Type_of_Travel='Business' ))*100 percent_satisfied
FROM passenger_satisfaction
UNION 
-- percentage of passengers that are travelling for personal reasons who are satisfied overall 
SELECT 'Personal', (SUM(Overall_Satisfaction='Satisfied' AND Type_of_Travel='Personal')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Type_of_Travel='Personal' ))*100 percent_satisfied
FROM passenger_satisfaction;


/* AGE GROUP */ 


-- Classify all ages into groups 
SELECT
	CASE 
	WHEN Age BETWEEN 0 AND 16 THEN "Child"
	WHEN Age BETWEEN 17 AND 30 THEN "Young Adult"
	WHEN Age BETWEEN 31 AND 45 THEN "Middle-aged Adult"
    WHEN Age BETWEEN 46 AND 64 THEN "Old-aged Adult"
	ELSE "Senior" END Age_Group
FROM passenger_satisfaction;


-- Add new column into table which will hold age classification for every passenger 
ALTER TABLE passenger_satisfaction
# DROP COLUMN Age_Group;
ADD COLUMN Age_Group TEXT AFTER Age;


-- Temporarily turn OFF sql safe updates in order to UPDATE the passenger_satisfaction table in the absence of a key 
SHOW VARIABLES LIKE '%safe%';
SET sql_safe_updates = 0;
SET sql_safe_updates = 1;


-- Create TEMP TABLE for age classification CASE statement result and include id so that it can be used in an UPDATE JOIN statement to populate 
-- newly added Age_Group field in passenger_satisfaction table 
CREATE TEMPORARY TABLE age_category (
id INT AUTO_INCREMENT,
age_class TEXT, 
PRIMARY KEY (id)
);


-- Fill TEMP TABLE with age classification CASE statement result
INSERT INTO age_category (age_class)
SELECT
	CASE 
	WHEN Age BETWEEN 0 AND 16 THEN "Child"
	WHEN Age BETWEEN 17 AND 30 THEN "Young Adult"
	WHEN Age BETWEEN 31 AND 45 THEN "Middle-aged Adult"
    WHEN Age BETWEEN 46 AND 64 THEN "Old-aged Adult"
	ELSE "Senior" END Age_Group
FROM passenger_satisfaction;


SELECT*
FROM age_category;


-- ADD INDEXES to fields that will be JOINED ON in UPDATE JOIN for fast query execution 
ALTER TABLE passenger_satisfaction ADD INDEX (id);
ALTER TABLE age_category ADD INDEX (id);


-- Use UPDATE JOIN clause to populate newly added Age_Group field in passenger_satisfaction table
START TRANSACTION;
UPDATE passenger_satisfaction ps
JOIN age_category ac ON ps.id = ac.id
SET ps.Age_Group = ac.age_class;

COMMIT;


-- Clear Age_Group field in case of incomplete data transfer during UPDATE JOIN
START TRANSACTION;
UPDATE passenger_satisfaction
SET Age_Group = NULL 
WHERE Age_Group IS NOT NULL;

COMMIT;
ROLLBACK;


-- Percentage of satisfied passengers by Age Group 
SELECT total_ppl_by_agegroup.Age_Group, (satisfied_by_age_group.num_of_passengers/total_ppl_by_agegroup.num_of_passengers)*100 percent_satisfied
FROM (
	-- Distribution of passengers by Age Group 
	SELECT Age_Group, COUNT(*) num_of_passengers
	FROM passenger_satisfaction
	GROUP BY 1) total_ppl_by_agegroup
JOIN 
	-- Distribution of satisfied passengers by Age Group 
	(SELECT Age_Group, Overall_Satisfaction, COUNT(*) num_of_passengers
	FROM passenger_satisfaction
	WHERE Overall_Satisfaction = 'Satisfied'
	GROUP BY 1, 2) satisfied_by_age_group
ON total_ppl_by_agegroup.Age_Group = satisfied_by_age_group.Age_Group;


/* TRAVEL CLASS */


-- Percentage of satisfied passengers by Travel Class
SELECT total_ppl_by_travelclass.Class, (satisfied_by_travelclass.num_of_passengers/total_ppl_by_travelclass.num_of_passengers)*100 percent_satisfied
FROM (
	-- Distribution of passengers by Travel Class
	SELECT Class, COUNT(*) num_of_passengers 
	FROM passenger_satisfaction
	GROUP BY 1) total_ppl_by_travelclass
JOIN
	-- Distribution of satisfied passengers by Travel Class
	(SELECT Class, Overall_Satisfaction, COUNT(*) num_of_passengers
	FROM passenger_satisfaction
	WHERE Overall_Satisfaction = 'Satisfied' 
	GROUP BY 1) satisfied_by_travelclass
	ON total_ppl_by_travelclass.Class = satisfied_by_travelclass.Class;


/* FLIGHT DISTANCE */


-- Percentage of satisfied passengers by flight distance category 
SELECT cbd.Flight_Category, (sbd.num_of_flights/cbd.num_of_flights)*100 percent_satisfied
FROM (
	-- Categorize all flights by distance
	SELECT Flight_Category, COUNT(*) num_of_flights
	FROM (
		SELECT 
        Flight_Distance,
		CASE 
			WHEN Flight_Distance BETWEEN 0 AND 700 THEN 'Short-haul'
			WHEN Flight_Distance BETWEEN 701 AND 2999 THEN 'Medium-haul'
			ELSE 'Long-haul' END Flight_Category
		FROM passenger_satisfaction) Category_by_Distance 
	GROUP BY 1) cbd
	JOIN 
	-- Number of passengers satisfied in each flight distance category 
	(SELECT Flight_Category, COUNT(*) num_of_flights
	FROM (
		SELECT 
		Flight_Distance, 
		CASE 
			WHEN Flight_Distance BETWEEN 0 AND 700 THEN 'Short-haul'
			WHEN Flight_Distance BETWEEN 701 AND 2999 THEN 'Medium-haul'
			ELSE 'Long-haul' END Flight_Category, 
		Overall_Satisfaction
		FROM passenger_satisfaction
		WHERE Overall_Satisfaction = 'Satisfied') Satisfied_by_Distance
	GROUP BY 1) sbd
	ON cbd.Flight_Category = sbd.Flight_Category;


/* The following queries are an analysis of the various airline factors (Seat Comfort, Gate_Location, etc.) */


-- Identify factors of airline which received the most number of lowest satisfaction score, 1
SELECT *
FROM (
	SELECT 'Departure_and_Arrival_Time_Convenience' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Departure_and_Arrival_Time_Convenience=1
	UNION
	SELECT 'Ease_of_Online_Booking', COUNT(*)
	FROM passenger_satisfaction
	WHERE Ease_of_Online_Booking=1
	UNION
	SELECT 'Check_in_Service', COUNT(*)
	FROM passenger_satisfaction
	WHERE Check_in_Service=1
	UNION
	SELECT 'Online_Boarding', COUNT(*)
	FROM passenger_satisfaction
	WHERE Online_Boarding=1
	UNION
	SELECT 'Gate_Location', COUNT(*)
	FROM passenger_satisfaction
	WHERE Gate_Location=1
	UNION
	SELECT 'Onboard_Service', COUNT(*)
	FROM passenger_satisfaction
	WHERE Onboard_Service=1
	UNION
	SELECT 'Seat_Comfort', COUNT(*)
	FROM passenger_satisfaction
	WHERE Seat_Comfort=1
	UNION
	SELECT 'Leg_Room_Service', COUNT(*)
	FROM passenger_satisfaction
	WHERE Leg_Room_Service=1
	UNION
	SELECT 'Cleanliness', COUNT(*)
	FROM passenger_satisfaction
	WHERE Cleanliness=1
	UNION
	SELECT 'Food_and_Drink', COUNT(*)
	FROM passenger_satisfaction
	WHERE Food_and_Drink=1
	UNION
	SELECT 'In_flight_Service', COUNT(*)
	FROM passenger_satisfaction
	WHERE In_flight_Service=1
	UNION
	SELECT 'In_flight_Wifi_Service', COUNT(*)
	FROM passenger_satisfaction
	WHERE In_flight_Wifi_Service=1
	UNION
	SELECT 'In_flight_Entertainment', COUNT(*)
	FROM passenger_satisfaction
	WHERE In_flight_Entertainment=1
	UNION
	SELECT 'Baggage_Handling', COUNT(*)
	FROM passenger_satisfaction
	WHERE Baggage_Handling=1) factors_lowest_score_count
ORDER BY 2 DESC;


-- Average satisfaction scores for each factor of the airline 
SELECT*
FROM (
	SELECT 'Departure_and_Arrival_Time_Convenience' Factors, AVG(Departure_and_Arrival_Time_Convenience) AVG_Satisfaction_Score
	FROM passenger_satisfaction
	UNION
	SELECT 'Ease_of_Online_Booking', AVG(Ease_of_Online_Booking)
	FROM passenger_satisfaction
	UNION
	SELECT 'Check_in_Service', AVG(Check_in_Service)
	FROM passenger_satisfaction
	UNION
	SELECT 'Online_Boarding', AVG(Online_Boarding)
	FROM passenger_satisfaction
	UNION
	SELECT 'Gate_Location', AVG(Gate_Location)
	FROM passenger_satisfaction
	UNION
	SELECT 'Onboard_Service', AVG(Onboard_Service)
	FROM passenger_satisfaction
	UNION
	SELECT 'Seat_Comfort', AVG(Seat_Comfort)
	FROM passenger_satisfaction
	UNION
	SELECT 'Leg_Room_Service', AVG(Leg_Room_Service)
	FROM passenger_satisfaction
	UNION
	SELECT 'Cleanliness', AVG(Cleanliness)
	FROM passenger_satisfaction
	UNION
	SELECT 'Food_and_Drink', AVG(Food_and_Drink)
	FROM passenger_satisfaction
	UNION
	SELECT 'In_flight_Service', AVG(In_flight_Service)
	FROM passenger_satisfaction
	UNION
	SELECT 'In_flight_Wifi_Service', AVG(In_flight_Wifi_Service)
	FROM passenger_satisfaction
	UNION
	SELECT 'In_flight_Entertainment', AVG(In_flight_Entertainment)
	FROM passenger_satisfaction
	UNION
	SELECT 'Baggage_Handling', AVG(Baggage_Handling)
	FROM passenger_satisfaction) factors_avg_satisfaction_score
ORDER BY 2 DESC;


/* The following queries analyze the distribution of lowest satisfaction score (1) among all the different airline factors for each Travel Class */


/* BUSINESS CLASS */

SELECT *
FROM (
	SELECT Class, 'Departure_and_Arrival_Time_Convenience' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Departure_and_Arrival_Time_Convenience = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Ease_of_Online_Booking' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Ease_of_Online_Booking = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Check_in_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Check_in_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Online_Boarding' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Online_Boarding = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Gate_Location' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Gate_Location = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Onboard_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Onboard_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Seat_Comfort' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Seat_Comfort = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Leg_Room_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Leg_Room_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Cleanliness' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Cleanliness = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Food_and_Drink' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Food_and_Drink = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND In_flight_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Wifi_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND In_flight_Wifi_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Entertainment' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND In_flight_Entertainment = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Baggage_Handling' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Business' AND Baggage_Handling = 1
	GROUP BY 1,2) least_satisfied_Business_Class
ORDER BY 3 DESC;

/* ECONOMY CLASS */

SELECT *
FROM (
	SELECT Class, 'Departure_and_Arrival_Time_Convenience' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Departure_and_Arrival_Time_Convenience = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Ease_of_Online_Booking' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Ease_of_Online_Booking = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Check_in_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Check_in_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Online_Boarding' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Online_Boarding = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Gate_Location' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Gate_Location = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Onboard_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Onboard_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Seat_Comfort' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Seat_Comfort = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Leg_Room_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Leg_Room_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Cleanliness' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Cleanliness = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Food_and_Drink' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Food_and_Drink = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND In_flight_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Wifi_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND In_flight_Wifi_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Entertainment' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND In_flight_Entertainment = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Baggage_Handling' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy' AND Baggage_Handling = 1
	GROUP BY 1,2) least_satisfied_Economy_Class
ORDER BY 3 DESC;

/* ECONOMY PLUS CLASS */

SELECT *
FROM (
	SELECT Class, 'Departure_and_Arrival_Time_Convenience' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Departure_and_Arrival_Time_Convenience = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Ease_of_Online_Booking' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Ease_of_Online_Booking = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Check_in_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Check_in_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Online_Boarding' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Online_Boarding = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Gate_Location' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Gate_Location = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Onboard_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Onboard_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Seat_Comfort' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Seat_Comfort = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Leg_Room_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Leg_Room_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Cleanliness' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Cleanliness = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Food_and_Drink' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Food_and_Drink = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND In_flight_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Wifi_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND In_flight_Wifi_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'In_flight_Entertainment' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND In_flight_Entertainment = 1
	GROUP BY 1,2
	UNION
	SELECT Class, 'Baggage_Handling' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Class = 'Economy Plus' AND Baggage_Handling = 1
	GROUP BY 1,2) least_satisfied_Economy_Plus_Class
ORDER BY 3 DESC;


/* The following queries analyze the distribution of lowest satisfaction score (1) among all the different airline factors for each Customer Type */


/* RETURNING CUSTOMERS */

SELECT *
FROM (
	SELECT Customer_Type, 'Departure_and_Arrival_Time_Convenience' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Departure_and_Arrival_Time_Convenience = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Ease_of_Online_Booking' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type= 'Returning' AND Ease_of_Online_Booking = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Check_in_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Check_in_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Online_Boarding' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Online_Boarding = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Gate_Location' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Gate_Location = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Onboard_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Onboard_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Seat_Comfort' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Seat_Comfort = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Leg_Room_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Leg_Room_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Cleanliness' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Cleanliness = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Food_and_Drink' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Food_and_Drink = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'In_flight_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND In_flight_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'In_flight_Wifi_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND In_flight_Wifi_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'In_flight_Entertainment' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND In_flight_Entertainment = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Baggage_Handling' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'Returning' AND Baggage_Handling = 1
	GROUP BY 1,2) least_satisfied_Returning_Customers
ORDER BY 3 DESC;

/* FIRST-TIME CUSTOMERS */

SELECT *
FROM (
	SELECT Customer_Type, 'Departure_and_Arrival_Time_Convenience' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Departure_and_Arrival_Time_Convenience = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Ease_of_Online_Booking' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type= 'First-time' AND Ease_of_Online_Booking = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Check_in_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Check_in_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Online_Boarding' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Online_Boarding = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Gate_Location' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Gate_Location = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Onboard_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Onboard_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Seat_Comfort' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Seat_Comfort = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Leg_Room_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Leg_Room_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Cleanliness' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Cleanliness = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Food_and_Drink' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Food_and_Drink = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'In_flight_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND In_flight_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'In_flight_Wifi_Service' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND In_flight_Wifi_Service = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'In_flight_Entertainment' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND In_flight_Entertainment = 1
	GROUP BY 1,2
	UNION
	SELECT Customer_Type, 'Baggage_Handling' Factors, COUNT(*) number_of_1s
	FROM passenger_satisfaction
	WHERE Customer_Type = 'First-time' AND Baggage_Handling = 1
	GROUP BY 1,2) least_satisfied_First_time_Customers
ORDER BY 3 DESC;


-- Breaking down number of passengers by Customer Type and Travel Class 
SELECT Customer_Type, Class, COUNT(*) num_of_passengers
FROM passenger_satisfaction
GROUP BY 1, 2
ORDER BY 1, 3 DESC;



-- Travel class passengers choose to fly in based on their flight distance 
SELECT *, COUNT(*) num_of_passengers 
FROM (
	SELECT
	CASE 
		WHEN Flight_Distance BETWEEN 0 AND 700 THEN 'Short-haul'
		WHEN Flight_Distance BETWEEN 701 AND 2999 THEN 'Medium-haul'
		ELSE 'Long-haul' END Distance_Category, 
	Class
	FROM passenger_satisfaction) flight_distance_travel_class
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


-- Percentage of passengers that experienced a departure delay 
SELECT 
(SELECT COUNT(*)
FROM passenger_satisfaction
WHERE Departure_Delay != 0)/(SELECT COUNT(*) FROM passenger_satisfaction)*100 departure_delay_percent;


-- Percentage of passengers that experienced an arrival delay 
SELECT 
(SELECT COUNT(*)
FROM passenger_satisfaction
WHERE Arrival_Delay != 0)/(SELECT COUNT(*) FROM passenger_satisfaction)*100 arrival_delay_percent;


-- Breaking down number of passengers by Type of Travel and Travel Class 
SELECT Type_of_Travel, Class, COUNT(*) num_of_passengers
FROM passenger_satisfaction
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


-- Number of Personal-purpose Economy Class passengers not pleased with the WiFi service
SELECT Type_of_Travel, Class, In_flight_Wifi_Service
FROM passenger_satisfaction
WHERE Type_of_Travel = 'Personal' AND Class = 'Economy' and In_flight_Wifi_Service = 1;


-- Number of Returning passengers not pleased with the WiFi service 
SELECT Customer_Type, Class, In_flight_Wifi_Service
FROM passenger_satisfaction
WHERE Customer_Type = 'Returning' AND In_flight_Wifi_Service = 1;


-- Number of passengers who purchased a ticket through Online Booking 
SELECT Ease_of_Online_Booking
FROM passenger_satisfaction
WHERE Ease_of_Online_Booking != 0;


-- Use of Online Booking Service by Age Group 
SELECT Age_Group, COUNT(*) num_of_passengers
FROM passenger_satisfaction
WHERE Ease_of_Online_Booking != 0
GROUP BY 1
ORDER BY 2 DESC;


