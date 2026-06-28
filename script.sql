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
