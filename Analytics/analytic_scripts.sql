--1. Which years had the best-rated movies?
SELECT "year", round(avg(rating), 3) as "Average Rating"
from public."Dim_Movies" m inner join public."Fact_Ratings" r on m.movie_id=r.movie_id
group by "year"
order by "Average Rating" desc

--2.Which is the most popular movie-tag pairing?
select title, tag, count(tag) as "Number of taggings"
from public."Dim_Movies" m inner join public."Fact_Taggings" ft on m.movie_id=ft.movie_id inner join public."Dim_Tags" dt on ft.tag_id=dt.tag_id
group by cube(title, tag)
having title is not null and tag is not null
order by count(tag) desc

--3. Top rated movies by genre
select genre_name, movie_id, title, "year", avg_rating, num_ratings,
rank() over (partition by genre_name order by avg_rating desc, num_ratings desc) as "rank_in_genre" from
(select m.movie_id, genre_name, title, "year", avg(rating) as "avg_rating", count(rating_id) as "num_ratings"
from public."Dim_Genres" g inner join public."Dim_Genres_Movies" gm
on g.genre_id=gm.genre_id
inner join public."Dim_Movies" m on gm.movie_id=m.movie_id
inner join public."Fact_Ratings" r on m.movie_id=r.movie_id
group by (m.movie_id,title, "year", genre_name)
)
where genre_name='Drama' --INSERT YOUR OWN!
--4. Select the movies that have all the mentioned tags
select 
    m.movie_id,
    m.title,
    m.year,
    string_agg(distinct t.tag, ', ' order by t.tag) as tags_applied
from public."Dim_Movies" m
join public."Fact_Taggings" ft on m.movie_id = ft.movie_id
join public."Dim_Tags" t on ft.tag_id = t.tag_id
where t.tag in ('action', 'shocking') --INSERT YOUR OWN
group by m.movie_id, m.title, m.year
having count(distinct ft.tag_id) = (
    select count(*) 
    from public."Dim_Tags"
    where tag in ('action', 'shocking') --THE SAME AS ABOVE
)
order by m.title;
--5.1. The most active users
select user_id, sum(count_engagements) as "engagements" from
(
select user_id, count(rating_id) as "count_engagements" from public."Fact_Ratings" r
group by user_id
union
select user_id, count(tagging_id) as "count_engagements" from public."Fact_Taggings" ft
group by user_id
)
group by user_id
order by engagements desc, user_id asc
---5.2. Tag performance
select 
    t.tag,
    count(distinct ft.user_id) as users_using_tag,
    count(ft.tagging_id) as total_uses,
    round(avg(tr.relevance), 3) as avg_relevance_score,
		-- Combined effectiveness metric
    round((avg(tr.relevance) * sqrt(count(ft.tagging_id)))::numeric, 3) as effectiveness,
    count(case when tr.relevance > 0.7 then 1 end) as highly_relevant_movies
from public."Dim_Tags" t
left join public."Fact_Taggings" ft on t.tag_id = ft.tag_id
left join public."Dim_Tag_Relevances" tr on t.tag_id = tr.tag_id 
    and ft.movie_id = tr.movie_id
group by t.tag
having count(ft.tagging_id) > 0  -- only show tags that have been used
order by effectiveness desc