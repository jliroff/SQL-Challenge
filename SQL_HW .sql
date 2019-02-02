USE sakila;

#1a. Display the first and last names of all actors from the table actor.
select first_name, last_name 
	from actor;

#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name," ", last_name) as 'Actor Name'
	from actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
select * 
	from actor
    where first_name= 'Joe';
    
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id,
	country
	from country
    where country in('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor
-- named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
Alter Table actor 
ADD description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
Alter Table actor 
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name, 
	count(last_name)
	from actor 
	group by 1
    order by 2 DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, 
	count(last_name)
	from actor 
	group by 1
    having count(last_name) >= 2
    order by 2 DESC;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
Update actor
	set first_name = 'HARPO'
	where first_name = 'GROUCHO' and last_name = 'WILLIAMS' ;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
Update actor
	set first_name = 'GROUCHO'
	where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
Show create table address;
select * from address; 

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select sta.first_name,
		  sta.last_name,
		  addr.address
	from staff sta 
	join address addr on addr.address_id = sta.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select sta.first_name,
		  sta.last_name,
          pay.staff_id,
          sum(pay.amount)
	from staff sta
	join payment pay on sta.staff_id = pay.staff_id
	where payment_date between '2005-08-01' and '2005-12-31'
	group by pay.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select fi.title,
          count(fa.actor_id) as Number_of_actors
	from film fi
	join  film_actor fa on fi.film_id = fa.film_id
	group by 1
	order by 2 DESC;
          
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select fi.title,
		count(i.inventory_id) as Number_of_copies
	from film fi
	join inventory i on fi.film_id = i.film_id
	group by 1
	order by 2 DESC;
        
-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select cus.first_name,
		  cus.last_name,
          cus.customer_id,
          sum(pay.amount)
	from customer cus
	join payment pay on cus.customer_id = pay.customer_id
	group by 3
	order by 2 ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
select title
	from film
	where language_id IN (
    select language_id 
		from language 
        where name = 'English')
	and title like 'K%'  or title like 'Q%';
									
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select first_name,
		  last_name
	from actor
	where actor_id in (
		  select actor_id 
	from film_actor 
   where film_id in (
		  select film_id 
    from film 
    where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select cu.first_name,
		  cu.last_name,
          email
	from customer cu
    join address ad on ad.address_id = cu.address_id 
    join city ci on ci.city_id = ad.city_id 
    join country co on co.country_id = ci.country_id 
    where co.country = 'Canada'; 

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
select title
	from film 
    where film_id in(
		select film_id
			from film_category
            where film_id in(
		select film_id 
			from category
            where `name` = 'Family'));
            
-- 7e. Display the most frequently rented movies in descending order.
select fi.title,
		   count(ren.inventory_id) 
	from inventory i 
    join rental ren on i.inventory_id = ren.inventory_id
    join film fi on fi.film_id = i.film_id
    group by 1
    order by 2 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
select sta.store_id,
		  sum(pay.amount)
	from payment pay
    join staff sta on sta.staff_id = pay.staff_id
    group by 1;
          			
-- 7g. Write a query to display for each store its store ID, city, and country.
select st.store_id,
		  ci.city,
          co.country
	from store st 
    join address ad on ad.address_id = st.address_id
    join city ci on ci.city_id = ad.city_id
    join country co on co.country_id = ci.country_id;
    
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select ca.name as genre,
		  sum(pay.amount) as gross_revenue
from category ca
join film_category fica on fica.category_id = ca.category_id
join inventory i on fica.film_id = i.film_id
join rental ren on ren.inventory_id = i.inventory_id
join payment pay on ren.rental_id = pay.rental_id
group by 1
order by 2 desc;
		   
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_5_genres
AS select ca.name as genre,
		  sum(pay.amount) as gross_revenue
from category ca
join film_category fica on fica.category_id = ca.category_id
join inventory i on fica.film_id = i.film_id
join rental ren on ren.inventory_id = i.inventory_id
join payment pay on ren.rental_id = pay.rental_id
group by 1
order by 2 desc;
-- 8b. How would you display the view that you created in 8a?
select * from Top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top_5_genres;