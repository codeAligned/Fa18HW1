DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  SELECT MAX(era) -- replace this line
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear -- replace this line
  FROM people
  WHERE weight > 300;
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear -- replace this line
  FROM people
  WHERE namefirst ~ '.* .*'
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*) -- replace this line
  FROM people 
  GROUP BY birthyear 
  ORDER BY birthyear ASC;
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT *  -- replace this line
  FROM q1iii 
  WHERE avgheight > 70 
  ORDER BY birthyear ASC;
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, P.playerid, H.yearid -- replace this line
  FROM people AS P, halloffame AS H 
  WHERE P.playerid = H.playerid AND H.inducted = 'Y' 
  ORDER BY H.yearid DESC;
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, Q.playerid, S.schoolid, Q.yearid -- replace this line
  FROM q2i AS Q, collegeplaying AS CP, schools AS S
  WHERE Q.playerid = CP.playerid and CP.schoolid = S.schoolid AND S.schoolstate = 'CA'
  ORDER BY Q.yearid DESC, S.schoolid, Q.playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT Q.playerid, namefirst, namelast, CP.schoolid -- replace this line
  FROM q2i AS Q
  LEFT OUTER JOIN collegeplaying AS CP
  ON Q.playerid = CP.playerid
  ORDER BY Q.playerid DESC, CP.schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT B.playerid as playerid, namefirst, namelast, B.yearid as yearid, (h - h2b - h3b - hr + 2*h2b + 3*h3b + 4*hr)::float/ab AS slg
  FROM people AS P, batting AS B
  WHERE P.playerid = B.playerid and ab > 50
  ORDER BY slg DESC, yearid, playerid
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT playerid, namefirst, namelast, (h1b_sum + 2*h2b_sum + 3*h3b_sum + 4*hr_sum)::float/ab_sum AS lslg FROM (
    SELECT B.playerid as playerid, namefirst, namelast, SUM(h - h2b - h3b - hr) AS h1b_sum, SUM(h2b) AS h2b_sum, SUM(h3b) AS h3b_sum, SUM(hr) AS hr_sum, SUM(ab) AS ab_sum
    FROM people AS P, batting AS B
    WHERE P.playerid = B.playerid
    GROUP BY (B.playerid, namefirst, namelast)
  ) AS t
  WHERE ab_sum > 50
  ORDER BY lslg DESC, playerid
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  WITH t2(playerid, namefirst, namelast, lslg) AS (
    SELECT playerid, namefirst, namelast, (h1b_sum + 2*h2b_sum + 3*h3b_sum + 4*hr_sum)::float/ab_sum AS lslg FROM (
      SELECT B.playerid as playerid, namefirst, namelast, SUM(h - h2b - h3b - hr) AS h1b_sum, SUM(h2b) AS h2b_sum, SUM(h3b) AS h3b_sum, SUM(hr) AS hr_sum, SUM(ab) AS ab_sum
      FROM people AS P, batting AS B
      WHERE P.playerid = B.playerid
      GROUP BY (B.playerid, namefirst, namelast)
      ) AS t1
    WHERE ab_sum > 50
  )
  SELECT namefirst, namelast, lslg 
  FROM t2
  WHERE lslg > ( SELECT lslg FROM t2 WHERE playerid = 'mayswi01')
  ORDER BY lslg DESC
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary), STDDEV(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS 
  WITH salaries_stat AS (
    SELECT min(salary) AS min_2006, max(salary) AS max_2006, (max(salary) - min(salary))/10 AS range_2006
    FROM salaries
    WHERE yearid = '2016'
  ), bin AS (
    SELECT width_bucket(salary, min_2006, max_2006 + 1, 10) - 1 as binid, count(*) as count
    FROM salaries, salaries_stat
    WHERE yearid = '2016'
    GROUP BY binid
  )
  SELECT binid, min_2006+range_2006*binid, min_2006+range_2006*(binid+1), count
  FROM bin, salaries_stat
  ORDER BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  SELECT cur.yearid, cur.min - pre.min, cur.max - pre.max, cur.avg - pre.avg
  FROM q4i AS cur
  INNER JOIN q4i AS pre
  ON cur.yearid - 1 = pre.yearid
  ORDER BY cur.yearid
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, namefirst, namelast, salary, yearid
  FROM people AS p 
  INNER JOIN salaries AS s
  ON p.playerid = s.playerid
  WHERE (yearid BETWEEN 2000 AND 2001) AND (yearid, salary) IN (
    SELECT yearid, MAX(salary)
    FROM salaries
    GROUP BY yearid
  )
;

-- Question 4v
CREATE VIEW q4v(team, diffAvg) 
AS
  SELECT s.teamid as team, MAX(salary) - MIN(salary)
  FROM allstarfull AS a 
  INNER JOIN salaries AS s
  ON a.playerid = s.playerid and a.yearid = s.yearid
  WHERE a.yearid = 2016
  GROUP BY team
  ORDER BY team
;

