-- Database: MovieLens_20M

-- DROP DATABASE IF EXISTS "MovieLens_20M";

CREATE DATABASE "MovieLens_20M"
    WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
-- \connect "MovieLens_20M";
-- -----------------------------------------------------
-- Schema: public
-- -----------------------------------------------------
-- SCHEMA: public

-- DROP SCHEMA IF EXISTS public ;

CREATE SCHEMA IF NOT EXISTS public
    AUTHORIZATION pg_database_owner;

COMMENT ON SCHEMA public
    IS 'standard public schema';

GRANT USAGE ON SCHEMA public TO PUBLIC;

GRANT ALL ON SCHEMA public TO pg_database_owner;

--Tables
CREATE TABLE IF NOT EXISTS public."Dim_Movies"
(
    movie_id integer NOT NULL,
    title character varying(255) NOT NULL,
    year integer NOT NULL CHECK (year BETWEEN 1900 AND date_part('year', current_date)),
    PRIMARY KEY (movie_id)
);

CREATE TABLE IF NOT EXISTS public."Dim_Genres"
(
    genre_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( START 1 ),
    genre_name character varying(50) NOT NULL,
    PRIMARY KEY (genre_id),
    CONSTRAINT "Unique_Genre" UNIQUE (genre_name)
);

CREATE TABLE IF NOT EXISTS public."Dim_Genres_Movies"
(
    movie_id integer NOT NULL,
    genre_id integer NOT NULL,
    PRIMARY KEY (movie_id, genre_id)
);

CREATE TABLE IF NOT EXISTS public."Dim_Links"
(
    movie_id integer NOT NULL,
    imdb_id integer,
    tmdb_id integer,
    PRIMARY KEY (movie_id)
);

CREATE TABLE IF NOT EXISTS public."Fact_Ratings"
(
    rating_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( START 1 ),
    user_id integer NOT NULL,
    movie_id integer NOT NULL,
    rating numeric(2, 1) NOT NULL CHECK (rating>=0 and rating<=5),
    "timestamp" timestamp without time zone NOT NULL,
    PRIMARY KEY (rating_id)
);

CREATE TABLE IF NOT EXISTS public."Fact_Taggings"
(
    tagging_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( START 1 ),
    user_id integer NOT NULL,
    movie_id integer NOT NULL,
    tag_id integer NOT NULL,
    "timestamp" timestamp without time zone NOT NULL,
    PRIMARY KEY (tagging_id)
);

CREATE TABLE IF NOT EXISTS public."Dim_Tags"
(
    tag_id integer NOT NULL GENERATED ALWAYS AS IDENTITY ( START 1 ),
    tag character varying(100) NOT NULL,
    PRIMARY KEY (tag_id),
    CONSTRAINT "Unique_Tag" UNIQUE (tag)
);

CREATE TABLE IF NOT EXISTS public."Dim_Tag_Relevances"
(
    movie_id integer NOT NULL,
    tag_id integer NOT NULL,
    relevance numeric(6, 5) check (relevance >=0 and relevance<=1),
    PRIMARY KEY (movie_id, tag_id)
);

ALTER TABLE IF EXISTS public."Dim_Genres_Movies"
    ADD FOREIGN KEY ("genre_id")
    REFERENCES public."Dim_Genres" (genre_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Dim_Genres_Movies"
    ADD FOREIGN KEY ("movie_id")
    REFERENCES public."Dim_Movies" (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Dim_Links"
    ADD FOREIGN KEY (movie_id)
    REFERENCES public."Dim_Movies" (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Fact_Ratings"
    ADD FOREIGN KEY (movie_id)
    REFERENCES public."Dim_Movies" (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Fact_Taggings"
    ADD FOREIGN KEY (movie_id)
    REFERENCES public."Dim_Movies" (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Fact_Taggings"
    ADD FOREIGN KEY (tag_id)
    REFERENCES public."Dim_Tags" (tag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Dim_Tag_Relevances"
    ADD FOREIGN KEY (movie_id)
    REFERENCES public."Dim_Movies" (movie_id) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE NO ACTION;


ALTER TABLE IF EXISTS public."Dim_Tag_Relevances"
    ADD FOREIGN KEY (tag_id)
    REFERENCES public."Dim_Tags" (tag_id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;