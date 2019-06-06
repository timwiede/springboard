/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

--Filter results with a > statement
SELECT name 
FROM country_club.Facilities
WHERE membercost > 0.0;

/* Q2: How many facilities do not charge a fee to members? */

--Just like the last one, but with =
SELECT COUNT(*)
FROM country_club.Facilities
WHERE membercost = 0.0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

--Just need an AND to find the intersection of two filters
SELECT facid, name, membercost, monthlymaintenance
FROM country_club.Facilities
WHERE membercost > 0.0
AND membercost < (monthlymaintenance*0.2);

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

--I can use IN instead of OR
SELECT *
FROM country_club.Facilities
WHERE facid IN (1,5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */


--Using CASE to build a new column with the correct labels
SELECT name, monthlymaintenance,
CASE WHEN monthlymaintenance >100 THEN 'expensive'
	 ELSE 'cheap' END AS cost
FROM country_club.Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

--Here I'm doing a subquery inside my WHERE clause to compute the max
SELECT firstname,surname
FROM country_club.Members
WHERE joindate = (SELECT MAX(joindate) FROM country_club.Members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

--This one was tough. I wasn't sure if the triple join would work.
--And I had to try a few things to concatenate the member names
SELECT  DISTINCT facilities.name AS facility_name,
CONCAT(members.firstname,' ',members.surname) AS member_name
FROM country_club.Facilities facilities
JOIN country_club.Bookings bookings
ON facilities.facid = bookings.facid
JOIN country_club.Members members
ON bookings.memid = members.memid
WHERE facilities.name LIKE 'Tennis Court%'
ORDER BY member_name


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

--This is super gross with doing the same CASE twice, but it works.
SELECT facilities.name AS facility_name,
CONCAT(members.firstname,' ',members.surname) AS member_name,
CASE WHEN members.firstname='GUEST'
		THEN (bookings.slots * facilities.guestcost)
	 ELSE (bookings.slots * facilities.membercost) END AS cost
FROM country_club.Facilities facilities
JOIN country_club.Bookings bookings
ON facilities.facid = bookings.facid
JOIN country_club.Members members
ON bookings.memid = members.memid
WHERE bookings.starttime LIKE '2012-09-14%'
AND CASE WHEN members.firstname='GUEST'
		THEN (bookings.slots * facilities.guestcost)
	 ELSE (bookings.slots * facilities.membercost) END > 30
ORDER BY cost DESC;


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

--This is a little bit nicer.
SELECT sub.facility_name, sub.member_name, sub.cost

FROM
(
SELECT facilities.name AS facility_name,
CONCAT(members.firstname,' ',members.surname) AS member_name,
CASE WHEN members.firstname='GUEST'
		THEN (bookings.slots * facilities.guestcost)
	 ELSE (bookings.slots * facilities.membercost) END AS cost
FROM country_club.Facilities facilities
JOIN country_club.Bookings bookings
ON facilities.facid = bookings.facid
JOIN country_club.Members members
ON bookings.memid = members.memid
WHERE bookings.starttime LIKE '2012-09-14%'
) sub


WHERE sub.cost > 30
ORDER BY sub.cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */


--Using a very similar subquery from the last problem, I got revenue by summing over cost
--Using GROUP BY and HAVING I was able to filter only facilities with revenue < 1000
SELECT sub.facility_name AS facility_name,
SUM(sub.cost) AS total_revenue


FROM
(
SELECT facilities.name AS facility_name,
CONCAT(members.firstname,' ',members.surname) AS member_name,
CASE WHEN members.firstname='GUEST'
		THEN (bookings.slots * facilities.guestcost)
	 ELSE (bookings.slots * facilities.membercost) END AS cost
FROM country_club.Facilities facilities
JOIN country_club.Bookings bookings
ON facilities.facid = bookings.facid
JOIN country_club.Members members
ON bookings.memid = members.memid
) sub

GROUP BY facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue



