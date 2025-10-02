Create Table new_spotify_table as
Select *
from spotify_songs s1
Inner Join spotify_songs2_1 s2
	ON s1.track_id=s2.trackid;
    
    Select * from new_spotify_table;
    
-- Finding out the 10 most popular songs
Select track_artist, track_name, track_popularity
from new_spotify_table
order by track_popularity desc
Limit 10;

-- Realizing there are doubles, and removing them

Create table spotify_songs_nodup as
select *
from(
Select *,
Row_number () Over(partition by track_id order by track_popularity desc) as row_num
from new_spotify_table) as mini_table
where row_num = 1;

-- Looking at the table
Select * 
from spotify_songs_nodup;

-- Seeing how many songs there are now
Select Count(*)
from spotify_songs_nodup;

-- Checking for duplicates once more
Select count(*), track_id
from spotify_songs_nodup
group by track_id
having count(*) >1;

-- Now checking the top 10 songs and the popularity
Select track_name, track_artist, track_popularity
from spotify_songs_nodup
order by track_popularity desc
limit 10;

/* 
The top 10 row all have a popularity score of 95 or above. I will investiage the year of these next, to see if there are any trends there, all songs are familiar. 
Billie Eilish appears twice, and is the only one to do so. I will also look at which artists are popular here
*/

-- adding in year
Select track_name, track_artist, track_popularity, Year(track_album_release_date) as album_year
from spotify_songs_nodup
order by track_popularity desc
limit 10;

-- All of the songs are 2019 or 2020. Analyzing what are the years included in the dataset gives us the following

Select distinct Year(track_album_release_date) as album_year
from spotify_songs_nodup
order by Year(track_album_release_date) desc;

-- We can notice that the most popular songs are from the most recent years. I will expand the question adding in year to see if this adjusts if I consider more observations

-- 50 most popular songs
Select track_name, track_artist, track_popularity, Year(track_album_release_date) as album_year
from spotify_songs_nodup
order by track_popularity desc
limit 50;

-- there is at least one 2018 in there. Seems like the popularity is definitely higher when it comes to newer songs. Is this because of when spotify became popular or something else
Select track_name, track_artist, track_popularity, Year(track_album_release_date) as album_year
from spotify_songs_nodup
order by track_popularity desc
limit 100;

/*even when giving 100, there is only one album year before 2015. Thus the popularity is very heavily related to what year it is. 
This makes me say that it could have to do with spotifys popularity or just songs going in and out of style- thus, newer songs are fresher and more with the times
It could be a thought to analyze songs in their own era, seeing if the popular songs change or their features change over time*/

-- Going over artists now, which are the most popular artists
SELECT 
    track_artist,
    AVG(track_popularity) AS artist_popularity,
    COUNT(*) AS song_count
FROM spotify_songs_nodup
GROUP BY track_artist
HAVING COUNT(*) > 1
ORDER BY artist_popularity DESC
LIMIT 15;

/* Billie Eilish gives us the most popular songs on average, excliding people who only have one song here.
Other high scoreers include Travis scott who is also above 90, Harry Styles and Halsey who have 4 songs averaging above 85
Also it is imortant to note Justin Beieber who has 6 songs with an average higher than 80. */

-- Now I want to look at some of the other factors, and how they relate to song popularity. At first, I won't include parts of year, and itll just be the factors themselves

Select * 
from spotify_songs_nodup;

-- Putting the columns here for easier follow up: Danceability, energy, Key, Loudness, Mode, Speechiness, Acoustics, Insturamenalness, liveliness, tempo, valence, duration_seconds, danceability_cat, popularity_category

Select avg(track_popularity), release_date_age, count(*)
from spotify_songs_nodup
group by release_date_age
order by avg(track_popularity);

-- Furthering the thoughts from before, old songs (before 2015) have a 48.3 average popularity, while songs released after 2015 have a popularity of 52.6.

Select round(avg(danceability)*100,2) as danceability, popularity_category
from spotify_songs_nodup
group by popularity_category
order by avg(danceability); 

-- Looking at the other way around, as we have seen that as the song becomes more popular, the danceability consistently goes up

Select round(avg(track_popularity),2) as popularity, danceability_cat
from spotify_songs_nodup
group by danceability_cat
order by avg(track_popularity) desc;

-- Similarly, the higher danceable category, the more popular the song is on average

Select round(avg(energy),2), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(energy);

-- This one doesn't have an exactly linear pattern, as it technically goes (in terms of song popularity and increasing energy) 1,3,2,4. 
-- However we can see that the banger has less energy than all the others. In addition the count allows us to see that there are enough in each category to make evidence based 
-- determinations. 

-- I did two for the first one as I made those categories. For most of them, as I will demonstrate by energy, the results indicate similar things no matter which one is categorical

Alter table spotify_songs_nodup
add column energy_category varchar(250);

Update spotify_songs_nodup
set energy_category =
case
	when energy <.25 then 'slow'
    when energy between .25 and .5 then 'medium slow'
    when energy between .5 and .75 then 'medium fast'
    else 'fast'
end;

select round(avg(track_popularity),2) as Pop, energy_category, count(*)
from spotify_songs_nodup
group by energy_category
order by avg(track_popularity);

/* The results for above show that slow songs are less popular, which while it contradics what we saw above, is understnadble when only 22 songs fit this category.
We then would expect fast, to be the lowest, which is true in this case. Thus something to see is adjusting the margins to make up for the difference and see if it first better.*/


 
Update spotify_songs_nodup
set energy_category =
case
	when energy <.6 then 'slow'
    when energy between .6 and .75 then 'medium slow'
    when energy between .75 and .9 then 'medium fast'
    else 'fast'
end;


select round(avg(track_popularity),2) as Pop, energy_category, count(*)
from spotify_songs_nodup
group by energy_category
order by avg(track_popularity);

-- The slow ones become more popular, while the fast ones are by far the least popular. 
-- This one has a more linear view than the one where its switched, but has a similar outcome- songs with higher energy are less popular than songs with low energy


 Select round(avg(track_popularity),2) as Pop, `key`, count(*)
 from spotify_songs_nodup
group by `key`
order by avg(track_popularity) desc;

/* Each key represents something totally different, not a numeric scale. Thus just want to note the top and bottom few. key=10 and key= 8 are the most popular, 
while 7 and 2 are below 50 on average
For translation purposes
key=2=D
Key=7=G

Popular:
Key= 8= G#
Key=10 = b flat  
*/

-- Loudness
Select round(avg(loudness),2), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(loudness);

/*We get and banger and alright songs are quiter, while the loudest songs are meh, followed by trash. 
While not perfectly linear, we have some indication that wuiter songs are more popular*/

-- Mode
 Select round(avg(track_popularity),2) as Pop, `mode`, count(*)
 from spotify_songs_nodup
group by `mode`
order by avg(track_popularity) desc;

-- Major scale (mode =1) songs are sligtly more popular, empahis on slightly as they are only .16 popularity average difference


Select round(avg(speechiness),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(speechiness);

-- while all are pretty similar, the higher speechiness the better the song (though trash does have a little higher speechiness) than meh 
-- Speechiness refers to the talkingness of the songs, the closer to one the more talk show like it is- this is why the average of the values doesn't even reach .1
 
 Select round(avg(acousticness),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(acousticness);

-- Banger has the highes average acousticness, while trash hwas the lowest, showing some evidence (despite the middles being switched) higher acousticness (confidence level of it) the higher the popularity
-- This is one I will also look at the other side, since this is a confidence level seems like it could be nice to target these as bins.


Alter table spotify_songs_nodup
add column acoustic_category varchar(250);

Update spotify_songs_nodup
set acoustic_category =
case
	when acousticness <.1 then 'not confident'
    when acousticness between .1 and .2 then 'slightly confident'
    when acousticness between .2 and .4 then 'semi confident'
    else 'confident'
end;

 Select round(avg(track_popularity),2) as Pop, acoustic_category, count(*)
 from spotify_songs_nodup
group by acoustic_category
order by avg(track_popularity) desc;

-- Though most songs are not very acoustic, or there is low confidence in acoustic, this confirms the other test, where confident in acousticness leads to a higher popularity- acoustic is popular


Select round(avg(instrumentalness),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(instrumentalness);

-- The almost linear pattern with bangers being significantly less instramentalness shows that people like songs better with vocals


Select round(avg(liveness),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(liveness);

-- The trend above in liveness shows that it doesn't matter, though the banger songs are less likely to be live while the others are the same. I want to make bins for this one too since it is confidence related. 

Alter table spotify_songs_nodup
add column liveness_category varchar(250);

Update spotify_songs_nodup
set liveness_category =
case
	when liveness <.1 then 'not confident'
    when liveness between .1 and .2 then 'slightly confident'
    when liveness between .25 and .4 then 'semi confident'
    else 'confident'
end; 

Select round(avg(track_popularity),2) as Pop, liveness_category, count(*)
 from spotify_songs_nodup
group by liveness_category
order by avg(track_popularity) desc;

/*This one provides more evidence that (though they are pretty close) liveness hurts a song on spotifys popularity. 
This makes sense because people might not want to hear the crowd, they want to hear a clearer and likey better sounding version of the song*/

 Select round(avg(tempo),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(tempo);

-- Tempo similar to energy, shows a slower song leads to a more popular song, though the middle is switched. 

 Select round(avg(valence),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(valence);

-- This one is all over the place, with meh having the least valence( more sad). Banger has the most, but trash is second, showing the fluctuation of people's interests

 Select round(avg(duration_seconds),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(duration_seconds);


-- this one is also mixed, though with an average of 7 seconds longer, songs are trash. This provides some evidence that people get bored of songs. It would be interesting to look further into this


-- Only thing I want to do here is to add year in as a category for one of the most changing ones, lets say dancebaility and energy


Select round(avg(duration_seconds),4), popularity_category, count(*)
from spotify_songs_nodup
group by popularity_category
order by avg(duration_seconds);


Select round(avg(track_popularity),4), release_date_age, count(*), energy_category
from spotify_songs_nodup
group by energy_category, release_date_age
order by avg(track_popularity) desc;

-- shows that there is some similarity, but old fast songs are not popular by a wide margin, when they are more popular nowadadys, but still the least popular. medium slow is the best for old by a wide margin


Select round(avg(track_popularity),4), release_date_age, count(*), danceability_cat
from spotify_songs_nodup
group by danceability_cat, release_date_age
order by avg(track_popularity) desc;

-- Consistency here, people like songs they can dance to 



