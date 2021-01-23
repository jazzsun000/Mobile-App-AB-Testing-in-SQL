#1.How many total experiments have run by month, from July 2020 to October 2020?

#PostgreSQL
#Here we will divide our idea into two part.
#1.how many total experiments have run by month, 
#mean how many experiments we start by month, will use experiment_start_timestamp
#2.July 2020 to October 2020 mean 
#experiment_start_timestamp between ‘2020-07-01 00:00:00’ and ‘2020-10-30 23:59:59’

SELECT to_char(experiment_start_timestamp, 'YYYY-MM')  as year_month,
COUNT(DISTINCT experiment_id) as number_of_experiments
FROM experiments
WHERE experiment_start_timestamp BETWEEN '2020-07-01 00:00:00'::timestamp 
AND '2020-10-30 23:59:59'::timestamp
GROUP BY year_month
ORDER BY year_month
;

#2.How many users received 
#the experiment ‘training_tab_extra_game_10_2020’ experiment?

#PostgreSQL


SELECT experiments.experiment_name  as experiment_name,
COUNT(DISTINCT user_experiments.user_id) as number_of_user_received_the experiment
FROM experiments
LEFT JOIN user_experiments
ON experiments.experiment_id = user_experiments.experiment_id
WHERE experiments.experiment_name = "training_tab_extra_game_10_2020"
GROUP BY experiments.experiment_name

;

#3.How many users were in more than 1 experiment 
#between January 2020 and March 2020?

#PostgreSQL

SELECT COUNT(DISTINCT subtable.user_id) as number_of_users_in_more_than_1_experiment 
FROM(
SELECT user_id as user_id,
count(DISTINCT experiment_id) as number_of_experiments_in
FROM user_experiments
WHERE entered_experiment_timestamp BETWEEN '2020-01-01 00:00:00'::timestamp 
AND '2020-03-31 23:59:59'::timestamp
GROUP BY user_id
HAVING count(DISTINCT experiment_id)>1
) AS subtable
;


#4.The ‘pre_mediation_animation_06_2020’ experiment is triggered immediately after a new user installs the app. 
#Let’s assume that 50% of new users got the variant and 50% of users did not get the variant. 
#This install event is labeled ‘app_installed’ a nd if the user completed a session then the ‘session_completed’ event will trigger.
#How many users within the control and experiment completed the ‘session_completed’ event within 7 days of installing the app? 
#(Please provide three metrics -- one for overall users, one for the control, and one for the experiment).

#PostgreSQL
#Let’s assume that 50% of new users got the variant(experiment group) 
#and 50% of users did not get the variant.(control group)


With ab_test_entrants as(
SELECT 
*,
#split new installed user into 50/50 by random row_number assignment,
#assign odd number with 'experiment_group' ane even number with 'control_group'
(case when row_number() over (order by random()) % 2 = 1
             then 'experiment_group' else 'control_group'
        end) as tag
FROM events_log 
WHERE event_name = 'app_installed'

),
session_completed_tab as(
SELECT 
event_id as event_id,
user_id as user_id,
event_name as event_name,
event_timestamp as session_completed_timestamp
FROM events_log 
WHERE event_name = 'session_completed'
)
calc_tab as(
SELECT ab_test_entrants.user_id as user_id,
ab_test_entrants.tag as tag,
DATE_PART('day', session_completed_tab.session_completed_timestamp - ab_test_entrants.install_timestamp) as session_completed_since_installed_days
FROM ab_test_entrants
LEFT JOIN session_completed_tab
ON ab_test_entrants.user_id = session_completed_tab.user_id
WHERE DATE_PART('day', session_completed_tab.session_completed_timestamp - ab_test_entrants.install_timestamp) BETWEEN 0 AND 7

)
SELECT 
COUNT(CASE WHEN calc_tab.tag='experiment_group' or calc_tab.tag='control_group' THEN 1 ELSE NULL END) as number_of_overall_users_completed_session_within_7_days,
COUNT(CASE WHEN calc_tab.tag='experiment_group'  THEN 1 ELSE NULL END) as number_of_experiment_group_users_completed_session_within_7_days,
COUNT(CASE WHEN calc_tab.tag='control_group' THEN 1 ELSE NULL END) as number_of_control_group_users_completed_session_within_7_days
FROM calc_tab