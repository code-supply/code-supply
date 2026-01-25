select b.flake_lock
from builds b 
join images i on i.id = b.image_id 
where i.id = :'image_id'
order by b.id desc
limit 1;
