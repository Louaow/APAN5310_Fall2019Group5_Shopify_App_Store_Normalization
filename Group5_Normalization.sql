create table apps (
app_id serial,
app_title varchar(100) NOT NULL,
url varchar(500) UNIQUE NOT NULL,
tagline varchar(500) NOT NULL,
icon varchar(500) NOT NULL,
pricing_hint varchar(100),
primary key (app_id));

create table developers(
developer_id serial,
developer varchar(250) NOT NULL,
developer_link varchar(500) NOT NULL,
primary key (developer_id));

create table apps_and_developers(
app_id integer,
developer_id integer,
primary key(app_id,developer_id),
foreign key(app_id) references apps(app_id) 
  on delete cascade
  on update cascade,
foreign key(developer_id) references developers(developer_id)
  on delete cascade
  on update cascade);

create table descriptions(
description_id serial,
description text NOT NULL,
description_raw text NOT NULL,
primary key(description_id));

create table apps_and_descriptions(
app_id integer,
description_id integer,
primary key(app_id,description_id),
foreign key(app_id) references apps(app_id)
  on delete cascade
  on update cascade,
foreign key(description_id) references descriptions(description_id)
  on delete cascade
  on update cascade);

create table categories(
category_id serial,
category_title varchar(100) NOT NULL,
primary key(category_id));

create table apps_and_categories(
app_id integer,
category_id integer,
primary key(app_id,category_id),
foreign key(app_id) references apps(app_id)
  on delete cascade
  on update cascade,
foreign key(category_id) references categories(category_id)
  on delete cascade
  on update cascade);

create table benefits(
benefit_id serial,
benefit_title varchar(100) NOT NULL,
benefit_description text NOT NULL,
primary key(benefit_id));

create table apps_and_benefits(
app_id integer,
benefit_id integer,
primary key(app_id,benefit_id),
foreign key(app_id) references apps(app_id)
  on delete cascade
  on update cascade,
foreign key(benefit_id) references benefits(benefit_id)
  on delete cascade
  on update cascade);

create table pricing_plans(
pricing_plan_id serial,
title varchar(100),
price_plan varchar(100) NOT NULL,
primary key(pricing_plan_id));

create table apps_and_pricing_plans(
app_id integer,
pricing_plan_id integer,
primary key(app_id,pricing_plan_id),
foreign key(app_id) references apps(app_id)
  on delete cascade
  on update cascade,
foreign key(pricing_plan_id) references pricing_plans(pricing_plan_id)
  on delete cascade
  on update cascade);

create table pricing_features(
pricing_feature_id serial,
feature varchar(250) NOT NULL,
primary key(pricing_feature_id));

create table pricing_plans_and_pricing_features(
pricing_plan_id integer,
pricing_feature_id integer,
primary key(pricing_plan_id,pricing_feature_id),
foreign key(pricing_plan_id) references pricing_plans(pricing_plan_id)
  on delete cascade
  on update cascade,
foreign key(pricing_feature_id) references pricing_features(pricing_feature_id)
  on delete cascade
  on update cascade);

create table apps_and_pricing_features(
app_id integer,
pricing_feature_id integer,
primary key(app_id,pricing_feature_id),
foreign key(app_id) references apps(app_id)
  on delete cascade
  on update cascade,
foreign key(pricing_feature_id) references pricing_features(pricing_feature_id)
  on delete cascade
  on update cascade);

create table reviews(
review_id serial,
author varchar(500),
body text,
rating integer NOT NULL,
posted_at timestamp DEFAULT current_timestamp,
helpful_counts integer DEFAULT 0,
check (rating>=0 and rating<=5),
primary key(review_id));

create table apps_and_reviews(
app_id integer,
review_id integer,
primary key(app_id,review_id),
foreign key(app_id) references apps(app_id)
  on delete cascade
  on update cascade,
foreign key(review_id) references reviews(review_id)
  on delete cascade
  on update cascade);

create table developer_replies(
developer_reply_id serial,
developer_reply text NOT NULL,
developer_reply_posted_at timestamp DEFAULT current_timestamp,
primary key(developer_reply_id));

create table reviews_and_developer_replies(
review_id integer,
developer_reply_id integer,
primary key(review_id,developer_reply_id),
foreign key(review_id) references reviews(review_id)
  on delete cascade
  on update cascade,
foreign key(developer_reply_id) references developer_replies(developer_reply_id)
  on delete cascade
  on update cascade);

--Alert table after inserting data
CREATE SEQUENCE id_seq;

ALTER TABLE apps ALTER app_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(app_id) from apps));

ALTER TABLE developers ALTER developer_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(developer_id) from developers));

ALTER TABLE descriptions ALTER description_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(description_id) from descriptions));

ALTER TABLE categories ALTER category_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(category_id) from categories));

ALTER TABLE benefits ALTER benefit_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(benefit_id) from benefits));

ALTER TABLE pricing_plans ALTER pricing_plan_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(pricing_plan_id) from pricing_plans));

ALTER TABLE pricing_features ALTER pricing_feature_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(pricing_feature_id) from pricing_features));

ALTER TABLE reviews ALTER review_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(review_id) from reviews));

ALTER TABLE developer_replies ALTER developer_reply_id SET DEFAULT NEXTVAL('id_seq');
select setval('id_seq', (select max(developer_reply_id) from developer_replies));

--triggers

CREATE OR REPLACE FUNCTION reply_trigger()
RETURNS trigger AS
$body$
BEGIN IF ((SELECT posted_at 
		  FROM reviews 
		  WHERE posted_at=NEW.posted_at)>=(SELECT developer_reply_posted_at FROM developer_replies WHERE developer_reply_posted_at=NEW.developer_reply_posted_at))
THEN RAISE EXCEPTION 'reply is not allowed';
END IF;
RETURN NEW;
END;
$body$
LANGUAGE plpgsql;

CREATE TRIGGER reply_trigger
BEFORE INSERT OR UPDATE OR DELETE ON developer_replies
FOR EACH ROW EXECUTE PROCEDURE reply_trigger();

