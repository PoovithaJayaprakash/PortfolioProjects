select *from Portfolioproject..Netflix_exact

--- changing the date_added format.

select date_added, convert(date, date_added)
from Portfolioproject..Netflix_exact

alter table Netflix_exact add date_added_converted date

update Netflix_exact
set date_added_converted=convert(date, date_added)

select date_added,date_added_converted from Netflix_exact

alter table Netflix_exact drop column date_added

--- checking if we have any duplicate in the column show_id. 

select show_id,count(*) from Netflix_exact
group by show_id
order by show_id desc

-- we don't have any duplicates

-- Let's find which are the column that are having null values.


select director,cast,country from Netflix_exact where director is null

-- To Update the director column with the help of cast coloumn

with cte as
( select title, CONCAT(director, '---', Movie_cast) as director_cast
from
Netflix_exact
)
select director_cast, count(*) as count from cte
group by director_cast
having count(*) > 1
order by count(*) desc;

select *from Netflix_exact where movie_cast like 'You%'


update Netflix_exact set
director='Ken Burns, Christopher Loren Ewers, Erik Ewers'
where movie_cast like 'Peter Coyote' and
director is null;

update Netflix_exact set
director='Tilak Shetty'
where movie_cast like 'Damandeep Singh Baggan, Smita Malhotra, Baba Sehgal' and
director is null;

update Netflix_exact set
country='United States'
where movie_cast='Brennan Mejia, Camille Hyde, Yoshi Sudarso, Michael Taber, James Davies, Claire Blackwelder' and
country is null;




-- Updating country column

select a.show_id,a.country,b.show_id,b.country, ISNULL (a.country, b.country)
from Netflix_exact a
join
Netflix_exact b
on
a.director=b.director
and
a.show_id<>b.show_id
where a.country is null

update a set
country=ISNULL (a.country, b.country)
from Netflix_exact a
join
Netflix_exact b
on
a.director=b.director
and
a.show_id<>b.show_id
where a.country is null


-- Updating Null values as "Not Given"

update Netflix_exact set
Movie_cast='Not Given'
where Movie_cast is null;

UPDATE Netflix_exact 
SET country = 'Not Given'
WHERE country IS NULL;


--Country column few records has two or more countries. splitting the countries and making sure one country is there in each record.


-- splitting the country column records and passing the results into a new table called country_exact

with cte_new 
as
(select show_id, VALUE, 
ROW_NUMBER() over(partition by show_id order by show_id) as rownum
from Netflix_exact 
cross apply 
string_split(country, ','))
select show_id,Value,rownum into country_exact from cte_new


--Updating the country name (VALUE) from country_exact into the Netflix_exact.country_correct column

update Netflix_exact
set Netflix_exact.country_correct=country_exact.VALUE
from Netflix_exact
inner join
country_exact
on
Netflix_exact.show_id=country_exact.show_id
and
country_exact.rownum='1'

select show_id,country,country_correct from Netflix_exact

-- Dropping the country column from Netflix_exact as it is not needed for visualization

alter table Netflix_exact
drop column country


-- Our data is now ready for visualization


















