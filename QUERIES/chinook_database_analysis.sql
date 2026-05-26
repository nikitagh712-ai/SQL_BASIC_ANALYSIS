#basic question
select firstname from customer;
select title from album;
select concat(firstname,' ',lastname) as fullname from employee;
select name from track;
select count(invoiceid) as totalinvoices from invoice;

#intermidiate
select name from track
where Milliseconds>300000;

select CustomerId from customer
where Country='USA';

select sum(Total) totalamount, BillingCity from invoice
group by BillingCity;

select i.invoiceId,c.FirstName from invoice i 
left join customer c on i.CustomerId=C.CustomerId;

SELECT t.TrackId,g.name,a.Title from track t 
left join album a on t.AlbumId=a.AlbumId
left join genre g  on t.GenreId=g.GenreId;

#Advanced

select * from employee
where ReportsTo is not null;

select t.TrackId,t.name,sum(i.Quantity) totalquantity from track t
join invoiceline i on t.TrackId=i.TrackId
group by t.TrackId,t.name
order by  totalquantity desc
limit 5;

select g.name, count(t.trackId)from genre g
left join track t on g.GenreId=t.GenreId
group by g.GenreId,g.name;


select count(t.TrackId) total_track,m.name from track t
join mediatype m on m.MediaTypeId=t.MediaTypeId
group by m.name,m.MediaTypeId;


select  DISTINCT p2.PlaylistId,p2.name from track t 
join playlisttrack p1 on t.TrackId=p1.TrackId
join playlist p2 on p1.PlaylistId=p2.PlaylistId
where t.Composer='AC/DC';

select  c.FirstName,sum(i.Total) total_spent from invoice i 
join customer c on c.CustomerId=i.CustomerId
group by c.FirstName,c.CustomerId;

select  BillingCountry,sum(total) avg_total,
dense_rank() over (order by avg(total) desc) ranking 
from invoice
group by BillingCountry;

select sum(i.total) total_sales,e.firstname from customer c 
join invoice i on c.CustomerId=i.CustomerId
join employee e on e.EmployeeId=c.SupportRepId
group by e.EmployeeId,e.firstname;

select  a2.ArtistId,a2.Name,sum(i.Quantity) from track t
join invoiceline i on t.trackid=i.TrackId
join album a on t.AlbumId=a.AlbumId
join artist a2 on a.ArtistId=a2.ArtistId
group by a2.ArtistId, a2.Name
order by sum(i.Quantity) desc
limit 3 ;


select * from  customer;
select * from invoice;
select c.firstname, sum( distinct i2.total) total_amount ,sum(i1.quantity) total_purchase from invoiceline i1
join invoice i2 on i1.InvoiceId=i2.InvoiceId
join customer c on i2.CustomerId=c.CustomerId
group by c.CustomerId, c.FirstName
having sum(i1.quantity)>20 and sum(distinct i2.total)<100;

CREATE VIEW CustomerInvoiceSummary AS(select concat(c.firstname,' ', c.lastname) fullname, count(i.invoiceid) total_invioces, sum(i.total)
from customer c join invoice i on c.CustomerId=i.CustomerId
group by c.CustomerId, concat(c.firstname,' ', c.lastname));

create view  TopSellingTracks as( select t.name,sum(i.UnitPrice *i.Quantity) revenue from track t 
join invoiceline i on i.TrackId=t.TrackId
group by t.name,t.TrackId);
SELECT *
FROM TopSellingTracks
ORDER BY revenue DESC
LIMIT 10;


create view  EmployeeCustomerList as(select concat(e.firstname,' ', e.lastname) fullempployeename, concat(c.firstname,' ', c.lastname) customerfullname,c.country from  customer c
join employee e on c.SupportRepId=e.EmployeeId);

create view views as(select  concat(c.firstname,' ', c.lastname) customer_fullname,count(distinct g.name) totalgen from customer c
join invoice i1 on c.CustomerId=i1.CustomerId
join invoiceline i2 on i2.InvoiceId=i1.InvoiceId
join track t on t.TrackId=i2.TrackId
join genre g on g.GenreId=t.GenreId
group by c.CustomerId
having count(distinct g.GenreId)>3);

with cte as (select avg(Milliseconds) avg_time from track)
select name, milliseconds from track
where Milliseconds>(select avg(Milliseconds) avg_time from track);


WITH RECURSIVE EmployeeHierarchy AS (
    SELECT EmployeeId,FirstName,LastName,ReportsTo,1 AS Level FROM Employee
    WHERE ReportsTo IS NULL
UNION ALL
    SELECT e.EmployeeId,e.FirstName,e.LastName,e.ReportsTo,eh.Level + 1
    FROM Employee e
    JOIN EmployeeHierarchy eh
	ON e.ReportsTo = eh.EmployeeId
)

SELECT *
FROM EmployeeHierarchy
ORDER BY Level, EmployeeId;


WITH AlbumStats AS (
    SELECT 
	a.AlbumId,
	a.Title,
	COUNT(t.TrackId) AS track_count,
	SUM(t.Milliseconds) AS total_duration_ms
    FROM Album a
    JOIN Track t
	ON a.AlbumId = t.AlbumId
    GROUP BY a.AlbumId, a.Title
)

SELECT Title,track_count,
total_duration_ms / 60000 AS total_duration_minutes
FROM AlbumStats
WHERE track_count > 5;

select c.CustomerId,sum(i.total) totalspent ,concat(c.firstname,' ',c.lastname) fullname,c.Country,
dense_rank() over(partition by c.Country order by sum(i.total) desc) from customer c
join invoice i on c.CustomerId=i.CustomerId
group by c.CustomerId,c.FirstName, c.LastName, c.Country;

select * from (select customerid,InvoiceId,InvoiceDate,
row_number() over(partition by customerid order by InvoiceDate) as rn from 
invoice) as ranked 
where rn=1;


select *,
sum(total)over(partition by customerid order by InvoiceDate) from invoice
order by CustomerId, InvoiceDate;

select *,
lag(InvoiceDate) over(partition by customerid order by InvoiceDate ) as beforedate,
datediff(invoicedate,lag(InvoiceDate) over(partition by customerid order by InvoiceDate ))AS days_since_previous_invoice 
from invoice
ORDER BY CustomerId, InvoiceDate;

select  a.ArtistId,
    a.Title AS Album,
    COUNT(t.TrackId) AS track_count,
    avg(COUNT(t.TrackId)) over(partition by a.artistid) as avgtraksperalbum from  track t 
join album a on t.AlbumId=a.AlbumId
group by t.TrackId, a.ArtistId,a.AlbumId


 