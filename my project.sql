select * from dataset1;
select * from dataset2;

-- number of rows into dataset
select count(*) from myproject.dataset1;
select count(*) from myproject.dataset2;

-- dataset for jharkhand and bihar
select * from myproject.dataset1 where State in ('Jharkhand', 'Bihar') order by State asc;
 

-- population of India
select sum(Population) from myproject.dataset2;

-- avg growth of states
select state,avg(growth) from dataset1 group by state;

-- avg sex ratio
select state,round(avg(sex_ratio),0) avg_sex_ratio from dataset1 group by state order by avg_sex_ratio desc;

-- avg literacy rate
select state,round(avg(literacy),0) as avg_literacy from dataset1 
group by state having round(avg(literacy),0) > 90 order by avg_literacy desc;

-- top 3 state showing highest growth ratio
select state,avg(growth) from dataset1 group by state order by avg(growth) desc limit 3;

-- bottom 3 state showing lowest sex ratio
select state,avg(Sex_Ratio) from dataset1 group by state order by avg(sex_ratio) asc limit 3;

-- top and bottom 3 states in literacy state

create table top3_states
( state nvarchar(255),
 topstate float
 );

insert into top3_states
select state,avg(literacy) from dataset1 group by state order by avg(literacy) desc limit 3;

select * from top3_states;

create table bottom3_states
( state nvarchar(255),
 bottomstate float
 );

insert into bottom3_states
select state,avg(literacy) from dataset1 group by state order by avg(literacy) asc limit 3;

select * from bottom3_states;

-- union operator

select * from (top3_states) union  select * from (bottom3_states);

-- states starting with letter a or b

select distinct state from dataset1 where state like 'a%' or state like 'b%';

-- states starting with letter a ending with m
select distinct state from dataset1 where state like 'a%m';


-- total males and females
-- females =popu*sr/(sr+1)
-- males =popu/(sr+1)


select d.state,sum(d.males) as totalmales,sum(d.females) as totalfemales from
(select c.district, c.state, round(c.Population/(c.sex_ratio + 1),0) as males, round((c.Population*c.Sex_Ratio)/(c.Sex_Ratio + 1),0) as females from
(select a.district,a.state,a.sex_ratio/1000 as sex_ratio,b.population from myproject.dataset1 as a inner join myproject.dataset2 as b on a.district=b.district ) as c) as d 
group by state;

-- total literacy rate
select c.state, sum(literate_people) as total_literate_popu, sum(illiterate_people) as total_illiterate_popu from
(select d.district, d.state,round(d.literacy_ratio*(d.population),0) as literate_people, round((1-d.literacy_ratio)* (d.population),0) as illiterate_people from
(select a.district,a.state,a.literacy/100 as literacy_ratio,b.population from myproject.dataset1 as a inner join myproject.dataset2 as b on a.district=b.district) d) c 
group by c.state;

-- population in previous census
-- prev census= popu(1+growth)
select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_populaiton from(
select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from 
(select d.district, d.state,round(d.population/(1+ d.growth),0) as previous_census_population,d.population as current_census_population  from
(select a.district,a.state,a.growth/100 as growth,b.population from myproject.dataset1 as a inner join myproject.dataset2 as b on a.district=b.district) d) e 
group by e.state)m;


-- population vs area

select (g.total_area/g.previous_census_population) as previous_census_population_vs_area, (g.total_area/g.current_census_population) as current_census_population_vs_area from
(select q.*,r.total_area from(

select '1' as keyy,n.* from
(select sum(m.previous_census_population) previous_census_population, sum(m.current_census_population) current_census_population from(
select e.state, sum(e.previous_census_population) as previous_census_population, sum(e.current_census_population) as current_census_population from 
(select d.district, d.state,round(d.population/(1+ d.growth),0) as previous_census_population,d.population as current_census_population  from
(select a.district,a.state,a.growth/100 as growth,b.population from myproject.dataset1 as a inner join myproject.dataset2 as b on a.district=b.district) d) e 
group by e.state)m )n )q inner join (

select '1' as keyy,z.* from (
select sum(area_km2) total_area from myproject.dataset2)z) r on q.keyy=r.keyy)g;






