/* Create VIEWS for tables that will be used in visualizations */


CREATE VIEW percent_neutral_dissatisfied AS
SELECT (SUM(Overall_Satisfaction = 'Neutral or Dissatisfied')/COUNT(*))*100 percent_neutral_dissatisfied
FROM passenger_satisfaction;


CREATE VIEW satisfied_gender AS 
SELECT 'Male' Gender, (SUM(Overall_Satisfaction='Satisfied' AND Gender='Male')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Gender='Male'))*100 percent_satisfied
FROM passenger_satisfaction
UNION 
SELECT 'Female', (SUM(Overall_Satisfaction='Satisfied' AND Gender='Female')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Gender='Female'))*100 percent_satisfied
FROM passenger_satisfaction;   


CREATE VIEW satisfied_customer_type AS 
SELECT 'First-time' Customer_Type, (SUM(Overall_Satisfaction='Satisfied' AND Customer_Type='First-time')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Customer_Type='First-time' ))*100 percent_satisfied
FROM passenger_satisfaction
UNION
SELECT 'Returning', (SUM(Overall_Satisfaction='Satisfied' AND Customer_Type='Returning')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Customer_Type='Returning' ))*100 percent_satisfied
FROM passenger_satisfaction; 


CREATE VIEW satisfied_travel_type AS 
SELECT 'Business' Type_of_Travel, (SUM(Overall_Satisfaction='Satisfied' AND Type_of_Travel='Business')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Type_of_Travel='Business' ))*100 percent_satisfied
FROM passenger_satisfaction
UNION 
SELECT 'Personal', (SUM(Overall_Satisfaction='Satisfied' AND Type_of_Travel='Personal')/(SELECT COUNT(*) FROM passenger_satisfaction WHERE Type_of_Travel='Personal' ))*100 percent_satisfied
FROM passenger_satisfaction;


CREATE VIEW satisfied_age_group AS 
SELECT total_ppl_by_agegroup.Age_Group, (satisfied_by_age_group.num_of_passengers/total_ppl_by_agegroup.num_of_passengers)*100 percent_satisfied
FROM (
	SELECT Age_Group, COUNT(*) num_of_passengers
	FROM passenger_satisfaction
	GROUP BY 1) total_ppl_by_agegroup
JOIN 
	(SELECT Age_Group, Overall_Satisfaction, COUNT(*) num_of_passengers
	FROM passenger_satisfaction
	WHERE Overall_Satisfaction = 'Satisfied'
	GROUP BY 1, 2) satisfied_by_age_group
ON total_ppl_by_agegroup.Age_Group = satisfied_by_age_group.Age_Group;


CREATE VIEW satisfied_travel_class AS 
SELECT total_ppl_by_travelclass.Class, (satisfied_by_travelclass.num_of_passengers/total_ppl_by_travelclass.num_of_passengers)*100 percent_satisfied
FROM (
	SELECT Class, COUNT(*) num_of_passengers 
	FROM passenger_satisfaction
	GROUP BY 1) total_ppl_by_travelclass
JOIN
	(SELECT Class, Overall_Satisfaction, COUNT(*) num_of_passengers
	FROM passenger_satisfaction
	WHERE Overall_Satisfaction = 'Satisfied' 
	GROUP BY 1) satisfied_by_travelclass
	ON total_ppl_by_travelclass.Class = satisfied_by_travelclass.Class;


CREATE VIEW satisfied_distance AS
SELECT cbd.Flight_Category, (sbd.num_of_flights/cbd.num_of_flights)*100 percent_satisfied
FROM (
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
    

CREATE VIEW least_satisfied_factors AS 
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


CREATE VIEW avg_satisfaction_score_factors AS 
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


CREATE VIEW business_class_least_satisfied AS
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


CREATE VIEW economy_class_least_satisfied AS 
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


CREATE VIEW economy_plus_class_least_satisfied AS 
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


CREATE VIEW returning_passengers_least_satisfied AS
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


CREATE VIEW first_time_passengers_least_satisfied AS
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


CREATE VIEW customer_type_travel_class AS 
SELECT Customer_Type, Class, COUNT(*) num_of_passengers
FROM passenger_satisfaction
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


CREATE VIEW distance_travel_class AS 
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

