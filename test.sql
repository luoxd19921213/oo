use test
create table test(
	id int,
	name varchar(20)
);
insert into test(id,name) values(1,'test');
insert into test(id,name) values(2,'haha');
insert into test(id,name) values(3,'oooo');

use mysql
update user set password=password('root') where user='root';
flush privileges;