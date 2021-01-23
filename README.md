# Mobile-App-AB-Testing-in-SQL

##

Here We are constantly A/B testing various features on both of our apps and assessing how they have performed with our users. Users can be in multiple experiments.

Let’s say we have the following three tables and columns:

#### ● experiments​ - listing of each experiment that has been performed

○ experiment_id (integer)

○ experiment_name (varchar)

○ experiment_start_timestamp (timestamp_tz)

○ experiment_end_timestamp (timestamp_tz)

#### ● user_experiments​ - users that received the experiment

○ user_id (integer)

○ experiment_id (integer)

○ entered_experiment_timestamp (timestamp_tz)

#### ● events_log​ - all users event log

○ event_id (integer)

○ user_id (integer)

○ event_name (varchar)

○ event_timestamp (timestamp_tz)

I will answer Questions below:

 1. How many total experiments have run by month, from July 2020 to October 2020?

 2. How many users received the experiment ​‘training_tab_extra_game_10_2020’​ experiment?

 3. How many users were in more than 1 experiment between January 2020 and March 2020?

 4. The ​‘pre_mediation_animation_06_2020’​ experiment is triggered immediately after a new user installs the app. 

 Let’s assume that 50% of new users got the variant and 50% of users did not get the variant. This install event is labeled ​‘app_installed’ a​ nd if the user completed a session then the​ ‘session_completed’​ event will trigger.

 How many users within the control and experiment completed the ​‘session_completed’ event within 7 days of installing the app? 

 (I will provide three metrics -- one for overall users, one for the control, and one for the experiment).
