./gradlew clean build copyMysql copySpooldir; docker build --tag petecknight/conny:4.0.0 .; docker push petecknight/conny:4.0.0; kubectl apply -f deployment.yml 

https://www.tutorialspoint.com/create-a-new-user-with-password-in-mysql-8

create user 'kafcon'@'192.168.0.38' IDENTIFIED BY 'kafcon';

grant all on *.* to 'kafcon'@'192.168.0.38';

use kafcon;
describe database kafcon;
show tables kafcon;

insert into kafcon (c1,c2) values(3,'foo');
insert into kafcon (c1,c2) values(2,'foo');

update kafcon set c2='bar' where c1=1;
select * from kafcon;
 
// tail the topic 
kafka-avro-console-consumer --bootstrap-server localhost:9092 --property schema.registry.url=http://localhost:8081 --property print.key=true --from-beginning --topic kafcon-kafcon 