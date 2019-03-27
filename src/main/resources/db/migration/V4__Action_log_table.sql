create table action_log
(
	id bigint not null
		constraint pk_action_log
			primary key,
	action_name varchar(100) not null,
	entity_name varchar(100) not null,
	author varchar(100),
	entity_id bigint not null
);