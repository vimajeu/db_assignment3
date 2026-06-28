--task 1
create or replace function calculate_order_total(p_order_id int)
returns numeric
as $$
	select
		coalesce(sum(quantity * price), 0)
	from order_items
	where order_id = p_order_id;
$$ language sql;


--task2
create or replace procedure create_order(p_customer_id int)
language plpgsql
as $$
begin
	if not exists (select 1 from customers where customer_id = p_customer_id) then
		raise exception 'No such client exists.';
	end if;
	insert into orders(customer_id, total_amount)
	values(p_customer_id, 0);
end;
$$;


--task 3
create or replace procedure add_product_to_order(
    p_order_id int,
    p_product_id int,
    p_quantity int
)
language plpgsql
as $$
begin
	if not exists (select 1 from orders where order_id = p_order_id) then
		raise exception 'No such order exists';
	end if;
	if not exists (select 1 from products where product_id = p_product_id) then
		raise exception 'No such product exists';
	end if;
	if p_quantity < 1 then
		raise exception 'Cannot add zero or negative quantity';
	end if;
	if (select stock_quantity from products where product_id = p_product_id) < p_quantity then
		raise exception 'Not enough products in stock';
	end if;

	insert into order_items(order_id, product_id, quantity, price)
	select p_order_id, p_product_id, p_quantity, price
	from products
	where product_id = p_product_id;
	
	update products
	set stock_quantity = stock_quantity - p_quantity
	where product_id = p_product_id;
end;
$$;


--task 4
create or replace function order_items_change()
returns trigger
as $$
declare
	v_order_id int;
begin
	if (tg_op = 'delete') then 
		v_order_id := old.order_id;
	else
		v_order_id := new.order_id;
	end if;

	update orders
	set total_amount = calculate_order_total(v_order_id)
	where order_id = v_order_id;
	
	return null;
end;
$$ language plpgsql;


create trigger order_items_change_tr
after insert or update or delete
on order_items
for each row 
execute function
order_items_change();


--task 5
create or replace function add_to_log()
returns trigger
as $$
begin
	insert into order_log (order_id, customer_id, action, log_date)
	values (new.order_id, new.customer_id, 'order created', new.order_date);
	
	return null;
end;
$$ language plpgsql;

create trigger add_to_log_tr
after insert on orders
for each row
execute function
add_to_log();
